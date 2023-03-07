module sign_extender (
    in, out
);
    input [16:0] in; // 17-bit immediate
    output [31:0] out; // 32-bit extended immediate

    assign out = {{15{in[16]}}, in};

endmodule