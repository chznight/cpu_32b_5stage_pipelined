module cpu_fibonacci_tb;
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
        $dumpfile("cpu_fibonacci_tb.vcd");
        $dumpvars(0, cpu_fibonacci_tb);
    end

    // Test program for Fibonacci sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Initialize instruction memory with Fibonacci program
        // Calculate first 20 Fibonacci numbers and store them in memory
        
        // Program logic:
        // - x1 will hold the count (20)
        // - x2 will hold first Fibonacci number (0)
        // - x3 will hold second Fibonacci number (1)
        // - x4 will be the memory address to store results
        // - x5 will be the loop counter
        // - x6 will hold the next Fibonacci number (x2 + x3)
        
        // addi x1, x0, 20      # Number of Fibonacci values to generate
        instr_mem[0] = 32'h01400093;
        
        // addi x2, x0, 0       # First Fibonacci value = 0
        instr_mem[1] = 32'h00000113;
        
        // addi x3, x0, 1       # Second Fibonacci value = 1
        instr_mem[2] = 32'h00100193;
        
        // addi x4, x0, 0       # Memory address starts at 0
        instr_mem[3] = 32'h00000213;
        
        // addi x5, x0, 0       # Loop counter starts at 0
        instr_mem[4] = 32'h00000293;
        
        // Loop start:
        // sw x2, 0(x4)         # Store current Fibonacci value to memory
        instr_mem[5] = 32'h00222023;
        
        // addi x5, x5, 1       # Increment loop counter
        instr_mem[6] = 32'h00128293;
        
        // addi x4, x4, 4       # Increment memory address
        instr_mem[7] = 32'h00420213;
        
        // add x6, x2, x3       # Calculate next Fibonacci value
        instr_mem[8] = 32'h00310333;
        
        // addi x2, x3, 0       # Shift values: x2 = x3
        instr_mem[9] = 32'h00018113;
        
        // addi x3, x6, 0       # Shift values: x3 = x6
        instr_mem[10] = 32'h00030193;
        
        // blt x5, x1, -24      # Loop if counter < limit (branch to Loop start)
        instr_mem[11] = 32'hfe12c4e3;  // Offset = -24 bytes = -6 instructions
        
        // Stop program

        // Initialize data memory
        for (i = 0; i < 64; i = i + 1) begin
            data_mem[i] = 32'h0;
        end

        // Apply reset
        #10 rst = 0;
        
        // Run simulation for a fixed time
        #5000;
        
        // Display results
        $display("Fibonacci Sequence (First 20 numbers):");
        for (i = 0; i < 20; i = i + 1) begin
            $display("Fib[%0d] = %0d", i, data_mem[i]);
        end
        
        // Verify the expected Fibonacci sequence values
        $display("\nVerification:");
        if (data_mem[0] == 0 && data_mem[1] == 1 && data_mem[2] == 1 && 
            data_mem[3] == 2 && data_mem[4] == 3 && data_mem[5] == 5 && 
            data_mem[6] == 8 && data_mem[7] == 13 && data_mem[8] == 21 && 
            data_mem[9] == 34 && data_mem[10] == 55 && data_mem[11] == 89 &&
            data_mem[12] == 144 && data_mem[13] == 233 && data_mem[14] == 377 &&
            data_mem[15] == 610 && data_mem[16] == 987 && data_mem[17] == 1597 &&
            data_mem[18] == 2584 && data_mem[19] == 4181) begin
            $display("PASS: Fibonacci sequence calculated correctly");
        end else begin
            $display("FAIL: Fibonacci sequence incorrect");
        end
        
        $finish;
    end

endmodule 