onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/DUT/CPU/DP/CLK
add wave -noupdate /system_tb/DUT/CPU/DP/nRST
add wave -noupdate /system_tb/DUT/CPU/DP/PC
add wave -noupdate /system_tb/DUT/CPU/DP/PCNxt
add wave -noupdate /system_tb/DUT/CPU/DP/Ext_dat
add wave -noupdate /system_tb/DUT/CPU/DP/ALU_Bin
add wave -noupdate /system_tb/DUT/CPU/DP/busA
add wave -noupdate /system_tb/DUT/CPU/DP/busB
add wave -noupdate /system_tb/DUT/CPU/DP/opcode
add wave -noupdate /system_tb/DUT/CPU/DP/branch
add wave -noupdate /system_tb/DUT/CPU/DP/PCEn
add wave -noupdate /system_tb/DUT/CPU/DP/rs
add wave -noupdate /system_tb/DUT/CPU/DP/rt
add wave -noupdate /system_tb/DUT/CPU/DP/rd
add wave -noupdate /system_tb/DUT/CPU/DP/rw
add wave -noupdate /system_tb/DUT/CPU/DP/shamt
add wave -noupdate /system_tb/DUT/CPU/DP/funct
add wave -noupdate /system_tb/DUT/CPU/DP/imm16
add wave -noupdate /system_tb/DUT/CPU/DP/addr
add wave -noupdate /system_tb/DUT/CPU/DP/PCInc
add wave -noupdate /system_tb/DUT/CPU/DP/ALU_out
add wave -noupdate /system_tb/DUT/CPU/DP/zero
add wave -noupdate /system_tb/DUT/CPU/DP/neg
add wave -noupdate /system_tb/DUT/CPU/DP/overflow
add wave -noupdate /system_tb/DUT/CPU/DP/aluop
add wave -noupdate /system_tb/DUT/CPU/DP/dataout
add wave -noupdate /system_tb/DUT/CPU/DP/RegWDat
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {648 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1310739050 ps} {1310740050 ps}
