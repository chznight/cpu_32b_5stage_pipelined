module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_op,
    output reg [31:0] result,
    output wire zero
);
    
    // ALU Operation codes
    parameter ALU_ADD  = 4'b0000;
    parameter ALU_SUB  = 4'b0001;
    parameter ALU_AND  = 4'b0010;
    parameter ALU_OR   = 4'b0011;
    parameter ALU_XOR  = 4'b0100;
    parameter ALU_SLL  = 4'b0101; // Shift left logical
    parameter ALU_SRL  = 4'b0110; // Shift right logical
    parameter ALU_SRA  = 4'b0111; // Shift right arithmetic
    parameter ALU_SLT  = 4'b1000; // Set less than (signed)
    parameter ALU_SLTU = 4'b1001; // Set less than (unsigned)
    parameter ALU_LUI  = 4'b1010; // Load upper immediate (pass b)
    
    // Operation result
    always @(*) begin
        case(alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_XOR:  result = a ^ b;
            ALU_SLL:  result = a << b[4:0];
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0];
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            ALU_SLTU: result = (a < b) ? 32'b1 : 32'b0;
            ALU_LUI:  result = b;
            default:  result = a; // Default to pass a
        endcase
    end
    
    // Zero flag (used for branches)
    assign zero = (result == 32'b0);

endmodule 