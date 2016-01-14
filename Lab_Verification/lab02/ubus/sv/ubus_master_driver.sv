
//------------------------------------------------------------------------------
//
// CLASS: ubus_master_driver
//
//------------------------------------------------------------------------------

class ubus_master_driver extends uvm_driver #(ubus_transfer);

  // The virtual interface used to drive and view HDL signals.
  protected virtual ubus_if vif;

  // Master Id
  protected int master_id;

  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(ubus_master_driver)
    `uvm_field_int(master_id, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual ubus_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask : run_phase

  // get_and_drive 
  virtual protected task get_and_drive();
      `uvm_info(get_type_name(),"Waiting for reset",UVM_NONE);
      @(posedge vif.sig_rst_n);
      `uvm_info(get_type_name(),"Getting reset",UVM_NONE);

      forever begin
	 @(posedge vif.sig_clk);
	 `uvm_info(get_type_name(),"Getting Next Item",UVM_NONE);
	 seq_item_port.get_next_item(req);
	 $cast(rsp, req.clone());
	 rsp.set_id_info(req);
	 drive_transfer(rsp);
	 seq_item_port.item_done();
	 seq_item_port.put_response(rsp);
      end
  endtask : get_and_drive

  // reset_signals
  virtual protected task reset_signals();
      forever begin
	 @(negedge vif.sig_rst_n);
	 
	 vif.sig_req <= 'h0;
	 vif.sig_write          <= 'bz;
	 vif.sig_addr           <= 'hz;
	 vif.sig_data_w         <= 'hz;
    end
  endtask : reset_signals

  // drive_transfer
  virtual protected task drive_transfer (ubus_transfer trans);
      `uvm_info(get_type_name(),"driving transfer",UVM_NONE);
    //.............................................................................................
    
    // Attendre le délai de transmission
    repeat(trans.transmit_delay)
      @(posedge vif.sig_clk);
    
    // Active le signal req, passage de l'addresse  
    vif.sig_req <= 'h1;
    vif.sig_addr <= trans.addr;
    
    // Attendre le signal gnt
   while (vif.sig_gnt == 0)
      @(posedge vif.sig_clk);
      
    // Read or write
    if (trans.read_write == READ)
      begin
        vif.sig_data_r <=trans.data;
        vif.sig_write = 0;
      end
    else
      begin
       vif.sig_data_w <= trans.data; 
        vif.sig_write = 1;
      end

  // LAB02 TODO: Implement proper BFM
	
      
      @(posedge vif.sig_clk);
      vif.sig_req <= 'h0;

  endtask : drive_transfer


endclass : ubus_master_driver


