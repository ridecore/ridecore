# UART
set_property PACKAGE_PIN AU36 [get_ports TXD]
set_property IOSTANDARD LVCMOS18 [get_ports TXD]
set_property PACKAGE_PIN AU33 [get_ports RXD]
set_property IOSTANDARD LVCMOS18 [get_ports RXD]

# LED
set_property PACKAGE_PIN AM39 [get_ports LED[0]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[0]]
set_property PACKAGE_PIN AN39 [get_ports LED[1]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[1]]
set_property PACKAGE_PIN AR37 [get_ports LED[2]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[2]]
set_property PACKAGE_PIN AT37 [get_ports LED[3]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[3]]
set_property PACKAGE_PIN AR35 [get_ports LED[4]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[4]]
set_property PACKAGE_PIN AP41 [get_ports LED[5]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[5]]
set_property PACKAGE_PIN AP42 [get_ports LED[6]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[6]]
set_property PACKAGE_PIN AU39 [get_ports LED[7]]
set_property IOSTANDARD LVCMOS18 [get_ports LED[7]]

# CLK
# PadFunction: IO_L12P_T1_MRCC_38 
set_property VCCAUX_IO DONTCARE [get_ports {CLK_P}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {CLK_P}]
set_property PACKAGE_PIN E19 [get_ports {CLK_P}]

# PadFunction: IO_L12N_T1_MRCC_38 
set_property VCCAUX_IO DONTCARE [get_ports {CLK_N}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {CLK_N}]
set_property PACKAGE_PIN E18 [get_ports {CLK_N}]

# PadFunction: IO_L13N_T2_MRCC_15 
set_property VCCAUX_IO DONTCARE [get_ports {RST_X_IN}]
set_property IOSTANDARD LVCMOS18 [get_ports {RST_X_IN}]
set_property PACKAGE_PIN AW40 [get_ports {RST_X_IN}]
