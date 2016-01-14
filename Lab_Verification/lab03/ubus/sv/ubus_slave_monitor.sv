
//------------------------------------------------------------------------------
//
// CLASS: ubus_slave_monitor
//
//------------------------------------------------------------------------------

class ubus_slave_monitor extends uvm_monitor;

  // This property is the virtual interfaced needed for this component to drive
  // and view HDL signals. 
  protected virtual slave_if svif;
  protected virtual ubus_if vif;

  // slave Id
  protected int slave_id;

  // The following two bits are used to control whether checks and coverage are
  // done both in the monitor class and the interface.
  bit checks_enable = 1;
  bit coverage_enable = 1;

  uvm_analysis_port #(slave_transfer) item_collected_port;

  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods). 
  protected slave_transfer trans_collected;

  // Fields to hold trans addr, data and wait_state.
  protected bit                  valid;
  protected bit [15:0]           data;
  protected bit                  overflow;
  protected bit                  ready;
  protected bit                  error;

//  // Transfer collected covergroup
  covergroup cov_trans;
    option.per_instance = 1;
    trans_valid : coverpoint trans_collected.valid;
    trans_overflow : coverpoint trans_collected.overflow {
      illegal_bins trans_overflow = {1};
    }
    trans_data : coverpoint trans_collected.data {
      option.auto_bin_max = 8; }
    trans_error : coverpoint trans_collected.error;
  endgroup : cov_trans

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(ubus_slave_monitor)
    `uvm_field_int(slave_id, UVM_DEFAULT)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    cov_trans = new();
    cov_trans.set_inst_name({get_full_name(), ".cov_trans"});
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ubus_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    if(!uvm_config_db#(virtual slave_if)::get(this, "", "svif", svif))
       `uvm_fatal("NOSVIF",{"virtual interface must be set for: ",get_full_name(),".svif"});
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info({get_full_name()," SLAVE ID"},$sformatf(" = %0d",slave_id),UVM_MEDIUM)
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
//        trans_collected.slave = m_parent.get_name();
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

  // collect_arbitration_phase
  virtual protected task collect_arbitration_phase();
    @(posedge vif.sig_clk iff (vif.sig_req === 1 
                                && vif.sig_gnt === 1));
  endtask : collect_arbitration_phase

  // collect_address_phase
  virtual protected task collect_address_phase();
  endtask : collect_address_phase

  // collect_data_phase
  virtual protected task collect_data_phase();
    void'(this.begin_tr(trans_collected));
    if(vif.sig_write == 1 && vif.sig_addr == 6'h21) begin
      trans_collected.action = DATA;
      trans_collected.data = svif.sig_out_data;
      trans_collected.valid = svif.sig_out_valid;
      trans_collected.overflow = svif.sig_overflow;
      trans_collected.error = svif.sig_err;
    end else if((vif.sig_write == 1 
                  && ((vif.sig_addr >= 6'h11 && vif.sig_addr <= 6'h14) || vif.sig_addr == 6'h20))
                || (vif.sig_write == 0 && (vif.sig_addr == 6'h21))) begin
      trans_collected.action = ERROR;
      trans_collected.data = 0;
      trans_collected.valid = 0;
      trans_collected.overflow = 0;
      trans_collected.error = svif.sig_err;
    end else begin
      trans_collected.action = INACTIVE;
      trans_collected.data = 0;
      trans_collected.valid = 0;
      trans_collected.overflow = 0;
      trans_collected.error = 0;
    end
    this.end_tr(trans_collected);
  endtask : collect_data_phase




  // perform_transfer_coverage
  virtual protected function void perform_transfer_coverage();
    cov_trans.sample();
  endfunction : perform_transfer_coverage

//  virtual function void report_phase(uvm_phase phase);
//    `uvm_info(get_full_name(),$sformatf("Covergroup 'cov_trans' coverage: %2f",
//					cov_trans.get_inst_coverage()),UVM_LOW)
//  endfunction

endclass : ubus_slave_monitor


