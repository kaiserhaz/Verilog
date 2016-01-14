
`include "ubus_pkg.sv"
//`include "dut_dummy.v"
`include "ubus_if.sv"
`include "slave_if.sv"

`timescale 1ns/1ps

module ubus_tb_top;
  import uvm_pkg::*;
  import ubus_pkg::*;
  `include "test_lib.sv" 

  ubus_if vif(); // SystemVerilog Interface
  slave_if svif(); // SystemVerilog Interface
   
   wire  out_valid;
   wire  overflow; // 1 cycle pulse each time there is an overflow
   wire [15:0] out_data;
   reg out_ready;
   wire err;
  

  assign svif.sig_out_valid = out_valid;
  assign svif.sig_overflow = overflow;
  assign svif.sig_out_data = out_data;
  assign svif.sig_out_ready = out_ready;
  assign svif.sig_err = err;




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
	      .overflow  (overflow   ),
        .out_ready (out_ready),
        .err       (err)
	      );

  initial begin
    uvm_config_db#(virtual ubus_if)::set(uvm_root::get(), "*", "vif", vif);
    uvm_config_db#(virtual slave_if)::set(uvm_root::get(), "*", "svif", svif);
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

  

//  initial begin
//     out_ready = 1'b1;
//  end

// Les lignes précedentes sont remplacées par les lignes suivantes
// Ainsi out_ready peut passer à 0 quand il y a trop d'écritures de data
// Ici par exmple, 50 cycles d'attente sont nécessaires après chaque écriture de data
  integer count;

  initial
  begin
    count = 0;
    forever
    begin
      @(posedge vif.sig_clk)
      if(vif.sig_gnt && vif.sig_req && vif.sig_addr == 'h21) begin
        if(count < 5)
          //count = count + 1;
          count = count + 50;
      end
      else
        if(count > 0)
          count = count - 1;
    end
  end
  
  initial
  begin
    out_ready = 1;
    forever
    begin
      @count
      if(count >= 5)
        out_ready = 0;
      else if (count == 0)
        out_ready = 1;
    end
  end
endmodule
