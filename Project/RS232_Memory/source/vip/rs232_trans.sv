/**********
 * RS232 Memory Trans
 **********
 */

/** Directives **/

/** Includes **/

/** Constants **/

typedef enum bit [1:0] { WRITE=2'b11,
                         READ=2'b10,
                         ERASE=2'b01,
                         PROT=2'b00
                       } rs232_cmd;            // RS232 Commands

/** Transaction Definition **/
class rs232_trans extends uvm_sequence_item;
  
  // Transaction attributes
  rand rs232_cmd  _cmd;                        // Command
  rand bit [13:0] _addr;                       // Address
  rand bit [7:0]  _data;                       // Data
  rand bit        _prot;                       // Protection bit
  
  // Constraints
  constraint cmd_const {                       // Command constraint, avoid ERASE in normal case
    _cmd inside { WRITE, READ, PROT };
  }

  // Constructor
  function new(string name="rs232_trans0");
    super.new(name);
  endfunction : new

  // Register with UVM directives
  `uvm_object_utils_begin(rs232_trans)
    `uvm_field_enum (_cmd, rs232_cmd, UVM_DEFAULT)
    `uvm_field_int  (_addr,           UVM_DEFAULT)
    `uvm_field_int  (_data,           UVM_DEFAULT)
    `uvm_field_int  (_prot,           UVM_DEFAULT)
  `uvm_object_utils_end

endclass : rs232_trans
