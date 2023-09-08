#asbl.asm
#assembly codes as instructions.
#Dijkstra Algorithm
############################################################################################################################################################
#Filename: sssp_dijkstra.asm
#Author:   Tonghe Zhang  4/29/2023 revivsed date:7/24/2023
#Desciption:djikstra search algorithm in MIPS assembly language.
#with BCD display plug-in
############################################################################################################################################################
.data
filename: .asciiz "test.dat"

.align 4                                # filename: .asciiz "test.dat"
buffer:   .space  4100   #4100           shrink buffer to a 8x8 matrix, with an additional first element [0] indicating number of nodes(n=6)
dist:     .space  128    #128
visited:  .space  128    #128

#AN  - loop for cycles operation: <<1, +1
#           control this scan by a small FSM:
#           BIN     HEX         DEC     Display digit place
#           0001    0000_0001   1       ones
#         0|0010                        tens
#        00|0100                        hundreds
#       000|1000    0000_0008   8       thousands
#      0001|0000    0000_0010           restart...

#rememeber that the return value of dijkstra($a0, now in $t1)
#is a 32-bit binary number.            32'b0000_0000_0000_0000_0001_0010_0011_0100  
#out aim is to print it as a 4-bit hexadecimal number       4'h  1    2    3    4
#and we print each number place in a 'scan'.
#to retrieve the last digit from the hex number <==> get the last 4 digits from bin.
#<==> execute "AND" operation with     32'b0000_0000_0000_0000_0000_0000_0000_1111
#to retrieve the "tens", we first right shift the bin number, then perform the trick
#again.

#since we will keep on displaying the result(keep scanning)
#we are actually writing a dead loop.

.text

j main

#after main has computed the result, we will start to scan it on BCD.
scan_init:
    li $s0,  0x00000000     # s0==BCD-lookup table head address :0x0000_0000
    li $s1,  0x40000010     # s1==12 bit BCD code output address  
    li $s2,  0x00000010     # s2==end state of   AN        0001|0000=EF(hex)
    
    li $t0,  0x00000001     # t0==start state of AN             0001==1(hex)
    move $t1, $a0           # Return value after calling .main is stored in $a0(34 using test.dat)

scan:
    andi $t2, $t1, 15       # GET THE LAST DIGIT.
                            # t2:the last digit of the hex number. Will be printed on BCD. here 15 ==4'b1111
    
    sll $t2, $t2, 2         # FIND ITS BCD7 CODE. (by referring back to the main memory)
                            # convert id(in WORD) to byte-address.
    add $t3, $t2, $s0       # t3==the BCD7 lookup table addr of the last digit. from t3 on there is a 32bit bin number
                            # whos last 8 digits are the BCD7code of this digit and the other digits are all 0.
    lw $t4, 0($t3)          # t4=the BCD7 code for the last digit. 

    sll $t5, $t0, 8         # CONCATENATE WITH AN->FULL BCD
                            # t0==AN, t3=AN<<8. Now since BCD code occupies 8 bits, we shift it leftward 8 bits so that AN and
                            # BCD7 can concatenate together.
    add $t6, $t5,$t4        # t6={AN,BCD7}, 12-bit BCD code.full length.
    
    sw $t6, 0($s1)          # WRITE BCD TO $s1.(see definition above)
                            # the CPU will immediately assign value in $s1 to its output [11:0]BCD, which will
                            # be attached to the hardward and light up LEDs.

    srl $t1, $t1, 4         # UPDATE LAST DIGIT
                            # num >> 4, put the second-to-last digit to the tail. 
    sll $t0, $t0, 1         # UPDATE AN:    AN_new = AN << 1

    bne $t0, $s2,scan       # RESTART AFTER 4 DIGITS ALL SCANNED
    
scan_restart:    
    li $t0,  0x00000001     # t0==start state of AN             0001==1(hex)
    move $t1, $a1           # Return value after calling .main is stored in $a1(34 using test.dat)
    j scan

main:



.text
main:
    # Open file
    la   $a0, filename  # load filename
    li   $a1, 0         # flag
    li   $a2, 0         # mode
    li   $v0, 13        # open file syscall index
    syscall
    # Read file
    move $a0, $v0       # load file description to $a0
    la   $a1, buffer    # buffer address
    li   $a2, 4100      # buffer size
    li   $v0, 14        # read file syscall index
    syscall
    # Close file
    li   $v0, 16        # close file syscall index
    syscall
    
    # Parameters
    la $t0,buffer
    add  $a1, $0, $t0   # set $a1 to n
    lw   $s0, 0($t0)    # set $s0 to n
    addi $a1, $t0, 4    # set $a1 to &graph=buffer+1;
	
    
    # Call Dijkstra
    jal  dijkstra

    # Sum Result
    li   $t0, 1             #delay slot.
    li   $t0, 1
    la   $t1, dist          #put t1 at the head of the distance vector.
    li   $a1, 0             #set a1==sum of distances=0;
sum_up:
        addi $t1, $t1, 4

        lw   $t2, 0($t1)    # t2=dist[i];
        
	    add $a1, $a1, $t2   # sum+=dist[i]

        addi $t0, $t0, 1
        blt  $t0, $s0, sum_up

    # Return sum of the distances to $a0
    add $t0, $t0, $zero#if we don't write this line, beq and j will incur a conflict to update PC_new
    add $t0, $zero, $t0	#the following two lines will be flushed because of the blt even if blt don't branch.
    j scan_init			

#parameter in C--------register name
#int  n                      $s0
#int* dist                   $s1
#int* graph                  $s2
#int* visited                $s3
#int* &dist[i]               $t0
#int* &dist[v]               $t1
#int* &visited[v,i,u]        $t2
#int  dist[v]                $t3
#int  visited[v]             $t4
#int  graph[i]               $t5
#int  min_dist               $t6
#int  i                      $t7
#int  u                      $t8
#int  v                      $t9
#int  dist[v]                $a0
#int  addr(in bytes)         $a1
#int  graph[addr]            $a2
#int  min+graph[addr]        $a3
#int* &graph[addr]           $gp
#const int 1                 $s6
#const int -1                $s7dijkstra:
    init:
        move $s6, $zero
        add $s6, $s6, 1         #s6==-1
        sub $s7, $zero, 1       #s7==-1

        la $s1, dist            #s1=dist
        move $s2, $a1           #s2=graph
        
        la $s3, visited		#s3=visited
        sw $zero, 0($s1)        #0=>dist[0];
        sw $s6, 0($s3)          #1=>visited[0];
        
        move $s2, $a1		#s2=graph
        
        move $t7, $s6           #for(int i=1;)
        for_1:
            bge $t7,$s0,end_for1#...i<n;
            
            sll $t5, $t7, 2
            add $t5, $s2, $t5
            lw $t5, 0($t5)      #t5=graph[i]

            sll $t0, $t7, 2
            add $t0, $s1, $t0
            
            sw $t5,0($t0)       #graph[i]=>dist[i]
            
            sll $t2, $t7, 2
            add $t2, $s3, $t2
            sw $zero, 0($t2)    #0=>visited[i]

            addi $t7, $t7,1
            j for_1             #i++)
        end_for1:
    end_init:

    move $t7, $s6            #for(int i=1;
    for_2:
        bge $t7, $s0, end_for2#...i<n;

        search_for_nearest_unvisited_node:
            move $t8, $s7                   #int u=-1
            move $t6, $s7                   #min_dist=-1
            
            move $t9, $s6                   #for(int v=1;
            for_3:
                bge $t9,$s0,end_for3

                if_1:
                    sll $t2, $t9,2
                    add $t2, $s3,$t2
                    lw $t4, 0($t2)          #t4=visited[v]

                    sll $t1, $t9,2
                    add $t1, $s1,$t1
                    lw $t3, 0($t1)          #t3=dist[v]

                    bnez $t4,continue_1     #if(visitied[v]!=0||
                    beq  $t3,$s7,continue_1     #dist[v]==-1)
                    
                    beq  $t6,$s7, update_1  #if(min_dist==-1
                    blt  $t3,$t6, update_1  #||dist[v]<min_dist)
                    j continue_1

                    update_1:
                        move $t6, $t3       #min_dist<=dist[v]
                        move $t8, $t9       #u<=v

                continue_1:
                    addi $t9, $t9,1
                    j for_3
            end_for3:

            beq $t6, $s7, return            #if (min_dist == -1) return;

        update:
            sll $t2, $t8, 2
            add $t2, $s3, $t2
            sw $s6,0($t2)                   #visited[u]<=1
            move $t9, $s6                   #int v=1;
            for_4:
                bge $t9, $s0,end_for4

                sll $t2, $t9,2
                add $t2, $s3,$t2
                lw $t4, 0($t2)              #t4=visited[v]

                sll $a1, $t8, 5             #addr=(u<<5)
                add $a1,$a1, $t9            #addr=(u<<5)+v (in Words)
                sll $a1, $a1, 2             #addr=(u<<5)+v (in Bytes)
                add $gp, $s2, $a1           #gp=&graph[addr]    
                lw $a2, 0($gp)              #a2=graph[addr]
                
                if_2:
                    bnez $t4, continue_2    #if (visited[v] != 0) continue;
                
                if_3:
                    beq $a2, $s7, continue_2    #if(graph[addr]==-1) continue
                if_4:
                    sll $t1, $t9,2
                    add $t1, $s1,$t1            #t1=&dist[v]
                    lw $a0, 0($t1)              #a0=dist[v]

                    add $a3, $t6, $a2           #a3=min_dist+graph[addr] 

                    beq $a0, $s7,update_2       #if (dist[v] == -1
                    bgt $a0, $a3,update_2       #|| dist[v] > min_dist + graph[addr])
                    j continue_2    

                    update_2:
                        sw $a3, 0($t1)          #dist[v]<=min_dist + graph[addr]

                continue_2:
                    addi $t9, $t9, 1        
                    j for_4                     #v++)
            end_for4:
        addi $t7, $t7,1       #i++)
        j for_2
    end_for2:

    return:
        jr $ra