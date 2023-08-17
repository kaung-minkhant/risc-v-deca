onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /i2c_master/clk
add wave -noupdate /i2c_master/reset_n
add wave -noupdate /i2c_master/ena
add wave -noupdate /i2c_master/addr
add wave -noupdate /i2c_master/rw
add wave -noupdate /i2c_master/data_wr
add wave -noupdate /i2c_master/data_clk
add wave -noupdate /i2c_master/scl_clk
add wave -noupdate /i2c_master/scl_ena
add wave -noupdate /i2c_master/sda_ena_n
add wave -noupdate /i2c_master/busy
add wave -noupdate /i2c_master/data_rd
add wave -noupdate /i2c_master/ack_error
add wave -noupdate /i2c_master/sda
add wave -noupdate /i2c_master/scl
add wave -noupdate /i2c_master/state
add wave -noupdate /i2c_master/sda_int
add wave -noupdate /i2c_master/addr_rw
add wave -noupdate /i2c_master/data_tx
add wave -noupdate /i2c_master/data_rx
add wave -noupdate /i2c_master/bit_cnt
add wave -noupdate /i2c_master/stretch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41297266 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 204
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {36271857 ps} {56501692 ps}
