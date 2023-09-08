//Hazard.v
//Hazard Unit
module Hazard(
    //load-use
    input [4:0]IF_ID_rs,
    input [4:0]IF_ID_rt,
    input ID_EX_mem_rd,
    //whether is branch/jump
    input   Branch, 
    input   Jump  ,
    input [4:0]ID_EX_rt,
    
    //output: hazard types
    output  KeepPC,//whether PC<=PC;
    output  [2-1:0]hazard_IF_ID, //2'b01: Flush   2'b10:Stall(Keep)   2'b00: Normal
    output  hazard_ID_EX  //1:flush 0:normal
);

wire load_use;
assign load_use=(ID_EX_mem_rd && ID_EX_rt == IF_ID_rs)||(ID_EX_mem_rd && ID_EX_rt == IF_ID_rt);

assign KeepPC=load_use?1:0;

parameter Flush = 2'b01;
parameter Stall = 2'b10;
parameter Normal = 2'b00;

assign hazard_IF_ID=
    load_use?Stall:
    (Jump||Branch)?Flush:
    Normal;

assign hazard_ID_EX=
    (load_use||Branch)?1:Normal;

endmodule