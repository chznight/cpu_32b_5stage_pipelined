# RISC CPU Instruction Set

This document provides a detailed overview of the supported instructions in our 32-bit RISC CPU.

## Instruction Format Types

The CPU follows RISC-V like instruction formats:

| Format | Description | Example Instructions |
|--------|-------------|---------------------|
| R-type | Register-Register operations | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type | Register-Immediate operations, Loads, Jumps | ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LW, JALR |
| S-type | Store operations | SW |
| B-type | Branch operations | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| U-type | Upper immediate operations | LUI, AUIPC |
| J-type | Jump operations | JAL |

## Instruction Set Table

| Instruction | Format | Opcode (Binary) | Funct3 | Funct7 | Description | Operation |
|-------------|--------|----------------|--------|--------|-------------|-----------|
| **Arithmetic & Logic Instructions** |
| ADD | R-type | 0110011 | 000 | 0000000 | Add | rd = rs1 + rs2 |
| SUB | R-type | 0110011 | 000 | 0100000 | Subtract | rd = rs1 - rs2 |
| AND | R-type | 0110011 | 111 | 0000000 | Bitwise AND | rd = rs1 & rs2 |
| OR | R-type | 0110011 | 110 | 0000000 | Bitwise OR | rd = rs1 \| rs2 |
| XOR | R-type | 0110011 | 100 | 0000000 | Bitwise XOR | rd = rs1 ^ rs2 |
| SLL | R-type | 0110011 | 001 | 0000000 | Shift Left Logical | rd = rs1 << rs2[4:0] |
| SRL | R-type | 0110011 | 101 | 0000000 | Shift Right Logical | rd = rs1 >> rs2[4:0] |
| SRA | R-type | 0110011 | 101 | 0100000 | Shift Right Arithmetic | rd = rs1 >>> rs2[4:0] |
| SLT | R-type | 0110011 | 010 | 0000000 | Set Less Than (Signed) | rd = (rs1 < rs2) ? 1 : 0 |
| SLTU | R-type | 0110011 | 011 | 0000000 | Set Less Than (Unsigned) | rd = (rs1 < rs2) ? 1 : 0 |
| ADDI | I-type | 0010011 | 000 | - | Add Immediate | rd = rs1 + imm |
| ANDI | I-type | 0010011 | 111 | - | Bitwise AND Immediate | rd = rs1 & imm |
| ORI | I-type | 0010011 | 110 | - | Bitwise OR Immediate | rd = rs1 \| imm |
| XORI | I-type | 0010011 | 100 | - | Bitwise XOR Immediate | rd = rs1 ^ imm |
| SLTI | I-type | 0010011 | 010 | - | Set Less Than Immediate (Signed) | rd = (rs1 < imm) ? 1 : 0 |
| SLTIU | I-type | 0010011 | 011 | - | Set Less Than Immediate (Unsigned) | rd = (rs1 < imm) ? 1 : 0 |
| SLLI | I-type | 0010011 | 001 | 0000000 | Shift Left Logical Immediate | rd = rs1 << imm[4:0] |
| SRLI | I-type | 0010011 | 101 | 0000000 | Shift Right Logical Immediate | rd = rs1 >> imm[4:0] |
| SRAI | I-type | 0010011 | 101 | 0100000 | Shift Right Arithmetic Immediate | rd = rs1 >>> imm[4:0] |
| **Memory Instructions** |
| LW | I-type | 0000011 | 010 | - | Load Word | rd = Mem[rs1 + imm] |
| SW | S-type | 0100011 | 010 | - | Store Word | Mem[rs1 + imm] = rs2 |
| **Control Flow Instructions** |
| BEQ | B-type | 1100011 | 000 | - | Branch if Equal | if (rs1 == rs2) PC += imm |
| BNE | B-type | 1100011 | 001 | - | Branch if Not Equal | if (rs1 != rs2) PC += imm |
| BLT | B-type | 1100011 | 100 | - | Branch if Less Than (Signed) | if (rs1 < rs2) PC += imm |
| BGE | B-type | 1100011 | 101 | - | Branch if Greater/Equal (Signed) | if (rs1 >= rs2) PC += imm |
| BLTU | B-type | 1100011 | 110 | - | Branch if Less Than (Unsigned) | if (rs1 < rs2) PC += imm |
| BGEU | B-type | 1100011 | 111 | - | Branch if Greater/Equal (Unsigned) | if (rs1 >= rs2) PC += imm |
| JAL | J-type | 1101111 | - | - | Jump and Link | rd = PC+4; PC += imm |
| JALR | I-type | 1100111 | 000 | - | Jump and Link Register | rd = PC+4; PC = rs1 + imm |
| **Upper Immediate Instructions** |
| LUI | U-type | 0110111 | - | - | Load Upper Immediate | rd = imm << 12 |
| AUIPC | U-type | 0010111 | - | - | Add Upper Immediate to PC | rd = PC + (imm << 12) |

## Instruction Encoding

### R-type Instruction Format
```
 31        25 24     20 19     15 14  12 11      7 6           0
+------------+---------+---------+------+---------+-------------+
| funct7     | rs2     | rs1     |funct3| rd      | opcode      |
+------------+---------+---------+------+---------+-------------+
```

### I-type Instruction Format
```
 31                  20 19     15 14  12 11      7 6           0
+----------------------+---------+------+---------+-------------+
| imm[11:0]            | rs1     |funct3| rd      | opcode      |
+----------------------+---------+------+---------+-------------+
```

### S-type Instruction Format
```
 31        25 24     20 19     15 14  12 11      7 6           0
+------------+---------+---------+------+---------+-------------+
| imm[11:5]  | rs2     | rs1     |funct3| imm[4:0]| opcode      |
+------------+---------+---------+------+---------+-------------+
```

### B-type Instruction Format
```
 31        25 24     20 19     15 14  12 11      7 6           0
+------------+---------+---------+------+---------+-------------+
|imm[12|10:5]| rs2     | rs1     |funct3|imm[4:1|11]| opcode    |
+------------+---------+---------+------+---------+-------------+
```

### U-type Instruction Format
```
 31                                   12 11      7 6           0
+---------------------------------------+---------+-------------+
| imm[31:12]                            | rd      | opcode      |
+---------------------------------------+---------+-------------+
```

### J-type Instruction Format
```
 31        30       21 20      19         12 11      7 6       0
+-----------+----------+---------+----------+---------+---------+
| imm[20]   | imm[10:1]| imm[11] | imm[19:12]| rd      | opcode |
+-----------+----------+---------+----------+---------+---------+
``` 