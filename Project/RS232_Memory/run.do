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

## Compile all testbenches
echo "\n\n\n"
echo "/**         Testbench Compile        **/"
#vlog -work work source/testbench/rs232_clk_gen_tb.v
vlog -work work source/testbench/rs232_mem_macro_tb.v

## Simulate
echo "\n\n\n"
echo "/**             Simulate             **/"
#vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_clk_gen_tb
vsim -l rs232_mem.log -wlf rs232_mem.wlf work.rs232_mem_macro_tb

# Add all signals in design
add wave *
#add wave -r /*

# Clock generator additions
#add wave /rs232_clk_gen_tb/DUT0/cnt

# Memory macro additions
add wave /rs232_mem_macro_tb/DUT0/addr_cnt
add wave /rs232_mem_macro_tb/DUT0/rst_done
add wave /rs232_mem_macro_tb/DUT0/mem_case

# Run for the set time in testbench
run -all
