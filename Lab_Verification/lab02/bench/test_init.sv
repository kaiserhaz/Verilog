
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


