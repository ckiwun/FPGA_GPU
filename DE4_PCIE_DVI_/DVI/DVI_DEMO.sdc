#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock  -period 20 -waveform {0.0 10.0} [get_ports {OSC_50_BANK2}]
create_clock  -period 20 -waveform {0.0 10.0} [get_ports {OSC_50_BANK3}]
create_clock  -period 20 -waveform {0.0 10.0} [get_ports {OSC_50_BANK4}]
create_clock  -period 20 -waveform {0.0 10.0} [get_ports {OSC_50_BANK5}]
create_clock  -period 20 -waveform {0.0 10.0} [get_ports {OSC_50_BANK6}]
create_clock  -period 20 -waveform {0.0 10.0} [get_ports {OSC_50_BANK7}]

#creates virtual clock
create_clock  -period "162 MHz" -name CLK_162
create_clock  -period "25 MHz"  -name CLK_25
#
create_clock -period "162 MHz" 		-name DVI_RX_CLK_MAX  [get_ports DVI_RX_CLK] 
create_clock -period "25 MHz"  		-name DVI_RX_CLK_MIN  [get_ports DVI_RX_CLK] -add
#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay   0.5 -clock_fall -clock CLK_162   [get_ports DVI_RX_D*] 
set_input_delay   0.5 -clock_fall -clock CLK_25    [get_ports DVI_RX_D*] -add_delay  


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -exclusive -group {DVI_RX_CLK_MAX} -group {DVI_RX_CLK_MIN}
set_clock_groups -exclusive -group {CLK_162} -group {CLK_25}
set_clock_groups -exclusive -group {CLK_162} -group {DVI_RX_CLK_MAX}
set_clock_groups -exclusive -group {CLK_25}  -group {DVI_RX_CLK_MIN}



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************
set_max_delay 2.0 -from [get_ports DVI_RX_DE]
set_max_delay 2.0 -from [get_ports DVI_RX_D*]
set_max_delay 2.0 -from [get_ports DVI_RX_CTL*]



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



