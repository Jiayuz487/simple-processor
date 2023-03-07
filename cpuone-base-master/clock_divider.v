module clock_div_half (
    in_clk, out_clk,
    rst
);

    input in_clk;
    input rst;
    output reg out_clk;

    always @(posedge in_clk, posedge rst) begin
        if (rst) begin
            out_clk <= 1'b0;
        end
        else begin
            out_clk <= ~out_clk;
        end
    end

endmodule

module clock_div_quarter (
    in_clk, out_clk,
    rst
);

    input in_clk;
    input rst;
    output out_clk;

    wire half_clk;
    clock_div_half CLK_HALF_0 (
        .in_clk(in_clk),
        .out_clk(half_clk),
        .rst(rst)
    );
    clock_div_half CLK_HALF_1 (
        .in_clk(half_clk),
        .out_clk(out_clk),
        .rst(rst)
    );

endmodule