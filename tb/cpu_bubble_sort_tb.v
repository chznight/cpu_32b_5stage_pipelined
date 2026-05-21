module cpu_bubble_sort_tb;
    parameter integer ARRAY_LEN = 200;

    // Clock and reset
    reg clk;
    reg rst;
    integer i;
    integer sorted = 1;
    integer seed = 42; // Seed for random number generation
    integer cycle_count;
    integer finish_cycle;
    reg sort_done_reported;
    localparam DISPLAY_EDGE_COUNT = (ARRAY_LEN < 25) ? ARRAY_LEN : 25;
    localparam TIMEOUT_CYCLES = (ARRAY_LEN * ARRAY_LEN * 100) + 10000;
    localparam INSTR_MEM_DEPTH = 128;
    localparam DATA_MEM_DEPTH = ARRAY_LEN + 1;
    // Memory interface
    wire [31:0] instr_addr;
    wire [31:0] instruction;
    wire [31:0] data_addr;
    wire [31:0] data_out;
    wire [31:0] data_in;
    wire mem_write;
    wire mem_read;

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

    // Separate block SRAMs match the CPU's instruction and data memory ports.
    bsram #(
        .DATA_WIDTH(32),
        .DEPTH(INSTR_MEM_DEPTH),
        .INIT_FILE("tb/bubble_sort.hex")
    ) instr_sram (
        .clk(clk),
        .rst(rst),
        .addr(instr_addr),
        .data_in(32'b0),
        .data_out(instruction),
        .we(1'b0),
        .re(1'b1)
    );

    bsram #(
        .DATA_WIDTH(32),
        .DEPTH(DATA_MEM_DEPTH)
    ) data_sram (
        .clk(clk),
        .rst(rst),
        .addr(data_addr),
        .data_in(data_out),
        .data_out(data_in),
        .we(mem_write),
        .re(mem_read)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Count clock cycles after reset; print once when sort marks done (x20 = 1)
    initial begin
        cycle_count = 0;
        finish_cycle = -1;
        sort_done_reported = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            cycle_count = 0;
            finish_cycle = -1;
            sort_done_reported = 0;
        end else begin
            cycle_count = cycle_count + 1;
            if (cpu_inst.registers.registers[20] == 32'd1 && !sort_done_reported) begin
                sort_done_reported = 1;
                finish_cycle = cycle_count;
                $display("Sort finished after %0d clock cycles", cycle_count);
            end
        end
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
        // - Memory address 0 contains the length of the array
        // - Memory addresses 1-ARRAY_LEN contain the unsorted array
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
        data_sram.mem[0] = ARRAY_LEN;
        
        // Generate random elements
        for (i = 1; i <= ARRAY_LEN; i = i + 1) begin
            // Generate pseudo-random numbers between 1 and 1000
            data_sram.mem[i] = ($urandom(seed) % 1000) + 1;
        end
        
        $display("Unsorted array (%0d elements):", ARRAY_LEN);
        for (i = 0; i < ARRAY_LEN; i = i + 1) begin
            $display("data[%0d] = %0d", i, data_sram.mem[i+1]);
        end

        // Apply reset
        #10 rst = 0;
        
        // Run simulation until the program marks completion or the timeout expires.
        while (!sort_done_reported && cycle_count < TIMEOUT_CYCLES) begin
            @(posedge clk);
        end

        if (!sort_done_reported)
            $display("Sort completion not observed before timeout (x20 = %0d)",
                     cpu_inst.registers.registers[20]);
        if (finish_cycle >= 0)
            $display("Total clock cycles after reset deassert: %0d", finish_cycle);
        else
            $display("Total clock cycles after reset deassert: %0d", cycle_count);
        $display("x20 = %0d (Expected: 1)", cpu_inst.registers.registers[20]);
        // Display the results
        $display("Bubble Sort Test Results:");
        $display("Sorted array (first 25 and last 25 elements):");
        
        // Display first 25 elements
        for (i = 0; i < DISPLAY_EDGE_COUNT; i = i + 1) begin
            $display("data[%0d] = %0d", i, data_sram.mem[i+1]);
        end
        
        $display("...");
        
        // Display last 25 elements
        for (i = ARRAY_LEN - DISPLAY_EDGE_COUNT; i < ARRAY_LEN; i = i + 1) begin
            $display("data[%0d] = %0d", i, data_sram.mem[i+1]);
        end
        
        // Verify the sorting worked by checking if the array is in ascending order
        $display("\nVerification:");
        begin
            sorted = 1;
            for (i = 1; i < ARRAY_LEN; i = i + 1) begin
                if (data_sram.mem[i] > data_sram.mem[i+1]) begin
                    sorted = 0;
                    $display("FAIL: Array not sorted correctly at index %0d (%0d > %0d)", 
                             i-1, data_sram.mem[i], data_sram.mem[i+1]);
                    i = ARRAY_LEN; // Break the loop
                end
            end
            
            if (sorted) begin
                $display("PASS: Array sorted correctly");
            end else begin
                $display("FAIL: Array not sorted correctly");
            end
        end
        $display("PC %0d", cpu_inst.PC);
        $display("x2 %0d", cpu_inst.registers.registers[2]);
        $display("x3 %0d", cpu_inst.registers.registers[3]);
        $display("x4 %0d", cpu_inst.registers.registers[4]);
        $display("x5 %0d", cpu_inst.registers.registers[5]);
        $display("x6 %0d", cpu_inst.registers.registers[6]);
        $finish;
    end
endmodule 
