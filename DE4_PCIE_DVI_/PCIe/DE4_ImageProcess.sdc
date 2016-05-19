#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 11.1 Build 259 01/25/2012 Service Pack 2 SJ Full Version
#
#************************************************************

# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "core_clock_out" -period 4.000ns [get_ports {pcie_example_chaining_pipen1b:core|pcie_plus:ep_plus|pcie:epmap|pcie_core:wrapper|core_clk_out}]

# Clock constraints

create_clock -name "clk_50_1" -period 20.000ns [get_ports {OSC_50_BANK2}]
create_clock -name "clk_50_2" -period 20.000ns [get_ports {OSC_50_BANK3}]
create_clock -name "clk_50_3" -period 20.000ns [get_ports {OSC_50_BANK4}]
create_clock -name "clk_50_4" -period 20.000ns [get_ports {OSC_50_BANK5}]
create_clock -name "clk_50_5" -period 20.000ns [get_ports {OSC_50_BANK6}]
create_clock -name "clk_50_6" -period 20.000ns [get_ports {OSC_50_BANK7}]
create_clock -name "clk_100_1" -period 10.000ns [get_ports {PCIE_REFCLK_p}]



# tsu/th constraints

# tco constraints

# tpd constraints
create_clock -period "100.0 MHz" -name {refclk} {refclk}
set_clock_groups -exclusive -group [get_clocks { *central_clk_div0* }] -group [get_clocks { *_hssi_pcie_hip* }]
set_clock_groups -exclusive -group [get_clocks { refclk*clkout }] -group [get_clocks { *div0*coreclkout}]
# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints

