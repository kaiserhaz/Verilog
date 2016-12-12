/**********
 * RS232 Clock Generator Testbench
 **********
 *
 * Author: Kaiser Haz
 *
 */

/**
 * Classic divisor values
 * 
 *  bps      | Divisor
 * --------------------
 * |110      | 909090
 * |150      | 666666
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
 * |230400   | 435
 * |256000   | 391
 * |460800   | 218    !
 * |921600   | 109    !
 * 
 * Note that acceptable values according to the specs are
 *  dividers that are below 255. But so far, these values
 *  prove to be too fast for the design.
 *
 */

/** Directives **/
`include "../module/rs232_clk_gen.v"
`timescale 1ns/1ps

/** Submodule testbench **/
module rs232_clk_gen_tb;

// Variables
reg t_clk, t_rst;

wire t_clk_rs232_en;

initial                                                                        // Testbench initial run
begin

  $monitor ("rst=%b, clk_rs232_en=%b", t_rst, t_clk_rs232_en);                 // Also output value in terminal

  t_clk = 0;                                                                   // Deassert input signals
  t_rst = 0;

  #5  t_rst = 1;                                                               // Assert reset
  #15 t_rst = 0;                                                               // Deassert reset
  #500000 t_rst = 1;                                                           // Reassert reset
  #10 $finish;                                                                 // End simulation

end

always
begin
  #5 t_clk = !t_clk;                                                           // Clock process
end

// Module instanciation
rs232_clk_gen #(
                 .RS232_RATIO(10417)
                )
DUT0 
               ( .clk(t_clk),
                 .rst(t_rst),
                 .clk_rs232_en(t_clk_rs232_en)
                );

endmodule
