onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ubus_tb_top/dut/DEPTH
add wave -noupdate /ubus_tb_top/dut/clk
add wave -noupdate /ubus_tb_top/dut/rst_n
add wave -noupdate /ubus_tb_top/dut/req
add wave -noupdate /ubus_tb_top/dut/gnt
add wave -noupdate /ubus_tb_top/dut/addr
add wave -noupdate /ubus_tb_top/dut/write
add wave -noupdate /ubus_tb_top/dut/data_w
add wave -noupdate /ubus_tb_top/dut/data_r
add wave -noupdate /ubus_tb_top/dut/out_valid
add wave -noupdate /ubus_tb_top/dut/out_data
add wave -noupdate /ubus_tb_top/dut/overflow
add wave -noupdate /ubus_tb_top/dut/out_ready
add wave -noupdate /ubus_tb_top/dut/err
add wave -noupdate /ubus_tb_top/dut/fir_enable
add wave -noupdate /ubus_tb_top/dut/fir_softreset
add wave -noupdate /ubus_tb_top/dut/fir_size
add wave -noupdate /ubus_tb_top/dut/out_data_tmp
add wave -noupdate /ubus_tb_top/dut/coefficients
add wave -noupdate /ubus_tb_top/dut/values_d
add wave -noupdate /ubus_tb_top/dut/values_q
add wave -noupdate /ubus_tb_top/dut/tmp_val_d
add wave -noupdate /ubus_tb_top/dut/nr_tap
add wave -noupdate /ubus_tb_top/dut/shift_en
add wave -noupdate /ubus_tb_top/dut/config_w
add wave -noupdate /ubus_tb_top/dut/coeff_w
add wave -noupdate /ubus_tb_top/dut/ii
add wave -noupdate /ubus_tb_top/dut/next_data_r
add wave -noupdate /ubus_tb_top/dut/config_val
add wave -noupdate /ubus_tb_top/dut/status_val
add wave -noupdate /ubus_tb_top/out_valid
add wave -noupdate /ubus_tb_top/overflow
add wave -noupdate /ubus_tb_top/out_data
add wave -noupdate /ubus_tb_top/out_ready
add wave -noupdate /ubus_tb_top/err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1480 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 321
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {8400 ps}
