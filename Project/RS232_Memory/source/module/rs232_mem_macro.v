/**********
 * Memory Macro
 **********
 */

/** Directives **/
 
/** Includes **/

/** Constants **/

/** Module Definition **/
module rs232_mem_macro( clk,
                        rst,
                        mem_addr,
                        mem_write,
                        mem_data_in,
                        mem_data_out
                      );
					
// Ports
input        clk;
input        rst;
input [13:0] mem_addr;
input        mem_write;
input [7:0]  mem_data_in;

output [7:0] mem_data_out;

// Datatype
reg [7:0] mem_data_out;       // Output register

// Variables
reg [7:0] mem_case [0:16383]; // Memory register cases
reg [15:0] addr_cnt = 0;      // Address counter
reg rst_done;                 // Reset done state variable

// Main process
always @(posedge clk or posedge rst)
begin

  if(rst || !rst_done)
  begin
  
    if(addr_cnt < 16384)
    begin

      rst_done <= 0;     // Write reset state not done  
    
      mem_case[addr_cnt] <= 0;  // Write 0 to memory case at the specified address

      addr_cnt <= addr_cnt + 1; // Increment address counter

      mem_data_out <= 8'bz;     // Write output data to high impedance since there is no output ready signal
	  
    end

    else
    begin

      addr_cnt <= 0;     // Reset address counter
      rst_done <= 1;     // Write reset state done

    end

  end

  else
  begin
    
    if(mem_write == 1)   // Write case
    begin
    
      mem_case[mem_addr] <= mem_data_in; // Write input to memory case

      mem_data_out <= 8'bz;              // Write output data to high impedance since there is no output ready signal
	  
    end

    else
    begin
    
      mem_data_out <= mem_case[mem_addr]; // Write from memory case to output

    end

    rst_done <= 1;       // Hold reset state done

  end

end

endmodule
