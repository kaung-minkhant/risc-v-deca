# Copyright (C) 2023  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.


# Quartus Prime Version 22.1std.2 Build 922 07/20/2023 SC Lite Edition
# File: signalprobe_qsf.tcl
# Generated on: Tue Aug 15 21:33:10 2023

# Note: This file contains a Tcl script generated from the Signal Probe Gui.
#       You can use this script to restore Signal Probes after deleting the DB
#       folder; at the command line use "quartus_cdb -t signalprobe_qsf.tcl".

package require ::quartus::chip_planner
package require ::quartus::project
project_open cpu_deca -revision cpu_deca
read_netlist
set had_failure 0

############
# Index: 1 #
############
set result [ make_sp  -src_name "|cpu_deca|general_io\[4\]~input" -loc PIN_AA2 -pin_name "general_io\[4\]_signalProbe" -io_std "2.5 V" ] 
if { $result == 0 } { 
	 puts "FAIL (general_io\[4\]_signalProbe): make_sp  -src_name \"|cpu_deca|general_io\[4\]~input\" -loc PIN_AA2 -pin_name \"general_io\[4\]_signalProbe\" -io_std \"2.5 V\""
} else { 
 	 puts "SET  (general_io\[4\]_signalProbe): make_sp  -src_name \"|cpu_deca|general_io\[4\]~input\" -loc PIN_AA2 -pin_name \"general_io\[4\]_signalProbe\" -io_std \"2.5 V\""
} 

