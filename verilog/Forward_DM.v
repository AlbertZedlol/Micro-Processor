//Forward_DM.v
//This unit analyzes input signals and 
//lw-sw hazard:
module Forward_DM(
     //lw-sw hazard
    input  [32-1:0]EX_MEM_ALU_in2_reg_forward,
    input  [32-1:0]MEM_WB_mem_rd_addr, 
    input  [32-1:0]EX_MEM_mem_wr_addr, 
    input          EX_MEM_mem_wr,
    input          MEM_WB_mem_rd,
    input  [32-1:0]MEM_WB_mem_rd_data,//data read directly from DM
    output [32-1:0]EX_MEM_mem_wr_data//the data written to the DM.(could be the forwarded data from the previous lw when lw-sw hazard occurs.)
);
//          MEM/WB           -->EX/MEM
//          alters the data fed into RegFile during WB.
wire is_lw;
wire is_sw;
wire lw_sw_cflct;//conflict

assign is_lw         =MEM_WB_mem_rd;
assign is_sw         =EX_MEM_mem_wr && EX_MEM_mem_wr_addr!=0;
assign lw_sw_cflct=(MEM_WB_mem_rd_addr==EX_MEM_mem_wr_addr);

assign EX_MEM_mem_wr_data=
    (is_lw && is_sw && lw_sw_cflct)? MEM_WB_mem_rd_data:
    EX_MEM_ALU_in2_reg_forward;
    //the output of ALU's second outlet. could be the data from regfile/forward result.
endmodule