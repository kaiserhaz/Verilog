/**********
 * RS232 Memory Core
 **********
 */

/** Directives **/
 
/** Includes **/

/** Constants **/

/** Module Definition **/
module rs232_mem_core ( clk,                   // Clock
                        rst,                   // Reset
                        new_word,              // New word
                        data_rs232_in,         // RS232 memory data in
                        data_rs232_out,        // RS232 memory data out
                        send_word,             // Send word
                        end_of_erase,          // End of erase
                        mem_addr,              // Memory address
                        mem_write,             // Memory write
                        mem_data_in,           // Memory data input
                        mem_data_out           // Memory data output
                      );

// Ports
input clk;
input rst;

input new_word;
input data_rs232_in;

output send_word;
output data_rs232_out;

output end_of_erase;

output mem_addr;
output mem_write;
output mem_data_in;
input mem_data_out;

// Datatype
reg send_word;                                 // Interpret output as registers
reg data_rs232_out;

wire end_of_erase;

reg [13:0] mem_addr;
reg        mem_write;
reg [7:0]  mem_data_in;
wire [7:0] mem_data_out;

// Variables
reg [7:0]    recv_buffer;                      // Receive buffer
reg [3:0]    recv_cnt;                         // Receive counter
reg [1:0]    recv_state_cnt;                   // Receive state counter
reg          recv_word_int;                    // Received word interrupt

reg [7:0]    send_buffer;                      // Send buffer
reg [3:0]    send_cnt;                         // Send counter
reg [1:0]    send_state_cnt;                   // Send state counter

reg [1:0]    core_cmd_word;                    // Memory core command word register
reg [13:0]   core_addr;                        // Memory core address register
reg [7:0]    core_data;                        // Memory core data register
reg [7:0]    core_er_data;                     // Memory core erase data register
reg          core_prot;                        // Memory core protection bit
reg [14:0]   core_er_cnt;                      // Memory core erase counter
wire         core_er_done;                     // Memory core erase done status line
reg          core_er_int;                      // Memory core busy status bit
reg [4:0]    core_state_cnt;                   // Memory core state counter
reg [4:0]    core_next_state;                  // Memory core next state variable

reg [7:0]    fifo_reg;                         // FIFO register, size 1
reg          fifo_ptr;                         // FIFO pointer
wire         fifo_full;                        // FIFO full status
wire         fifo_empty;                       // FIFO empty status

// Main process
always @(posedge clk or rst)
begin

  if(rst)                                      // On reset
  begin

    core_state_cnt <= 5'b10101;                // Go to reset state

  end
  else if(clk)                                 // On clock posedge
  begin

    core_state_cnt <= core_next_state;         // Load next state

  end
  else                                         // Supposibly on reset negedge
  begin
  
    core_state_cnt <= 5'b10000;                // Go to idle

  end

end

// State process
always @(core_state_cnt or posedge recv_word_int)
begin

  case(core_state_cnt)
    5'b10000 : begin                           // Fetch cycle
                 if(recv_word_int)
                 begin
                   core_cmd_word <= (recv_buffer & 8'hC0) >> 6;
                   core_addr     <= recv_buffer & 8'h3F;
                   core_next_state <= 5'b10001;
                 end
                 else
                 begin
                   core_next_state <= 5'b10000;
                 end
               end
    5'b10001 : begin                           // Decode cycle
                 case(core_cmd_word)
                   2'b11 : begin               // Write
                             core_next_state <= 5'b01100;
                           end
                   2'b10 : begin               // Read
                             core_next_state <= 5'b01000;
                           end
                   2'b01 : begin               // Erase
                             core_next_state <= 5'b00100;
                           end
                   2'b00 : begin               // Protection change
                             if(core_addr == 8'h05)
                             begin
                               core_next_state <= 5'b00000;
                             end
                             else
                             begin
                               core_next_state <= 5'b10011;
                             end
                           end
                   default : begin             // Other cases
                             core_next_state <= 5'b10011;
                             end
                 endcase
               end
    5'b10010 : begin                           // ACK cycle
                 if(fifo_empty)
                 begin
                   fifo_push(8'h55);           // Send ACK word
                   core_next_state <= 5'b10000; // Back to fetch
                 end
                 else
                 begin
                   core_next_state <= 5'b10010;
                 end
               end
    5'b10011 : begin                           // NACK cycle
                 if(fifo_empty)
                 begin
                   fifo_push(8'hAA);           // Send NACK word
                   core_next_state <= 5'b10000; // Back to fetch
                 end
                 else
                 begin
                   core_next_state <= 5'b10010;
                 end
               end
    5'b10100 : begin                           // Return protection cycle
                 if(core_prot)                 // If core protection is enabled
                 begin
                   fifo_push(8'h01);           // Send 1
                 end
                 else                          // Else
                 begin
                   fifo_push(8'h02);           // Send 2
                 end
                 core_next_state <= 5'b10000;  // Back to fetch
               end
    5'b10101 : begin                           // Reset cycle
                 mem_addr <= 0;
                 mem_data_in <= 0;
                 mem_write <= 0;
                 core_cmd_word <= 0;           // Clear all
                 core_addr     <= 0;
                 core_data     <= 0;
                 core_er_data  <= 0;
                 core_prot     <= 1;           // Protection is set to read-only by default
                 core_er_int   <= 0;
                 core_next_state <= 5'b10000;
               end
    5'b01100 : begin                           // Write phase 1
                 if(recv_word_int)
                 begin
                   core_addr <= (core_addr << 8) | recv_buffer; // Get address from buffer
                   core_next_state <= 5'b01101;
                 end
                 else
                 begin
                   core_next_state <= 5'b01100;
                 end
               end
    5'b01101 : begin                           // Write phase 2
                 if(recv_word_int)
                 begin
                   core_data <= recv_buffer;   // Get data from buffer
                   core_next_state <= 5'b01110;
                 end
                 else
                 begin
                   core_next_state <= 5'b01101;
                 end
               end
    5'b01110 : begin                           // Write phase 3
                 if(!core_er_done)             // If memory busy
                 begin
                   core_next_state <= 5'b10011;
                 end
                 else if(core_prot)            // If core protected
                 begin
                   core_next_state <= 5'b10011;
                 end
                 else
                 begin
                   mem_write <= 1;             // Set memory write
                   mem_addr <= core_addr;      // Set memory address
                   mem_data_in <= core_data;   // Set memory data
                   core_next_state <= 5'b10010;
                 end
               end
    5'b01000 : begin                           // Read phase 1
                 if(recv_word_int)
                 begin
                   core_addr <= (core_addr << 8) | recv_buffer; // Get address from buffer
                   core_next_state <= 5'b01001;
                 end
                 else
                 begin
                   core_next_state <= 5'b01000;
                 end
               end
    5'b01001 : begin                           // Read phase 2
                 if(!core_er_done)             // If memory busy
                 begin
                   core_next_state <= 5'b10011;
                 end
                 else
                 begin
                   mem_write <= 0;             // Set memory read
                   mem_addr <= core_addr;      // Set memory address
                   core_next_state <= 5'b01010;
                 end
               end
    5'b01010 : begin                           // Read phase 3
                 fifo_push(mem_data_out);      // Get data from memory
                 core_next_state <= 5'b10010;
               end
    5'b00100 : begin                           // Erase phase 1
                 if(recv_word_int)
                 begin
                   if(recv_buffer == 8'h5A)    // If correct sequence detected
                   begin
                     core_next_state <= 5'b00101;
                   end
                   else
                   begin
                     core_next_state <= 5'b10011;                   
                   end
                 end
                 else
                 begin
                   core_next_state <= 5'b00100;
                 end
               end
    5'b00101 : begin                           // Erase phase 2
                 if(recv_word_int)
                 begin
                   core_er_data <= recv_buffer; // Get erase data from buffer
                   core_er_int <= 1;           // Assert erase trigger
                   core_next_state <= 5'b00110;
                 end
                 else
                 begin
                   core_next_state <= 5'b00101;
                 end
               end
    5'b00110 : begin                           // Erase phase 3
                 core_er_int <= 0;             // Deassert erase trigger
                 core_next_state <= 5'b10010;
               end
    5'b00000 : begin                           // Protection phase 1
                 if(recv_word_int)
                 begin
                   if(recv_buffer == 8'h12)    // If sequence detected
                   begin
                     core_next_state <= 5'b00001;
                   end
                   else if(recv_buffer == 8'h34) // If another sequence detected
                   begin
                     core_next_state <= 5'b00010;
                   end
                   else
                   begin
                     core_next_state <= 5'b10011;
                   end
                   end
                 else
                 begin
                   core_next_state <= 5'b00000;
                 end
               end
    5'b00001 : begin                           // Protection phase 2
                 if(recv_word_int)
                 begin
                   if(recv_buffer == 8'h56)    // If subsequent sequence detected
                   begin
                     core_prot <= 1;           // Protect from write
                     core_next_state <= 5'b10100;
                   end
                   else
                   begin
                     core_next_state <= 5'b10011;
                   end
                 end
                 else
                 begin
                   core_next_state <= 5'b00001;
                 end
               end
    5'b00010 : begin                           // Protection phase 3
                 if(recv_word_int)
                 begin
                   if(recv_buffer == 8'h78)    // If subsequent sequence detected
                   begin
                     core_prot <= 0;           // Disable protection
                     core_next_state <= 5'b10100;
                   end
                   else
                   begin
                     core_next_state <= 5'b10011;
                   end
                 end
                 else
                 begin
                   core_next_state <= 5'b00010;
                 end
               end
    default : begin
                core_next_state <= 5'b10101;
              end
  endcase

end

// Memory erase process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin
    core_er_cnt <= 0;                          // Clear counter
  end
  else if((core_er_int) || (!core_er_done))    // On erase interrupt or erase not done
  begin

    mem_write <= 1;                            // Trigger memory write
    mem_addr <= core_er_cnt;                   // Set memory address
    mem_data_in <= core_data;                  // Set memory data
    core_er_cnt <= core_er_cnt + 1;            // Update counter

  end
  else
  begin
    core_er_cnt <= 0;
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
                if(new_word)                   // If new_word signal is asserted
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
                recv_buffer <= (recv_buffer << 1) | data_rs232_in; // Receive data
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

    send_word <= 0;                            // Clear all vars and ports
    data_rs232_out <= 0;
    send_buffer <= 0;                          
    send_cnt <= 0;
    send_state_cnt <= 0;

  end
  else
  begin
    
    case(send_state_cnt)                       // Switch on send state counter
      2'b00 : begin                            // Idle state
                send_word <= 0;
                if(!fifo_empty)                // If FIFO is not empty
                begin
                  send_buffer <= fifo_pop(1);  // Get data from FIFO
                  send_cnt <= 0;               // Initialise counter
                  send_state_cnt <= 2'b01;     // Go to next state
                end
                else
                begin
                  send_state_cnt <= 2'b00;
                end
              end
      2'b01 : begin                            // Wait state
                send_word <= 1;
                send_state_cnt <= 2'b10;       // Go to next state
              end
      2'b10 : begin                            // Send state
                data_rs232_out <= send_buffer[7]; // Send MSB first
                if(send_cnt < 8)               // While counter is below 7
                begin
                  send_word <= 1;              // Keep line asserted
                  send_buffer <= send_buffer << 1; // Shift send buffer
                  send_cnt <= send_cnt + 1;    // Increment counter
                  send_state_cnt <= 2'b10;
                end
                else                           // While counter equal 8
                begin
                  send_word <= 0;              // Keep line asserted
                  send_state_cnt <= 2'b00;     // Go back to idle
                end
              end
      default : begin                          // Default state
                  send_word <= 0;              // Clear all
                  data_rs232_out <= 0;
                  send_state_cnt <= 2'b00;     // Go back to idle
                end
    endcase

  end

end

// FIFO reset
always @(posedge rst)
begin

  fifo_ptr <= 0;
  fifo_reg <= 0;

end

// Continuous assigns
assign end_of_erase = (core_er_cnt == 16385) ? 1 : 0;
assign core_er_done = ((core_er_cnt == 16385) || (core_er_cnt == 0)) ? 1 : 0;
assign fifo_full = (fifo_ptr == 1) ? 1 : 0;
assign fifo_empty = (fifo_ptr > 0) ? 0 : 1;

// FIFO push
task fifo_push;
input [7:0] _data;

  if(!fifo_full)                               // When FIFO not full
  begin
    fifo_reg = _data;                          // Push data
    fifo_ptr = fifo_ptr + 1;                   // Update pointer
  end

endtask

// FIFO pop function
function [7:0] fifo_pop;
input _d;
  
  if(!fifo_empty)                              // If FIFO not empty
  begin
    fifo_ptr = fifo_ptr - 1;                   // Update pointer
    fifo_pop = fifo_reg;                       // Get data
  end
  else
  begin
    fifo_pop = 0;                              // Output 0 if empty
  end

endfunction

endmodule
