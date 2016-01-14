
`include "ubus_pkg.sv"
//`include "dut_dummy.v"
`include "ubus_if.sv"


module ubus_tb_top;
  import uvm_pkg::*;
  import ubus_pkg::*;
  `include "test_lib.sv" 

  ubus_if vif(); // SystemVerilog Interface
   
   wire  out_valid;
   wire  overflow; // 1 cycle pulse each time there is an overflow
   wire [15:0] out_data;
  
//  dut_dummy dut(
//    vif.sig_request[0],
//    vif.sig_grant[0],
//    vif.sig_request[1],
//    vif.sig_grant[1],
//    vif.sig_clk,
//    vif.sig_rst_n,
//    vif.sig_addr,
//    vif.sig_size,
//    vif.sig_read,
//    vif.sig_write,
//    vif.sig_start,
//    vif.sig_bip,
//    vif.sig_data,
//    vif.sig_wait,
//    vif.sig_error
//  );
   filter dut(.clk     ( vif.sig_clk    ) ,
	      .rst_n   ( vif.sig_rst_n  ),
	      .req     ( vif.sig_req    ),
	      .gnt     ( vif.sig_gnt    ),
	      .write   ( vif.sig_write  ),
	      .addr    ( vif.sig_addr   ),
	      .data_w  ( vif.sig_data_w ),  
	      .data_r  ( vif.sig_data_r ),  
//	      in_valid,
//	      in_data,
	      .out_valid ( out_valid ),
	      .out_data  ( out_data  ),
	      .overflow  (overflow   ) 
	      );

  initial begin
    uvm_config_db#(virtual ubus_if)::set(uvm_root::get(), "*", "vif", vif);
    run_test();
  end

  initial begin
     vif.sig_rst_n <= 1'b0;
     vif.sig_clk <= 1'b1;     
     #51 vif.sig_rst_n = 1'b1;
  end

  //Generate Clock
  always
    #5 vif.sig_clk = ~vif.sig_clk;

endmodule
