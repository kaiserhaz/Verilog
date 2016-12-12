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

output [7:0] mem_addr;
output mem_write;
output [7:0] mem_data_in;
input [7:0] mem_data_out;

// Datatype
reg send_word;                                 // Interpret output as registers
reg data_rs232_out;

wire end_of_erase;

wire [7:0] mem_addr;
wire        mem_write;
wire [7:0]  mem_data_in;
wire [7:0]  mem_data_out;

// Parameters
parameter CORE_RST = 5'b10101;                // State machine states
parameter CORE_FET = 5'b10000;
parameter CORE_DEC = 5'b10001;
parameter CORE_ACK = 5'b10010;
parameter CORE_NAK = 5'b10011;
parameter CORE_RPR = 5'b10100;
parameter CORE_WR1 = 5'b01100;
parameter CORE_WR2 = 5'b01101;
parameter CORE_WR3 = 5'b01110;
parameter CORE_RD1 = 5'b01000;
parameter CORE_RD2 = 5'b01001;
parameter CORE_RD3 = 5'b01010;
parameter CORE_ER1 = 5'b00100;
parameter CORE_ER2 = 5'b00101;
parameter CORE_ER3 = 5'b00110;
parameter CORE_PR1 = 5'b00000;
parameter CORE_PR2 = 5'b00001;
parameter CORE_PR3 = 5'b00010;

parameter CMD_WR = 2'b11;                      // Command words
parameter CMD_RD = 2'b10;
parameter CMD_ER = 2'b01;
parameter CMD_PR = 2'b00;

parameter SND_IDLE  = 2'b00;                   // Send states
parameter SND_WAIT  = 2'b01;
parameter SND_SEND  = 2'b10;

parameter RECV_IDLE = 2'b00;                   // Receive states
parameter RECV_GET  = 2'b01;
parameter RECV_STOP = 2'b10;

parameter PROT_WORD_L1 = 8'h12;                // Protection words
parameter PROT_WORD_L2 = 8'h56;
parameter PROT_WORD_U1 = 8'h34;
parameter PROT_WORD_U2 = 8'h78;

parameter CORE_ACK_WORD = 8'h55;
parameter CORE_NAK_WORD = 8'hAA;
parameter CORE_PRON_WORD = 8'h01;
parameter CORE_POFF_WORD = 8'h02;
parameter CORE_ER_WORD = 8'h5A;
parameter FIFO_RST_WORD = 9'h100;              // FIFO reset word

parameter CORE_PRCH_ADDR = 8'h05;

parameter MEM_MAX_CASE = 9'd256;                 // Maximum memory case
//parameter MEM_MAX_CASE = 8192;                 // Maximum memory case (testing only)

// Variables
reg [7:0]    recv_buffer;                      // Receive buffer
reg [3:0]    recv_cnt;                         // Receive counter
reg [1:0]    recv_curr_state;                  // Receive state counter
reg          recv_word_int;                    // Received word interrupt
wire         recv_less_8;                      // Receive counter compare

reg [7:0]    send_buffer;                      // Send buffer
reg [3:0]    send_cnt;                         // Send counter
reg [1:0]    send_curr_state;                  // Send state counter
wire         send_less_8;                      // Send counter compare

reg [1:0]    core_cmd_word;                    // Memory core command word register
reg [7:0]    core_addr_hi;                     // Memory core address register (hi byte)
reg [7:0]    core_addr_lo;                     // Memory core address register (lo byte)
reg [7:0]    core_data;                        // Memory core data register
reg          core_rn_w = 0;                    // Memory core read/write signal
reg          core_cmd_int;                     // Memory core cmd word signal
reg          core_addr_hb_int;                 // Memory core address signal (hi byte)
reg          core_addr_lb_int;                 // Memory core address signal (lo byte)
reg          core_data_int;                    // Memory core data signal
reg          core_prot;                        // Memory core protection bit
reg          core_prot_en;                     // Memory core protection enable signal
reg          core_prot_dis;                    // Memory core protection disable signal
reg [8:0]    core_er_cnt;                      // Memory core erase counter
wire         core_er_done;                     // Memory core erase done status line
reg          core_er_int;                      // Memory core busy status bit
reg          core_er_write;                    // Memory core erase write signal
reg [7:0]    core_er_addr;                     // Memory core erase address
reg [7:0]    core_er_data;                     // Memory core erase data
reg          core_eoe_int;                     // Memory core erase interrupt trigger
reg [4:0]    core_curr_state;                  // Memory core state counter
reg [4:0]    core_next_state;                  // Memory core next state variable

reg [8:0]    fifo_reg = FIFO_RST_WORD;         // FIFO register, size 1
wire         fifo_full;                        // FIFO register full indicator bit

// Main process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin

    core_curr_state <= CORE_RST;               // Go to reset state

  end
  else if(clk)                                 // On clock posedge
  begin

    core_curr_state <= core_next_state;        // Load next state

  end

end

// State process
always @(*)
begin

  core_cmd_int  <= 0;
  core_addr_hb_int <= 0;
  core_addr_lb_int <= 0;
  core_data_int <= 0;
  core_prot_en  <= 0;
  core_prot_dis <= 0;
  core_er_int   <= 0;
  core_rn_w     <= 0;

  fifo_push(FIFO_RST_WORD);                    // Empty FIFO each clock cycle

  case(core_curr_state)
    CORE_FET : begin                           // Fetch cycle
		 fifo_push(FIFO_RST_WORD);     // Reset FIFO at each fetch
                 if(recv_word_int)
                 begin
                   core_cmd_int <= 1;
                   core_addr_hb_int <= 1;
                   core_next_state <= CORE_DEC;
                 end
                 else
                   core_next_state <= CORE_FET;
               end
    CORE_DEC : begin                           // Decode cycle
                 case(core_cmd_word)
                   CMD_WR : begin              // Write
                             core_next_state <= CORE_WR1;
                           end
                   CMD_RD : begin              // Read
                             core_next_state <= CORE_RD1;
                           end
                   CMD_ER : begin              // Erase
                             core_next_state <= CORE_ER1;
                           end
                   CMD_PR : begin              // Protection change
                             if(core_addr_hi == CORE_PRCH_ADDR)
                             begin
                               core_next_state <= CORE_PR1;
                             end
                             else
                             begin
                               core_next_state <= CORE_NAK;
                             end
                           end
                   default : begin             // Other cases
                             core_next_state <= CORE_NAK;
                             end
                 endcase
               end
    CORE_ACK : begin                           // ACK cycle
                   fifo_push(CORE_ACK_WORD);   // Send ACK word
                   core_next_state <= CORE_FET; // Back to fetch
               end
    CORE_NAK : begin                           // NACK cycle
                   fifo_push(CORE_NAK_WORD);   // Send NACK word
                   core_next_state <= CORE_FET; // Back to fetch
               end
    CORE_RPR : begin                           // Return protection cycle
                 if(core_prot)                 // If core protection is enabled
                 begin
                   fifo_push(CORE_PRON_WORD);  // Send 1
                 end
                 else                          // Else
                 begin
                   fifo_push(CORE_POFF_WORD);  // Send 2
                 end
                 core_next_state <= CORE_FET;  // Back to fetch
               end
    CORE_RST : begin                           // Reset cycle
                 core_next_state <= CORE_FET;
               end
    CORE_WR1 : begin                           // Write phase 1
                 if(recv_word_int)
                 begin
                   core_addr_lb_int <= 1;
                   core_next_state <= CORE_WR2;
                 end
                 else
                 begin
                   core_next_state <= CORE_WR1;
                 end
               end
    CORE_WR2 : begin                           // Write phase 2
                 if(recv_word_int)
                 begin
                   core_data_int <= 1;   // Get data from buffer
                   core_next_state <= CORE_WR3;
                 end
                 else
                 begin
                   core_next_state <= CORE_WR2;
                 end
               end
    CORE_WR3 : begin                           // Write phase 3
                 if(!core_er_done)             // If memory busy
                 begin
                   core_next_state <= CORE_NAK;
                 end
                 else if(core_prot)            // If core protected
                 begin
                   core_next_state <= CORE_NAK;
                 end
                 else
                 begin
                   core_rn_w <= 1;             // Set memory write
                   core_next_state <= CORE_ACK;
                 end
               end
    CORE_RD1 : begin                           // Read phase 1
                 if(recv_word_int)
                 begin
                   core_addr_lb_int <= 1;
                   core_next_state <= CORE_RD2;
                 end
                 else
                 begin
                   core_next_state <= CORE_RD1;
                 end
               end
    CORE_RD2 : begin                           // Read phase 2
                 if(!core_er_done)             // If memory busy
                 begin
                   core_next_state <= CORE_NAK;
                 end
                 else
                 begin
                   core_next_state <= CORE_RD3;
                 end
               end
    CORE_RD3 : begin                           // Read phase 3
                 fifo_push(mem_data_out);      // Get data from memory
                 core_next_state <= CORE_ACK;
               end
    CORE_ER1 : begin                           // Erase phase 1
                 if(recv_word_int)
                 begin
                   if(recv_buffer == CORE_ER_WORD)    // If correct sequence detected
                   begin
                     core_next_state <= CORE_ER2;
                   end
                   else
                   begin
                     core_next_state <= CORE_NAK;                   
                   end
                 end
                 else
                 begin
                   core_next_state <= CORE_ER1;
                 end
               end
    CORE_ER2 : begin                           // Erase phase 2
                 if(recv_word_int)
                 begin
                   core_er_int <= 1;           // Assert erase trigger
                   core_next_state <= CORE_ER3;
                 end
                 else
                 begin
                   core_next_state <= CORE_ER2;
                 end
               end
    CORE_ER3 : begin                           // Erase phase 3
                 core_next_state <= CORE_ACK;
               end
    CORE_PR1 : begin                           // Protection phase 1
                 if(recv_word_int)
                 begin
                   if(recv_buffer == PROT_WORD_L1)    // If sequence detected
                   begin
                     core_next_state <= CORE_PR2;
                   end
                   else if(recv_buffer == PROT_WORD_U1) // If another sequence detected
                   begin
                     core_next_state <= CORE_PR3;
                   end
                   else
                   begin
                     core_next_state <= CORE_NAK;
                   end
                   end
                 else
                 begin
                   core_next_state <= CORE_PR1;
                 end
               end
    CORE_PR2 : begin                           // Protection phase 2
                 if(recv_word_int)
                 begin
                   if(recv_buffer == PROT_WORD_L2) // If subsequent sequence detected
                   begin
                     core_prot_en <= 1;        // Protect from write
                     core_next_state <= CORE_RPR;
                   end
                   else
                   begin
                     core_next_state <= CORE_NAK;
                   end
                 end
                 else
                 begin
                   core_next_state <= CORE_PR2;
                 end
               end
    CORE_PR3 : begin                           // Protection phase 3
                 if(recv_word_int)
                 begin
                   if(recv_buffer == PROT_WORD_U2)    // If subsequent sequence detected
                   begin
                     core_prot_dis <= 1;       // Disable protection
                     core_next_state <= CORE_RPR;
                   end
                   else
                   begin
                     core_next_state <= CORE_NAK;
                   end
                 end
                 else
                 begin
                   core_next_state <= CORE_PR3;
                 end
               end
    default : begin
                core_next_state <= CORE_RST;
              end
  endcase

end

// Command word process
always @(posedge core_cmd_int or
         posedge rst)
begin

  if(rst)
  begin
    core_cmd_word <= 0;
  end
  else
  begin
    if(core_cmd_int)
    begin
      core_cmd_word <= recv_buffer[7 -: 2];
    end
    else
    begin
      core_cmd_word <= 0;
    end
  end

end

// Address hi byte process
always @(posedge core_addr_hb_int or
         posedge rst)
begin

  if(rst)
  begin
    core_addr_hi <= 0;
  end
  else
  begin
    if(core_addr_hb_int)
    begin
      core_addr_hi <= recv_buffer & 8'h3F;
    end
    else
    begin
      core_addr_hi <= 0;
    end
  end

end

// Address lo byte process
always @(posedge core_addr_lb_int or
         posedge rst)
begin

  if(rst)
  begin
    core_addr_lo <= 0;
  end
  else
  begin
    if(core_addr_lb_int)
    begin
      core_addr_lo <= recv_buffer;
    end
    else
    begin
      core_addr_lo <= 0;
    end
  end

end

// Data process
always @(posedge core_data_int or
         posedge rst)
begin

  if(rst)
  begin
    core_data <= 0;
  end
  else
  begin
    if(core_data_int)
    begin
      core_data <= recv_buffer;
    end
    else
    begin
      core_data <= 0;
    end
  end

end

// Memory erase process
always @(posedge clk or posedge rst)
begin

  if(rst)                                      // On reset
  begin
    core_er_write <= 0;
    core_er_addr <= 0;
    core_er_data <= 0;
    core_er_cnt <= 0;                          // Clear counter
  end
  else if((core_er_int) || (!core_er_done))    // On erase interrupt or erase not done
  begin

    core_er_write <= 1;                        // Trigger memory write
    core_er_addr <= core_er_cnt[7 -: 8];       // Set memory address
    core_er_data <= recv_buffer;               // Set memory data
    core_er_cnt <= core_er_cnt + 9'h1;         // Update counter

  end
  else
  begin

    core_er_write <= 0;
    core_er_addr <= 0;
    core_er_data <= 0;
    core_er_cnt <= 0;                          // Clear counter

  end

end

// End of erase interrupt process
always @(posedge clk or posedge rst)
begin

  if(rst)
  begin
    core_eoe_int <= 0;
  end
  else
  begin
    if(core_er_cnt == MEM_MAX_CASE)
      core_eoe_int <= 1;
    else
      core_eoe_int <= 0;
  end

end

// Protection process
always @(posedge core_prot_en or
         posedge core_prot_dis or
         posedge rst)
begin

  if(rst)
  begin
    core_prot <= 1;
  end
  else
  begin
    if(core_prot_dis)
    begin
      core_prot <= 0;
    end
    else if(core_prot_en)
    begin
      core_prot <= 1;
    end
    else
    begin
      core_prot <= 1;
    end
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
                    if(new_word)             // If new_word signal is asserted
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
                     recv_buffer <= (recv_buffer << 1) | data_rs232_in; // Receive data
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

  if(rst)                                      // On reset
  begin

    send_word <= 0;                            // Clear all vars and ports
    data_rs232_out <= 0;
    send_buffer <= 0;                          
    send_cnt <= 0;
    send_curr_state <= SND_IDLE;

  end
  else
  begin
    
    case(send_curr_state)                       // Switch on send state counter
      SND_IDLE : begin                            // Idle state
                send_word <= 0;
                send_cnt <= 0;               // Initialise counter
                if(fifo_full)                // If FIFO has something in it
                begin
                  send_buffer <= fifo_pop(1);  // Get data from FIFO
                  send_curr_state <= SND_WAIT;     // Go to next state
                end
                else
                begin
                  send_buffer <= 0;
                  send_curr_state <= SND_IDLE;
                end
              end
      SND_WAIT : begin                            // Wait state
                send_word <= 1;
                send_curr_state <= SND_SEND;       // Go to next state
              end
      SND_SEND : begin                            // Send state
                data_rs232_out <= send_buffer[7]; // Send MSB first
                if(send_less_8)               // While counter is below 7
                begin
                  send_word <= 1;              // Keep line asserted
                  send_buffer <= send_buffer << 1; // Shift send buffer
                  send_cnt <= send_cnt + 4'h1;    // Increment counter
                  send_curr_state <= SND_SEND;
                end
                else                           // While counter equal 8
                begin
                  send_word <= 0;              // Keep line asserted
                  send_curr_state <= SND_IDLE;     // Go back to idle
                end
              end
      default : begin                          // Default state
                  send_word <= 0;              // Clear all
                  data_rs232_out <= 0;
                  send_curr_state <= SND_IDLE;     // Go back to idle
                end
    endcase

  end

end

// Continuous assigns
assign end_of_erase = core_eoe_int;
assign core_er_done = ((core_er_cnt == 9'b0) || (core_er_cnt == MEM_MAX_CASE+1)) ? 1'b1 : 1'b0;
assign mem_write = (core_er_done == 1'b1) ? core_rn_w : core_er_write;
assign mem_addr = (core_er_done == 1'b1) ? core_addr_lo : core_er_addr; //{core_addr_hi[4 -: 5],core_addr_lo} : core_er_addr;
assign mem_data_in = core_data | core_er_data;
assign recv_less_8 = !(recv_cnt & 4'b1000);
assign send_less_8 = !(send_cnt & 4'b1000);
assign fifo_full = (fifo_reg[8] == 1'b0) ? 1'b1 : 1'b0;

// FIFO push
task fifo_push;
input [8:0] _data;

  fifo_reg = _data;                           // Push data

endtask

// FIFO pop function
function [7:0] fifo_pop;
input _d;

  fifo_pop = fifo_reg[7:0];                  // Pop data

endfunction

endmodule
