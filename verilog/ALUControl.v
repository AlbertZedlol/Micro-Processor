//ALUControl.v
//Note that branch family and jump family do not have a valid ALUCtl signal, nor a valid Sign signal.
//the subtraction in branch is executed in the comp unit, while jump family does not even need alu operation.
module ALUControl(
	input  [4 -1:0] ALUOp      ,
	input  [6 -1:0] Funct      ,
	
	output reg [5 -1:0] ALUCtl ,
	output Sign
);
	//Will be used in ALU.v to guide the operations.
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

    //possible values for ALUOp[2:0], input by Control unit.(Control.v)
    //used to determine operation for I-type instructions.
    parameter alu_add=3'b000;
    parameter alu_sub=3'b001;
    parameter alu_funct=3'b010;
    parameter alu_mul=3'b011;
    parameter alu_and=3'b100;
    parameter alu_slt=3'b101;
    parameter alu_or=3'b110;

	// Sign: whether the ALU treats the input as a signed number or an unsigned number
	assign Sign = (ALUOp[2:0] == 3'b010)? ~Funct[0]: ~ALUOp[3];
	
	// set aluFunct
	reg [4:0] aluFunct;
	always @(*)
		case (Funct)
			6'b00_0000: aluFunct <= aluSLL;
			6'b00_0010: aluFunct <= aluSRL;
			6'b00_0011: aluFunct <= aluSRA;
			6'b10_0000: aluFunct <= aluADD;
			6'b10_0001: aluFunct <= aluADD;//aluADDu
			6'b10_0010: aluFunct <= aluSUB;
			6'b10_0011: aluFunct <= aluSUB;//aluSUBu
			6'b10_0100: aluFunct <= aluAND;

			6'b10_0101: aluFunct <= aluOR;
			6'b10_0110: aluFunct <= aluXOR;
			6'b10_0111: aluFunct <= aluNOR;

			6'b10_1010: aluFunct <= aluSLT;
			6'b10_1011: aluFunct <= aluSLT;//aluSLTu			
			default: aluFunct <= aluADD;
		endcase
	
	// set ALUCtrl
	always @(*)
		case (ALUOp[2:0])
			alu_add: ALUCtl <= aluADD;
			alu_sub: ALUCtl <= aluSUB;
            alu_funct: ALUCtl <= aluFunct;
            alu_mul: ALUCtl <= aluMUL;
			alu_and: ALUCtl <= aluAND;
			alu_slt: ALUCtl <= aluSLT;
            alu_or : ALUCtl <=aluOR;
			default: ALUCtl <= aluADD;
		endcase
endmodule
