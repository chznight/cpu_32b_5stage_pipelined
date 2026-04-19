module cpu_hazard_tb;
    // Clock and reset
    reg clk;
    reg rst;
    integer i;
    // Memory interface
    wire [31:0] instr_addr;
    reg [31:0] instruction;
    wire [31:0] data_addr;
    wire [31:0] data_out;
    reg [31:0] data_in;
    wire mem_write;
    wire mem_read;
    
    // Instruction memory (ROM)
    reg [31:0] instr_mem [0:63];
    
    // Data memory (RAM)
    reg [31:0] data_mem [0:63];
    
    // Instantiate the CPU
    cpu cpu_inst(
        .clk(clk),
        .rst(rst),
        .instr_addr(instr_addr),
        .instruction(instruction),
        .data_addr(data_addr),
        .data_out(data_out),
        .data_in(data_in),
        .mem_write(mem_write),
        .mem_read(mem_read)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end
    
    // Memory read/write
    always @(*) begin
        // Provide instruction from instruction memory
        instruction = instr_mem[instr_addr[7:2]]; // Word-aligned addresses
        
        // Provide data from data memory
        if (mem_read)
            data_in = data_mem[data_addr[7:2]];
    end
    
    // Handle memory writes
    always @(posedge clk) begin
        if (mem_write)
            data_mem[data_addr[7:2]] <= data_out;
    end

    initial begin
        $dumpfile("cpu_hazard_tb.vcd");
        $dumpvars(0, cpu_hazard_tb);
    end

    // Test program for various hazards
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Initialize data memory
        for (i = 0; i < 64; i = i + 1) begin
            data_mem[i] = 32'h0;
        end
        
        // Initialize instruction memory with hazard tests
        
        // -------------------------
        // Test 1: RAW Data Hazards
        // -------------------------
        // addi x1, x0, 5       # x1 = 5
        instr_mem[0] = 32'h00500093;
        
        // addi x2, x0, 10      # x2 = 10
        instr_mem[1] = 32'h00A00113;
        
        // add x3, x1, x2       # RAW hazard for x1 and x2: x3 = 15
        instr_mem[2] = 32'h002081B3;
        
        // sub x4, x3, x1       # RAW hazard for x3: x4 = 10
        instr_mem[3] = 32'h40118233;
        
        // -------------------------
        // Test 2: Load-Use Hazard
        // -------------------------
        // sw x2, 0(x0)         # Store x2 (10) to memory[0]
        instr_mem[4] = 32'h00202023;
        
        // lw x5, 0(x0)         # Load from memory[0] to x5
        instr_mem[5] = 32'h00002283;
        
        // add x6, x5, x1       # Load-use hazard for x5: x6 = 15
        instr_mem[6] = 32'h00128333;
        
        // -------------------------
        // Test 3: Load After Store Hazard
        // -------------------------
        // addi x7, x0, 20      # x7 = 20
        instr_mem[7] = 32'h01400393;
        
        // sw x7, 4(x0)         # Store x7 (20) to memory[1]
        instr_mem[8] = 32'h00702223;
        
        // lw x8, 4(x0)         # Load after store hazard: x8 should be 20
        instr_mem[9] = 32'h00402403;
        
        // -------------------------
        // Test 4: Store After Load Hazard
        // -------------------------
        // lw x9, 0(x0)         # Load from memory[0] to x9 (x9 should be 10)
        instr_mem[10] = 32'h00002483;
        
        // sw x9, 8(x0)         # Store x9 to memory[2]
        instr_mem[11] = 32'h00902423;
        
        // -------------------------
        // Test 5: Branch Control Hazards
        // -------------------------
        // addi x10, x0, 5      # x10 = 5
        instr_mem[12] = 32'h00500513;
        
        // addi x11, x0, 5      # x11 = 5
        instr_mem[13] = 32'h00500593;
        
        // beq x10, x11, 8      # Branch if equal (should branch)
        instr_mem[14] = 32'h00b50463;
        
        // addi x12, x0, 1      # Should be skipped
        instr_mem[15] = 32'h00100613;
        
        // addi x13, x0, 30     # Should execute after branch: x13 = 30
        instr_mem[16] = 32'h01E00693;
        
        // -------------------------
        // Test 6: Jump and Link Hazards
        // -------------------------
        // jal x14, 8           # Jump to instr_mem[20], x14 = PC+4
        instr_mem[17] = 32'h0080076f;
        
        // addi x15, x0, 2      # Should be skipped
        instr_mem[18] = 32'h00200793;
        
        // addi x16, x0, 3      # Should execute after branch: x16 = 3
        instr_mem[19] = 32'h00300813;
        
        // addi x17, x14, 0     # x17 = x14 (PC+4 from jal)
        instr_mem[20] = 32'h00070893;

        // Apply reset
        #10 rst = 0;
        
        // Run simulation for a fixed time
        #500;
        
        // Display results
        $display("Hazard Tests Results:");
        
        // Test 1: RAW Data Hazards
        $display("\nTest 1: RAW Data Hazards");
        $display("x1 = %0d (Expected: 5)", cpu_inst.registers.registers[1]);
        $display("x2 = %0d (Expected: 10)", cpu_inst.registers.registers[2]);
        $display("x3 = %0d (Expected: 15)", cpu_inst.registers.registers[3]);
        $display("x4 = %0d (Expected: 10)", cpu_inst.registers.registers[4]);
        
        // Test 2: Load-Use Hazard
        $display("\nTest 2: Load-Use Hazard");
        $display("memory[0] = %0d (Expected: 10)", data_mem[0]);
        $display("x5 = %0d (Expected: 10)", cpu_inst.registers.registers[5]);
        $display("x6 = %0d (Expected: 15)", cpu_inst.registers.registers[6]);
        
        // Test 3: Load After Store Hazard
        $display("\nTest 3: Load After Store Hazard");
        $display("x7 = %0d (Expected: 20)", cpu_inst.registers.registers[7]);
        $display("memory[1] = %0d (Expected: 20)", data_mem[1]);
        $display("x8 = %0d (Expected: 20)", cpu_inst.registers.registers[8]);
        
        // Test 4: Store After Load Hazard
        $display("\nTest 4: Store After Load Hazard");
        $display("x9 = %0d (Expected: 10)", cpu_inst.registers.registers[9]);
        $display("memory[2] = %0d (Expected: 10)", data_mem[2]);
        
        // Test 5: Branch Control Hazards
        $display("\nTest 5: Branch Control Hazards");
        $display("x10 = %0d (Expected: 5)", cpu_inst.registers.registers[10]);
        $display("x11 = %0d (Expected: 5)", cpu_inst.registers.registers[11]);
        $display("x12 = %0d (Expected: 0, skipped by branch)", cpu_inst.registers.registers[12]);
        $display("x13 = %0d (Expected: 30)", cpu_inst.registers.registers[13]);
        
        // Test 6: Jump and Link Hazards
        $display("\nTest 6: Jump and Link Hazards");
        $display("x14 = %0d (Expected: PC+4 of jal)", cpu_inst.registers.registers[14]);
        $display("x15 = %0d (Expected: 0, skipped by jump)", cpu_inst.registers.registers[15]);
        $display("x16 = %0d (Expected: 3)", cpu_inst.registers.registers[16]);
        $display("x17 = %0d (Expected: same as x14)", cpu_inst.registers.registers[17]);
        
        $finish;
    end

endmodule 