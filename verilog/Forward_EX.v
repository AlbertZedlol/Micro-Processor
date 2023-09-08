
//Forward_EX.v
//Forwarding unit.
//This unit analyzes input signals and 
//tells the processor how to handle data hazards(
//EX hazard) by forwarding.
//(which data should be fed into the ALU/RegFile in advance 
//given that specific data hazards are detected.)

module Forward_EX(
    //EX hazard(forward to EX stage)
    input  [5 -1:0]ID_EX_rs,
    input  [5 -1:0]ID_EX_rt,

    input  EX_MEM_reg_wr,     //enable signal
    input  [4:0]EX_MEM_reg_wr_addr,//possible value: rt, rd, ra
    
    input  MEM_WB_reg_wr,
    input  [4:0]MEM_WB_reg_wr_addr,//possible value: rt, rd, ra.
    input  [32-1:0]ID_EX_bus1,//data read from the regfile after ID stage, at outlet A(rs)
    input  [32-1:0]ID_EX_bus2,//at outlet B (rt/rd)
    input  [32-1:0]EX_MEM_ALU_out,//data computed by the ALU
    input  [32-1:0]MEM_WB_reg_wr_data,
    output [32-1:0]ALU_in1_reg_forward,//suggested input for ALU channel 1 given that the data comes from register file (rs,rt,rd) or forwarding(DM, ALU)
    output [32-1:0]ALU_in2_reg_forward
);

//EX hazard:
//          EX/MEM or MEM/WB -->ID/EX
//          alters the data fed into ALU inputs. during EX.

wire EX_MEM_EX_rs;//forward rs from EX_MEM to EX entrance.
assign EX_MEM_EX_rs=(EX_MEM_reg_wr &&(EX_MEM_reg_wr_addr!=0)&& EX_MEM_reg_wr_addr==ID_EX_rs);

wire EX_MEM_EX_rt;
assign EX_MEM_EX_rt=(EX_MEM_reg_wr &&(EX_MEM_reg_wr_addr!=0)&& EX_MEM_reg_wr_addr==ID_EX_rt);

wire MEM_WB_EX_rs;
assign MEM_WB_EX_rs=(MEM_WB_reg_wr &&(MEM_WB_reg_wr_addr!=0)&& MEM_WB_reg_wr_addr==ID_EX_rs);

wire MEM_WB_EX_rt;
assign MEM_WB_EX_rt=(MEM_WB_reg_wr &&(MEM_WB_reg_wr_addr!=0)&& MEM_WB_reg_wr_addr==ID_EX_rt);

assign ALU_in1_reg_forward=
    EX_MEM_EX_rs?EX_MEM_ALU_out:
    (MEM_WB_EX_rs?MEM_WB_reg_wr_data:
    ID_EX_bus1);

assign ALU_in2_reg_forward=
    EX_MEM_EX_rt?EX_MEM_ALU_out:
    (MEM_WB_EX_rt?MEM_WB_reg_wr_data:
    ID_EX_bus2);

endmodule
