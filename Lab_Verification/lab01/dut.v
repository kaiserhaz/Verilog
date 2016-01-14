// $Id$
// Description:
//    This design implements a FIR filter
//    DOut = Din*Coeff1 + Din(-1)xCoeff2 + Din(-2)*Coeff3 + Din(-3)*Coeff4
//
//              
//       -----      -----       -----       -----    
//  in --|D Q|---+--|D Q|---+---|D Q|---+---|D Q|---+
//       -----   |  -----   |   -----   |   -----   |
//               |          |           |           |
//            C3 X       C2 X        C1 X        C0 X
//               |          |           |           |
//               -----------+-----------+-----------+------> Dout
//;              
//
//
//
// Register Description:
//--------------+------------+--------+------------------------------------------------------------------
// Offset       |   Name     | Access |  Description
//--------------+------------+--------+-------------------------------------------------------------------
// 0x0          |   CONFIG   | R/W    | [0:0] : 1=Enable , 0=Disable
//              |            | W      | [1:1] : Soft Reset: writting 1 resets the content of Din[*]
//              |            | R/W    | [5:3] : Filter depth : 0=1 coeffs, 1=2 coeffs, 2=3 coeffs, 3=4 coeffs
//--------------+------------+---------------------------------------------------------------------------
// 0x1 to 0x4   |   Coeff[n] | R/W    | 16 bits signed integer value of the coefficients
//--------------+------------+--------+------------------------------------------------------------------
// 0x11 to 0x14 |   Value[n] | R      | 16 bits signed integer value of the previous 4 Din
//--------------+------------+--------+------------------------------------------------------------------
// 0x20         |   Status   | R      | Reading this register clears it
//              |            |        | [0:0] : overflow
//--------------+------------+--------+------------------------------------------------------------------
// 0x21         |   Data In  | W      | [15:0] Data In to be filtered
//--------------+------------+--------+------------------------------------------------------------------

`timescale 1ns/10ps

// Module declaration

module filter(
	      // clock and reset
	      clk,rst_n,
	      // Register Access
	      req,
	      gnt,
	      write,
	      addr,
	      data_w,  // valid on req if write = 1
	      data_r,  // valid on gnt if write = 0
	      //
	      out_valid,
	      out_data,
	      //
	      overflow  // 1 cycle pulse each time there is an overflow
	      );

   parameter DEPTH=4;

   // Interface Signal
   input              clk;
   input 	      rst_n;
   input 	      req;
   output 	      gnt;
   input 	      addr;
   input 	      write;
   input 	      data_w;  // valid on req if write = 1
   output 	      data_r;  // valid on gnt if write = 0
   output 	      out_valid;
   output [15:0]      out_data;
   output 	      overflow; // 1 cycle pulse each time there is an overflow

   wire [5:0] 	      addr;
   wire [15:0] 	      data_w;
   reg [15:0] 	      data_r;
   reg 		      gnt;

   // Internal Signals and Registers
   reg [31:0] 	      out_data_tmp;
   reg [15:0] 	      coefficients [DEPTH-1:0];
   wire [15:0] 	      values_d    [DEPTH-1:0];
   reg [15:0] 	      values_q    [DEPTH-1:0];
   wire [31:0] 	      tmp_val_d   [DEPTH-1:0];
   reg [4:0] 	      nr_tap;
   wire 	      shift_en;
   wire 	      config_w;
   wire 	      coeff_w [DEPTH-1:0];

   // tmp variables
   integer 	      ii;
  
  //...............................................FILTER ENABLE......................
  reg filter_enable;
  //...............................................SOFT RESET.........................
  reg soft_reset;
  //...............................................VALUES.............................
  reg [15:0] values_n   [DEPTH-1:0];
  
   //--------------------------------------------------------------------------------
   // Register Read Access
   //--------------------------------------------------------------------------------
   reg [15:0] 	      next_data_r;
   reg [15:0] 	      config_val;
   reg [15:0] 	      status_val;
   
   always @(write,addr,coefficients[0],coefficients[1],coefficients[2],coefficients[3])
     begin
	  if ( ! write ) 
	  case (addr)
	    'h00 : next_data_r = config_val;
	    'h01 : next_data_r = coefficients[0];
	    'h02 : next_data_r = coefficients[1];
	    'h03 : next_data_r = coefficients[2];
	    'h04 : next_data_r = coefficients[3];
	    'h11 : next_data_r = values_n[0];
	    'h12 : next_data_r = values_n[1];
	    'h13 : next_data_r = values_n[2];
	    'h14 : next_data_r = values_n[3];
	    'h20 : next_data_r = status_val;
	    default: next_data_r = 'h0000;
	  endcase // case(addr)
	else
	  next_data_r = 'hZZZZ;
     end
   
   
   //..........................OVERFLOW.CLEAR...............
   always @(write, addr)
    if( (!write) && (addr == 'h20) )
      status_val <= 0;
   //.....................................................................
   always @(posedge clk)
     if ( rst_n )
       data_r <= 0;
     else
       data_r <= next_data_r;
   
   //--------------------------------------------------------------------------------
   // Register Write Access
   //--------------------------------------------------------------------------------
   assign 	      config_w   = req && gnt && write && addr[5:0] == 0'h00;
   assign 	      coeff_w[0] = req && gnt && write && addr[5:0] == 0'h01;
   assign 	      coeff_w[1] = req && gnt && write && addr[5:0] == 0'h02;
   assign 	      coeff_w[2] = req && gnt && write && addr[5:0] == 0'h03;
   assign 	      coeff_w[3] = req && gnt && write && addr[5:0] == 0'h04;
   assign 	      shift_en   = req && gnt && write && addr == 0'h21;
   
   assign 	      values_d[DEPTH-1] = shift_en ? data_w : 'h0000; 
   
  //..................CONFIG....................................
  always @(write, addr)
    if (config_w)
      begin
        filter_enable <= data_w[0];
        soft_reset <= data_w[1];
        
        config_val[0] <= data_w[0];
        config_val[1] <= data_w[1];
      end
  
  //...................RESET.VALUE...............................
  always @(posedge clk)
    if ( ! rst_n )
      config_val <= 'h0031; // 3 = 4 coefficients
      
   // Coefficients
   always @(posedge clk)
     if ( ! rst_n )
       for (ii=0; ii<DEPTH; ii=ii+1 )
	 coefficients[ii] <= 0;
     else
       for (ii=0; ii<DEPTH; ii=ii+1 )
	 if ( coeff_w[ii] )
	   coefficients[ii] <= data_w;

   //--------------------------------------------------------------------------------
   // Processing
   //--------------------------------------------------------------------------------
   // shifter
   always @(posedge clk)
     if ( ! rst_n || soft_reset) //...SOFT.RESET...ALT.:.if(!rst_n || config_val[0])
       for ( ii=0; ii < DEPTH; ii=ii+1)
	       values_q[ii] <= 0;
     else
       if ( shift_en && filter_enable ) //...FILTER.ENABLE...ALT.:.if(shift_en && config_val[1])
	 for ( ii=0; ii < DEPTH; ii=ii+1)
	   begin
	     values_q[ii] <= values_d[ii];
	     values_n[ii] <= values_d[ii];
	   end

   generate
      genvar jj;
      for (jj=0;jj<DEPTH-1;jj=jj+1) begin
	 assign values_d[jj] = values_q[jj+1];
      end
   endgenerate


   // Tap Filtering
   generate
      for (jj=0; jj<DEPTH; jj=jj+1) begin
	 assign tmp_val_d[jj] = values_d[jj] * coefficients[jj];
      end
   endgenerate
   
   always @(tmp_val_d[0],tmp_val_d[1],tmp_val_d[2],tmp_val_d[2])
     begin
	out_data_tmp = 0;   
	for (ii = 0;ii < DEPTH; ii = ii + 1)
	  out_data_tmp = out_data_tmp + tmp_val_d[ii];
     end
   
   assign 	      out_data   = out_data_tmp;
   assign 	      overflow   = | { out_data_tmp[31:16] }; //...OVERFLOW...

   // Output validating
   
   always @(posedge clk)
     if ( rst_n == 0 ) begin
	gnt <= 1;
	nr_tap <= 0;
     end
     else
       if ( shift_en && ( nr_tap < DEPTH-1 ) )
	 nr_tap <= nr_tap + 1;
   
   assign out_valid = shift_en && (nr_tap >= DEPTH-1) && filter_enable && (~soft_reset); //...SOFT.RESET...ALT.:.(config_val[0]) && (~config_val[1])

   
endmodule // filter

