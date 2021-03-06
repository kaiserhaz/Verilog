
echo "================================================================================"
echo "== SETUP"
echo "================================================================================"
vlib work


echo "================================================================================"
echo "== UBUS UVM VIP"
echo "================================================================================"
vlog +acc +incdir+ubus/sv ubus/sv/ubus_pkg.sv

echo "================================================================================"
echo "== Design"
echo "================================================================================"
vlog +acc design/filter.v

echo "================================================================================"
echo "== Test Bench"
echo "================================================================================"
vlog +acc +incdir+ubus/sv +incdir+bench bench/ubus_tb_top.sv

echo "================================================================================"
echo "== Simulation"
echo "================================================================================"
vsim -voptargs=+acc ubus_tb_top +UVM_TESTNAME=test_transfer_delay_0 -sv_seed random

add wave sim:/ubus_tb_top/dut/* sim:/ubus_tb_top/*

