

package ubus_pkg;

   import uvm_pkg::*;

`include "uvm_macros.svh"

   typedef uvm_config_db#(virtual ubus_if) ubus_vif_config;
   typedef virtual ubus_if ubus_vif;

`include "ubus_transfer.sv"

`include "ubus_master_monitor.sv"
`include "ubus_master_sequencer.sv"
`include "ubus_master_driver.sv"
`include "ubus_master_agent.sv"


   typedef uvm_config_db#(virtual slave_if) slave_vif_config;
   typedef virtual slave_if slave_vif;

`include "slave_transfer.sv"

`include "ubus_slave_monitor.sv"
//`include "ubus_slave_sequencer.sv"
//`include "ubus_slave_driver.sv"
`include "ubus_slave_agent.sv"

//`include "ubus_bus_monitor.sv"

`include "ubus_env.sv"

endpackage: ubus_pkg

