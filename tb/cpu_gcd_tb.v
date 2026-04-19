module cpu_gcd_tb;
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
        $dumpfile("cpu_gcd_tb.vcd");
        $dumpvars(0, cpu_gcd_tb);
    end

    // Test program for GCD calculation
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Initialize instruction memory with GCD program
        // Program will calculate GCD of multiple pairs and store results in memory
        
        // Program logic:
        // - Memory address 0 contains the number of pairs (5)
        // - Starting from memory address 1, consecutive pairs of numbers
        // - Results will be stored after the pairs
        // - x1 will hold number A
        // - x2 will hold number B
        // - x3 will hold the result register
        // - x4 will track memory address for reading pairs and storing results
        // - x5 will hold the number of pairs to process
        // - x6 will be used as a counter
        
        // Load test pairs into memory before starting
        data_mem[0] = 32'd5;  // Number of pairs to test
        
        // Test pairs
        data_mem[1] = 32'd48;  data_mem[2] = 32'd36;   // GCD = 12
        data_mem[3] = 32'd101; data_mem[4] = 32'd13;   // GCD = 1  
        data_mem[5] = 32'd128; data_mem[6] = 32'd32;   // GCD = 32
        data_mem[7] = 32'd27;  data_mem[8] = 32'd9;    // GCD = 9
        data_mem[9] = 32'd56;  data_mem[10] = 32'd42;  // GCD = 14
        
        // Result locations will be data_mem[11] through data_mem[15]
        
        // addi x4, x0, 0       # Initialize memory pointer to address 0
        instr_mem[0] = 32'h00000213;
        // lw x5, 0(x4)         # Load number of pairs to process
        instr_mem[1] = 32'h00022283;
        // addi x4, x4, 4       # Increment memory pointer to the first number
        instr_mem[2] = 32'h00420213;
        // addi x6, x0, 0       # Initialize counter
        instr_mem[3] = 32'h00000313;
        // addi x7, x0, 44      # Initialize counter
        instr_mem[4] = 32'h02c00393;
        // PROCESS_PAIR:
        // lw x1, 0(x4)         # Load first number
        instr_mem[5] = 32'h00022083;
        // addi x4, x4, 4       # Increment memory pointer
        instr_mem[6] = 32'h00420213;
        // lw x2, 0(x4)         # Load second number
        instr_mem[7] = 32'h00022103;
        // addi x4, x4, 4       # Increment memory pointer
        instr_mem[8] = 32'h00420213;
        // GCD_LOOP:
        // beq x1, x2, GCD_DONE # If A == B, we found the GCD
        instr_mem[9] = 32'h00208c63;
        // blt x1, x2, A_LESS   # If A < B, go to A_LESS
        instr_mem[10] = 32'h0020c663;
        // sub x1, x1, x2       # A = A - B
        instr_mem[11] = 32'h402080b3;
        // beq x0, x0, GCD_LOOP # Always branch back to GCD_LOOP
        instr_mem[12] = 32'hfe000ae3;
        // A_LESS:
        // sub x2, x2, x1       # B = B - A
        instr_mem[13] = 32'h40110133;
        // beq x0, x0, GCD_LOOP # Always branch back to GCD_LOOP
        instr_mem[14] = 32'hfe0006e3;
        // GCD_DONE:
        // sw x1, 0(x7)         # Store result to memory
        instr_mem[15] = 32'h0013a023;
        // addi x7, x7, 4       # Increment memory pointer
        instr_mem[16] = 32'h00438393;
        // addi x6, x6, 1       # Increment counter
        instr_mem[17] = 32'h00130313;
        // blt x6, x5, PROCESS_PAIR # If counter < number of pairs, process next pair
        instr_mem[18] = 32'hfc5346e3;

        // Apply reset
        #10 rst = 0;
        
        // Run simulation for a fixed time
        #5000;
        
        // Display results
        $display("GCD Test Results:");
        for (i = 0; i < 5; i = i + 1) begin
            $display("GCD(%0d, %0d) = %0d", data_mem[i*2+1], data_mem[i*2+2], data_mem[i+11]);
        end
        
        // Verify the expected GCD values
        $display("\nVerification:");
        if (data_mem[11] == 12 && data_mem[12] == 1 && data_mem[13] == 32 && 
            data_mem[14] == 9 && data_mem[15] == 14) begin
            $display("PASS: All GCD calculations correct");
        end else begin
            $display("FAIL: GCD calculations incorrect");
            for (i = 0; i < 5; i = i + 1) begin
                if (i == 0 && data_mem[11] != 12) $display("Pair 1: Expected 12, got %0d", data_mem[11]);
                if (i == 1 && data_mem[12] != 1)  $display("Pair 2: Expected 1, got %0d", data_mem[12]);
                if (i == 2 && data_mem[13] != 32) $display("Pair 3: Expected 32, got %0d", data_mem[13]);
                if (i == 3 && data_mem[14] != 9)  $display("Pair 4: Expected 9, got %0d", data_mem[14]);
                if (i == 4 && data_mem[15] != 14) $display("Pair 5: Expected 14, got %0d", data_mem[15]);
            end
        end
        
        $finish;
    end

endmodule 