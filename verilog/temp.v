    In this 32-bit MIPS architecture, the unit of a data block is 32bits(one word)
    If we do not introduce the read byte operation, we will assume that each read operation access one unit (one word, 4 bytes, 32 bits).
    That's why we build the main memory by reg[31:0].
    
    The memory is organized in the fashion of vectors, and we customize its size to 256 WORDS.
    Then the memory is a vector with len=256, unit =1 WORD.
    RAM_data[i] means the data in the i+1-th register.
    
    when memory is read, we only need to retrieve the information in a unit (one word), 
    so we only need to specify the index of the register(32bits) we are accessing.
    To fully represent the indices, we need at least log_2(RAM_SIZE)=log_2(512)=9 bits.
    we use "RAM_ID_BIT_LEN" to represent this value
    RAM_data is an array of 512 32-bit registers (which is 2048xBytes in the Byte address)
    They correspond to the byte addresses 0x0000_0000 ~ 0x0000_07FF (4'd0000~4'd2047 bytes)   

    parameter RAM_SIZE        = 512;
    parameter RAM_ID_BIT_LEN  = $clog2(RAM_SIZE);//RAM_ID_BIT_LEN=log_2(RAM_SIZE)       
    reg [32-1:0] RAM_data [RAM_SIZE - 1: 0];

    Device_data: in this application, only BCD is used as a device, it only takes 12 bits.(<=1WORD)
    We place the BCD's data in the byte address 0x4000_0010 and 0x4000_0011
    
    parameter DEVICE_SIZE      = 32;
    parameter DEVICE_ID_BIT_LEN  = $clog2(DEVICE_SIZE);
    reg [32-1:0] DEVICE_data [DEVICE_SIZE - 1: 0];

    Byte Address Distribution
    Data Memory:  32'b0~32'b
                 0x0000~0x3FFFF_FFFF
    Device Mem :  32'0100_0000_0000_0000_0000_0000_0000_0000~32'b011111111111111111111111111111111111
                 0x4000_0000~0x7FFFF_FFFF
    To distinguish DM and DeviceMEM:  whether Address[30](the second MSB) is >=1.
