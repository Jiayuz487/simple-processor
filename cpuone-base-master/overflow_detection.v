module overflow_detection(is_Type_R, is_inst_addi, inst_aluop, rstatus);
    input [4:0] inst_aluop;
    input is_Type_R, is_inst_addi;
    output [31:0] rstatus;

    wire is_inst_add, is_inst_sub;
    assign is_inst_add = (is_Type_R & (inst_aluop == 5'b0));
    assign is_inst_sub = (is_Type_R & (inst_aluop == 5'b1));

    assign rstatus = is_inst_add ? 32'd1 : 32'bz;
    assign rstatus = is_inst_addi ? 32'd2 : 32'bz;
    assign rstatus = is_inst_sub ? 32'd3 : 32'bz;


endmodule