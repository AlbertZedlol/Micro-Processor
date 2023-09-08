
module RegisterFile(
	input  reset                    , 
	input  clk                      ,
	input  RegWrite                 ,//register write enable signal.
	input  [5 -1:0]  Read_register1 , 
	input  [5 -1:0]  Read_register2 , 
	input  [5 -1:0]  Write_register ,
	input  [32 -1:0] Write_data     ,
	output [32 -1:0] Read_data1     , 
	output [32 -1:0] Read_data2
);

	// RF_data is an array of 32 32-bit registers
	// [WARNING]RF_data[0] is the $zero register. It READ ONLY.
	reg [31:0] RF_data[31:0];
	
	// read data from RF_data as Read_data1 and Read_data2
	//<New>Write-first-then-read (WFTR)
	assign Read_data1 = 
		(Read_register1 == 5'b00000)? 32'h00000000: 			//check whether $zero
		(Read_register1 == Write_register)?Write_data:			//guarantee WFTR
		RF_data[Read_register1];

	assign Read_data2 = 
		(Read_register2 == 5'b00000)? 32'h00000000: 
		(Read_register2 == Write_register)?Write_data:
		RF_data[Read_register2];
	
	// write data back to RF
	integer i;
	always @(posedge reset or posedge clk)begin
		if (reset) begin
			for (i = 0; i < 32; i = i + 1)begin
				RF_data[i] <= 32'h00000000;
		end
		end
		else if (RegWrite && (Write_register != 5'b00000))begin	//always protect $zero.
			RF_data[Write_register] <= Write_data;
		end
	end
endmodule
			