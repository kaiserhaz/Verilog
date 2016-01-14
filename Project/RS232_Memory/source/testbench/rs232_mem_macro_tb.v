/**********
 * Memory Macro Testbench
 **********
 */

/** Directives **/
`include "../module/rs232_mem_macro.v"
`timescale 1ns/1ps

/** Submodule testbench **/
module rs232_mem_macro_tb;

// Variables
reg        t_clk;
reg        t_rst;
reg [13:0] t_mem_addr;
reg        t_mem_write;
reg [7:0]  t_mem_data_in;

wire [7:0] t_mem_data_out;

initial                   // Testbench initial run
begin

  $monitor ("Address: %d\nRead/Write: %b\nDatain: %d\nDataout: %d\n", t_mem_addr, t_mem_write, t_mem_data_in, t_mem_data_out); // Also output value in terminal

  t_clk = 0;             // Deassert input signals
  t_rst = 0;
  t_mem_addr = 0;
  
  repeat(16384)          // Write test
  begin

    t_mem_write = 1;     // Assert write
    
    t_mem_data_in = 8'h8; // Write value 8

    #10 t_mem_addr = t_mem_addr + 1; // Count address up

  end

  repeat(16384)          // Read test
  begin

    t_mem_write = 0;     // Assert read (low mem_write)

    #8 t_mem_addr = t_mem_addr - 1; // Count address up

  end

  #1 t_rst = 1;          // Reassert reset
  #1 t_rst = 0;          // Deassert reset
  #163840 $finish;       // End simulation

end

always
begin
  #5 t_clk = !t_clk;     // Clock process
end

// Module instanciation
rs232_mem_macro DUT0( .clk(t_clk),
                      .rst(t_rst),
                      .mem_addr(t_mem_addr),
                      .mem_write(t_mem_write),
                      .mem_data_in(t_mem_data_in),
                      .mem_data_out(t_mem_data_out)
                     );

endmodule
