/**********
 * RS232 Clock Generator
 **********
 */

/** Directives **/
 
/** Includes **/

/** Constants **/

/** Module Definition **/
module rs232_clk_gen( clk,                     // Clock
                      rst,                     // Reset
                      clk_rs232_en             // RS232 clock
                    );
					
// Ports
input clk;
input rst;

output clk_rs232_en;

// Parameters
parameter [19:0] RS232_RATIO = 10417;          // Clock divider, default at 9600 bps, assuming clock rate is 100 MHz

// Datatype
reg clk_rs232_en;                              // Interpret output as register

// Variables
reg [19:0] cnt = 0;                            // Internal register to count clock cycle

// Main process
always @(posedge clk or posedge rst)
begin

  if(rst)
  begin
  
    cnt <= 0;                                  // Empty count register
    clk_rs232_en <= 0;                         // Reset case: deassert clock enable

  end

  else
  begin
    
    if(cnt == RS232_RATIO-1)
    begin
      cnt <= 0;
      clk_rs232_en <= 1;                       // Assert clock enable, normally held for 1 clock cycle
    end
    
    else
    begin
      cnt <= cnt + 1;                          // Count up
      clk_rs232_en <= 0;                       // Keep enable deasserted
    end

  end

end

endmodule
