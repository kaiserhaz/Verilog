
//------------------------------------------------------------------------------
//
// ubus transfer enums, parameters, and events
//
//------------------------------------------------------------------------------

typedef enum { READ,
               WRITE
             } ubus_read_write_enum;

//------------------------------------------------------------------------------
//
// CLASS: ubus_transfer
//
//------------------------------------------------------------------------------

class ubus_transfer extends uvm_sequence_item;                                  

  rand bit [5:0]           addr;
  rand ubus_read_write_enum read_write;
  rand bit [15:0]            data;
  rand int unsigned         transmit_delay = 0;

  constraint c_read_write {
    read_write inside { READ, WRITE };
  }

  constraint c_transmit_delay { 
    transmit_delay <= 10 ; 
  }

  `uvm_object_utils_begin(ubus_transfer)
    `uvm_field_int      (addr,           UVM_DEFAULT)
    `uvm_field_enum     (ubus_read_write_enum, read_write, UVM_DEFAULT)
    `uvm_field_int      (data,           UVM_DEFAULT)
    `uvm_field_int      (transmit_delay, UVM_DEFAULT)
  `uvm_object_utils_end

  // new - constructor
  function new (string name = "ubus_transfer_inst");
    super.new(name);
  endfunction : new

endclass : ubus_transfer


