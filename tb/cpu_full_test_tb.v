module cpu_full_test_tb;
    reg clk;
    reg rst;
    integer i;
    integer pass_count;
    integer fail_count;

    wire [31:0] instr_addr;
    reg [31:0] instruction;
    wire [31:0] data_addr;
    wire [31:0] data_out;
    reg [31:0] data_in;
    wire mem_write;
    wire mem_read;

    reg [31:0] instr_mem [0:255];
    reg [31:0] data_mem [0:127];

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

    always begin
        #5 clk = ~clk;
    end

    always @(*) begin
        instruction = instr_mem[instr_addr[9:2]];
        if (mem_read)
            data_in = data_mem[data_addr[7:2]];
    end

    always @(posedge clk) begin
        if (mem_write)
            data_mem[data_addr[7:2]] <= data_out;
    end

    initial begin
        $dumpfile("cpu_full_test_tb.vcd");
        $dumpvars(0, cpu_full_test_tb);
    end

    task check_reg;
        input [255:0] name;
        input [4:0] reg_num;
        input [31:0] expected;
        begin
            if (cpu_inst.registers.registers[reg_num] === expected) begin
                $display("PASS: %0s (x%0d) = %0d", name, reg_num, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s (x%0d) = %0d, got %0d", name, reg_num, expected, cpu_inst.registers.registers[reg_num]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_mem;
        input [255:0] name;
        input [31:0] addr;
        input [31:0] expected;
        begin
            if (data_mem[addr[7:2]] === expected) begin
                $display("PASS: %0s Mem[%0d] = %0d", name, addr, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s Mem[%0d] = %0d, got %0d", name, addr, expected, data_mem[addr[7:2]]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        pass_count = 0;
        fail_count = 0;

        for (i = 0; i < 256; i = i + 1)
            instr_mem[i] = 32'h0;
        for (i = 0; i < 128; i = i + 1)
            data_mem[i] = 32'h0;

        // Generated from full_instruction_test.s via risc_assembler.py
        instr_mem[0]  = 32'h0ff00093;
        instr_mem[1]  = 32'h00a00113;
        instr_mem[2]  = 32'hfff00193;
        instr_mem[3]  = 32'h00208233;
        instr_mem[4]  = 32'h402082b3;
        instr_mem[5]  = 32'h0020f333;
        instr_mem[6]  = 32'h0020e3b3;
        instr_mem[7]  = 32'h0020c433;
        instr_mem[8]  = 32'h00300513;
        instr_mem[9]  = 32'h00a094b3;
        instr_mem[10] = 32'h00200513;
        instr_mem[11] = 32'h00a0d5b3;
        instr_mem[12] = 32'h00500513;
        instr_mem[13] = 32'h40a1d633;
        instr_mem[14] = 32'h001126b3;
        instr_mem[15] = 32'h00500793;
        instr_mem[16] = 32'h0027b733;
        instr_mem[17] = 32'h00710813;
        instr_mem[18] = 32'h00f0f893;
        instr_mem[19] = 32'h02016913;
        instr_mem[20] = 32'h00a14993;
        instr_mem[21] = 32'h06412a13;
        instr_mem[22] = 32'h00513a93;
        instr_mem[23] = 32'h00409b13;
        instr_mem[24] = 32'h0040db93;
        instr_mem[25] = 32'h4081dc13;
        instr_mem[26] = 32'h00402023;
        instr_mem[27] = 32'h00502223;
        instr_mem[28] = 32'h00002d03;
        instr_mem[29] = 32'h00402d83;
        instr_mem[30] = 32'h00001e37;
        instr_mem[31] = 32'h00001e97;
        instr_mem[32] = 32'h00000f13;
        instr_mem[33] = 32'h00208463;
        instr_mem[34] = 32'h001f0f13;
        instr_mem[35] = 32'h00209663;
        instr_mem[36] = 32'h00af0f13;
        instr_mem[37] = 32'h0080006f;
        instr_mem[38] = 32'h002f0f13;
        instr_mem[39] = 32'h00114663;
        instr_mem[40] = 32'h00af0f13;
        instr_mem[41] = 32'h0080006f;
        instr_mem[42] = 32'h004f0f13;
        instr_mem[43] = 32'h0020d663;
        instr_mem[44] = 32'h00af0f13;
        instr_mem[45] = 32'h0080006f;
        instr_mem[46] = 32'h008f0f13;
        instr_mem[47] = 32'h00116663;
        instr_mem[48] = 32'h00af0f13;
        instr_mem[49] = 32'h0080006f;
        instr_mem[50] = 32'h010f0f13;
        instr_mem[51] = 32'h0020f663;
        instr_mem[52] = 32'h00af0f13;
        instr_mem[53] = 32'h0080006f;
        instr_mem[54] = 32'h020f0f13;
        instr_mem[55] = 32'h00109463;
        instr_mem[56] = 32'h040f0f13;
        instr_mem[57] = 32'h0020c463;
        instr_mem[58] = 32'h080f0f13;
        instr_mem[59] = 32'h00108663;
        instr_mem[60] = 32'h00af0f13;
        instr_mem[61] = 32'h0040006f;
        instr_mem[62] = 32'h0021d463;
        instr_mem[63] = 32'h100f0f13;
        instr_mem[64] = 32'h0021e463;
        instr_mem[65] = 32'h200f0f13;
        instr_mem[66] = 32'h00317463;
        instr_mem[67] = 32'h400f0f13;
        instr_mem[68] = 32'h00800fef;
        instr_mem[69] = 32'h3e8f0f13;
        instr_mem[70] = 32'h00000c97;
        instr_mem[71] = 32'h010c8c93;
        instr_mem[72] = 32'h000c8fe7;
        instr_mem[73] = 32'h3e8f0f13;
        instr_mem[74] = 32'h00000c93;
        instr_mem[75] = 32'h004ca023;
        instr_mem[76] = 32'h005ca223;
        instr_mem[77] = 32'h0000006f;

        // Apply reset
        #10 rst = 0;
        #4000;

        $display("\n========================================");
        $display("  Full Instruction Set Test Results");
        $display("========================================\n");

        $display("--- R-type Instructions (10) ---");
        check_reg("ADD  x4",  4,  32'd265);
        check_reg("SUB  x5",  5,  32'd245);
        check_reg("AND  x6",  6,  32'd10);
        check_reg("OR   x7",  7,  32'd255);
        check_reg("XOR  x8",  8,  32'd245);
        check_reg("SLL  x9",  9,  32'd2040);
        check_reg("SRL  x11", 11, 32'd63);
        check_reg("SRA  x12", 12, 32'hFFFFFFFF);
        check_reg("SLT  x13", 13, 32'd1);
        check_reg("SLTU x14", 14, 32'd1);

        $display("\n--- I-type ALU Instructions (9) ---");
        check_reg("ADDI  x16", 16, 32'd17);
        check_reg("ANDI  x17", 17, 32'd15);
        check_reg("ORI   x18", 18, 32'd42);
        check_reg("XORI  x19", 19, 32'd0);
        check_reg("SLTI  x20", 20, 32'd1);
        check_reg("SLTIU x21", 21, 32'd0);
        check_reg("SLLI  x22", 22, 32'd4080);
        check_reg("SRLI  x23", 23, 32'd15);
        check_reg("SRAI  x24", 24, 32'hFFFFFFFF);

        $display("\n--- Memory Instructions (SW, LW) ---");
        check_reg("LW x26", 26, 32'd265);
        check_reg("LW x27", 27, 32'd245);
        check_mem("SW Mem[0]", 32'h0, 32'd265);
        check_mem("SW Mem[4]", 32'h4, 32'd245);

        $display("\n--- Upper Immediate Instructions (LUI, AUIPC) ---");
        check_reg("LUI   x28", 28, 32'd4096);
        // auipc x29, 4096 at addr=124: x29 = 124 + 4096 = 4220
        check_reg("AUIPC x29", 29, 32'd4220);

        $display("\n--- Branch Instructions (6) ---");
        // 1+2+4+8+16+32+64+128+0+256+512+1024 = 2047
        check_reg("BRANCH x30", 30, 32'd2047);

        $display("\n--- Jump Instructions (JAL, JALR) ---");
        // JAL at idx=68 (addr=272): x31 = 272+4 = 276
        // Then JALR at idx=72 (addr=288) overwrites x31 = 288+4 = 292
        check_reg("JALR x31", 31, 32'd292);
        // Verify JALR jumped correctly (skipped instr should not execute)
        check_reg("JALR skip (x30)", 30, 32'd2047);

        $display("\n========================================");
        $display("  Summary: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("========================================\n");

        if (fail_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED - review output above");

        $finish;
    end

endmodule