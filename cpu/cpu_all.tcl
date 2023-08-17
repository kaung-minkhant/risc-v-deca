quit -sim
#C:/Users/user/Desktop
#D:/Polar
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/half_adder.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/full_adder.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/one_bit_alu.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/adder.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/pc.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/pc_container.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/address_decoder.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/instruction_memory.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/register_file.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/data_memory.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/alu.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/alu_controller.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/immediate_generator.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/branch_controller.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/branch_calculator.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/control_unit.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/if_id_pipe_reg.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/id_ex_pipe_reg.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/ex_mem_pipe_reg.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/mem_wb_pipe_reg.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/forwarding_unit.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/hazard_detection.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/forwarding_unit_branch.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/cpu.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/cpu_pipelined.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/cpu_tb.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/cpu_pipelined_tb.vhd


vsim -gui work.cpu_pipelined_tb
add wave sim:/cpu_pipelined_tb/*

add wave sim:/cpu_pipelined_tb/DUT/pc_address_piped_id
add wave sim:/cpu_pipelined_tb/DUT/instruction_piped_id
add wave sim:/cpu_pipelined_tb/DUT/rs1_data
add wave sim:/cpu_pipelined_tb/DUT/rs2_data
add wave sim:/cpu_pipelined_tb/DUT/immediate

add wave sim:/cpu_pipelined_tb/DUT/rs1_piped_ex
add wave sim:/cpu_pipelined_tb/DUT/rs2_piped_ex
add wave sim:/cpu_pipelined_tb/DUT/rd_data
add wave sim:/cpu_pipelined_tb/DUT/data_memory_read
add wave sim:/cpu_pipelined_tb/DUT/alu_a_piped
add wave sim:/cpu_pipelined_tb/DUT/alu_b_piped
add wave sim:/cpu_pipelined_tb/DUT/b_data
add wave sim:/cpu_pipelined_tb/DUT/immediate_piped_ex
add wave sim:/cpu_pipelined_tb/DUT/alu_result
add wave sim:/cpu_pipelined_tb/DUT/rd_ex
add wave sim:/cpu_pipelined_tb/DUT/rs1_addr_ex
add wave sim:/cpu_pipelined_tb/DUT/rs2_addr_ex

add wave sim:/cpu_pipelined_tb/DUT/alu_result_piped_mem
add wave sim:/cpu_pipelined_tb/DUT/rs2_data_piped_mem
add wave sim:/cpu_pipelined_tb/DUT/rd_mem
add wave sim:/cpu_pipelined_tb/DUT/rs2_addr_mem
add wave sim:/cpu_pipelined_tb/DUT/data_memory_read

add wave sim:/cpu_pipelined_tb/DUT/alu_result_piped_wb
add wave sim:/cpu_pipelined_tb/DUT/mem_data_piped_wb
add wave sim:/cpu_pipelined_tb/DUT/rd_data
add wave sim:/cpu_pipelined_tb/DUT/rd_wb

add wave sim:/cpu_pipelined_tb/DUT/register_file_u/register_file
add wave sim:/cpu_pipelined_tb/DUT/data_memory_u/data_memory_array

add wave sim:/cpu_pipelined_tb/DUT/pc_u/pc_u/input_addr
add wave sim:/cpu_pipelined_tb/DUT/pc_u/pc_u/branch_addr
add wave sim:/cpu_pipelined_tb/DUT/pc_u/pc_u/inst_addr
add wave sim:/cpu_pipelined_tb/DUT/pc_u/pc_u/branch

add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/rd_ex 
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/rd_mem
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/rd_wb
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/rs1_id
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/rs2_id
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/opcode
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/opcode_ex
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/opcode_mem
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/stall_branch
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/forward_branch_A
add wave sim:/cpu_pipelined_tb/DUT/forwarding_unit_branch_u/forward_branch_B
