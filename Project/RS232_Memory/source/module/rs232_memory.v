/**********
 * Memory Macro
 **********
 */

/** Directives **/
 
/** Includes **/
`include "../module/rs232_clk_gen.v"
`include "../module/rs232_ctrl.v"
`include "../module/rs232_mem_core.v"
`include "../module/rs232_mem_macro.v"

/** Constants **/

/** Module Definition **/
module rs232_memory( clk,                      // Clock
                     rst,                      // Reset
                     end_of_erase,             // End of erase
                     rx,                       // Rx
                     tx,                       // Tx  
                   );

// Ports
input        clk;
input        rst;

output       end_of_erase;                     // End of erase signal

input        rx;                               // RS232 Rx
output       tx;                               // RS232 Tx

// Parameters
parameter [19:0] RS232_RATIO = 10417;          // Clock divider ratio, assuming 10MHz global clock
parameter PARITY = 1;                          // Parity: 1, impair; 0, pair

// Datatype
wire         end_of_erase;                     // EOE output wire
wire         tx;                               // Tx output wire

// Connecting wires
wire         clk_rs232_en;                     // RS232 clock line

wire         new_word;                         // New word interrupt line
wire         send_word;                        // Send word interrupt line
wire         data_rs232_in;                    // RS232 data in line
wire         data_rs232_out;                   // RS232 data out line

wire [13:0]  mem_addr;                         // Memory address bus
wire         mem_write;                        // Memory read/write line
wire [7:0]   mem_data_in;                      // Memory input data bus
wire [7:0]   mem_data_out;                     // Memory output data bus

// Module instanciation
rs232_clk_gen   #(.RS232_RATIO(RS232_RATIO))   // Divider ratio
                RS232_CLK_G0(.*);              // RS232 clock
rs232_ctrl      #(.PARITY(PARITY))             // Parity
                RS232_C0(.*);                  // RS232 controller
rs232_mem_core  RS232_M_C0(.*);                // Memory core controller
rs232_mem_macro RS232_M_M0(.*);                // Memory macro

endmodule
