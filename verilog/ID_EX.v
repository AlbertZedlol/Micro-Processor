//ID_EX.v
//ID-EX interphase register

//reset: zero
//ID_EX_hazard:
//             flush: same as zero
//             normal:trasport
//total: 21 entries
module ID_EX (
input clk,
input reset,
input hazard_ID_EX,
input [31:0]IF_ID_PC_plus_4,
input [4:0]IF_ID_shamt,
input [1:0]IF_ID_reg_dst,
input [2:0]IF_ID_BranchOp,
input IF_ID_ALUSrc1,
input IF_ID_ALUSrc2,
input [3:0]IF_ID_ALUOp,
input [4:0]IF_ID_rs,
input [4:0]IF_ID_rt,
input [4:0]IF_ID_rd,
input [1:0]IF_ID_mem_to_reg,
input [31:0]IF_ID_bus1,
input [31:0]IF_ID_bus2,
input [31:0]IF_ID_imm_ext_out,
input IF_ID_mem_rd,
input IF_ID_mem_wr,
input IF_ID_reg_wr,
input [5:0]IF_ID_funct,
input IF_ID_Branch,
input [32-1:0]IF_ID_PC_plus_8,//for WB.
output reg [31:0]ID_EX_PC_plus_4,
output reg [4:0]ID_EX_shamt,
output reg [1:0]ID_EX_reg_dst,
output reg [2:0]ID_EX_BranchOp,
output reg ID_EX_ALUSrc1,
output reg ID_EX_ALUSrc2,
output reg [3:0]ID_EX_ALUOp,
output reg [4:0]ID_EX_rs,
output reg [4:0]ID_EX_rt,
output reg [4:0]ID_EX_rd,
output reg [1:0]ID_EX_mem_to_reg,
output reg [31:0]ID_EX_bus1,
output reg [31:0]ID_EX_bus2,
output reg [31:0]ID_EX_imm_ext_out,
output reg ID_EX_mem_rd,
output reg ID_EX_mem_wr,
output reg ID_EX_reg_wr,
output reg [5:0]ID_EX_funct,
output reg ID_EX_Branch,
output reg [32-1:0]ID_EX_PC_plus_8//for WB.
);
//output [31:0]Branch_target, don't need to be transported by ID_EX.it is written by EX
//output [4:0]ALUCtl,output Sign,the same reason as above.
//output [31:0]ID_EX_ALU_out, the sam.e
//output Zero, the same.
//output ID_EX_ALU_in1_reg_forward,//though it is used in the 
//forwarding unit to EX, it is only deemed as a container(it serves as the output of the forward unit.)
//so we don't need to pass its value accross inter-stage regsters.
//output ID_EX_ALU_in2_reg_forward,  the same.

//reset: zero
//ID_EX_hazard:
//             flush: same as zero
//             normal:trasport

parameter flush = 1;
parameter normal = 0;

always @(posedge clk or posedge reset)begin
        if(reset)begin
            ID_EX_PC_plus_4<=0;
            ID_EX_shamt<=0;
            ID_EX_reg_dst<=0;
            ID_EX_BranchOp<=0;
            ID_EX_ALUSrc1<=0;
            ID_EX_ALUSrc2<=0;
            ID_EX_ALUOp<=0;
            ID_EX_rs<=0;
            ID_EX_rt<=0;
            ID_EX_rd<=0;
            ID_EX_mem_to_reg<=0;
            ID_EX_bus1<=0;
            ID_EX_bus2<=0;
            ID_EX_imm_ext_out<=0;
            ID_EX_mem_rd<=0;
            ID_EX_mem_wr<=0;
            ID_EX_reg_wr<=0;
            ID_EX_funct<=0;
            ID_EX_Branch<=0;
            ID_EX_PC_plus_8<=0;
        end
        else if (hazard_ID_EX==flush)begin
            ID_EX_PC_plus_4<=0;
            ID_EX_shamt<=0;
            ID_EX_reg_dst<=0;
            ID_EX_BranchOp<=0;
            ID_EX_ALUSrc1<=0;
            ID_EX_ALUSrc2<=0;
            ID_EX_ALUOp<=0;
            ID_EX_rs<=0;
            ID_EX_rt<=0;
            ID_EX_rd<=0;
            ID_EX_mem_to_reg<=0;
            ID_EX_bus1<=0;
            ID_EX_bus2<=0;
            ID_EX_imm_ext_out<=0;
            ID_EX_mem_rd<=0;
            ID_EX_mem_wr<=0;
            ID_EX_reg_wr<=0;
            ID_EX_funct<=0;
            ID_EX_Branch<=0;
            ID_EX_PC_plus_8<=0;
        end

        else if (hazard_ID_EX==normal) begin
            ID_EX_PC_plus_4<=IF_ID_PC_plus_4;
            ID_EX_shamt<=IF_ID_shamt;
            ID_EX_reg_dst<=IF_ID_reg_dst;
            ID_EX_BranchOp<=IF_ID_BranchOp;
            ID_EX_ALUSrc1<=IF_ID_ALUSrc1;
            ID_EX_ALUSrc2<=IF_ID_ALUSrc2;
            ID_EX_ALUOp<=IF_ID_ALUOp;
            ID_EX_rs<=IF_ID_rs;
            ID_EX_rt<=IF_ID_rt;
            ID_EX_rd<=IF_ID_rd;
            ID_EX_mem_to_reg<=IF_ID_mem_to_reg;
            ID_EX_bus1<=IF_ID_bus1;
            ID_EX_bus2<=IF_ID_bus2;
            ID_EX_imm_ext_out<=IF_ID_imm_ext_out;
            ID_EX_mem_rd<=IF_ID_mem_rd;
            ID_EX_mem_wr<=IF_ID_mem_wr;
            ID_EX_reg_wr<=IF_ID_reg_wr;
            ID_EX_funct<=IF_ID_funct;
            ID_EX_Branch<=IF_ID_Branch;
            ID_EX_PC_plus_8<=IF_ID_PC_plus_8;
        end
end

endmodule