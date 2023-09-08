//IF_ID.v
//IF-ID interphase register.
//Passing {PC,PC+4,PC+8} downstream.
//supports hazard handling inside.
module IF_ID (
input clk,
input reset,
input [1:0]hazard_IF_ID,
input [31:0]Inst,
input [31:0]PC_plus_4,
input [31:0]PC_plus_8,

output reg[31:0]IF_ID_Inst,
output reg[31:0]IF_ID_PC_plus_4,
output reg[31:0]IF_ID_PC_plus_8
);

parameter Normal = 2'b00;
parameter Flush = 2'b01;
parameter Stall = 2'b10;

always @(posedge clk or posedge reset)begin

    if (reset) begin
        IF_ID_Inst<=0;
        IF_ID_PC_plus_4<=0;
        IF_ID_PC_plus_8<=0;    
    end
    else begin
    if (hazard_IF_ID==Flush)begin
        IF_ID_Inst<=0;
        IF_ID_PC_plus_4<=0;
        IF_ID_PC_plus_8<=0;  
    end
    else if(hazard_IF_ID==Stall)begin
        IF_ID_Inst<=IF_ID_Inst;
        IF_ID_PC_plus_4<=IF_ID_PC_plus_4;
        IF_ID_PC_plus_8<=IF_ID_PC_plus_8;
    end
    else begin                              //default and hazard_IF_ID==Normal
        IF_ID_Inst<=Inst;
        IF_ID_PC_plus_4<=PC_plus_4;
        IF_ID_PC_plus_8<=PC_plus_8;
    end 
    
    end
end    
endmodule