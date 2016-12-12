/**********
 * RS232 Bus Driver
 **********
 */

/** Directives **/

/** Includes **/

/** Constants **/

/** Interface Definition **/
class rs232_driver extends uvm_driver #(rs232_trans);
  
  // Virtual IF
  protected virtual rs232_if vif;

  // Driver ID
  protected int d_ID;
  
  // UVM directives to allow implementation of virtual methods
  `uvm_component_utils_begin(rs232_driver)
    `uvm_field_int(d_ID, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual rs232_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  // Run phase
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // get_and_drive implementation  
  virtual protected task get_and_drive();
    `uvm_info(get_type_name(),"Waiting for reset",UVM_NONE);
    @(posedge vif._rst);
    `uvm_info(get_type_name(),"Getting reset",UVM_NONE);

    forever begin
      @(posedge vif._clk);
      `uvm_info(get_type_name(),"Getting Next Item",UVM_NONE);
      seq_item_port.get_next_item(req);
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      drive_transfer(rsp);
      seq_item_port.item_done();
      seq_item_port.put_response(rsp);
    end
  endtask : get_and_drive

  // reset_signals implementation
  virtual protected task reset_signals();
    forever begin
      @(negedge vif._rst);    
      vif._rx <= 1'b0;
    end
  endtask : reset_signals

  virtual protected task drive_transfer(rs232_trans trans);
    `uvm_info(get_type_name(),"driving transfer",UVM_NONE);
    `uvm_info(get_full_name(), $sformatf("Transfer drived :\n%s",
              trans.sprint()), UVM_MEDIUM)
      
    vif._rx = 0;                                   // Start bit
    vif._rx = #(RS232_RATIO*10) trans._data[7];    // Bit 7
    vif._rx = #(RS232_RATIO*10) trans._data[6];    // Bit 6
    vif._rx = #(RS232_RATIO*10) trans._data[5];    // Bit 5
    vif._rx = #(RS232_RATIO*10) trans._data[4];    // Bit 4
    vif._rx = #(RS232_RATIO*10) trans._data[3];    // Bit 3
    vif._rx = #(RS232_RATIO*10) trans._data[2];    // Bit 2
    vif._rx = #(RS232_RATIO*10) trans._data[1];    // Bit 1
    vif._rx = #(RS232_RATIO*10) trans._data[0];    // Bit 0
    vif._rx = #(RS232_RATIO*10) (^trans._data)^PARITY; // Parity bit
    vif._rx = #(RS232_RATIO*10) 1;                 // Stop bit
              #(RS232_RATIO*10);                   // Idle

  endtask : drive_transfer

endinterface : rs232_if
