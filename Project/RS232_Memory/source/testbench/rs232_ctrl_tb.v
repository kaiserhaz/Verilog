/**********
 * RS232 Controller Testbench
 **********
 */

/** Directives **/
`include "../module/rs232_ctrl.v"
`include "../module/rs232_clk_gen.v"
`timescale 1ns/1ps

/** Submodule testbench **/
module rs232_ctrl_tb;

// Variables
reg   t_clk;
reg   t_rst;
wire  t_clk_rs232_en;

reg   t_send_word;       // Send word signal
wire  t_new_word;        // New word signal

reg   t_data_rs232_out;  // Data from memory line
wire  t_data_rs232_in;   // Data wire from RS232 line

reg   t_rx;              // RS232 Rx
wire  t_tx;              // RS232 Tx

initial                  // Testbench initial run
begin

  t_clk = 0;

  t_rst = 1;
  t_rx = 1;
  t_data_rs232_out = 0;
  t_send_word = 0;

  #20 t_rst = 0;
  
  // 1) Normal Rx and Send
  
  #20 t_rx = 0;                                // Start bit
  #104170 t_rx = 0;                            // Bit 7
  #104170 t_rx = 0;                            // Bit 6
  #104170 t_rx = 0;                            // Bit 5
  #104170 t_rx = 0;                            // Bit 4
  #104170 t_rx = 1;                            // Bit 3
  #104170 t_rx = 1;                            // Bit 2
  #104170 t_rx = 0;                            // Bit 1
  #104170 t_rx = 1;                            // Bit 0
  #104170 t_rx = 0;                            // Parity bit
  #104170 t_rx = 1;                            // Stop bit
  #(2*104170)                                  // Idle

  // 2) Normal Recv and Tx
  
//  #5 t_send_word = 1;                          // Send interrupt
//  #10 t_data_rs232_out = 0;                    // Allow for start
//  #10 t_data_rs232_out = 0;                    // Bit 7
//  #10 t_data_rs232_out = 0;                    // Bit 6
//  #10 t_data_rs232_out = 0;                    // Bit 5
//  #10 t_data_rs232_out = 0;                    // Bit 4
//  #10 t_data_rs232_out = 1;                    // Bit 3
//  #10 t_data_rs232_out = 0;                    // Bit 2
//  #10 t_data_rs232_out = 1;                    // Bit 1
//  #10 t_data_rs232_out = 0;                    // Bit 0
//      t_send_word = 0;                         // Interrupt deasserted
//  #(24*104170)


  // 3) Abnormal Rx (parity error)

  #20 t_rx = 0;
  #104170 t_rx = 0;
  #104170 t_rx = 0;
  #104170 t_rx = 0;
  #104170 t_rx = 0;
  #104170 t_rx = 1;
  #104170 t_rx = 0;
  #104170 t_rx = 1;
  #104170 t_rx = 1;
  #104170 t_rx = 1;
  #104170 t_rx = 1;
  #(2*104170)

  #10 $finish;           // End simulation

end

always
begin
  #5 t_clk = !t_clk;     // Clock process
end

// TODO: Assign here

// Submodule instanciation
rs232_clk_gen CLK_GEN( .clk(t_clk),
                       .rst(t_rst),
                       .clk_rs232_en(t_clk_rs232_en)
                      );

// Module instanciation
rs232_ctrl DUT0( .clk(t_clk),                        
                 .rst(t_rst),                        
                 .clk_rs232_en(t_clk_rs232_en),               
                 .send_word(t_new_word),                
                 .new_word(t_new_word),              
                 .data_rs232_out(t_data_rs232_in),         
                 .data_rs232_in(t_data_rs232_in),     
                 .rx(t_rx),               
                 .tx (t_tx)             
                );

endmodule
