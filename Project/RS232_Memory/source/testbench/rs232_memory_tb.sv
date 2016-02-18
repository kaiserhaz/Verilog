/**********
 * RS232 Controller Testbench
 **********
 */

/**
 * Classic divisor values
 * 
 *  bps      | Divisor
 * --------------------
 * |300      | 333333
 * |600	     | 166667
 * |1200     | 83333
 * |2400     | 41667
 * |4800     | 20833
 * |9600     | 10417
 * |14400    | 6944
 * |19200    | 5208
 * |28800    | 3472
 * |38400    | 2604
 * |56000    | 1786
 * |57600    | 1736
 * |115200   | 868
 * |128000   | 781
 * |256000   | 391
 * 
 */

/** Directives **/
`include "../module/rs232_ctrl.v"
`timescale 1ns/1ps

/** Submodule testbench **/
module rs232_memory_tb;

// Variables
reg   t_clk;
reg   t_rst;

wire  t_end_of_erase;

reg   t_rx;              // RS232 Rx
wire  t_tx;              // RS232 Tx

parameter [19:0] RS232_RATIO = 10417;
parameter PARITY = 1;

typedef enum bit [1:0] { WRITE=2'b11, READ=2'b10, ERASE=2'b01, PROT=2'b00 } rs232_cmd;

typedef enum bit [7:0] { PROT_WORD=8'h05,
                 ERASE_WORD=8'h5A,
                 PROT_W_1=8'h34,
                 PROT_W_2=8'h78,
                 PROT_R_1=8'h12,
                 PROT_R_2=8'h56 } rs232_att;

initial                  // Testbench initial run
begin

  t_clk = 0;

  t_rst = 1;
  t_rx = 1;

  #20 t_rst = 0;
  
  // 1) Write, memory protected
  
  rs232_set_cmd(WRITE, 14'h06F1, 8'h8A, 'bX);

  // 2) Read
  
  rs232_set_cmd(READ, 14'h0511, 8'hXX, 'bX);

  // 3) Protect off
  
  rs232_set_cmd(PROT, 14'hXXXX, 8'hXX, 'b0);

  // 4) Write
  
  rs232_set_cmd(WRITE, 14'h0101, 8'h8A, 'bX);

  // 5) Read
  
  rs232_set_cmd(READ, 14'h0101, 8'hXX, 'bX);

  // 6) Erase
  
  rs232_set_cmd(ERASE, 14'hXXXX, 8'hAF, 'bX);

  // 7) Write
  
  rs232_set_cmd(WRITE, 14'h010, 8'h1A, 'bX);

  // 8) Protect off
  
  rs232_set_cmd(PROT, 14'hXXXX, 8'hXX, 'b1);
  
  // X) Abnormal Rx (parity error)

  rs232_drive_err(8'h0F);

  #10 $finish;                                 // End simulation

end

always
begin
  #5 t_clk = !t_clk;                           // Clock process
end

// RS232 Set Command
task rs232_set_cmd;
input [1:0]  _cmd;
input [13:0] _addr;
input [7:0]  _data;
input        _prot;
begin

  case(_cmd)
    WRITE : begin
              rs232_drive({_cmd, 6'b000000}^_addr[13:8]);
              rs232_drive(_addr[7:0]);
              rs232_drive(_data);
            end
    READ  : begin
              rs232_drive({_cmd, 6'b000000}^_addr[13:8]);
              rs232_drive(_addr[7:0]);
            end
    ERASE : begin
              rs232_drive({_cmd, 6'b000000});
              rs232_drive(ERASE_WORD);
              rs232_drive(_data);
            end
    PROT  : begin
              rs232_drive({_cmd, 6'b000000}^PROT_WORD);
              if(_prot)
              begin
                rs232_drive(PROT_R_1);
                rs232_drive(PROT_R_2);
              end
              else
              begin
                rs232_drive(PROT_W_1);
                rs232_drive(PROT_W_2);
              end
            end
  endcase

end
endtask

// Protocol driver
task rs232_drive;
input [7:0] _word;
begin

  #20 t_rx = 0;                                // Start bit
  #(RS232_RATIO*10) t_rx = _word[7];           // Bit 7
  #(RS232_RATIO*10) t_rx = _word[6];           // Bit 6
  #(RS232_RATIO*10) t_rx = _word[5];           // Bit 5
  #(RS232_RATIO*10) t_rx = _word[4];           // Bit 4
  #(RS232_RATIO*10) t_rx = _word[3];           // Bit 3
  #(RS232_RATIO*10) t_rx = _word[2];           // Bit 2
  #(RS232_RATIO*10) t_rx = _word[1];           // Bit 1
  #(RS232_RATIO*10) t_rx = _word[0];           // Bit 0
  #(RS232_RATIO*10) t_rx = (^_word)^PARITY;    // Parity bit
  #(RS232_RATIO*10) t_rx = 1;                  // Stop bit
  #(2*RS232_RATIO*10);                         // Idle

end
endtask

// Protocol driver, with parity error
task rs232_drive_err;
input [7:0] _word;
begin

  #20 t_rx = 0;                                // Start bit
  #(RS232_RATIO*10) t_rx = _word[7];           // Bit 7
  #(RS232_RATIO*10) t_rx = _word[6];           // Bit 6
  #(RS232_RATIO*10) t_rx = _word[5];           // Bit 5
  #(RS232_RATIO*10) t_rx = _word[4];           // Bit 4
  #(RS232_RATIO*10) t_rx = _word[3];           // Bit 3
  #(RS232_RATIO*10) t_rx = _word[2];           // Bit 2
  #(RS232_RATIO*10) t_rx = _word[1];           // Bit 1
  #(RS232_RATIO*10) t_rx = _word[0];           // Bit 0
  #(RS232_RATIO*10) t_rx = (~^_word)^PARITY;   // Parity bit
  #(RS232_RATIO*10) t_rx = 1;                  // Stop bit
  #(2*RS232_RATIO*10);                         // Idle

end
endtask

// Module instanciation
rs232_memory #( .RS232_RATIO(RS232_RATIO),
                .PARITY(PARITY)
               )
DUT0          ( .clk(t_clk),                        
                .rst(t_rst),                        
                .end_of_erase(t_end_of_erase),    
                .rx(t_rx),               
                .tx (t_tx)             
               );

endmodule
