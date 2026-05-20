module bsram #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 1024,

    // Optional init file. Example: "program.hex"
    parameter string INIT_FILE = ""
)(
    input  wire                  clk,
    input  wire                  rst,

    input  wire [31:0]           addr,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out,

    input  wire                  we,
    input  wire                  re
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] read_addr;

    wire [ADDR_WIDTH-1:0] word_addr;
    // Convert byte address to word index (drop addr[1:0] for 32-bit words).
    assign word_addr = addr[ADDR_WIDTH+1:2];

    // Memory initialization happens at FPGA configuration / simulation start,
    // not during reset.
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_addr <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (we) begin
                mem[word_addr] <= data_in;
            end else if (re) begin
                read_addr <= word_addr;
            end
        end
    end

    assign data_out = mem[read_addr];

endmodule