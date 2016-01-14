
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
#vlog +acc design/filter.v
vlog +acc +cover=bcesfx -coveropt 1  design/filter.v

echo "================================================================================"
echo "== Test Bench"
echo "================================================================================"
vlog +acc +incdir+ubus/sv +incdir+bench bench/ubus_tb_top.sv

echo "================================================================================"
echo "== Simulation"
echo "================================================================================"
#vsim -voptargs=+acc -coverage ubus_tb_top +UVM_TESTNAME=test_read_modify_write 
#vsim -voptargs=+acc -coverage ubus_tb_top +UVM_TESTNAME=test_init_and_go 
vsim -voptargs=+acc -coverage ubus_tb_top +UVM_TESTNAME=test_filter_random
#vsim -voptargs=+acc -coverage ubus_tb_top +UVM_TESTNAME=test_filter_Krandom
#vsim -voptargs=+acc -coverage ubus_tb_top +UVM_TESTNAME=test_filter_Krandom_nodelay

radix -hexadecimal
add wave sim:/ubus_tb_top/dut/* sim:/ubus_tb_top/*
do wave.do
run -all
