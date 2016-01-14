
`timescale 1ns/100ps





module tb;

   reg clk;
   reg  rst_n;

   initial
     forever
       begin
	  clk = 0;
	  #10;
	  clk = 1;
	  #10;
       end

   task start_reset;
      @(posedge clk);
      rst_n <= 0;
      @(posedge clk);
      rst_n <= 1;
      @(posedge clk);
   endtask // start_reset

   
   initial
     start_reset;
   
   
   reg   req;
   reg   gnt;
   reg   write;
   reg   in_valid;
   wire  out_valid;
   wire  overflow; // 1 cycle pulse each time there is an overflow

   reg   [5:0]  addr;
   reg   [15:0] data_w;
   wire  [15:0] data_r;

//   reg [15:0] in_data;
   wire [15:0] out_data;

   filter dut(clk,rst_n,
	      req,
	      gnt,
	      write,
	      addr,
	      data_w,  
	      data_r,  
//	      in_valid,
//	      in_data,
	      out_valid,
	      out_data,
	      overflow );

   task write_reg;
      input [6:0] reg_addr;
      input [15:0] reg_data;
      begin

	 req <= 1;
	 write <= 1;
	 data_w <= reg_data;
	 addr <= reg_addr;

	 while ( gnt == 0 )
	   @(posedge clk);
      
	 // sync to clk rising edge
	 @(posedge clk);
	 req <= 0;
      end
   endtask // write_reg


   initial
     begin
	@(posedge rst_n);
	repeat (10) @(posedge clk);
	write_reg(0,'h00); //...................ENABLE.OFF................
	write_reg(1,'h10);
	write_reg(2,'h01);
     end
   
   initial
     begin
//	in_valid = 0;
	repeat (50) @(posedge clk);

	write_reg('h21,16'hCAFE);

	@(posedge clk);
	write_reg(0,'h01); //...................ENABLE.ON................
	write_reg('h21,16'hBABE);
	write_reg('h21,16'h900D);
	write_reg('h21,16'hDEAD);
	write_reg(0,'h03); //...................SOFT.RESET.............
	write_reg('h21,16'hBEEF);
	write_reg('h21,16'h9090);
	write_reg('h21,16'hBAFF);
	write_reg(0,'h01); //...................SOFT.RESET...............
	@(posedge clk);
	
	write_reg('h21,16'hB10D);
	write_reg('h21,16'hBAD);
	write_reg('h21,16'hB0FF);
		
	repeat (1000)
	  @(posedge clk);
	$stop;
	
     end
   
endmodule // tb
