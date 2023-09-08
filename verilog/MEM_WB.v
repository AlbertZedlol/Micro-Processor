//MEM_WB.v
//MEM-WB interphase register

//reset: zero
//else : transport
//total: 6 entries
module MEM_WB (
input clk,
input reset,
input [2-1:0]EX_MEM_mem_to_reg,
input [32 -1:0]EX_MEM_ALU_out,
input [31:0]EX_MEM_mem_rd_data,
input [31:0]EX_MEM_mem_rd_addr,
input EX_MEM_reg_wr,
input [4:0]EX_MEM_reg_wr_addr,
input [32-1:0]EX_MEM_PC_plus_8,
input EX_MEM_mem_rd,               //for forwarding to DM

//output [31:0]MEM_WB_reg_wr_data, this is used for forwarding and created by wb.It should not be passed from EX_MEM.
output reg [31:0]MEM_WB_mem_rd_data,
output reg [2-1:0]MEM_WB_mem_to_reg,
output reg [32 -1:0]MEM_WB_ALU_out,
output reg [31:0]MEM_WB_mem_rd_addr,//this is for forwarding.
output reg MEM_WB_reg_wr,
output reg MEM_WB_mem_rd,               //for forwarding to DM
output reg [4:0]MEM_WB_reg_wr_addr,
output reg [32-1:0]MEM_WB_PC_plus_8
);
    always @(posedge clk or posedge reset)begin
        if(reset)begin
            MEM_WB_mem_to_reg <=0;
            MEM_WB_ALU_out    <=0;
            MEM_WB_mem_rd_addr<=0;
            MEM_WB_reg_wr     <=0;
            MEM_WB_reg_wr_addr<=0;
            MEM_WB_PC_plus_8  <=0;
            MEM_WB_mem_rd_data<=0;
            MEM_WB_mem_rd     <=0;
        end

        else begin
            
            MEM_WB_mem_to_reg <=EX_MEM_mem_to_reg;
            MEM_WB_ALU_out    <=EX_MEM_ALU_out;
            MEM_WB_mem_rd_addr<=EX_MEM_mem_rd_addr;
            MEM_WB_reg_wr     <=EX_MEM_reg_wr;
            MEM_WB_reg_wr_addr<=EX_MEM_reg_wr_addr;
            MEM_WB_PC_plus_8  <=EX_MEM_PC_plus_8;
            MEM_WB_mem_rd_data<=EX_MEM_mem_rd_data;
            MEM_WB_mem_rd     <=EX_MEM_mem_rd;
        end
    end
endmodule
