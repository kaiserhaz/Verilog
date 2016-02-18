/**********
 * Memory Macro
 **********
 */

/** Directives **/
 
/** Includes **/

/** Constants **/

/** Module Definition **/
module rs232_mem_macro( clk,                   // Clock
                        rst,                   // Reset
                        mem_addr,              // Memory address
                        mem_write,             // Memory write
                        mem_data_in,           // Memory data input
                        mem_data_out           // Memory data output
                      );
					
// Ports
input        clk;
input        rst;
input [13:0] mem_addr;
input        mem_write;
input [7:0]  mem_data_in;

output [7:0] mem_data_out;

// Datatype
reg [7:0] mem_data_out;                        // Output register

// Variables
reg [7:0] mem_case [0:16383];                  // Memory register cases

integer i;                                     // Counter variable

// Main process
always @(posedge clk or posedge rst)
begin

  if(rst)
  begin
  
    for(i=0; i<16384; i=i+1)
    begin
      mem_case[i] <= 0;                        // Write 0 to memory case at the specified address
    end

    mem_data_out <= 8'h00;                     // Write output data to low since there is no output ready signal

  end

  else
  begin
    
    if(mem_write == 1)                         // Write case
    begin
    
      mem_case[mem_addr] <= mem_data_in;       // Write input to memory case

      mem_data_out <= 8'h00;                   // Write output data to high impedance since there is no output ready signal
	  
    end

    else
    begin
    
      mem_data_out <= mem_case[mem_addr];      // Write from memory case to output

    end

  end

end

endmodule
