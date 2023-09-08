
//PC.v
//program counter,  that only handles Control Hazard and naively updates PC.
//(the correct new PC is computed outside this module.)
module PC(
    input clk   ,
    input reset ,
    input KeepPC,           //whether a PC hazard is detected and that we have to keep PC.
    input [31:0]PC_new,           //new PC, just updated at the start of the cycle.
    output reg[31:0]  PC    //current PC, will be fed to InstMem
);
	wire [31 :0] PC_plus_4;

	always @(posedge reset or posedge clk) begin
        if (reset)
			PC <= 32'h00000000;
		else begin
            case (KeepPC)
                1:PC<=PC;
                default:PC <= PC_new;
            endcase
        end
    end
endmodule