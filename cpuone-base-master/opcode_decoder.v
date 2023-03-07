module opcode_decoder (
    opcode,
    is_type_R,
    is_inst_addi,
    is_inst_sw,
    is_inst_lw,
    is_inst_jal,
    is_inst_jr,
    is_inst_j,
    is_inst_blt,
    is_inst_bne,
    is_inst_bex,
    is_inst_setx,
    decoded_ALU_opcode
);

    input [4:0] opcode;
    output is_type_R;
    output is_inst_addi;
    output is_inst_sw;
    output is_inst_lw;
    output is_inst_jal;
    output is_inst_jr;
    output is_inst_j;
    output is_inst_blt;
    output is_inst_bne;
    output is_inst_bex;
    output is_inst_setx;
    output [4:0] decoded_ALU_opcode;

    parameter   TYPE_R_OPCODE = 5'b00000,
                ADDI_OPCODE   = 5'b00101,
                SW_OPCODE     = 5'b00111,
                LW_OPCODE     = 5'b01000,
                JAL_OPCODE    = 5'b00011,
                JR_OPCODE     = 5'b00100,
                J_OPCODE      = 5'b00001,
                BLT_OPCODE    = 5'b00110,
                BNE_OPCODE    = 5'b00010,
                BEX_OPCODE     = 5'b10110,
                SETX_OPCODE    = 5'b10101;

    assign is_type_R = opcode == TYPE_R_OPCODE;
    assign is_inst_addi = opcode == ADDI_OPCODE;
    assign is_inst_lw = opcode == LW_OPCODE;
    assign is_inst_sw = opcode == SW_OPCODE;
    assign is_inst_jal = opcode == JAL_OPCODE;
    assign is_inst_jr = opcode == JR_OPCODE;
    assign is_inst_j = opcode == J_OPCODE;
    assign is_inst_blt = opcode == BLT_OPCODE;
    assign is_inst_bne = opcode == BNE_OPCODE;
    assign is_inst_bex = opcode == BEX_OPCODE;
    assign is_inst_setx = opcode == SETX_OPCODE;

    parameter ALU_ADD = 5'd0,
              ALU_SUB = 5'd1,
              ALU_AND = 5'd2,
              ALU_OR  = 5'd3,
              ALU_SLL = 5'd4,
              ALU_SRA = 5'd5;
    assign decoded_ALU_opcode[4:0] = ALU_ADD;

endmodule
