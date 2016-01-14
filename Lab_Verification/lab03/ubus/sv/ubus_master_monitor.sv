
//------------------------------------------------------------------------------
//
// CLASS: ubus_master_monitor
//
//------------------------------------------------------------------------------

class ubus_master_monitor extends uvm_monitor;

  // This property is the virtual interfaced needed for this component to drive
  // and view HDL signals. 
  protected virtual ubus_if vif;

  // Master Id
  protected int master_id;

  // The following two bits are used to control whether checks and coverage are
  // done both in the monitor class and the interface.
  bit checks_enable = 1;
  bit coverage_enable = 1;

  uvm_analysis_port #(ubus_transfer) item_collected_port;

  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods). 
  protected ubus_transfer trans_collected;

  // Fields to hold trans addr, data and wait_state.
  protected bit [15:0] addr;
  protected bit [7:0] data;
  protected int unsigned wait_state;

  // Transfer collected covergroup
  covergroup cov_trans;
    option.per_instance = 1;
    trans_reg_addr : coverpoint trans_collected.addr {
      bins reg_config = {6'h00};
      bins reg_coeff_0 = {6'h01};
      bins reg_coeff_1 = {6'h02};
      bins reg_coeff_2 = {6'h03};
      bins reg_coeff_3 = {6'h04};
      bins reg_values_0 = {6'h11};
      bins reg_values_1 = {6'h12};
      bins reg_values_2 = {6'h13};
      bins reg_values_3 = {6'h14};
      bins reg_status = {6'h20};
      bins reg_datain = {6'h21};
      illegal_bins reg_none = default; }
    // New coverpoint
    trans_data1 : coverpoint trans_collected.data[1] {
      bins equal_1 = { 0'b1 }; }
//    trans_reg_configXdata1 : cross trans_reg_addr, trans_data1 {
//      bins config_access_when_equal_1 = binsof(trans_reg_addr) intersect {6'h00} &&
//                                        binsof(trans_data1); }
    trans_access_kind : coverpoint trans_collected.read_write;
//    trans_reg_addrXaccess_kind : cross trans_reg_addr, trans_access_kind {
//      illegal_bins no_read = binsof(trans_reg_addr) intersect {6'h21} &&
//                              binsof(trans_access_kind) intersect {READ};
//      illegal_bins no_write = binsof(trans_reg_addr) intersect {[6'h11:6'h14], 6'h20} &&
//                              binsof(trans_access_kind) intersect {WRITE};}
    trans_transmit_delay : coverpoint trans_collected.transmit_delay {
      bins delay_0 = {0};
      bins delay_1 = {1};
      bins delay_2 = {2};
      bins delay_3 = {3};
      bins delay_4 = {4};
      bins delay_5 = {5};
      bins delay_6 = {6};
      bins delay_7 = {7};
      bins delay_8 = {8};
      bins delay_9 = {9};
      bins delay_10 = {10};
      illegal_bins delay_none = default; }
  endgroup : cov_trans

//  // Transfer collected beat covergroup
  covergroup cov_trans_beat;
    option.per_instance = 1;
    beat_addr : coverpoint addr {
      option.auto_bin_max = 16; }
    beat_dir : coverpoint trans_collected.read_write;
    beat_data : coverpoint data {
      option.auto_bin_max = 8; }
    beat_wait : coverpoint wait_state {
      bins waits[] = { [0:9] };
      bins others = { [10:$] }; }
//    beat_addrXdir : cross beat_addr, beat_dir;
//    beat_addrXdata : cross beat_addr, beat_data;
  endgroup : cov_trans_beat

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(ubus_master_monitor)
    `uvm_field_int(master_id, UVM_DEFAULT)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    cov_trans = new();
    cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
    cov_trans_beat = new();
    cov_trans_beat.set_inst_name({get_full_name(), ".cov_trans_beat"});
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ubus_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info({get_full_name()," MASTER ID"},$sformatf(" = %0d",master_id),UVM_MEDIUM)
    @(posedge vif.sig_rst_n);
    fork
      collect_transactions();
    join
  endtask : run_phase

  // collect_transactions
  virtual protected task collect_transactions();
    forever begin
      @(posedge vif.sig_clk);
//      if (m_parent != null)
//        trans_collected.master = m_parent.get_name();
      collect_delay_phase();
      collect_arbitration_phase();
      collect_address_phase();
      collect_data_phase();
      `uvm_info(get_full_name(), $sformatf("Transfer collected :\n%s",
        trans_collected.sprint()), UVM_MEDIUM)
//      if (checks_enable)
//        perform_transfer_checks();
      if (coverage_enable)
         perform_transfer_coverage();
      item_collected_port.write(trans_collected);
    end
  endtask : collect_transactions

  // collect_delay_phase
  virtual protected task collect_delay_phase();
    int unsigned count = 0;
    
    fork
      @(posedge vif.sig_req);
      while(!vif.sig_req)
        @(posedge vif.sig_clk) count++;
    join_any
    @(posedge vif.sig_clk iff vif.sig_gnt === 1);
    
    void'(this.begin_tr(trans_collected));
    trans_collected.transmit_delay = count;
  endtask : collect_delay_phase

  // collect_arbitration_phase
  virtual protected task collect_arbitration_phase();
    //@(posedge vif.sig_clk iff vif.sig_gnt === 1);
  endtask : collect_arbitration_phase

  // collect_address_phase
  virtual protected task collect_address_phase();
    //@(posedge vif.sig_clk);
    trans_collected.addr = vif.sig_addr;
    //case ({vif.sig_read,vif.sig_write})
    case ({0,vif.sig_write})
      2'b0 : trans_collected.read_write = READ;
      2'b1 : trans_collected.read_write = WRITE;
    endcase
  endtask : collect_address_phase

  // collect_data_phase
  virtual protected task collect_data_phase();
    case(trans_collected.read_write)
      READ: trans_collected.data = vif.sig_data_r;
      WRITE: trans_collected.data = vif.sig_data_w;
    endcase
    this.end_tr(trans_collected);
  endtask : collect_data_phase


  // perform_transfer_coverage
  virtual protected function void perform_transfer_coverage();
    cov_trans.sample();
    cov_trans_beat.sample();
  endfunction : perform_transfer_coverage

//  virtual function void report_phase(uvm_phase phase);
//    `uvm_info(get_full_name(),$sformatf("Covergroup 'cov_trans' coverage: %2f",
//					cov_trans.get_inst_coverage()),UVM_LOW)
//  endfunction

endclass : ubus_master_monitor


