module cpu_tb;
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
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end
    // Test program
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Initialize instruction memory with a simple test program
        
        // addi x1, x0, 10      # x1 = 10
        instr_mem[0] = 32'h00A00093;
        
        // addi x2, x0, 20      # x2 = 20
        instr_mem[1] = 32'h01400113;
        
        // add x3, x1, x2       # x3 = x1 + x2 = 30
        instr_mem[2] = 32'h002081B3;

        // sub x4, x2, x1       # x4 = x2 - x1 = 10
        instr_mem[3] = 32'h40110233;
        
        // sw x3, 0(x0)         # Store x3 to memory address 0
        instr_mem[4] = 32'h00302023;
        
        // lw x5, 0(x0)         # Load from memory address 0 to x5
        instr_mem[5] = 32'h00002283;
        
        // beq x1, x4, 8        # Branch if x1 equals x4 (should branch, as both are 10)
        instr_mem[6] = 32'h00408463;
        
        // addi x6, x0, 1       # Should be skipped by the branch
        instr_mem[7] = 32'h00100313;
        
        // addi x7, x0, 7       # Should be executed after the branch
        instr_mem[8] = 32'h00700393;

        // Initialize data memory

        for (i = 0; i < 64; i = i + 1) begin
            data_mem[i] = 32'h0;
        end
        // Apply reset
        #10 rst = 0;
        
        // Run simulation for a fixed time
        #300;
        
        // Display results
        $display("Register file contents after execution:");
        $display("x1 = %d (Expected: 10)", cpu_inst.registers.registers[1]);
        $display("x2 = %d (Expected: 20)", cpu_inst.registers.registers[2]);
        $display("x3 = %d (Expected: 30)", cpu_inst.registers.registers[3]);
        $display("x4 = %d (Expected: 10)", cpu_inst.registers.registers[4]);
        $display("x5 = %d (Expected: 30)", cpu_inst.registers.registers[5]);
        $display("x6 = %d (Expected: 0, skipped by branch)", cpu_inst.registers.registers[6]);
        $display("x7 = %d (Expected: 7)", cpu_inst.registers.registers[7]);
        
        $display("Data memory location 0 = %d (Expected: 30)", data_mem[0]);
        
        $finish;
    end

endmodule 