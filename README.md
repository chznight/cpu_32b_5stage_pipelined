# 32-bit RISC CPU

This project implements a 32-bit RISC CPU with 5-stage pipeline and hazard detection/handling. The CPU design is based on RISC-V ISA.

## Architecture Overview

The CPU features a 5-stage pipeline:
1. **Instruction Fetch (IF)**: Fetches instructions from memory
2. **Instruction Decode (ID)**: Decodes instructions and reads register values
3. **Execute (EX)**: Performs ALU operations
4. **Memory (MEM)**: Accesses data memory for loads and stores
5. **Write Back (WB)**: Writes results back to registers

## Hazard Handling

The CPU includes mechanisms to handle pipeline hazards:

1. **Data Hazards**: 
   - Forwarding unit detects data dependencies and forwards values from later pipeline stages
   - Handles most RAW (Read-After-Write) hazards

2. **Load-Use Hazards**: 
   - Hazard detection unit stalls the pipeline for one cycle when a load is followed by an instruction that uses the loaded value

3. **Control Hazards**: 
   - Branch outcomes are determined in the EX stage
   - Pipeline is flushed on branch taken

## Instruction Set

The CPU supports a RISC-V like instruction set with the following types:

- **R-type**: Register-to-register operations (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
- **I-type**: Register-immediate operations (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LW)
- **S-type**: Store operations (SW)
- **B-type**: Branch operations (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- **U-type**: Upper immediate operations (LUI, AUIPC)
- **J-type**: Jump operations (JAL, JALR)

## Project Structure

- `cpu.v`: Top-level CPU module
- `alu.v`: Arithmetic Logic Unit
- `register_file.v`: Register file with 32 32-bit registers
- `control_unit.v`: Instruction decoder and control signal generator
- `immediate_gen.v`: Immediate value generator for different instruction types
- `hazard_detection.v`: Detects load-use hazards
- `forwarding_unit.v`: Implements data forwarding
- `cpu_*_tb.v`: Testbench for CPU validation

## Simulation

To run the simulation:

1. Compile all Verilog files using your preferred simulator
2. Run the `cpu_tb` testbench
3. The testbench initializes a simple program that tests various instructions and hazard situations

The test program exercises basic arithmetic, memory operations, and branching to verify pipeline functionality and hazard handling.

## Extensions

Possible extensions to this design:
- Branch prediction
- Memory hierarchy (caches)
- Support for interrupts and exceptions
- Memory management unit
- Out-of-order execution 
