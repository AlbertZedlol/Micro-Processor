module ALU(
	input [32 -1:0] in1      , 
	input [32 -1:0] in2      ,
	input [5 -1:0] ALUCtl    ,
	input Sign               ,
	
	output reg [32 -1:0] out
);
	//<Revised>Removed Zero to Comp.
	
	// lt_signed means whether signed inputs in1 and in2 satisfies (in1 < in2) 
	wire ss;
	assign ss = {in1[31], in2[31]};
	wire lt_31;
	assign lt_31 = (in1[30:0] < in2[30:0]);
	wire lt_signed;
	assign lt_signed = (in1[31] ^ in2[31])? 
		((ss == 2'b01)? 0: 1): lt_31;
	
	// funct number for different operations
	//ALUCtl:
	parameter aluAND = 5'b00000;
	parameter aluOR  = 5'b00001;
	parameter aluADD = 5'b00010;
	parameter aluSUB = 5'b00110;
	parameter aluSLT = 5'b00111;
	parameter aluNOR = 5'b01100;
	parameter aluXOR = 5'b01101;

	parameter aluSLL = 5'b10000;
	parameter aluSRL = 5'b11000;
	parameter aluSRA = 5'b11001;
	parameter aluMUL = 5'b11010;//multiplication

	// different ALU operations
	always @(*)
		case (ALUCtl)
			aluAND: out <= in1 & in2;
			aluOR: out  <= in1 | in2;
			aluADD: out <= in1 + in2;
			aluSUB: out <= in1 - in2;
			aluMUL:out  <= in1*in2;
			aluSLT: out <= {31'h00000000, Sign? lt_signed: (in1 < in2)};
			aluNOR: out <= ~(in1 | in2);
			aluXOR: out <= in1 ^ in2;
			//for shift family, in1[4:0]==shamt, in2==rt
			aluSLL: out <= (in2 << in1[4:0]);
			aluSRL: out <= (in2 >> in1[4:0]);
			aluSRA: out <= ({{32{in2[31]}}, in2} >> in1[4:0]);
			
			default: out <= 32'h00000000;//jump family and branch family don't use ALU
		endcase
endmodule



	

