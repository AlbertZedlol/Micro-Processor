module Control(
	input  [6 -1:0] OpCode   ,
	input  [6 -1:0] Funct    ,

	output Branch            ,//whether belongs to the branch family. 
	output [3 -1:0] BranchOp ,//difference between the branch family.
	
	output Jump				 ,//whether belongs to the jump family. j, jal, jr, jalr.
	output JumpReg			 ,//whether is jr/jalr.

	output ALUSrc1           ,
	output ALUSrc2           ,
	output ExtOp             ,
	output LuOp              ,
	output  [4 -1:0] ALUOp	 ,
	
	output RegWrite          ,//whether writes the regfile
	output  [2 -1:0] RegDst   ,//rd or rt
	output MemRead           ,//is lw
	output MemWrite          ,//is sw
	output  [2 -1:0] MemtoReg//whihc data will be written back to reg file.
);

//new insts

//ori:
    //ori $17, $1, 0x0000_0010:  001101 00001 10001 00000000000100 00
    //ori: $rt=$rs|ZeroExi(Imm)
    parameter ori=(6'h0d);    //needs ZeroExtension

//branch family:
//beq, bne
    parameter beq =6'h04;
    parameter bne =6'h05;
    //(bltz, bnez, bgtz, blez  are breaked down to the combinatino of slt and beq/bne.)


//old stuff:
    //here WE OMITTS THE DEFINITIONS FOR ADD, ADDU, SLT and SUB OPERATIONS, 
    //because their control signals are all defined by default.
    //and they have a funct code, so ALUOp[2:0]neglects them too.
    //they we be distinguished only at ALUControl.v where we 
    //read their Functs and define ALUCtl, then guid ALU operation.

    //here xxx_F means the function code of instruction xxx
    //xxx means the OpCode of the instruction xxx.
    parameter slti=6'h0a;
    parameter sltiu=6'h0b;

    parameter sll =6'h0;
    parameter sll_F=6'h00;
    
    parameter srl =6'h0;
    parameter srl_F=6'h02;

    parameter sra=6'h0;
    parameter sra_F=6'h03;
    
    parameter addi=6'h08;
    parameter addiu=6'h09;
    parameter andi=6'h0c;
    parameter mul =6'h1c;
    parameter sw= 6'h2b;
    parameter lw=6'h23;

    parameter lui=(6'h0f);
    parameter j =(6'h02) ;
    parameter jal =(6'h03);
    parameter jr =(6'h00);
    parameter jr_F=6'h08;
    parameter jalr =(6'h00);
    parameter jalr_F=6'h09;
    
	
	//<Revised>Branch Family 
	assign Branch=
		(OpCode==beq||OpCode==bne)?1:0;

	//<New>
	assign BranchOp=
		(OpCode==beq)?3'b000://OpCode==beq
		(OpCode==bne)?3'b001://OpCode==bne
		3'b111;//not in the branch family.

	//<New>Jump family
	//j, jal: jump to target.
	//jr, jalr: jump to value read from $rs in RegFile.
	assign Jump=(OpCode==j||OpCode==jal)||(OpCode==jr && Funct==jr_F)||(OpCode==jalr && Funct==jalr_F);				
	//<New>Differences within the jump family: register indexing/pseudo-direct.
	assign JumpReg=(OpCode==jr && Funct==jr_F)||(OpCode==jalr && Funct==jalr_F);

	//RegWrite
	//	==0 for instructions that don't write the main memory: sw, branch family, j, jr set to 
	//	<New> add new branch families to this list
	//	==1 for inst that writes.
	assign RegWrite=
		(OpCode==sw || OpCode==beq||OpCode==bne || OpCode==j || (OpCode==jr && Funct==jr_F ))?0:1;

	//RegDst
	//the INDEX of the register in RF that will be written back
	//==2'b00, means "write to rt". lw, lui, addi, addiu, andi, slti, sltiu: 
	//==2'b01: means "write to rd". R-type and jalr (jalr writes to rd)
	//==2'b11: jal and those that don't even write to reg file
	//the INDEX of the register in RF that will be written back
	assign RegDst[1:0]=
		(OpCode==lw || OpCode==lui || OpCode==addi ||OpCode==addiu||OpCode==andi ||OpCode==slti || OpCode==sltiu||OpCode==ori)?2'b00:
		(OpCode==jal)?2'b11:
		(OpCode==beq|| OpCode==bne ||OpCode==j|| (OpCode==jr && Funct==jr_F ))?2'b10:
		2'b01;//R-type and OpCode==jalr && Funct==jalr_F

	//MemRead=lw
	assign MemRead=(OpCode==lw)?1:0;

	//MemWrite=sw
	assign MemWrite=(OpCode==sw)?1:0;
	
	//MemtoReg: what will be written to regfile.
	//2'b01: lw. from DM
	//2'b11: jal, jalr. from PC+8
	//2'b00: R.  from ALU_out
	assign MemtoReg[1:0]=
		(OpCode==lw)?2'b01:
		(OpCode==jal||OpCode==jalr && Funct==jalr_F)?2'b11:
		2'b00;//R

	//LuOp:whether LOAD UPPER IMMEDIATE.
	//==1 when lui.  
	//==0 else.
	assign LuOp=(OpCode==lui)?1:0;

	//ExtOp==1 signed ext.
	//			note tha branch family and lwsw are similar to I-type operations, whose immediate CAN BE NEGATIVE
	//			coz we can go to previous locations.
	//	   ==0 unsigned ext. when andi, ori etc.logic opertaions.
	//	   ==x anything when otherwise(these operations does not use the immediata). here we force x to 0.
	assign ExtOp=
		(OpCode==beq||OpCode==bne||OpCode==lw||OpCode==sw||(OpCode==addi)||(OpCode==addiu)||(OpCode==slti)||(OpCode==sltiu))?1:0;

	//ALUSrc1==1: when sll srl sra
	//		 ==0: else.
	assign ALUSrc1=
		(OpCode==sll && Funct ==sll_F||OpCode==srl && Funct ==srl_F||OpCode==sra && Funct ==sra_F)?1:0;
	
	//ALUSrc2
	//		 ==1: data fed into the second input of ALU will be ImmExt_out(see file CPU.v)
	//			  for I-type or Branch family
	//			  lw sw lui addi addiu andi slti sltiu
	//			  
	//		 ==0: :data fed into the second ALU entrance will be Databus2.
	//			  for R-type and branch family.
	//			  Note that branch family actually does not use ALU.
	//			  It uses an additional module called 'Comp', which receives the same 
	//			  inputs as ALU. branch family inputs $rs, $rt to Comp to compare, 
	//			  Comp outputs Zero and the new address is computed in a naked way outsize all the submodules.
	//			  Then it directly updates PC.So branch family has ALUSrc2==0
	assign ALUSrc2=
		((OpCode==lw)||(OpCode==sw)||(OpCode==lui)||(OpCode==addi)||(OpCode==addiu)||(OpCode==andi)||(OpCode==slti)||(OpCode==sltiu)||OpCode==ori)?1:0;
		                            
    parameter alu_add=3'b000;
    parameter alu_sub=3'b001;
    parameter alu_funct=3'b010;
    parameter alu_mul=3'b011;
    parameter alu_and=3'b100;
    parameter alu_slt=3'b101;
    parameter alu_or=3'b110;
    //here we only provide with I-type instructions (including lw/sw)with an ALUOp signal
    //because they don't have a function code, so they cannot be solely determined
    //by Funct.(as in ALUControl.v)
    assign ALUOp[2:0]=
        (OpCode==addi||OpCode==addiu||OpCode==lw||OpCode==sw)?alu_add:        //add and addu will be determined by funct.
        (OpCode==mul)?alu_mul:
        (OpCode==andi)?alu_and:
        (OpCode==slti||OpCode==sltiu)?alu_slt:        //slt will be determined by funct.
        (OpCode==ori)?alu_or:
        alu_funct;                    				  //determine by funct.

	assign ALUOp[3] = OpCode[0];


endmodule