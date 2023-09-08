//Main Module of the pipelined CPU
module CPU(
	input  reset     , 
	input  clk       ,                                    
	output wire [11:0]BCD  //retrieved from the memory		
);


//internal signals/data
	//from IF/for IF
		wire [31:0]PC;
		wire [31:0]PC_new;
		wire [31:0]PC_plus_4;
		wire [31:0]PC_plus_8;
		wire KeepPC;
		wire Jump;
		wire JumpReg;
		wire [31:0]Jump_target;
		wire ExtOp;
		wire LuOp;
		wire [31:0]Instruction;
		
		wire [4:0]ALUCtl;
		wire Sign;
		wire [31:0]ALU_in1;
		wire [31:0]ALU_in2;
		wire Zero;
		
		wire [1:0]hazard_IF_ID;
	//for ID
		wire [31:0]IF_ID_Inst;
		wire [31:0]IF_ID_PC_plus_4;
		wire [5:0]IF_ID_opcode;
		wire [5:0]IF_ID_funct;
		wire [4:0]IF_ID_shamt;
		wire [15:0]IF_ID_imm;
		wire [4:0]IF_ID_rs;
		wire [1:0]IF_ID_reg_dst;
		wire IF_ID_Branch;
		wire [2:0]IF_ID_BranchOp;
		wire [31:0]Branch_target;
		wire [3:0]IF_ID_ALUOp;
		wire [4:0]IF_ID_rt;
		wire [4:0]IF_ID_rd;
		wire [1:0]IF_ID_mem_to_reg;
		wire [31:0]IF_ID_bus1;
		wire [31:0]IF_ID_bus2;
		wire [31:0]IF_ID_imm_ext_out;
		wire hazard_ID_EX;
		
		wire IF_ID_mem_rd;
		wire IF_ID_mem_wr;
		
		wire IF_ID_reg_wr;
		wire [32-1:0]IF_ID_PC_plus_8;
		wire IF_ID_ALUSrc1;
		wire IF_ID_ALUSrc2;
	//for EX
		wire [5:0]ID_EX_funct; 
		wire [31:0]ID_EX_PC_plus_4;
		wire [4:0]ID_EX_shamt;
		wire [1:0]ID_EX_reg_dst;
		wire [2:0]ID_EX_BranchOp;
		wire [3:0]ID_EX_ALUOp;
		wire [31:0]ID_EX_ALU_out;
		wire [4:0]ID_EX_rs;
        wire [4:0]ID_EX_rt;
        wire [4:0]ID_EX_rd;
		wire [1:0]ID_EX_mem_to_reg;
		wire [31:0]ID_EX_bus1;
		wire [31:0]ID_EX_bus2;
		wire [31:0]ID_EX_imm_ext_out;
		wire [31:0]ID_EX_ALU_in1_reg_forward;
		wire [31:0]ID_EX_ALU_in2_reg_forward;
		wire ID_EX_mem_rd;
		wire ID_EX_mem_wr;
		wire ID_EX_Branch;
		wire ID_EX_reg_wr;
		wire [4:0]ID_EX_reg_wr_addr;
		wire [32-1:0]ID_EX_PC_plus_8;
		wire ID_EX_ALUSrc1;
		wire ID_EX_ALUSrc2;
	//for MEM
		wire [31:0]EX_MEM_mem_wr_data;
		wire [31:0]EX_MEM_ALU_out;
		wire [31:0]EX_MEM_ALU_in2_reg_forward ;
		wire EX_MEM_mem_rd;
		wire EX_MEM_mem_wr;
		wire [31:0]EX_MEM_mem_rd_data;
		wire [2-1:0]EX_MEM_mem_to_reg;
		
		wire [31:0]EX_MEM_mem_rd_addr;
		wire [31:0]EX_MEM_mem_wr_addr;
		wire EX_MEM_reg_wr;
		wire [4:0]EX_MEM_reg_wr_addr;
		wire [32-1:0]EX_MEM_PC_plus_8;
	//for WB;
		wire MEM_WB_mem_rd;
		wire [31:0]MEM_WB_mem_rd_data;
		wire [32-1:0]MEM_WB_reg_wr_data;
		wire [2-1:0]MEM_WB_mem_to_reg;
		wire [32 -1:0]MEM_WB_ALU_out;
		wire [31:0]MEM_WB_mem_rd_addr;
		wire MEM_WB_reg_wr;
		wire [4:0]MEM_WB_reg_wr_addr;
		wire [32-1:0]MEM_WB_PC_plus_8;

//============================================================================================================================================================
//Hazard Unit
		Hazard hazard_unit(
				.IF_ID_rs		(IF_ID_rs		),
				.IF_ID_rt		(IF_ID_rt		),
				.ID_EX_rt       (ID_EX_rt       ),
				.ID_EX_mem_rd	(ID_EX_mem_rd   ),
				.Branch			(ID_EX_Branch   ),
				.Jump			(Jump			),
				.KeepPC			(KeepPC			),//outputs
				.hazard_IF_ID	(hazard_IF_ID	),
				.hazard_ID_EX	(hazard_ID_EX	)
		);
//============================================================================================================================================================
//IF
	//IM
		InstructionMemory instruction_memory1(
			.Address        (PC             ), //input
			.Instruction    (Instruction    )  //output
		);
	//PC
		//Update PC		
			assign PC_plus_4 = PC + 32'd4;		
			assign PC_plus_8 = PC + 32'd8;		
			assign PC_new=
				ID_EX_Branch ?(Zero?Branch_target:PC_plus_4):
				Jump?(JumpReg?IF_ID_bus1:Jump_target):		//ID_EX_bus1==RegFile[rs], for j, jal.   Jump_target, for jr,jalr.
				PC_plus_4;
		//PC instance
		PC program_counter(
				.clk			(clk			),
				.reset			(reset			),
				.KeepPC			(KeepPC			),
				.PC_new			(PC_new			),
				.PC				(PC				)//output
		);
//============================================================================================================================================================
// IF_ID
	IF_ID if_id(
		.clk(clk),
		.reset			(reset			),
		.hazard_IF_ID	(hazard_IF_ID	),
		.Inst			(Instruction	),
		.PC_plus_4		(PC_plus_4		),
		.PC_plus_8		(PC_plus_8		),
		.IF_ID_Inst		(IF_ID_Inst		),//output
		.IF_ID_PC_plus_4(IF_ID_PC_plus_4),
		.IF_ID_PC_plus_8(IF_ID_PC_plus_8)			
	);
//============================================================================================================================================================
//ID
	//Instruction decode: generate signals for IF_ID
	assign IF_ID_opcode = IF_ID_Inst[31:26];
	assign IF_ID_rs		 =IF_ID_Inst[25:21];
	assign IF_ID_rt		 =IF_ID_Inst[20:16];
	assign IF_ID_rd		 =IF_ID_Inst[15:11];
	assign IF_ID_shamt	 =IF_ID_Inst[10: 6];
	assign IF_ID_funct 	 =IF_ID_Inst[5 : 0];
	assign IF_ID_imm	 =IF_ID_Inst[15: 0];
	//Control unit
		Control ctrl_unit(
			.OpCode     (IF_ID_opcode ), 		//inputs
			.Funct      (IF_ID_funct  ),
												//<deleted>PCSrc
			.Branch     (IF_ID_Branch 		),  //outputs:
			.BranchOp   (IF_ID_BranchOp           ),
			.Jump		(Jump				),			//<New>
			.JumpReg	(JumpReg			),			//<New>		
			.RegWrite   (IF_ID_reg_wr       ), 
			.RegDst     (IF_ID_reg_dst       ), 
			.MemRead    (IF_ID_mem_rd       ),	
			.MemWrite   (IF_ID_mem_wr		), 
			.MemtoReg   (IF_ID_mem_to_reg   ),
			.ALUSrc1    (IF_ID_ALUSrc1      ), 			//decides input 1 of ALU (ALU_in1)
			.ALUSrc2    (IF_ID_ALUSrc2      ), 			//decides input 2 of ALU (ALU_in2)
			.ExtOp      (ExtOp              ), 			//
			.LuOp       (LuOp               ), 			//whether this instructiono is "lui"load unsigned integer (LuOp==1). in'lui', Extension result is covered by unsigned.
			.ALUOp      (IF_ID_ALUOp              )	
		);

	//Regfile									
		//NOTE: because of potential hazards, EX_MEM_reg_wr_addr signal is determined after ID_EX.
		//which indicates the register to which data is written.
		RegisterFile regfile(
			.reset          (reset              ), 
			.clk            (clk                ),
			.RegWrite       (IF_ID_reg_wr       ), 
			.Read_register1 (IF_ID_rs 			), 
			.Read_register2 (IF_ID_rt			), 
			.Write_register (MEM_WB_reg_wr_addr ),
			.Write_data     (MEM_WB_reg_wr_data ), 
			.Read_data1     (IF_ID_bus1         ), //output
			.Read_data2     (IF_ID_bus2         )  //output
		);

	//ImmExt
		ImmExt imm_ext(
			.Ext_op			(ExtOp	    	  ),//from control
			.LuOp			(LuOp	   		  ),//from control
			.Imm			(IF_ID_imm		  ),
			.ImmExt_out		(IF_ID_imm_ext_out)	//output
		);

	//Jump target
		assign Jump_target = {IF_ID_PC_plus_4[31:28], IF_ID_Inst[25:0], 2'b00};
		//This is only for j and jal
		//jr, jalr are using ID_EX_bus1 as the PC_new, which is $rs

//============================================================================================================================================================
// ID_EX
	ID_EX id_ex(
		.clk(clk),									//inputs
		.reset(reset),
		.hazard_ID_EX(hazard_ID_EX),
		.IF_ID_PC_plus_4(IF_ID_PC_plus_4),
		.IF_ID_shamt(IF_ID_shamt),
		.IF_ID_reg_dst(IF_ID_reg_dst),
		.IF_ID_BranchOp(IF_ID_BranchOp),
		.IF_ID_ALUSrc1(IF_ID_ALUSrc1),
		.IF_ID_ALUSrc2(IF_ID_ALUSrc2),
		.IF_ID_ALUOp(IF_ID_ALUOp),
		.IF_ID_rs(IF_ID_rs),
		.IF_ID_rt(IF_ID_rt),
		.IF_ID_rd(IF_ID_rd),
		.IF_ID_mem_to_reg(IF_ID_mem_to_reg),
		.IF_ID_bus1(IF_ID_bus1),
		.IF_ID_bus2(IF_ID_bus2),
		.IF_ID_imm_ext_out(IF_ID_imm_ext_out),
		.IF_ID_mem_rd(IF_ID_mem_rd),
		.IF_ID_mem_wr(IF_ID_mem_wr),
		.IF_ID_reg_wr(IF_ID_reg_wr),
		.IF_ID_funct(IF_ID_funct),
		.IF_ID_Branch(IF_ID_Branch),
		.IF_ID_PC_plus_8(IF_ID_PC_plus_8),
		.ID_EX_PC_plus_4(ID_EX_PC_plus_4),			//outputs
		.ID_EX_shamt(ID_EX_shamt),
		.ID_EX_reg_dst(ID_EX_reg_dst),
		.ID_EX_BranchOp(ID_EX_BranchOp),
		.ID_EX_ALUSrc1(ID_EX_ALUSrc1),
		.ID_EX_ALUSrc2(ID_EX_ALUSrc2),
		.ID_EX_ALUOp(ID_EX_ALUOp),
		.ID_EX_rs(ID_EX_rs),
		.ID_EX_rt(ID_EX_rt),
		.ID_EX_rd(ID_EX_rd),
		.ID_EX_mem_to_reg(ID_EX_mem_to_reg),
		.ID_EX_bus1(ID_EX_bus1),
		.ID_EX_bus2(ID_EX_bus2),
		.ID_EX_imm_ext_out(ID_EX_imm_ext_out),
		.ID_EX_mem_rd(ID_EX_mem_rd),
		.ID_EX_mem_wr(ID_EX_mem_wr),
		.ID_EX_reg_wr(ID_EX_reg_wr),
		.ID_EX_funct(ID_EX_funct),
		.ID_EX_Branch(ID_EX_Branch),
		.ID_EX_PC_plus_8(ID_EX_PC_plus_8)
	);
//============================================================================================================================================================
// EX
	//Forward Unit to the entrance of ALU(//Ex hazard)
		Forward_EX forward_unit_ex(
			.ID_EX_rs(ID_EX_rs),
			.ID_EX_rt(ID_EX_rt),					
			.EX_MEM_reg_wr(EX_MEM_reg_wr),
			.EX_MEM_reg_wr_addr(EX_MEM_reg_wr_addr),
			.MEM_WB_reg_wr(MEM_WB_reg_wr),
			.MEM_WB_reg_wr_addr(MEM_WB_reg_wr_addr),
			.ID_EX_bus1(ID_EX_bus1),
			.ID_EX_bus2(ID_EX_bus2),
			.EX_MEM_ALU_out(EX_MEM_ALU_out),
			.MEM_WB_reg_wr_data(MEM_WB_reg_wr_data),
			.ALU_in1_reg_forward(ID_EX_ALU_in1_reg_forward),//output
			.ALU_in2_reg_forward(ID_EX_ALU_in2_reg_forward) //output
		);
	//better write this line in the ID_EX reg as the output.then EX_MEM collects this output.
	//ID_EX                 																			//ra
	assign ID_EX_reg_wr_addr = 
		(ID_EX_reg_dst == 2'b00)? ID_EX_rt: 
		(ID_EX_reg_dst == 2'b01)? ID_EX_rd:
		(ID_EX_reg_dst == 2'b11)? 5'd31:
		5'd0;
			//ID_EX_reg_wr_addr indicates the register to which data is written.
			//				==IR[20:16]==rt, when RegDst == 2'b00 for lw, sw, I-type
			//				==IR[15:11]==rd, when RegDst == 2'b01	for R, jalr			(jalr rd, rs)	
			//				==31==$ra, 	     when RegDst == 2'b11   jal
			//				==0(which is forbidden)for other instructions that don't even need to WB to regfile.

	//ALUControl
		ALUControl alu_control1(
			.ALUOp  (ID_EX_ALUOp        ), 
			.Funct  (ID_EX_funct        ), 
			.ALUCtl (ALUCtl             ), //output
			.Sign   (Sign               )  //output
		);
	//ALU
		assign ALU_in1 = ID_EX_ALUSrc1? ID_EX_shamt			:ID_EX_ALU_in1_reg_forward; 
		assign ALU_in2 = ID_EX_ALUSrc2? ID_EX_imm_ext_out	:ID_EX_ALU_in2_reg_forward;
		ALU alu(
			.in1    (ALU_in1    	), 
			.in2    (ALU_in2    	), 
			.ALUCtl (ALUCtl     	), 
			.Sign   (Sign           ), //output
			.out    (ID_EX_ALU_out  ) //output
		);
	//Cmp
		Cmp cmp_unit(
			.BranchOp(ID_EX_BranchOp),
			.op1	 (ALU_in1	),
			.op2	 (ALU_in2	),
			.Zero	 (Zero			)   //output
		);
	//Branch target
	assign Branch_target = ID_EX_PC_plus_4 + {ID_EX_imm_ext_out[29:0], 2'b00};

//============================================================================================================================================================ 
// EX/MEM
	EX_MEM ex_mem(
	    .clk                        (clk          ),
	    .reset                      (reset        ),
		.ID_EX_ALU_out				(ID_EX_ALU_out),				//inputs
		.ID_EX_ALU_in2_reg_forward	(ID_EX_ALU_in2_reg_forward),
		.ID_EX_mem_rd				(ID_EX_mem_rd),
		.ID_EX_mem_wr				(ID_EX_mem_wr),
		.ID_EX_mem_to_reg			(ID_EX_mem_to_reg),
		.ID_EX_reg_wr				(ID_EX_reg_wr),
		.ID_EX_reg_wr_addr			(ID_EX_reg_wr_addr),
		.ID_EX_PC_plus_8			(ID_EX_PC_plus_8),
		.ID_EX_mem_rd_addr			(ID_EX_ALU_out),						//if this is lw.
		.ID_EX_mem_wr_addr			(ID_EX_ALU_out),						//if this is sw.
		.EX_MEM_ALU_out				(EX_MEM_ALU_out),				//outputs
		.EX_MEM_ALU_in2_reg_forward	(EX_MEM_ALU_in2_reg_forward),
		.EX_MEM_mem_rd				(EX_MEM_mem_rd),
		.EX_MEM_mem_wr				(EX_MEM_mem_wr),
		.EX_MEM_mem_to_reg			(EX_MEM_mem_to_reg),
		.EX_MEM_mem_rd_addr			(EX_MEM_mem_rd_addr),					//if this is lw.
		.EX_MEM_mem_wr_addr			(EX_MEM_mem_wr_addr),					//if this is sw.
		.EX_MEM_reg_wr				(EX_MEM_reg_wr),
		.EX_MEM_reg_wr_addr			(EX_MEM_reg_wr_addr),
		.EX_MEM_PC_plus_8			(EX_MEM_PC_plus_8)
	);
//============================================================================================================================================================
// DM
	//Forwarding to the entrance of DM(//lw-sw hazard)
		Forward_DM forward_unit_dm(
			.EX_MEM_ALU_in2_reg_forward	(EX_MEM_ALU_in2_reg_forward),	//input  
			.MEM_WB_mem_rd_addr			(MEM_WB_mem_rd_addr),
			.EX_MEM_mem_wr_addr			(EX_MEM_mem_wr_addr),
			.EX_MEM_mem_wr				(EX_MEM_mem_wr),
			.MEM_WB_mem_rd				(MEM_WB_mem_rd),
			.MEM_WB_mem_rd_data			(MEM_WB_mem_rd_data),
			.EX_MEM_mem_wr_data			(EX_MEM_mem_wr_data)//output
		);
	//DM
	DataMemory data_memory(
		.reset      (reset              	), 
		.clk        (clk                	), 
		.MemRead    (EX_MEM_mem_rd        	), 		//inst is lw
		.MemWrite   (EX_MEM_mem_wr       	), 		//inst is sw
		.Address    (EX_MEM_ALU_out			), 		//for both lw and sw, the addresses of the data accessed are computed by the ALU with a base+offset method. 
		.Write_data (EX_MEM_mem_wr_data	    ), 		//input.	sw: DM<---$rt or forward result of the previous lw.
		.Read_data  (EX_MEM_mem_rd_data   	), 		//output. 	lw:	DM--->B--->$rt
		.BCD_out	(BCD					)		//outptut
	);
	//<Deleted Device and DM relationship.>
//============================================================================================================================================================
// MEM_WB
	MEM_WB mem_wb(
		.clk					(clk					),//inputs
		.reset					(reset					),
		.EX_MEM_mem_rd_data		(EX_MEM_mem_rd_data		),
		.EX_MEM_mem_to_reg		(EX_MEM_mem_to_reg		),
		.EX_MEM_ALU_out			(EX_MEM_ALU_out			),
		.EX_MEM_mem_rd_addr		(EX_MEM_mem_rd_addr		),
		.EX_MEM_reg_wr			(EX_MEM_reg_wr			),
		.EX_MEM_mem_rd			(EX_MEM_mem_rd			),//for forwarding to DM
		.EX_MEM_reg_wr_addr		(EX_MEM_reg_wr_addr		),
		.EX_MEM_PC_plus_8		(EX_MEM_PC_plus_8		),
		.MEM_WB_mem_rd_data		(MEM_WB_mem_rd_data		),//outputs
		.MEM_WB_mem_to_reg		(MEM_WB_mem_to_reg		),
		.MEM_WB_ALU_out			(MEM_WB_ALU_out			),
		.MEM_WB_mem_rd_addr		(MEM_WB_mem_rd_addr		),//**for DM forwarding.
		.MEM_WB_reg_wr			(MEM_WB_reg_wr			),
		.MEM_WB_mem_rd			(MEM_WB_mem_rd			),//for forwarding to DM
		.MEM_WB_reg_wr_addr		(MEM_WB_reg_wr_addr		),
		.MEM_WB_PC_plus_8		(MEM_WB_PC_plus_8		)
	);
//============================================================================================================================================================
//WB
	//The DATA written back to RegFile (compare with RegDst--That is the INDEX)															
	assign MEM_WB_reg_wr_data = 
		(MEM_WB_mem_to_reg == 2'b00)? MEM_WB_ALU_out: 
		(MEM_WB_mem_to_reg == 2'b01)? MEM_WB_mem_rd_data: 
		MEM_WB_PC_plus_8;								//<verified>it was PC_plus_4 in single cycle
	//ID_EX_mem_to_reg: what will be written to regfile.
	//2'b00: R.  		from ALU_out
	//2'b01: lw. 		from DM
	//2'b11: jal, jalr. from PC+8	(delay slot considered)
endmodule




