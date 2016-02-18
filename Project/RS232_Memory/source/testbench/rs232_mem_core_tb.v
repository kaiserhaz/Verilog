/**********
 * RS232 Memory Core Testbench
 **********
 */

/** Directives **/
`include "../module/rs232_mem_core.v"
`include "../module/rs232_mem_macro.v"
`timescale 1ns/1ps

/** Submodule testbench **/
module rs232_mem_core_tb;

// Variables
reg   t_clk;
reg   t_rst;

wire  t_send_word;       // Send word signal
reg   t_new_word;        // New word signal

wire  t_data_rs232_out;  // Data from memory line
reg   t_data_rs232_in;   // Data wire from RS232 line

wire [13:0] t_mem_addr;  // Address line
wire        t_mem_write; // Write enable
wire [7:0]  t_mem_data_in; // Input data line

wire [7:0]  t_mem_data_out; // Output data line

initial                  // Testbench initial run
begin

  t_clk = 0;

  t_rst = 1;
  t_data_rs232_in = 0;
  t_new_word = 0;

  #20 t_rst = 0;

  // 1) Read at @14'b01101000001010 = 14'h1A0A

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 1;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20
  
  #20                                          // Processing time wait

  #110                                         // Wait for output
  #110                                         // Wait for ACK

  // 2) Write; protection on

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 1;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20
  
  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #20                                          // Processing time wait

  #110                                         // Wait for ACK

  // 3) Protection off

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 0;                     // Bit 3
  #10 t_data_rs232_in = 1;                     // Bit 2
  #10 t_data_rs232_in = 0;                     // Bit 1
  #10 t_data_rs232_in = 1;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 1;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 0;                     // Bit 3
  #10 t_data_rs232_in = 1;                     // Bit 2
  #10 t_data_rs232_in = 0;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 1;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 0;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #20                                          // Processing time wait

  #110                                         // Wait for output

  // 4) Write, protection off

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 1;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20
  
  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #20                                          // Processing time wait

  #110                                         // Wait for ACK

  // 5) Read at written address

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 1;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20
  
  #20                                          // Processing time wait

  #110                                         // Wait for output
  #110                                         // Wait for ACK

  // 6) Erase

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 0;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 0;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20
  
  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 1;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 1;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #20                                          // Processing time wait

  #110                                         // Wait for output
  #110                                         // Wait for ACK

  // 7) Protection on

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 0;                     // Bit 3
  #10 t_data_rs232_in = 1;                     // Bit 2
  #10 t_data_rs232_in = 0;                     // Bit 1
  #10 t_data_rs232_in = 1;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 0;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 1;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 0;                     // Bit 3
  #10 t_data_rs232_in = 1;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #20                                          // Processing time wait

  #110                                         // Wait for output

  // 8) Read at any address

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 1;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 1;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20

  #5  t_new_word = 1;                          // Send interrupt
      t_data_rs232_in = 0;                     // Allow for start
  #10 t_data_rs232_in = 0;                     // Bit 7
  #10 t_data_rs232_in = 0;                     // Bit 6
  #10 t_data_rs232_in = 0;                     // Bit 5
  #10 t_data_rs232_in = 0;                     // Bit 4
  #10 t_data_rs232_in = 1;                     // Bit 3
  #10 t_data_rs232_in = 0;                     // Bit 2
  #10 t_data_rs232_in = 1;                     // Bit 1
  #10 t_data_rs232_in = 0;                     // Bit 0
      t_new_word = 0;                          // Interrupt deasserted
  #20
  
  #20                                          // Processing time wait

  #110                                         // Wait for output
  #110                                         // Wait for ACK

  #162720                                      // Wait for erase to finish

  #10 $finish;                                 // End simulation

end

always
begin
  #5 t_clk = !t_clk;                           // Clock process
end

// Submodule instanciation
rs232_mem_macro MEM_MACRO0( .clk(t_clk),
                            .rst(t_rst),
                            .mem_addr(t_mem_addr),
                            .mem_write(t_mem_write),
                            .mem_data_in(t_mem_data_in),
                            .mem_data_out(t_mem_data_out)
                           );

// Module instanciation
rs232_mem_core DUT0( .clk(t_clk),                        
                     .rst(t_rst),                        
                     .new_word(t_new_word),
                     .data_rs232_in(t_data_rs232_in),
                     .data_rs232_out(t_data_rs232_out),
                     .send_word(t_send_word),
                     .end_of_erase(t_end_of_erase),
                     .mem_addr(t_mem_addr),
                     .mem_write(t_mem_write),
                     .mem_data_in(t_mem_data_in),
                     .mem_data_out(t_mem_data_out)       
                    );

endmodule
