quit -sim

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
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/cpu_pipelined.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/uart/uart_tx.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/uart/uart_rx.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/uart/uart.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/uart/uart_container.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/spi/spi_master.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/spi/spi_master_container.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/i2c/i2c_master.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/i2c/i2c_master_container.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/io/iopin.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/peripherals/io/io.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/microcontroller.vhd
vcom -reportprogress 300 -work work /home/polar/Documents/liverpool_project/risc-v-micro-master/cpu/microcontroller_tb.vhd


vsim -gui work.microcontroller_tb
add wave -position end  sim:/microcontroller_tb/DUT/clk
add wave -position end  sim:/microcontroller_tb/DUT/reset_n
add wave -position end  sim:/microcontroller_tb/general_io
add wave -position end  sim:/microcontroller_tb/special_io
add wave -position end  sim:/microcontroller_tb/DUT/cpu/register_file_u/register_file
add wave -position end  sim:/microcontroller_tb/DUT/cpu/data_memory_u/data_memory_array
