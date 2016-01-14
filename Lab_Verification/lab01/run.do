# Create Working Library called work
vlib work

# Compile Design and TestBench
vlog +acc dut.v 
vlog +acc tb.sv 

# Launch Simulator
vsim work.tb

# Add signals to waveform viewer
radix -hexadecimal
add wave sim:/tb/dut/* sim:/tb/dut/coefficients sim:/tb/dut/values_d sim:/tb/dut/values_q sim:/tb/dut/tmp_val_d

# Start running simulation

