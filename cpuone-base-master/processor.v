/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);

    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    // Instruction machine code format
    wire [4:0] inst_opcode, inst_rd, inst_rs, inst_rt;
    wire [4:0] inst_shamt, inst_aluop;
    wire [16:0] inst_I_immediate;
    wire [26:0] inst_JI_target;

    assign inst_opcode = q_imem[31:27];
    assign inst_rd = q_imem[26:22];
    assign inst_rs = q_imem[21:17];
    assign inst_rt = q_imem[16:12];
    assign inst_shamt = q_imem[11:7];
    assign inst_aluop = q_imem[6:2];
    assign inst_I_immediate = q_imem[16:0];
    assign inst_JI_target = q_imem[26:0];

    // Opcode decoder
    wire is_type_R;
    wire is_inst_addi;
    wire is_inst_sw;
    wire is_inst_lw;
    wire is_inst_jal;
    wire is_inst_jr;
    wire is_inst_j;
    wire is_inst_blt;
    wire is_inst_bne;
    wire is_inst_bex;
    wire is_inst_setx;
    wire [4:0] decoded_ALU_opcode;

    opcode_decoder OPCODE_DECODER(
        .opcode(inst_opcode),
        .is_type_R(is_type_R),
        .is_inst_addi(is_inst_addi),
        .is_inst_sw(is_inst_sw),
        .is_inst_lw(is_inst_lw),
        .is_inst_jal(is_inst_jal),
        .is_inst_jr(is_inst_jr),
        .is_inst_j(is_inst_j),
        .is_inst_blt(is_inst_blt),
        .is_inst_bne(is_inst_bne),
        .is_inst_bex(is_inst_bex),
        .is_inst_setx(is_inst_setx),
        .decoded_ALU_opcode(decoded_ALU_opcode)
    );

    // Control signals
    wire ctrl_Rdst, ctrl_Rwe;   // regfile
    wire ctrl_ALUinB;
    wire ctrl_Rwd;

    assign ctrl_Rdst = is_inst_sw || is_inst_blt || is_inst_bne || is_inst_jr;
    assign ctrl_Rwe = is_type_R || is_inst_addi || is_inst_lw || is_inst_jal || is_inst_setx;
    assign ctrl_ALUinB = is_inst_addi || is_inst_lw || is_inst_sw;
    assign ctrl_Rwd = is_inst_lw;


    // SX
    wire [31:0] data_immediate;
    sign_extender SX(inst_I_immediate, data_immediate);

    // PC
    wire [31:0] pc, pc_nxt;
    wire is_blt_condition_true;
    register PC(
        .d(pc_nxt),
        .q(pc),
        .clk(clock),
        .rst(reset)
    );
    branch_and_jump BNR(
        .pc(pc),
        .pc_nxt(pc_nxt),
        .is_inst_blt(is_inst_blt),
        .is_inst_bne(is_inst_bne),
        .is_inst_bex(is_inst_bex),
        .branch_rd(data_readRegB),
        .branch_rs(data_readRegA),
        .branch_offset(data_immediate),
        .is_inst_jal(is_inst_jal),
        .is_inst_jr(is_inst_jr),
        .is_inst_j(is_inst_j),
        .jump_target(inst_JI_target)
    );

    // Imem
    assign address_imem[11:0] = pc[11:0];

    // ALU
    wire [31:0] data_ALU_inA, data_ALU_inB;
    wire [31:0] data_ALU_out;
    wire [4:0] ctrl_ALU_opcode;
    wire isNotEqual, isLessThan, overflow;

    assign data_ALU_inA[31:0] = data_readRegA[31:0];
    assign data_ALU_inB[31:0] = ctrl_ALUinB? data_immediate[31:0]: data_readRegB[31:0];
    assign ctrl_ALU_opcode[4:0] = is_type_R? inst_aluop[4:0]: decoded_ALU_opcode[4:0];

    // exception handling
    wire [31:0] rstatus, writeback_data;
    overflow_detection ovf_det(is_type_R, is_inst_addi, inst_aluop, rstatus);
    assign writeback_data = (overflow & (q_imem != 32'b0)) ? rstatus : data_ALU_out;

    alu ALU(
        .data_operandA(data_ALU_inA[31:0]),
        .data_operandB(data_ALU_inB[31:0]),
        .ctrl_ALUopcode(ctrl_ALU_opcode[4:0]),
        .ctrl_shiftamt(inst_shamt[4:0]),
        .data_result(data_ALU_out[31:0]),
        .isNotEqual(isNotEqual),
        .isLessThan(isLessThan),
        .overflow(overflow)
    );

    // Regfile
    assign ctrl_readRegA[4:0] = is_inst_bex? 5'd0: inst_rs[4:0];
    assign ctrl_readRegB[4:0] = is_inst_bex? 5'd30: ctrl_Rdst? inst_rd[4:0]: inst_rt[4:0];
    assign ctrl_writeReg[4:0] = is_inst_setx? 5'd30: is_inst_jal? 5'd31:(overflow & (q_imem != 32'b0)) ? 5'd30 : inst_rd[4:0]; // make sure that our processor is correctly handling nop instructions as well as overflow exception overwrites
    assign ctrl_writeEnable = ctrl_Rwe;
    assign data_writeReg[31:0] = is_inst_setx? {5'd0, inst_JI_target}: is_inst_jal? pc + 32'd1: (ctrl_Rwd & !overflow) ? q_dmem[31:0]: writeback_data;

    // Dmem
    assign wren = is_inst_sw;
    assign data[31:0] = data_readRegB[31:0];
    assign address_dmem[11:0] = data_ALU_out[11:0];

endmodule
