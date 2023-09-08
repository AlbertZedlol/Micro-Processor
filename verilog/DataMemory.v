
//DataMemory.v

module DataMemory(
	input  reset    , 
	input  clk      ,  
	input  MemRead  ,
	input  MemWrite ,
	input  [32 -1:0] Address    ,
	input  [32 -1:0] Write_data ,

	output [32 -1:0] Read_data,
	output [12 -1:0] BCD_out
);
	// In this 32-bit MIPS architecture, the unit of a data block is 32bits(one word.)
	// If we do not introduce the read byte operation, 
	// we will assume that each read operation access one unit (one word, 4 bytes, 32 bits).
	// That's why we build the main memory by reg[31:0].
	//
	// The memory is organized in the fashion of vectors, and we customize its size to 256 WORDS.
	// Then the memory is a vector with len=256, unit =1 WORD.
	// RAM_data[i] means the data in the i+1-th register.
	//
	// when memory is read, we only need to retrieve the information in a unit (one word), 
	// so we only need to specify the index of the register(32bits) we are accessing.
	// To fully represent the indices, we need at least log_2(RAM_SIZE)=log_2(512)=9 bits.
	// we use "RAM_ID_BIT_LEN" to represent this value
	// RAM_data is an array of 512 32-bit registers (which is 2048xBytes in the Byte address)
	// They correspond to the byte addresses 0x0000_0000 ~ 0x0000_07FF (4'd0000~4'd2047 bytes)											   
	parameter RAM_SIZE        = 512;
	parameter RAM_ID_BIT_LEN  = $clog2(RAM_SIZE);//RAM_ID_BIT_LEN=log_2(RAM_SIZE)		
	reg [32-1:0] RAM_data [RAM_SIZE - 1: 0];

	//Device_data: in this application, only BCD is used as a device, it only takes 12 bits.(<=1WORD)
	//We place the BCD's data in the byte address 0x4000_0010 and 0x4000_0011
	parameter DEVICE_SIZE      = 32;
	parameter DEVICE_ID_BIT_LEN  = $clog2(DEVICE_SIZE);
	reg [32-1:0] DEVICE_data [DEVICE_SIZE - 1: 0];

	//Byte Address Distribution
	//Data Memory:  32'b0~32'b
	//				0x0000~0x3FFFF_FFFF
	//Device Mem :	32'0100_0000_0000_0000_0000_0000_0000_0000~32'b011111111111111111111111111111111111
	//				0x4000_0000~0x7FFFF_FFFF
	//To distinguish DM and DeviceMEM:  whether Address[30](the second MSB) is >=1.
	
	//<Write> data to RAM_data/DEVICE_data at clock posedge
	integer i;
	always @(posedge reset or posedge clk)begin
		if (reset)begin
			for (i = 0; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
			for (i = 0; i < DEVICE_SIZE; i = i + 1)
				DEVICE_data[i] <= 32'h00000000;//<New>

			//<Initialize RAM_data> Manually
			
			//Initialize 8-bit BCD7 look-up table
				//The MIPS assembly codes access this region of DM to convert hexadecimal
				//to 8-bit BCD7code which is a part of the 12-digit full length BCD codes.
				//in the MIPS assembly code, the 12-digit BCD codes(with Decimal Place included, 
				//here DP==1, disabled)
				//are located in the places that start from byte-address 0x0000_0000(according to the MIPS code)
				//this is the first byte in the memory, 
				//the first WORD in the memory, 
				//the first element in the memory array-----RAM_data[0]

				//format:			     DP-G-F-E-D-C-B-A
				RAM_data[0]  <= {24'b0, 8'b00111111};//8-bit BCD code for '0', with DP included.
				RAM_data[1]  <= {24'b0, 8'b00000110};//8-bit BCD code for '1', with DP included.
				RAM_data[2]  <= {24'b0, 8'b01011011};//8-bit BCD code for '2', with DP included.
				RAM_data[3]  <= {24'b0, 8'b01001111};//8-bit BCD code for '3', with DP included.
				RAM_data[4]  <= {24'b0, 8'b01100110};//8-bit BCD code for '4', with DP included.
				RAM_data[5]  <= {24'b0, 8'b01101101};//8-bit BCD code for '5', with DP included.
				RAM_data[6]  <= {24'b0, 8'b01111101};//8-bit BCD code for '6', with DP included.
				RAM_data[7]  <= {24'b0, 8'b00000111};//8-bit BCD code for '7', with DP included.
				RAM_data[8]  <= {24'b0, 8'b01111111};//8-bit BCD code for '8', with DP included.
				RAM_data[9]  <= {24'b0, 8'b01101111};//8-bit BCD code for '9', with DP included.
				RAM_data[10] <= {24'b0, 8'b01110111};//8-bit BCD code for 'A', with DP included.
				RAM_data[11] <= {24'b0, 8'b01111100};//8-bit BCD code for 'B', with DP included.
				RAM_data[12] <= {24'b0, 8'b00111001};//8-bit BCD code for 'C', with DP included.
				RAM_data[13] <= {24'b0, 8'b01011110};//8-bit BCD code for 'D', with DP included.
				RAM_data[14] <= {24'b0, 8'b01111001};//8-bit BCD code for 'E', with DP included.
				RAM_data[15] <= {24'b0, 8'b01110001};//8-bit BCD code for 'F', with DP included.

			//Initialize dijikstra buffer. 
			//Address starts from RAM_data[16]----0x0000_0040 the 64-th byte, the 16-th WORD.
				// dat_raw=[  
				// 	6,
				// 	0, 9, 3, 6,-1,-1, 0, 0,
				// 	9, 0,-1, 3, 4, 1, 0, 0,
				// 	3,-1, 0, 2,-1, 5, 0, 0,
				// 	6, 3, 2, 0, 6,-1, 0, 0,
				// 	-1,4,-1, 6, 0, 2, 0, 0,
				// 	-1,1, 5,-1, 2, 0, 0, 0,
				// 	0, 0, 0, 0, 0, 0, 0, 0,
				// 	0, 0, 0, 0, 0, 0, 0, 0]


 //for test only
				RAM_data[16] <= 6;
				RAM_data[17] <= 1;
				RAM_data[18] <= 2;
				RAM_data[19] <= 3;
				RAM_data[20] <= 4;
				RAM_data[21] <= 5;
				RAM_data[22] <= 6;
				RAM_data[23] <= 7;
				RAM_data[24] <= 8;
				RAM_data[25] <= 9;
				RAM_data[26] <= 10;
				RAM_data[27] <= 11;
				RAM_data[28] <= 12;
				RAM_data[29] <= 13;
				RAM_data[30] <= 14;
				RAM_data[31] <= 15;
				RAM_data[32] <= 16;
				RAM_data[33] <= 17;
				RAM_data[34] <= 18;
				RAM_data[35] <= 19;
				RAM_data[36] <= 20;
				RAM_data[37] <= 21;
				RAM_data[38] <= 22;
				RAM_data[39] <= 23;
		end
		else if (MemWrite)begin
			case(Address)
			//<New>write device
			32'h4000_0010:		DEVICE_data[4]<=Write_data;//DEVICE_data[Address[(DEVICE_ID_BIT_LEN + 1):2]]<= Write_data;//write to BCD
			default:			RAM_data[Address[(RAM_ID_BIT_LEN + 1):2]] 	   <= Write_data;
			endcase
			//THE REASON WHY WE RESTRICT ADDRESS TO THE FIELD [RAM_ID_BIT_LEN+1:2]
			//IS BECAUSE DUE TO MEMORY, LIMIT, THIS IS THE VALID REGION OF INDEXING IN WORDS.
			//details:
			//the last two bits are always zero, since this is a byte-address system and we are retrieving WORDS.
			//Address: XXXXXXXXXXXXXX[DataId]00;
			//DataId is of lenght log_2(DEVICE_SIZE), which is the minimum width to represent all the WORDS
			//So the DataId== Address[DEVICE_ID_BIT_LEN+1   :  2]
		end
	end

	//<Read>
	// After each scan, the current value of BCD code
	// is stored in Byte address  0x4000_0010
	// which is the 1x16^1==16-th byte in the Device-memory, 
	// that is , the 16/4==4-th WORD in the Device_Mememory, 
	// a.k.a the 4-th element of the Device_Memory array.
	// that is DEVICE_DATA[4]
	// Since the BCD codes are 12 bits binary codes, they 
	// at most occupied the last 12 bits of the WORD. 
	// And we only need the CPU to output a [11:0]binary code to the DEvice.
	// So we only get the top-12 LSBs out of the WORD that stores the value of BCD.
    assign BCD_out = DEVICE_data[4][11:0];
	// Read data from RAM or Device as Read_data
	assign Read_data = 
		Address[30]>=1?  DEVICE_data[Address[DEVICE_ID_BIT_LEN+1:2]]:
		MemRead? 		 RAM_data[Address[RAM_ID_BIT_LEN + 1:2]]: 
		32'h00000000;

	//here Addres[30]>=1 means in hexadecimal, 
	//adddres >= 0x4000_0000
	//because 30 is the second MSB, and 0x4000_0000
	//correspond to 32'b0100_0000_...
	//whose 30-th place is 1.
endmodule
