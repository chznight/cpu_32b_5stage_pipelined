module cpu_fibonacci_tb;
    // Clock and reset
    reg clk;
    reg rst;
    integer i;

    localparam integer MEM_DEPTH = 64;
    
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

    // Separate instruction/data SRAMs match the CPU's Harvard-style memory ports.
    bsram #(
        .DATA_WIDTH(32),
        .DEPTH(MEM_DEPTH),
        .INIT_FILE("tb/fibonacci_0.hex")
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
        .DEPTH(MEM_DEPTH)
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

        // Apply reset
        #10 rst = 0;
        
        // Run simulation for a fixed time
        // Should be long enough for the program to complete 20 Fibonacci numbers
        #2500;
        
        // Display results
        $display("Fibonacci Sequence:");
        for (i = 0; i < 20; i = i + 1) begin
            $display("Fib[%0d] = %0d", i, data_sram.mem[i]);
        end
        
        // The expected Fibonacci sequence starts with 1, 1, 2, 3, 5, 8, 13, 21, 34, 55...
        if (data_sram.mem[0] == 1 && data_sram.mem[1] == 1 && data_sram.mem[2] == 2 &&
            data_sram.mem[3] == 3 && data_sram.mem[4] == 5 && data_sram.mem[5] == 8 &&
            data_sram.mem[6] == 13 && data_sram.mem[7] == 21 && data_sram.mem[8] == 34 &&
            data_sram.mem[9] == 55 && data_sram.mem[10] == 89 && data_sram.mem[11] == 144 &&
            data_sram.mem[12] == 233 && data_sram.mem[13] == 377 && data_sram.mem[14] == 610 &&
            data_sram.mem[15] == 987 && data_sram.mem[16] == 1597 && data_sram.mem[17] == 2584 &&
            data_sram.mem[18] == 4181 && data_sram.mem[19] == 6765) begin
            $display("PASS: First 20 Fibonacci numbers calculated correctly");
        end else begin
            $display("FAIL: Fibonacci sequence incorrect");
            $display("Expected: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ..., 6765");
            $display("Got first 10: %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d...",
                     data_sram.mem[0], data_sram.mem[1], data_sram.mem[2], data_sram.mem[3], data_sram.mem[4],
                     data_sram.mem[5], data_sram.mem[6], data_sram.mem[7], data_sram.mem[8], data_sram.mem[9]);
            $display("Got Fib[19]: %0d", data_sram.mem[19]);
        end
        
        $finish;
    end
endmodule 
