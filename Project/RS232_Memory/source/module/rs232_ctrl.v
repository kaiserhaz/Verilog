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
parameter PARITY = 1;                          // Parity: 1, impair; 0, pair

// Datatype
reg          new_word;                         // New word output register
reg          data_rs232_in;                    // Data word register
reg          tx;                               // Output buffer register

// Variables
reg          samp_prev_val;                    // Sampler prev value
reg          samp_rx_front;                    // Sampler front detect

reg          del_delayed;                      // Delay delayed signal
reg          del_delaying;                     // Delaying status register
reg [19:0]   del_delay_cnt;                    // Delay sample delay counter

reg [7:0]    rx_buffer;                        // Rx buffer register
reg [3:0]    rx_cnt;                           // Rx counter
reg          rx_parity_bit;                    // Rx parity bit
reg          rx_parity_ok;                     // Rx parity ok indicator
reg [2:0]    rx_state_cnt;                     // Rx state counter
reg          rx_finish;                        // Rx finish bit

reg [7:0]    tx_buffer;                        // Tx buffer register
reg          tx_parity_bit;                    // Tx parity bit
reg [3:0]    tx_cnt;                           // Tx counter
reg [2:0]    tx_state_cnt;                     // Tx state counter

reg [7:0]    recv_buffer;                      // Receive buffer
reg [3:0]    recv_cnt;                         // Receive counter
reg [1:0]    recv_state_cnt;                   // Receive state counter
reg          recv_word_int;                    // Received word interrupt

reg [7:0]    send_buffer;                      // Send buffer
reg [3:0]    send_cnt;                         // Send counter
reg          send_once;                        // Send once bit
reg [1:0]    send_state_cnt;                   // Send state counter
reg          send_word_int;                    // Send word interrupt

// Sampling process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin
    samp_prev_val <= rx;                       // Force sample
    samp_rx_front <= 0;                        // Deassert interrupt
  end
  else
  begin

    if(rx_finish)                              // If Rx is finished
    begin
      
      if((samp_prev_val != rx) && (rx == 0))   // On rx not stable and is falling edge
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
always @(posedge clk or posedge rst or posedge samp_rx_front)
begin

  if(rst)                                      // On reset
  begin

    del_delayed <= 0;                          // Clear all variables
    del_delaying <= 0;
    del_delay_cnt <= 0;

  end
  else
  begin

    if((samp_rx_front) || (del_delaying))      // If front detected or is delaying
    begin

      if(del_delay_cnt == 20'd300)             // If delayed for 300 cycles
      begin
        del_delayed <= 1;                      // Assert delayed
        del_delaying <= 0;
        del_delay_cnt <= 0;                    // Clear counter
      end
      else
      begin
        del_delayed <= 0;                      // Deassert delayed
        del_delaying <= 1;
        del_delay_cnt <= del_delay_cnt + 1;    // Count up
      end

    end

  end

end

// Receive Rx process
always @(posedge clk_rs232_en or rst or posedge samp_rx_front or posedge del_delayed)
begin

  if(rst)
  begin

    send_word_int <= 0;                        // Clear all vars
    rx_buffer <= 0;
    rx_cnt <= 0;
    rx_parity_bit <= 0;
    rx_parity_ok <= 0;
    rx_finish <= 1;
    rx_state_cnt <= 3'b000;

  end
  else
  begin

    case(rx_state_cnt)                         // Switch on state
      3'b000 : begin                           // Idle state
                 send_word_int <= 0;
                 rx_finish <= 1;
                 if(samp_rx_front)             // On rx_front
                 begin
                   rx_state_cnt <= 3'b001;     // Go to next state
                 end
                 else                          // If no rx_front
                 begin
                   rx_state_cnt <= 3'b000;     // Remain at idle
                 end
               end
      3'b001 : begin                           // Delay state
                 send_word_int <= 0;
                 rx_finish <= 0;
                 if(del_delayed)               // On delayed
                 begin
                   rx_state_cnt <= 3'b010;     // Switch to next state
                 end
                 else
                 begin
                   rx_state_cnt <= 3'b001;
                 end
               end
      3'b010 : begin                           // Start state
                 send_word_int <= 0;           // Initialize vars
                 rx_buffer <= 0;
                 rx_cnt <= 0;
                 rx_finish <= 0;
                 rx_state_cnt <= 3'b011;       // Go to next state
               end
      3'b011 : begin                           // Sample state
                 send_word_int <= 0;
                 rx_finish <= 0;
                 if(rx_cnt < 8)                // While counter is less than 8
                 begin
                   rx_buffer <= rx | (rx_buffer << 1); // Sample Rx input
                   rx_cnt <= rx_cnt + 1;       // Count up
                   rx_state_cnt <= 3'b011;
                 end
                 else                          // On counter = 8
                 begin
                   rx_parity_bit <= rx;        // Sample parity bit
                   rx_state_cnt <= 3'b100;     // Go to next state
                 end
               end
      3'b100 : begin                           // Parity calculate state
                 send_word_int <= 0;                      
                 rx_parity_ok <= (^rx_buffer)^rx_parity_bit~^PARITY; // Calculate parity
                 rx_finish <= 0;
                 rx_state_cnt <= 3'b101;       // Go to next state
               end
      3'b101 : begin                           // Parity state
                 rx_finish <= 1;               // Assert finish signal
                 if(rx_parity_ok)              // If parity ok
                 begin
                   send_word_int <= 1;         // Assert send_word_int
                 end
                   rx_state_cnt <= 3'b000;     // Go back to idle state
                 end
      default : begin
                  send_word_int <= 0;          // Default state: go to idle
                  rx_state_cnt <= 0;
                end
    endcase

  end

end

// Transmit Tx process
always @(posedge clk_rs232_en or posedge rst or posedge recv_word_int)
begin

  if(rst)                                      // On reset
  begin
    tx <= 1;                                   // Assert Tx line
    tx_buffer <= 0;                            // Clear other vars
    tx_parity_bit <= 0;
    tx_cnt <= 0;
    tx_state_cnt <= 0;
  end
  else
  begin
    
    case(tx_state_cnt)                         // Switch on Tx process state
      3'b000 : begin                           // Idle state
                 tx <= 1;
                 if(recv_word_int)             // If recv_word_int triggered
                 begin
                   tx_buffer <= recv_buffer;   // Load from recv_buffer
                   tx_state_cnt <= 3'b001;     // Go to next state
                 end
               end
      3'b001 : begin                           // Start state
                 tx <= 0;                      // Deassert line for start bit
                 tx_cnt <= 0;
                 tx_parity_bit <= (^tx_buffer)^PARITY; // Calculate parity bit
                 tx_state_cnt <= 3'b010;       // Go to next state
               end
      3'b010 : begin                           // Transmit state
                 if(tx_cnt < 8)
                 begin
                   tx <= tx_buffer[7];         // Transmit from MSB to LSB. Use MSB
                   tx_cnt <= tx_cnt + 1;       // Increment counter
                   tx_buffer <= tx_buffer << 1; // Shift buffer
                 end
                 else                          // If finished transmit
                 begin
                   tx <= tx_parity_bit;        // Output parity bit
                   tx_state_cnt <= 3'b011;     // Go to next state
                 end
               end
      3'b011 : begin                           // Stop state
                 tx <= 1;
                 tx_state_cnt <= 3'b000;       // Go back to idle
               end
      default : begin                          // Default state
                 tx <= 1;                      // Assert Tx line
                 tx_state_cnt <= 3'b000;       // Go to idle
                end
    endcase
    
  end

end

// Receive process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin

    recv_word_int <= 0;                        // Clear all vars
    recv_buffer <= 0;
    recv_cnt <= 0;
    recv_state_cnt <= 0;

  end
  else
  begin

    case(recv_state_cnt)                       // Switch on state counter
      2'b00 : begin                            // Idle state
                recv_word_int <= 0;
                if(send_word)                  // If send_word signal is asserted
                begin
                  recv_buffer <= 0;            // Clear vars
                  recv_cnt <= 0;
                  recv_state_cnt <= 2'b01;     // Go to next state
                end
                else
                  recv_state_cnt <= 2'b00;     // Remain at idle
              end
      2'b01 : begin                            // Receive state
                recv_word_int <= 0;
                recv_buffer <= (recv_buffer << 1) | data_rs232_out; // Receive data
                if(recv_cnt < 7)               // While receive not complete
                begin
                  recv_cnt <= recv_cnt + 1;    // Increment counter
                  recv_state_cnt <= 2'b01;     // Remain at current state
                end
                else                           // If receive complete
                begin
                  recv_state_cnt <= 2'b10;     // Go to next state
                end
              end
      2'b10 : begin                            // Notify state
                recv_word_int <= 1;            // Assert interrupt
                recv_state_cnt <= 2'b00;       // Go back to idle
              end
      default : begin                          // Default state
                  recv_word_int <= 0;          // Deassert interrupt
                  recv_state_cnt <= 2'b00;     // Go to idle
                end
    endcase

  end

end

// Send process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin

    new_word <= 0;                             // Clear all vars and ports
    data_rs232_in <= 0;
    send_buffer <= 0;                          
    send_cnt <= 0;
    send_once <= 0;
    send_state_cnt <= 0;

  end
  else
  begin
    
    case(send_state_cnt)                       // Switch on send state counter
      2'b00 : begin                            // Idle state
                new_word <= 0;
                if(send_word_int)              // If send word interrupt is asserted
                begin
                  if(!send_once)
                  begin
                    send_buffer <= rx_buffer;  // Load from Rx buffer
                    send_cnt <= 0;             // Initialise counter
                    send_once <= 1;            // Send only once
                    send_state_cnt <= 2'b01;   // Go to next state
                  end
                  else
                  begin
                    send_state_cnt <= 2'b00;
                  end
                end
                else
                begin
                  send_once <= 0;
                  send_state_cnt <= 2'b00;
                end
              end
      2'b01 : begin                            // Wait state
                new_word <= 1;                 // Assert new_word signal
                send_state_cnt <= 2'b10;       // Go to next state
              end
      2'b10 : begin                            // Send state
                data_rs232_in <= send_buffer[7]; // Send MSB first
                if(send_cnt < 8)               // While counter is below 7
                begin
                  new_word <= 1;               // Keep line asserted
                  send_buffer <= send_buffer << 1; // Shift send buffer
                  send_cnt <= send_cnt + 1;    // Increment counter
                  send_state_cnt <= 2'b10;
                end
                else                           // While counter equal 8
                begin
                  new_word <= 0;               // Keep line asserted
                  send_state_cnt <= 2'b00;     // Go back to idle
                end
              end
      default : begin                          // Default state
                  new_word <= 0;               // Clear all
                  data_rs232_in <= 0;
                  send_state_cnt <= 2'b00;     // Go back to idle
                end
    endcase

  end

end

endmodule
