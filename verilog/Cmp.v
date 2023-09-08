//Cmp.v
//Compare Unit for branch family.

module Cmp(
    input [3-1:0]BranchOp,
    input [32-1:0]op1,
    input [32-1:0]op2,
    output Zero
);
//the prefix 't_' means "type:"
parameter t_beq=  3'b000;
parameter t_bne=  3'b001;

assign Zero=
    (BranchOp==t_beq)?(op1==op2):
    (BranchOp==t_bne)?(~(op1==op2)):
    0;
endmodule

//here we do not introduce explicit comparisons
//for bltz etc. because we break them into the 
//combinations of slt and beq/bne.
//Details:
//bltz $rs, label  <==> slt $1, $rs, $0   bne $1, $0,label
//bgtz $rs, label  <==> slt $1, $0,  $rs  bne $1, $0, label
//blez $rs, label  <==> slt $1, $0,  $rs  beq $1, $0, label 