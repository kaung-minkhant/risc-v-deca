quit -sim

vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/half_adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/full_adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/half_adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/adder.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/pc.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/pc_container.vhd
vcom -reportprogress 300 -work work C:/Users/user/Desktop/risc-v-micro-master/risc-v-micro-master/cpu/pc_container_tb.vhd


vsim -gui work.pc_container_tb
add wave sim:/pc_container_tb/*

