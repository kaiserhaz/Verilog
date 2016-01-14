
//------------------------------------------------------------------------------
//
// slave transfer enums, parameters, and events
//
//------------------------------------------------------------------------------
typedef enum {INACTIVE, DATA, ERROR} action_enum;

//------------------------------------------------------------------------------
//
// CLASS: slave_transfer
//
//------------------------------------------------------------------------------

class slave_transfer extends uvm_sequence_item;                                  

  rand action_enum          action;
  rand bit                  valid;
  rand bit [15:0]           data;
  rand bit                  overflow;
  rand bit                  error;


  `uvm_object_utils_begin(slave_transfer)
    `uvm_field_enum     (action_enum, action, UVM_DEFAULT)
    `uvm_field_int      (valid,           UVM_DEFAULT)
    `uvm_field_int      (data,            UVM_DEFAULT)
    `uvm_field_int      (overflow,        UVM_DEFAULT)
    `uvm_field_int      (error,           UVM_DEFAULT)
  `uvm_object_utils_end

  // new - constructor
  function new (string name = "slave_transfer_inst");
    super.new(name);
  endfunction : new

endclass : slave_transfer


