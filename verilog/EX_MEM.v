//EX_MEM.v
//EX-MEM interphase register
//reset: zero
//else : transport
//total: 10  entries
module EX_MEM (
    input clk,
    input reset,
    
    input [31:0]ID_EX_ALU_out,
    input [31:0]ID_EX_ALU_in2_reg_forward,
    input ID_EX_mem_rd,
    input ID_EX_mem_wr,
    input [2-1:0]ID_EX_mem_to_reg,
    
    input ID_EX_reg_wr,
    input [4:0]ID_EX_reg_wr_addr,
    input [32-1:0]ID_EX_PC_plus_8,
    input [31:0]ID_EX_mem_rd_addr,
    input [31:0]ID_EX_mem_wr_addr,


    output reg [31:0]EX_MEM_ALU_out,
    output reg [31:0]EX_MEM_ALU_in2_reg_forward,
    output reg EX_MEM_mem_rd,
    output reg EX_MEM_mem_wr,
    output reg [2-1:0]EX_MEM_mem_to_reg,
    output reg [31:0]EX_MEM_mem_rd_addr,
    output reg [31:0]EX_MEM_mem_wr_addr,
    output reg EX_MEM_reg_wr,
    output reg [4:0]EX_MEM_reg_wr_addr,
    output reg [32-1:0]EX_MEM_PC_plus_8
);

//Forward device writes to it.
// output [31:0]EX_MEM_mem_rd_data,//EX_MEM don't need to output this.
//because it is the output of DM, not the input. We only need to define this wire before and only use it as a container.
// output [31:0]EX_MEM_mem_wr_data,
//don't need to be passed by EX_MEM.
//because it is output by  Forward DM unit, and it is from in2_reg_forward.

always @(posedge clk or posedge reset)begin
        if(reset)begin
            EX_MEM_ALU_out<=0;
            EX_MEM_ALU_in2_reg_forward<=0;
            EX_MEM_mem_rd<=0;
            EX_MEM_mem_wr<=0;
            EX_MEM_mem_to_reg<=0;
            EX_MEM_mem_rd_addr<=0;
            EX_MEM_reg_wr<=0;
            EX_MEM_reg_wr_addr<=0;
            EX_MEM_PC_plus_8<=0;
            EX_MEM_mem_wr_addr<=0;
        end
        else begin
            EX_MEM_ALU_out<=ID_EX_ALU_out;
            EX_MEM_ALU_in2_reg_forward<=ID_EX_ALU_in2_reg_forward;
            EX_MEM_mem_rd<=ID_EX_mem_rd;
            EX_MEM_mem_wr<=ID_EX_mem_wr;
            EX_MEM_mem_to_reg<=ID_EX_mem_to_reg;
            
            EX_MEM_reg_wr<=ID_EX_reg_wr;
            EX_MEM_reg_wr_addr<=ID_EX_reg_wr_addr;
            EX_MEM_PC_plus_8<=ID_EX_PC_plus_8;
            EX_MEM_mem_rd_addr<= ID_EX_mem_rd_addr;
            EX_MEM_mem_wr_addr<=ID_EX_mem_wr_addr;
        end
    end

endmodule
