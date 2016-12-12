## Quit simulation if still in it
quit -sim

## Creates the specified folder in the current directory where this file is located
echo "/** Create Library and Map to work47 **/"

# Check to see if there are any existing directory
if [file exist work] {
	vdel -all
}

# Create the library if not yet done
vlib rs232_mem/work47

# Remap work to the library
vmap work [pwd]/rs232_mem/work47

## Compile all modules
echo "\n\n\n"
echo "/**          Module Compile          **/"
vlog -work work source/module/rs232_clk_gen.v
vlog -work work source/module/rs232_ctrl.v
vlog -work work source/module/rs232_mem_core.v
vlog -work work source/module/rs232_mem_macro.v
vlog -work work source/module/rs232_memory.v

## Compile all testbenches
echo "\n\n\n"
echo "/**         Testbench Compile        **/"
#vlog -work work source/testbench/rs232_clk_gen_tb.v
#vlog -work work source/testbench/rs232_mem_macro_tb.v
#vlog -work work source/testbench/rs232_ctrl_tb.v
#vlog -work work source/testbench/rs232_mem_core_tb.v
vlog -work work source/testbench/rs232_memory_tb.sv

## Simulate
echo "\n\n\n"
echo "/**             Simulate             **/"
#vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_clk_gen_tb
#vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_mem_macro_tb
#vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_ctrl_tb
#vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_mem_core_tb
vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_memory_tb

# Add all signals in design
#add wave *
#add wave -r /*

# Clock generator additions
#add wave /rs232_clk_gen_tb/DUT0/cnt

# Memory macro additions
#add wave /rs232_mem_macro_tb/DUT0/mem_case

# Controller additions
#add wave /rs232_ctrl_tb/DUT0/samp_rx_front
#add wave /rs232_ctrl_tb/DUT0/del_delayed
#add wave /rs232_ctrl_tb/DUT0/rx_buffer
#add wave /rs232_ctrl_tb/DUT0/rx_parity_ok
#add wave /rs232_ctrl_tb/DUT0/rx_finish
#add wave /rs232_ctrl_tb/DUT0/tx_buffer
#add wave /rs232_ctrl_tb/DUT0/tx_parity_bit
#add wave /rs232_ctrl_tb/DUT0/recv_buffer
#add wave /rs232_ctrl_tb/DUT0/recv_word_int
#add wave /rs232_ctrl_tb/DUT0/send_buffer
#add wave /rs232_ctrl_tb/DUT0/send_word_int

# Memory core addition
#add wave rs232_mem_core_tb/DUT0/recv_buffer 
#add wave rs232_mem_core_tb/DUT0/recv_word_int 
#add wave rs232_mem_core_tb/DUT0/send_buffer
#add wave rs232_mem_core_tb/DUT0/core_cmd_word 
#add wave rs232_mem_core_tb/DUT0/core_addr 
#add wave rs232_mem_core_tb/DUT0/core_data 
#add wave rs232_mem_core_tb/DUT0/core_prot 
#add wave rs232_mem_core_tb/DUT0/core_er_data
#add wave rs232_mem_core_tb/DUT0/core_er_done
#add wave rs232_mem_core_tb/DUT0/core_er_int
#add wave rs232_mem_core_tb/DUT0/core_state_cnt 
#add wave rs232_mem_core_tb/DUT0/core_next_state 
#add wave rs232_mem_core_tb/DUT0/fifo_reg
#add wave rs232_mem_core_tb/DUT0/fifo_ptr  
#add wave rs232_mem_core_tb/DUT0/fifo_full 
#add wave rs232_mem_core_tb/DUT0/fifo_empty
#add wave rs232_mem_core_tb/MEM_MACRO0/mem_case

# RS232 Memory waves
add wave rs232_memory_tb/rs232_drive/_word
add wave rs232_memory_tb/DUT0/rx
add wave rs232_memory_tb/DUT0/tx
add wave rs232_memory_tb/DUT0/end_of_erase
add wave rs232_memory_tb/DUT0/clk_rs232_en
add wave rs232_memory_tb/DUT0/new_word
add wave rs232_memory_tb/DUT0/send_word
add wave rs232_memory_tb/DUT0/data_rs232_in
add wave rs232_memory_tb/DUT0/data_rs232_out
add wave rs232_memory_tb/DUT0/mem_addr
add wave rs232_memory_tb/DUT0/mem_write
add wave rs232_memory_tb/DUT0/mem_data_in
add wave rs232_memory_tb/DUT0/mem_data_out
add wave rs232_memory_tb/DUT0/RS232_CLK_G0/clk_rs232_en
add wave rs232_memory_tb/DUT0/RS232_C0/new_word
add wave rs232_memory_tb/DUT0/RS232_C0/data_rs232_in
add wave rs232_memory_tb/DUT0/RS232_C0/del_eq_300
add wave rs232_memory_tb/DUT0/RS232_C0/del_neq_0
add wave rs232_memory_tb/DUT0/RS232_C0/rx_buffer
add wave rs232_memory_tb/DUT0/RS232_C0/rx_parity_ok
add wave rs232_memory_tb/DUT0/RS232_C0/rx_curr_state
add wave rs232_memory_tb/DUT0/RS232_C0/rx_enable
add wave rs232_memory_tb/DUT0/RS232_C0/rx_finish
add wave rs232_memory_tb/DUT0/RS232_C0/tx_buffer
add wave rs232_memory_tb/DUT0/RS232_C0/tx_parity_bit
add wave rs232_memory_tb/DUT0/RS232_C0/tx_curr_state
add wave rs232_memory_tb/DUT0/RS232_C0/tx_enable
add wave rs232_memory_tb/DUT0/RS232_C0/tx_load
add wave rs232_memory_tb/DUT0/RS232_C0/recv_buffer
add wave rs232_memory_tb/DUT0/RS232_C0/recv_curr_state
add wave rs232_memory_tb/DUT0/RS232_C0/recv_word_int
add wave rs232_memory_tb/DUT0/RS232_C0/send_buffer
add wave rs232_memory_tb/DUT0/RS232_C0/send_curr_state
add wave rs232_memory_tb/DUT0/RS232_C0/send_word_int
add wave rs232_memory_tb/DUT0/RS232_M_C0/send_word
add wave rs232_memory_tb/DUT0/RS232_M_C0/data_rs232_out
add wave rs232_memory_tb/DUT0/RS232_M_C0/end_of_erase
add wave rs232_memory_tb/DUT0/RS232_M_C0/mem_addr
add wave rs232_memory_tb/DUT0/RS232_M_C0/mem_write
add wave rs232_memory_tb/DUT0/RS232_M_C0/mem_data_in
add wave rs232_memory_tb/DUT0/RS232_M_C0/recv_buffer
add wave rs232_memory_tb/DUT0/RS232_M_C0/recv_curr_state
add wave rs232_memory_tb/DUT0/RS232_M_C0/recv_word_int
add wave rs232_memory_tb/DUT0/RS232_M_C0/send_buffer
add wave rs232_memory_tb/DUT0/RS232_M_C0/send_curr_state
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_cmd_word
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_addr_hi
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_addr_lo
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_data
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_prot
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_er_addr
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_er_data
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_curr_state
add wave rs232_memory_tb/DUT0/RS232_M_C0/core_next_state
add wave rs232_memory_tb/DUT0/RS232_M_C0/fifo_reg
add wave rs232_memory_tb/DUT0/RS232_M_M0/mem_data_out
add wave rs232_memory_tb/DUT0/RS232_M_M0/mem_case

# Run for the set time in testbench
run -all
