

create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports clk]

#from the 4-th experiment that uses the new board. 
#R4: clk   100MHZ input clock
#K21:reset Key4 on FPGA board.
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports {clk}]
set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS33} [get_ports {reset}]

#12-bits BCD code:
#BCD  bit :       11   10   9    8   7   6  5  4  3  2  1  0
#Port Name:      AN3  AN2  An1  An0  Dp  G  F  E  D  C  B  A
#Bin  Name:      M2    P2   R1   Y3  V3  W4 P1 T5 U5 V5 P5 N2
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {BCD[0]}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {BCD[1]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {BCD[2]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {BCD[3]}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {BCD[4]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {BCD[5]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {BCD[6]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {BCD[7]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD LVCMOS33} [get_ports {BCD[8]}]
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {BCD[9]}]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {BCD[10]}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {BCD[11]}]