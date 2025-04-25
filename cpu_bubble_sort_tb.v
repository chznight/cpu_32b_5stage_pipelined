module cpu_bubble_sort_tb;
    // Clock and reset
    reg clk;
    reg rst;
    integer i;
    integer sorted = 1;
    integer seed = 42; // Seed for random number generation
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
    
    // Data memory (RAM) - Sized to accommodate 50 elements
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
        $dumpfile("cpu_bubble_sort_tb.vcd");
        $dumpvars(0, cpu_bubble_sort_tb);
    end

    // Test program for bubble sort
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        
        // Initialize instruction memory with bubble sort program
        // Program will sort an array of integers in memory
        
        // Program logic:
        // - Memory address 0 contains the length of the array (50)
        // - Memory addresses 1-50 contain the unsorted array
        // - The sorted array will be in the same locations after execution
        // - Register usage:
        //   x1: array base address (4, after the length word)
        //   x2: outer loop counter (i)
        //   x3: inner loop counter (j)
        //   x4: array length
        //   x5: temporary for address calculations
        //   x6, x7: values being compared
        //   x8: array length - 1
        //   x9: array base address (constant)
        
        // Load test array into memory
        data_mem[0] = 32'd50;  // Array length - changed to 50
        
        // Generate 50 random elements
        for (i = 1; i <= 50; i = i + 1) begin
            // Generate pseudo-random numbers between 1 and 1000
            data_mem[i] = ($urandom(seed) % 1000) + 1;
        end
        
        $display("Unsorted array (50 elements):");
        for (i = 0; i < 50; i = i + 1) begin
            $display("data[%0d] = %0d", i, data_mem[i+1]);
        end

        // addi x1, x0, 4       # Initialize base address (skip length word)
        instr_mem[0] = 32'h00400093;
        // lw x4, -4(x1)        # Load array length from memory address 0
        instr_mem[1] = 32'hffc0a203;
        // addi x9, x1, 0       # Save base address in x9
        instr_mem[2] = 32'h00008493;
        // addi x8, x4, -1      # n-1 for loop bound
        instr_mem[3] = 32'hfff20413;
        // addi x2, x0, 0       # Initialize outer loop counter i=0
        instr_mem[4] = 32'h00000113;
        
        // OUTER_LOOP:
        // bge x2, x8, SORT_DONE # If i >= n-1, sorting is done
        instr_mem[5] = 32'h04815063;
        // addi x3, x0, 0       # Initialize inner loop counter j=0
        instr_mem[6] = 32'h00000193;
        
        // INNER_LOOP:
        // sub x5, x8, x2       # Calculate n-1-i
        instr_mem[7] = 32'h402402b3;
        // bge x3, x5, OUTER_INCREMENT # If j >= n-1-i, inner loop done
        instr_mem[8] = 32'h0251d663;
        // slli x5, x3, 2       # j*4 (word offset)
        instr_mem[9] = 32'h00219293;
        // add x5, x1, x5       # base_addr + j*4
        instr_mem[10] = 32'h005082b3;
        // lw x6, 0(x5)         # Load data[j]
        instr_mem[11] = 32'h0002a303;
        // lw x7, 4(x5)         # Load data[j+1]
        instr_mem[12] = 32'h0042a383;
        // slt x10, x7, x6      # x10 = 1 if x7 < x6 (need to swap)
        instr_mem[13] = 32'h0063a533;
        // beq x10, x0, SKIP_SWAP # If x10 == 0, skip swap (meaning x6 <= x7)
        instr_mem[14] = 32'h00050663;
        // sw x7, 0(x5)         # Store data[j+1] to data[j]
        instr_mem[15] = 32'h0072a023;
        // sw x6, 4(x5)         # Store data[j] to data[j+1]
        instr_mem[16] = 32'h0062a223;
        
        // SKIP_SWAP:
        // addi x3, x3, 1       # j++
        instr_mem[17] = 32'h00118193;
        // jal x0, INNER_LOOP   # Jump back to inner loop
        instr_mem[18] = 32'hfd5ff06f;
        
        // OUTER_INCREMENT:
        // addi x2, x2, 1       # i++
        instr_mem[19] = 32'h00110113;
        // jal x0, OUTER_LOOP   # Jump back to outer loop
        instr_mem[20] = 32'hfc5ff06f;
        
        // SORT_DONE:
        // (program ends)
        
        // Apply reset
        #10 rst = 0;
        
        // Run simulation for bubble sort with 50 elements
        #400000;
        
        // Display the results
        $display("Bubble Sort Test Results:");
        $display("Sorted array (first 25 and last 25 elements):");
        
        // Display first 25 elements
        for (i = 0; i < 25; i = i + 1) begin
            $display("data[%0d] = %0d", i, data_mem[i+1]);
        end
        
        $display("...");
        
        // Display last 25 elements
        for (i = 25; i < 50; i = i + 1) begin
            $display("data[%0d] = %0d", i, data_mem[i+1]);
        end
        
        // Verify the sorting worked by checking if the array is in ascending order
        $display("\nVerification:");
        begin
            sorted = 1;
            for (i = 1; i < 50; i = i + 1) begin
                if (data_mem[i] > data_mem[i+1]) begin
                    sorted = 0;
                    $display("FAIL: Array not sorted correctly at index %0d (%0d > %0d)", 
                             i-1, data_mem[i], data_mem[i+1]);
                    i = 50; // Break the loop
                end
            end
            
            if (sorted) begin
                $display("PASS: Array sorted correctly");
            end else begin
                $display("FAIL: Array not sorted correctly");
            end
        end
        
        $finish;
    end

endmodule 