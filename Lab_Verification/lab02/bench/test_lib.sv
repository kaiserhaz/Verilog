
`include "ubus_example_tb.sv"


//--------------------------------------------------------------------------------
// Base Test
//--------------------------------------------------------------------------------
class ubus_base_test extends uvm_test;

  `uvm_component_utils(ubus_base_test)

  ubus_example_tb ubus_tb0;
  uvm_table_printer printer;
  bit test_pass = 1;

  function new(string name = "ubus_base_test", 
    uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Enable transaction recording for everything
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
      
    // Create the tb
    ubus_tb0 = ubus_example_tb::type_id::create("ubus_tb0", this);
      
    // Create a specific depth printer for printing the created topology
    printer = new();
    printer.knobs.depth = 3;
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    // Set verbosity for the bus monitor for this demo
//     if(ubus_tb0.ubus0.bus_monitor != null)
//       ubus_tb0.ubus0.bus_monitor.set_report_verbosity_level(UVM_FULL);
    `uvm_info(get_type_name(),
      $sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
  endfunction : end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase

  function void extract_phase(uvm_phase phase);
//    if(ubus_tb0.scoreboard0.sbd_error)
//      test_pass = 1'b0;
  endfunction // void
  
  function void report_phase(uvm_phase phase);
    if(test_pass) begin
      `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "** UVM TEST FAIL **")
    end
  endfunction

endclass : ubus_base_test


//--------------------------------------------------------------------------------
// Read Modify Write Read Test
//--------------------------------------------------------------------------------
class test_read_modify_write extends ubus_base_test;

  `uvm_component_utils(test_read_modify_write)

  function new(string name = "test_read_modify_write", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				read_modify_write_seq::type_id::get());
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

endclass : test_read_modify_write

//....................................................................

//--------------------------------------------------------------------------------
// Test init
//--------------------------------------------------------------------------------
class test_init extends ubus_base_test;

  `uvm_component_utils(test_init)

  function new(string name = "test_init", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				init_seq_and_go::type_id::get());
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

endclass : test_init



//--------------------------------------------------------------------------------
// Test_filter_random
//--------------------------------------------------------------------------------
class test_filter_random extends ubus_base_test;

  `uvm_component_utils(test_filter_random)

  function new(string name = "test_filter_random", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				filter_random_seq::type_id::get());
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

endclass : test_filter_random

//--------------------------------------------------------------------------------
// Test_random_activate_deactivate
//--------------------------------------------------------------------------------
class test_random_activate_deactivate extends ubus_base_test;

  `uvm_component_utils(test_random_activate_deactivate)

  function new(string name = "test_random_activate_deactivate", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				random_activate_deactivate_seq::type_id::get());
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

endclass : test_random_activate_deactivate



//--------------------------------------------------------------------------------
// Test_transfer_delay_0
//--------------------------------------------------------------------------------
class test_transfer_delay_0 extends ubus_base_test;

  `uvm_component_utils(test_transfer_delay_0)

  function new(string name = "test_transfer_delay_0", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				transfer_delay_0_seq::type_id::get());
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

endclass : test_transfer_delay_0