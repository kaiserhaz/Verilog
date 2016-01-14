
//------------------------------------------------------------------------------
//
// SEQUENCE: ubus_base_sequence
//
//------------------------------------------------------------------------------

// This sequence raises/drops objections in the pre/post_body so that root
// sequences raise objections but subsequences do not.

virtual class ubus_base_sequence extends uvm_sequence #(ubus_transfer);

  function new(string name="ubus_base_seq");
    super.new(name);
  endfunction
  
  // Raise in pre_body so the objection is only raised for root sequences.
  // There is no need to raise for sub-sequences since the root sequence
  // will encapsulate the sub-sequence. 
  virtual task pre_body();
    if (starting_phase!=null) begin
       `uvm_info(get_type_name(),
		 $sformatf("%s pre_body() raising %s objection", 
			   get_sequence_path(),
			   starting_phase.get_name()), UVM_MEDIUM);
       starting_phase.raise_objection(this);
    end
  endtask

  // Drop the objection in the post_body so the objection is removed when
  // the root sequence is complete. 
  virtual task post_body();
    if (starting_phase!=null) begin
       `uvm_info(get_type_name(),
		 $sformatf("%s post_body() dropping %s objection", 
			   get_sequence_path(),
			   starting_phase.get_name()), UVM_MEDIUM);
    starting_phase.drop_objection(this);
    end
  endtask
  
endclass : ubus_base_sequence

//------------------------------------------------------------------------------
// SEQUENCE: read
//------------------------------------------------------------------------------

class read_seq extends ubus_base_sequence;

  function new(string name="read_seq");
    super.new(name);
  endfunction
  
  `uvm_object_utils(read_seq)

  rand bit [5:0] start_addr;
  rand int unsigned transmit_del = 0;
  constraint transmit_del_ct { (transmit_del <= 10); }

  virtual task body();
    `uvm_do_with(req, 
      { req.addr == start_addr;
        req.read_write == READ;
//        req.size == 1;
//        req.error_pos == 1000;
        req.transmit_delay == transmit_del; } )
    get_response(rsp);
    `uvm_info(get_type_name(),
      $sformatf("%s read : addr = `x%0h, data[0] = `x%0h",
      get_sequence_path(), rsp.addr, rsp.data[0]), 
      UVM_HIGH);
  endtask
  
endclass : read_seq



//------------------------------------------------------------------------------
// SEQUENCE: write_seq
//------------------------------------------------------------------------------

class write_seq extends ubus_base_sequence;

  function new(string name="write_seq");
    super.new(name);
  endfunction

  `uvm_object_utils(write_seq)
    
  rand bit [5:0] start_addr;
  rand bit [15:0] data0;
  rand int unsigned transmit_del = 0;
  constraint transmit_del_ct { (transmit_del <= 10); }

  virtual task body();
    `uvm_do_with(req, 
      { req.addr == start_addr;
        req.read_write == WRITE;
//        req.size == 1;
        req.data == data0;
//        req.error_pos == 1000;
        req.transmit_delay == transmit_del; } )
    `uvm_info(get_type_name(),
      $sformatf("%s wrote : addr = `x%0h, data[0] = `x%0h",
      get_sequence_path(), req.addr, req.data[0]),
      UVM_HIGH);
  endtask

endclass : write_seq

