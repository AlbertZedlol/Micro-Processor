//ImmExt.v 
//Immediate Extension Unit
module ImmExt(
    input Ext_op, //Ext_Op=1, when 'signed extension'. Exp_Op=0, when 'unsigned extension'.
    input LuOp,   //Load Upper Immediate. =1, when lui. =0, else.
    input [16-1:0]Imm, //immediate.    
        
    output [31:0] ImmExt_out//extension result with the possibility of upper half included.
);
    wire [32 -1:0] Ext;         

    //Ext: the signed/unsigned extension of the immediate.  
    //understand this line:
    //ExtOp? {16{Imm[15]}}: 16'h0000 is a 16bit prefix. It is decided by ExtOp?
    //if ExtOp==1, the result is 16{Imm[15]}, which means to copy the first bit(sign bit) of Imm for 16 times.
    // this means signed extension. 
    //if ExtOp==0, the result is 16'h0000, which is unsigned prefix.
    //Ext is the prefix + suffix, which is {16'h1111...,Imm} or {16'h0000,Imm}.          
    assign Ext = { Ext_op? {16{Imm[15]}}: 16'h0000, Imm};
                            //signed ext //unsigned ext
    
    //ImmExt_out: 
    //if the instruction is not lui, it is the same as Ext.
    //if is lui, then returnt the UPPER 16 bits of Imm, and append it with zeros to become a 32-bit number.(upper immediate)
    assign  ImmExt_out= LuOp? {Imm[15:0], 16'h0000}: Ext;

endmodule


