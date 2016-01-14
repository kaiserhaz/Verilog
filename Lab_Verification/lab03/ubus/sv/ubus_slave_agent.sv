
//------------------------------------------------------------------------------
//
// CLASS: ubus_slave_agent
//
//------------------------------------------------------------------------------

class ubus_slave_agent extends uvm_agent;

  protected int slave_id;

  //ubus_slave_driver driver;
  //uvm_sequencer#(ubus_transfer) sequencer;
  ubus_slave_monitor monitor;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(ubus_slave_agent)
    `uvm_field_int(slave_id, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = ubus_slave_monitor::type_id::create("monitor", this);

    //if(get_is_active() == UVM_ACTIVE) begin
    //  sequencer = uvm_sequencer#(ubus_transfer)::type_id::create("sequencer", this);
    //  driver = ubus_slave_driver::type_id::create("driver", this);
    //end
  endfunction : build_phase

  // connect_phase
  function void connect_phase(uvm_phase phase);
    //if(get_is_active() == UVM_ACTIVE) begin
    //  driver.seq_item_port.connect(sequencer.seq_item_export);
    //end
  endfunction : connect_phase

endclass : ubus_slave_agent


