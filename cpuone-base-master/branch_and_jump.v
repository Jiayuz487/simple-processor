module branch_and_jump (
    pc,
    pc_nxt,
    // branch
    is_inst_blt,
    is_inst_bne,
    is_inst_bex,
    branch_rd,
    branch_rs,
    branch_offset,
    // jump
    is_inst_jal,
    is_inst_jr,
    is_inst_j,
    jump_target
);

    input [31:0] pc;
    input is_inst_blt;
    input is_inst_bne;
    input is_inst_bex;
    input [31:0] branch_rd;
    input [31:0] branch_rs;
    input [31:0] branch_offset; // signed & sign-extended
    input is_inst_jal;
    input is_inst_jr;
    input is_inst_j;
    input [26:0] jump_target;

    output reg [31:0] pc_nxt;

    // branch conditions
    wire is_blt_condition_true;
    wire is_bne_condition_true;
    wire is_bex_condition_true;
    assign is_blt_condition_true = branch_rd < branch_rs;
    assign is_bne_condition_true = branch_rd != branch_rs;
    assign is_bex_condition_true = branch_rd != 32'd0;

    always @(*) begin
        if (is_inst_jal) begin
            // jal: pc = target
            pc_nxt = {{5{jump_target[26]}}, jump_target}; // perform sign extension
        end
        else if (is_inst_jr) begin
            // jr: pc = $rd
            pc_nxt = branch_rd;
        end
        else if (is_inst_blt) begin
            // blt if ($rd < $rs) pc = pc + 1 + immediate
            pc_nxt = is_blt_condition_true?
                     pc + 1 + branch_offset:
                     pc + 1;
        end
        else if (is_inst_bne) begin
            // bne if ($rd != $rs) pc = pc + 1 + immediate
            pc_nxt = is_bne_condition_true?
                     pc + 1 + branch_offset:
                     pc + 1;
        end
        else if (is_inst_j) begin
                // j: pc = target
                pc_nxt = {{5{jump_target[26]}}, jump_target}; // perform sign extension
        end
        else if (is_inst_bex) begin
            pc_nxt = is_bex_condition_true?
                     {{5{jump_target[26]}}, jump_target}:
                     pc + 1;
        end
        else begin
            //default: next instruction
            pc_nxt = pc + 1;
        end
    end
endmodule
