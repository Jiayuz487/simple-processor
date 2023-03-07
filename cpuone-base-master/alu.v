module alu(data_operandA, data_operandB, ctrl_ALUopcode,
			ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

	input [31:0] data_operandA, data_operandB;
	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	output [31:0] data_result;
	output isNotEqual, isLessThan, overflow;
	
	wire signed[31:0] inner_A, inner_B;
	reg signed[31:0] inner_result;
	reg inner_cout;
	
	assign inner_A = data_operandA;
	assign inner_B = data_operandB;
	assign data_result = inner_result;
	
	assign isNotEqual = inner_A != inner_B;
	assign isLessThan = inner_A < inner_B;
	assign overflow = inner_cout != inner_result[31];
	
	always @(ctrl_ALUopcode or inner_A or inner_B or ctrl_shiftamt)
		begin
			case (ctrl_ALUopcode)
				0 : {inner_cout, inner_result} = inner_A + inner_B;  // ADD
				1 : {inner_cout, inner_result} = inner_A - inner_B;	// SUBTRACT
				2 : begin // explicit value assignments were made for inner_cout in all of the case blocks to avoid an issue with Quartus "inferring a latch" for inner_cout
					inner_result = inner_A & inner_B;  			// AND
					inner_cout = 1'b0;
					end
				3 : begin
					inner_result = inner_A | inner_B;  			// OR
					inner_cout = 1'b0;
					end
				4 : begin
					inner_result = inner_A << ctrl_shiftamt;		// SLL
					inner_cout = 1'b0;
					end
				5 : begin
					inner_result = inner_A >>> ctrl_shiftamt;	// SRA
					inner_cout = 1'b0;
					end
				default: {inner_cout, inner_result} = inner_A + inner_B; // Default state for other ctrl_ALUopcode states
			endcase
		end
	
endmodule
