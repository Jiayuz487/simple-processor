module register (
    d, q, clk, rst
);
    input [31:0] d;
    input clk, rst;
    output reg [31:0] q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 32'd0;
        end
        else begin
            q <= d;
        end
    end
endmodule