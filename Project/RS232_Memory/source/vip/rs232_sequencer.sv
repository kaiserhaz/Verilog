/**********
 * RS232 Bus Interface
 **********
 */

/** Directives **/

/** Includes **/

/** Constants **/

/** Interface Definition **/
class rs232_sequencer extends uvm_sequencer #(rs232_trans);
  
  // Factory registration
  `uvm_component_utils(rs232_sequencer)
  
  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : rs232_sequencer
