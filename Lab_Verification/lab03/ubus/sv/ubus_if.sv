
interface ubus_if;

  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

  // Actual Signals
  logic              sig_clk;
  logic              sig_rst_n;
  logic       sig_req;
  logic       sig_gnt;
  logic       [5:0] sig_addr;
//logic        [1:0] sig_size;
//  logic              sig_read;
  logic              sig_write;
//  logic              sig_start;
//  logic              sig_bip;
  logic   [15:0] sig_data_w;
  logic        [15:0] sig_data_r;
//  logic              sig_wait;
//  logic              sig_error;

//  logic              rw;

//assign sig_data = rw ? sig_data_out : 8'bz;

// Coverage and assertions to be implemented here.

//always @(negedge sig_clock)
//begin
//
//// Address must not be X or Z during Address Phase
//assertAddrUnknown:assert property (
//                  disable iff(!has_checks) 
//                  ($onehot(sig_grant) |-> !$isunknown(sig_addr)))
//                  else
//                    $error("ERR_ADDR_XZ\n Address went to X or Z \
//                            during Address Phase");
//
//// Read must not be X or Z during Address Phase
//assertReadUnknown:assert property ( 
//                  disable iff(!has_checks) 
//                  ($onehot(sig_grant) |-> !$isunknown(sig_read)))
//                  else
//                    $error("ERR_READ_XZ\n READ went to X or Z during \
//                            Address Phase");
//
//// Write must not be X or Z during Address Phase
//assertWriteUnknown:assert property ( 
//                   disable iff(!has_checks) 
//                   ($onehot(sig_grant) |-> !$isunknown(sig_write)))
//                   else
//                     $error("ERR_WRITE_XZ\n WRITE went to X or Z during \
//                             Address Phase");
//
//// Size must not be X or Z during Address Phase
//assertSizeUnknown:assert property ( 
//                  disable iff(!has_checks) 
//                  ($onehot(sig_grant) |-> !$isunknown(sig_size)))
//                  else
//                    $error("ERR_SIZE_XZ\n SIZE went to X or Z during \
//                            Address Phase");
//
//
//// Wait must not be X or Z during Data Phase
//assertWaitUnknown:assert property ( 
//                  disable iff(!has_checks) 
//                  ($onehot(sig_grant) |=> !$isunknown(sig_wait)))
//                  else
//                    $error("ERR_WAIT_XZ\n WAIT went to X or Z during \
//                            Data Phase");
//
//
//// Error must not be X or Z during Data Phase
//assertErrorUnknown:assert property ( 
//                   disable iff(!has_checks) 
//                   ($onehot(sig_grant) |=> !$isunknown(sig_error)))
//                   else
//                    $error("ERR_ERROR_XZ\n ERROR went to X or Z during \
//                            Data Phase");
//
//
////Reset must be asserted for at least 3 clocks each time it is asserted
//assertResetFor3Clocks: assert property (
//                       disable iff(!has_checks) 
//                       ($rose(sig_reset) |=> sig_reset[*2]))
//                       else 
//                         $error("ERR_SHORT_RESET_DURING_TEST\n",
//                                "Reset was asserted for less than 3 clock \
//                                 cycles");
//
//// Only one grant is asserted
////assertSingleGrant: assert property (
////                   disable iff(!has_checks)
////                   (sig_start |=> $onehot0(sig_grant)))
////                   else
////                     $error("ERR_GRANT\n More that one grant asserted");
//
//// Read and write never true at the same time
//assertReadOrWrite: assert property (
//                   disable iff(!has_checks) 
//                   ($onehot(sig_grant) |-> !(sig_read && sig_write)))
//                   else
//                     $error("ERR_READ_OR_WRITE\n Read and Write true at \
//                             the same time");
//
//end

endinterface : ubus_if

