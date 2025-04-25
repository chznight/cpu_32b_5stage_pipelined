module cpu_fibonacci_tb;
    // Clock and reset
    reg clk;
    reg rst;
    integer i, f;
    
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
        else
            data_in = 32'h0;
    end
    
    // Handle memory writes
    always @(posedge clk) begin
        if (mem_write)
            data_mem[data_addr[7:2]] <= data_out;
    end

    // Create VCD file for waveform analysis
    initial begin
        $dumpfile("cpu_fibonacci_tb.vcd");
        $dumpvars(0, cpu_fibonacci_tb);
    end

    // Test program for Fibonacci sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Initialize instruction memory with Fibonacci program from fibonacci.bin
        // The initialization is based on the actual binary values from the file
        instr_mem[0] = 32'h00100093; // addi x1, x0, 1
        instr_mem[1] = 32'h00100113; // addi x2, x0, 1
        instr_mem[2] = 32'h00000193; // addi x3, x0, 0
        instr_mem[3] = 32'h01400213; // addi x4, x0, 20
        instr_mem[4] = 32'h00000293; // addi x5, x0, 0
        instr_mem[5] = 32'h0011a023; // sw x1, 0(x3)
        instr_mem[6] = 32'h00418193; // addi x3, x3, 4
        instr_mem[7] = 32'h0021a023; // sw x2, 0(x3)
        instr_mem[8] = 32'h00418193; // addi x3, x3, 4
        instr_mem[9] = 32'h00228293; // addi x5, x5, 2
        instr_mem[10] = 32'h02428063; // beq x5, x4, done
        instr_mem[11] = 32'h00208333; // add x6, x1, x2
        instr_mem[12] = 32'h0061a023; // sw x6, 0(x3)
        instr_mem[13] = 32'h00418193; // addi x3, x3, 4
        instr_mem[14] = 32'h00010093; // addi x1, x2, 0
        instr_mem[15] = 32'h00030113; // addi x2, x6, 0
        instr_mem[16] = 32'h00128293; // addi x5, x5, 1
        instr_mem[17] = 32'hfe5ff06f; // jal x0, fibonacci_loop
        instr_mem[18] = 32'h00100393; // addi x7, x0, 1
        instr_mem[19] = 32'h0000006f; // jal x0, halt_loop

        // Initialize data memory to zeros
        for (i = 0; i < 64; i = i + 1) begin
            data_mem[i] = 32'h0;
        end

        // Apply reset
        #10 rst = 0;
        
        // Run simulation for a fixed time
        // Should be long enough for the program to complete 20 Fibonacci numbers
        #2100;
        
        // Display results
        $display("Fibonacci Sequence:");
        for (i = 0; i < 20; i = i + 1) begin
            $display("Fib[%0d] = %0d", i, data_mem[i]);
        end
        
        // Verification of the first 10 Fibonacci numbers
        // The expected Fibonacci sequence starts with 1, 1, 2, 3, 5, 8, 13, 21, 34, 55...
        if (data_mem[0] == 1 && data_mem[1] == 1 && data_mem[2] == 2 && 
            data_mem[3] == 3 && data_mem[4] == 5 && data_mem[5] == 8 && 
            data_mem[6] == 13 && data_mem[7] == 21 && data_mem[8] == 34 && 
            data_mem[9] == 55) begin
            $display("PASS: First 10 Fibonacci numbers calculated correctly");
        end else begin
            $display("FAIL: Fibonacci sequence incorrect");
            $display("Expected: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55...");
            $display("Got: %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d...",
                     data_mem[0], data_mem[1], data_mem[2], data_mem[3], data_mem[4],
                     data_mem[5], data_mem[6], data_mem[7], data_mem[8], data_mem[9]);
        end
        
        $finish;
    end
endmodule 