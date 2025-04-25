#!/bin/bash

# Compile the Verilog files
iverilog -o fibonacci_tb cpu.v control_unit.v register_file.v immediate_gen.v alu.v hazard_detection.v forwarding_unit.v cpu_fibonacci_0_tb.v

# Run the simulation
vvp fibonacci_tb

# Open the waveform if GTKWave is available
#if command -v gtkwave >/dev/null 2>&1; then
#    gtkwave fibonacci_wave.gtkw &
#else
#    echo "GTKWave not found. Please install it to view the waveforms."
#fi