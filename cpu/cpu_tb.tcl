quit -sim

vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/half_adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/full_adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/one_bit_alu.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/pc.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/pc_container.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/address_decoder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/instruction_memory.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/register_file.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/data_memory.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/alu.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/alu_controller.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/immediate_generator.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/branch_controller.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/control_unit.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/cpu.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/cpu_tb.vhd


vsim -gui work.cpu_tb
add wave sim:/cpu_tb/*
add wave sim:/cpu_tb/DUT/instruction
add wave sim:/cpu_tb/DUT/load
add wave sim:/cpu_tb/DUT/register_file_rw
add wave sim:/cpu_tb/DUT/alu_src
add wave sim:/cpu_tb/DUT/alu_op
add wave sim:/cpu_tb/DUT/memtoreg
add wave sim:/cpu_tb/DUT/data_memory_controls
add wave sim:/cpu_tb/DUT/branch
add wave -position end  sim:/cpu_tb/DUT/immediate_generator_u/immediate
#add wave -position end  sim:/cpu_tb/DUT/rs1_data
#add wave -position end  sim:/cpu_tb/DUT/rs2_data
#add wave -position end  sim:/cpu_tb/DUT/alu_u/result_buffer
add wave -position end  sim:/cpu_tb/DUT/register_file_u/register_file