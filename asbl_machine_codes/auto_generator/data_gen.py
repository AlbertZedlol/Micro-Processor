


mode="verilog"

filename="data_gen.txt"
dat_raw=[  6,
           0, 9, 3, 6,-1,-1, 0, 0,
           9, 0,-1, 3, 4, 1, 0, 0,
           3,-1, 0, 2,-1, 5, 0, 0,
           6, 3, 2, 0, 6,-1, 0, 0,
           -1,4,-1, 6, 0, 2, 0, 0,
           -1,1, 5,-1, 2, 0, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 0,
           0, 0, 0, 0, 0, 0, 0, 0]
with open(filename,mode='w') as f:
    
    
    if mode=="C":
        for i,  dat in enumerate(dat_raw):
            line="buffer["+str(i)+"] = "+str(dat)+";\n"
            f.write(line)
    elif mode=="verilog":
        for i,  dat in enumerate(dat_raw):
            line="RAM_DATA["+str(16+i)+"] = "+str(dat)+";\n"
            f.write(line)