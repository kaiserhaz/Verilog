/**********
 * RS232 Controller
 **********
 */

/** Directives **/
 
/** Includes **/

/** Constants **/

/** Module Definition **/
module rs232_ctrl( clk,                        // Clock
                   rst,                        // Reset
                   clk_rs232_en,               // RS232 clock
                   send_word,                  // Send word
                   new_word,                   // New word
                   data_rs232_out,             // RS232 memory data out
                   data_rs232_in,              // RS232 memory data in
                   rx,                         // Rx
                   tx                          // Tx
                 );
					
// Ports
input        clk;
input        rst;
input        clk_rs232_en;

input        send_word;                        // Send word signal
output       new_word;                         // New word signal

input        data_rs232_out;                   // Data output from memory line
output       data_rs232_in;                    // Data output from RS232 line

input        rx;                               // RS232 Rx
output       tx;                               // RS232 Tx

// Parameters
parameter PARITY = 1'b1;                       // Parity: 1, impair; 0, pair

parameter RX_IDLE   = 3'b000;                  // Rx states
parameter RX_DELAY  = 3'b001;
parameter RX_START  = 3'b010;
parameter RX_SAMPLE = 3'b011;
parameter RX_STOP   = 3'b100;

parameter TX_IDLE   = 3'b000;                  // Tx states
parameter TX_START  = 3'b001;
parameter TX_TRANSMIT = 3'b010;
parameter TX_STOP   = 3'b011;

parameter SND_IDLE  = 2'b00;                   // Send states
parameter SND_WAIT  = 2'b01;
parameter SND_SEND  = 2'b10;

parameter RECV_IDLE = 2'b00;                   // Receive states
parameter RECV_GET  = 2'b01;
parameter RECV_STOP = 2'b10;

// Datatype
reg          new_word;                         // New word output register
reg          data_rs232_in;                    // Data word register
reg          tx;                               // Output buffer register

// Variables
reg          samp_prev_val;                    // Sampler prev value
wire         samp_front_det;                   // Sampler front detected signal
reg          samp_rx_front;                    // Sampler front interrupt

reg          del_delayed;                      // Delay delayed signal
reg [19:0]   del_delay_cnt;                    // Delay sample delay counter
wire         del_eq_300;                       // Delay equal 300 cycles signal
wire         del_neq_0;                        // Delay not equal 0 signal

reg [7:0]    rx_buffer;                        // Rx buffer register
reg [3:0]    rx_cnt;                           // Rx counter
reg          rx_parity_ok;                     // Rx parity ok indicator
reg [2:0]    rx_curr_state;                    // Rx current state
reg          rx_enable;                        // Rx enable bit
reg          rx_finish;                        // Rx finish bit
wire         rx_less_8;                        // Rx compare to 8 signal

reg [7:0]    tx_buffer;                        // Tx buffer register
reg          tx_parity_bit;                    // Tx parity bit
reg [3:0]    tx_cnt;                           // Tx counter
reg [2:0]    tx_curr_state;                    // Tx current state
reg          tx_enable;                        // Tx enable signal
reg          tx_load;                          // Tx buffer load signal
wire         tx_less_8;                        // Tx compare to 8 signal

reg [7:0]    recv_buffer;                      // Receive buffer
reg [3:0]    recv_cnt;                         // Receive counter
reg [1:0]    recv_curr_state;                  // Receive state counter
reg          recv_word_int;                    // Received word interrupt
wire         recv_less_8;                      // Receive counter compare

reg [7:0]    send_buffer;                      // Send buffer
reg [3:0]    send_cnt;                         // Send counter
reg          send_once;                        // Send once bit
reg [1:0]    send_curr_state;                  // Send state counter
wire         send_word_int;                    // Send word interrupt
wire         send_less_8;                      // Send counter compare

// Sampling process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin
  
    samp_prev_val <= 1;                        // Force sample
    samp_rx_front <= 0;                        // Deassert interrupt
    
  end
  else
  begin

    if(rx_finish)                              // If Rx is finished
    begin
      
      if(samp_front_det)                       // On front detected
      begin
        samp_rx_front <= 1;                    // Assert front detect
      end
      else
      begin
        samp_rx_front <= 0;                    // Deassert front detect
      end

    end
    else
    begin
      
      samp_rx_front <= 0;

    end

    samp_prev_val <= rx;                       // Sample next value

  end

end

// Delay process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin

    del_delayed <= 0;                          // Clear all variables
    del_delay_cnt <= 0;

  end
  else if(samp_rx_front)                       // If front is detected
  begin

    del_delayed <= 0;                          // Deassert delayed
    del_delay_cnt <= del_delay_cnt + 20'd1;    // Count up

  end
  else
  begin
    if(del_eq_300)
    begin

      del_delayed <= 1;                       // Assert delayed
      del_delay_cnt <= 0;                     // Clear counter

    end
    else if(del_neq_0)
    begin

      del_delayed <= 0;                          // Clear all variables
      del_delay_cnt <= del_delay_cnt + 20'd1;    // Count up
    
    end
    else
    begin

      del_delayed <= 0;                         // Clear all variables                          
      del_delay_cnt <= 0;

    end

  end

end

// Receive Rx sampler
always @(posedge clk_rs232_en or posedge rst)
begin

  if(rst)                                     // On reset
  begin
    rx_buffer     <= 0;                       // Clear all
    rx_cnt        <= 0;
    rx_parity_ok  <= 0;
  end
  else
  begin
    
    if(rx_enable)
    begin
      if(rx_less_8)                             // If counter is less than 8
      begin
        rx_buffer     <= rx | (rx_buffer << 1); // Sample Rx input
        rx_cnt        <= rx_cnt + 4'd1;         // Count up
        rx_parity_ok  <= 0;
      end
      else
      begin
        rx_buffer     <= rx_buffer;
        rx_cnt        <= 0;
        rx_parity_ok  <= (^rx_buffer)^rx~^PARITY; // Calculate parity
      end
    end
    else
    begin
      rx_buffer     <= 0;
      rx_cnt        <= 0;
      rx_parity_ok  <= 0;
    end
    
  end

end

// Receive Rx state machine
always @(posedge clk_rs232_en or posedge rst or posedge samp_rx_front or posedge del_delayed)
begin

  if(rst)                                     // On reset
  begin

    rx_enable     <= 0;
    rx_finish     <= 1;
    rx_curr_state <= RX_IDLE;

  end
  else
  begin

    case(rx_curr_state)                         // Switch on current state
      RX_IDLE : begin                           // Idle state
                  rx_enable     <= 0;
                  if(samp_rx_front)             // On rx_front
                  begin
                    rx_finish     <= 0;
                    rx_curr_state <= RX_DELAY;  // Go to next state
                  end
                  else                          
                  begin
                    rx_finish     <= 1;
                    rx_curr_state <= RX_IDLE;
                  end                           
                end
      RX_DELAY : begin                          // Delay state
                   rx_enable     <= 0;
                   rx_finish     <= 0;
                   if(del_delayed)              // On delayed
                   begin
                     rx_curr_state <= RX_START; // Switch to next state
                   end
                   else                         
                   begin
                     rx_curr_state <= RX_DELAY;
                   end                          
                 end
      RX_START : begin                          // Start state
                   rx_enable     <= 1;          // Enable sampler
                   rx_finish     <= 0;
                   rx_curr_state <= RX_SAMPLE;  // Go to next state
                 end
      RX_SAMPLE : begin                         // Sample state
                    rx_enable     <= 1;
                    rx_finish     <= 0;
                    if(!rx_less_8)              // While counter is not less than 8
                    begin
                      rx_curr_state <= RX_STOP; // Go to next state
                    end
                    else                        
                    begin
                      rx_curr_state <= RX_SAMPLE;
                    end                         
                  end
      RX_STOP : begin                           // End state
                  rx_enable     <= 0;
                  rx_finish     <= 1;           // Assert finish signal
                  rx_curr_state <= RX_IDLE;     // Go back to idle state
                end
      default : begin
                  rx_enable     <= 0;
                  rx_finish     <= 1;           
                  rx_curr_state <= RX_IDLE;     // Default state: go to idle
                end
    endcase

  end

end

// Transmit Tx transmitter
always @(posedge clk_rs232_en or posedge rst)
begin

  if(rst)                                      // On reset
  begin

    tx            <= 1;                        // Assert Tx line
    tx_parity_bit <= 0;
    tx_buffer     <= 0;                        // Clear buffer
  
  end
  else
  begin

    if(tx_enable)
    begin
      
      if(tx_load)                             // On load signal
      begin
        tx            <= 0;
        tx_buffer     <= recv_buffer;         // Load buffer
        tx_parity_bit <= (^recv_buffer)^PARITY; // Calculate parity bit
      end
      else
      begin
        if(tx_less_8)                         // If counter less than 8
        begin
          tx            <= tx_buffer[7];      // Transfer MSB first
          tx_buffer     <= tx_buffer<<1;      // Shift buffer left
          tx_parity_bit <= tx_parity_bit;
        end
        else
        begin
          tx            <= tx_parity_bit;     // Transmit parity bit
          tx_buffer     <= 0;
          tx_parity_bit <= 0;
        end
      end

    end
    else
    begin
    
      tx            <= 1;                      // Assert Tx line
      tx_parity_bit <= 0;
      tx_buffer     <= 0;

    end

  end

end

// Transmit Tx state machine
always @(posedge clk_rs232_en or posedge rst or posedge recv_word_int)
begin

  if(rst)
  begin

    tx_cnt        <= 0;                       // Reset
    tx_enable     <= 0;
    tx_load       <= 0;
    tx_curr_state <= TX_IDLE;

  end
  else
  begin

    case(tx_curr_state)                       // Switch on Tx process state
      TX_IDLE : begin                         // Idle state
                  tx_cnt    <= 0;
                  if(recv_word_int)           // If recv_word_int triggered
                  begin
                    tx_enable <= 1;           // Enable transmitter
                    tx_load   <= 1;
                    tx_curr_state <= TX_START; // Go to next state
                  end
                  else
                  begin
                    tx_enable <= 0;           
                    tx_load   <= 0;
                    tx_curr_state <= TX_IDLE; // Go to next state
                  end
                end
      TX_START : begin                        // Start state
                   tx_enable     <= 1;
                   tx_load       <= 0;
                   tx_cnt        <= 0;              
                   tx_curr_state <= TX_TRANSMIT; // Go to next state
                 end
      TX_TRANSMIT : begin                     // Transmit state
                      tx_load   <= 0;
                      if(tx_less_8)           // When counter less than 8
                      begin
                        tx_enable <= 1;
                        tx_cnt        <= tx_cnt + 4'd1; // Increment counter
                        tx_curr_state <= TX_TRANSMIT;
                      end
                      else                    // If finished transmit
                      begin
                        tx_enable <= 0;
                        tx_cnt        <= 0;
                        tx_curr_state <= TX_STOP; // Go to next state
                      end
                    end
      TX_STOP : begin                         // Stop state
                  tx_enable     <= 0;
                  tx_load       <= 0;
                  tx_cnt        <= 0;
                  tx_curr_state <= TX_IDLE;   // Go back to idle
                end
      default : begin                         // Default state
                  tx_enable     <= 0;
                  tx_load       <= 0;
                  tx_cnt        <= 0;
                  tx_curr_state <= TX_IDLE;   // Go to idle
                end
    endcase

  end

end

// Receive process
always @(posedge clk or posedge rst)
begin

  if(rst)                                     // On reset
  begin

    recv_word_int <= 0;                       // Clear all vars
    recv_buffer <= 0;
    recv_cnt <= 0;
    recv_curr_state <= RECV_IDLE;

  end
  else
  begin

    case(recv_curr_state)                     // Switch on state counter
      RECV_IDLE : begin                       // Idle state
                    recv_word_int <= 0;
                    if(send_word)             // If send_word signal is asserted
                    begin
                      recv_buffer <= 0;       // Clear vars
                      recv_cnt <= 0;
                      recv_curr_state <= RECV_GET; // Go to next state
                    end
                    else
                      recv_curr_state <= RECV_IDLE; // Remain at idle
                  end
      RECV_GET : begin                        // Receive state
                   recv_word_int <= 0;
                   if(recv_less_8)            // While receive not complete
                   begin
                     recv_buffer <= (recv_buffer << 1) | data_rs232_out; // Receive data
                     recv_cnt <= recv_cnt + 4'd1; // Increment counter
                     recv_curr_state <= RECV_GET; // Remain at current state
                   end
                   else                       // If receive complete
                   begin
                     recv_buffer <= recv_buffer;
                     recv_cnt <= 0;
                     recv_curr_state <= RECV_STOP; // Go to next state
                   end
                 end
      RECV_STOP : begin                       // Stop state
                    recv_word_int <= 1;       // Assert interrupt
                    recv_curr_state <= RECV_IDLE; // Go back to idle
                  end
      default : begin                         // Default state
                  recv_word_int <= 0;         // Deassert interrupt
                  recv_curr_state <= RECV_IDLE; // Go to idle
                end
    endcase

  end

end

// Send process
always @(posedge clk or posedge rst)
begin

  if(rst)                                     // On reset
  begin

    new_word      <= 0;                       // Clear all vars and ports
    data_rs232_in <= 0;
    send_buffer   <= 0;                          
    send_cnt      <= 0;
    send_once     <= 0;
    send_curr_state <= SND_IDLE;

  end
  else
  begin
    
    case(send_curr_state)                     // Switch on send state counter
      SND_IDLE : begin                        // Idle state
                   new_word <= 0;
                   if(send_word_int)          // If send word interrupt is asserted
                   begin
                     if(!send_once)
                     begin
                       send_buffer <= rx_buffer; // Load from Rx buffer
                       send_cnt <= 0;         // Initialise counter
                       send_once <= 1;        // Send only once
                       send_curr_state <= SND_WAIT; // Go to next state
                     end
                     else
                     begin
                       send_buffer <= 0;
                       send_cnt <= 0;
                       send_curr_state <= SND_IDLE;
                     end
                   end
                   else
                   begin
                    send_once <= 0;
                    send_curr_state <= SND_IDLE;
                   end
                 end
      SND_WAIT : begin                        // Wait state
                   new_word <= 1;             // Assert new_word signal
                   send_curr_state <= SND_SEND; // Go to next state
                 end
      SND_SEND : begin                        // Send state
                   data_rs232_in <= send_buffer[7]; // Send MSB first
                   if(send_less_8)            // While counter is below 7
                   begin
                     new_word <= 1;           // Keep line asserted
                     send_buffer <= send_buffer << 1; // Shift send buffer
                     send_cnt <= send_cnt + 4'd1; // Increment counter
                     send_curr_state <= SND_SEND;
                   end
                   else                       // While counter equal 8
                   begin
                     new_word <= 0;           // Keep line asserted
                     send_curr_state <= SND_IDLE; // Go back to idle
                   end
                 end
      default : begin                         // Default state
                  new_word <= 0;              // Clear all
                  data_rs232_in <= 0;
                  send_curr_state <= SND_IDLE; // Go back to idle
                end
    endcase

  end

end

// Continuous assign
assign samp_front_det = ((samp_prev_val != rx) && (rx == 0));
assign del_eq_300  = (del_delay_cnt == 20'd300);
assign del_neq_0   = (del_delay_cnt != 20'd000);
assign rx_less_8   = !(rx_cnt & 4'b1000);
assign tx_less_8   = !(tx_cnt & 4'b1000);
assign recv_less_8 = !(recv_cnt & 4'b1000);
assign send_less_8 = !(send_cnt & 4'b1000);
assign send_word_int = rx_parity_ok;

endmodule
