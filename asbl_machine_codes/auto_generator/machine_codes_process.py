

raw_machine_codes_file_name="dijkstra_machine_codes_AN_reversed_raw.txt"
machine_code_file_name="dijkstra_machine_code_AN_reversed_processed.txt"



with open(raw_machine_codes_file_name,mode='r') as f:
    A=f.readlines()
    B=[]
    for i,code in enumerate(A):
        B.append('8\'d'+str(i)+':'+"\t"+"Instruction<="+"32\'h"+str(code[0:-1])+";\n")
    
with open(machine_code_file_name,mode='w') as f:
    for line in B:
        f.write(line)

