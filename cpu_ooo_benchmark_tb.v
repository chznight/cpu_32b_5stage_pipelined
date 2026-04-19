module cpu_ooo_benchmark_tb;
    // Clock and reset
    reg clk;
    reg rst;
    integer i;
    integer cycle_count;
    integer finish_cycle;
    reg benchmark_done_reported;

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
        instruction = instr_mem[instr_addr[7:2]];

        if (mem_read)
            data_in = data_mem[data_addr[7:2]];
        else
            data_in = 32'h0;
    end

    always @(posedge clk) begin
        if (mem_write)
            data_mem[data_addr[7:2]] <= data_out;
    end

    // Count cycles after reset deassertion and report when x20 marks completion.
    initial begin
        cycle_count = 0;
        finish_cycle = -1;
        benchmark_done_reported = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            cycle_count = 0;
            finish_cycle = -1;
            benchmark_done_reported = 0;
        end else begin
            cycle_count = cycle_count + 1;
            if (cpu_inst.registers.registers[20] == 32'd1 && !benchmark_done_reported) begin
                benchmark_done_reported = 1;
                finish_cycle = cycle_count;
                $display("OoO benchmark finished after %0d clock cycles", cycle_count);
            end
        end
    end

    initial begin
        $dumpfile("cpu_ooo_benchmark_tb.vcd");
        $dumpvars(0, cpu_ooo_benchmark_tb);
    end

    initial begin
        clk = 0;
        rst = 1;

        for (i = 0; i < 64; i = i + 1) begin
            instr_mem[i] = 32'h0;
            data_mem[i] = 32'h0;
        end

        // Program assembled from ooo_benchmark.s using risc_assembler.py
        instr_mem[0] = 32'h7d000093;  // addi x1,  x0, 2000
        instr_mem[1] = 32'h00100513;  // addi x10, x0, 1
        instr_mem[2] = 32'h00200593;  // addi x11, x0, 2
        instr_mem[3] = 32'h00300613;  // addi x12, x0, 3
        instr_mem[4] = 32'h00400693;  // addi x13, x0, 4
        instr_mem[5] = 32'h00500713;  // addi x14, x0, 5
        instr_mem[6] = 32'h00600793;  // addi x15, x0, 6
        instr_mem[7] = 32'h00700813;  // addi x16, x0, 7
        instr_mem[8] = 32'h00800893;  // addi x17, x0, 8
        instr_mem[9] = 32'h00900913;  // addi x18, x0, 9
        instr_mem[10] = 32'h00a00993; // addi x19, x0, 10
        instr_mem[11] = 32'h00000013; // addi x0, x0, 0
        instr_mem[12] = 32'h00b50533; // add x10, x10, x11
        instr_mem[13] = 32'h00d60633; // add x12, x12, x13
        instr_mem[14] = 32'h00f70733; // add x14, x14, x15
        instr_mem[15] = 32'h01180833; // add x16, x16, x17
        instr_mem[16] = 32'h01390933; // add x18, x18, x19
        instr_mem[17] = 32'hfff08093; // addi x1, x1, -1
        instr_mem[18] = 32'hfe0094e3; // bne x1, x0, loop
        instr_mem[19] = 32'h00c50c33; // add x24, x10, x12
        instr_mem[20] = 32'h01070cb3; // add x25, x14, x16
        instr_mem[21] = 32'h01890d33; // add x26, x18, x24
        instr_mem[22] = 32'h01ac8db3; // add x27, x25, x26
        instr_mem[23] = 32'h01b02023; // sw x27, 0(x0)
        instr_mem[24] = 32'h00100a13; // addi x20, x0, 1
        instr_mem[25] = 32'h0000006f; // jal x0, done

        #10 rst = 0;

        // 2000 loop iterations plus branch penalties can take substantially more than 20k cycles here.
        while (!benchmark_done_reported && cycle_count < 50000)
            @(posedge clk);

        #20;

        if (!benchmark_done_reported)
            $display("OoO benchmark completion not observed before timeout (x20 = %0d)",
                     cpu_inst.registers.registers[20]);

        if (finish_cycle >= 0)
            $display("Total clock cycles after reset deassert: %0d", finish_cycle);
        else
            $display("Total clock cycles after reset deassert: %0d", cycle_count);
        $display("Final checksum at data_mem[0] = %0d (Expected: 60025)", data_mem[0]);
        $display("x20 = %0d (Expected: 1)", cpu_inst.registers.registers[20]);

        if (benchmark_done_reported && data_mem[0] == 32'd60025 && cpu_inst.registers.registers[20] == 32'd1)
            $display("PASS: OoO benchmark completed successfully");
        else
            $display("FAIL: OoO benchmark did not complete as expected");

        $finish;
    end
endmodule
