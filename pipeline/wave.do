onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CPU/DP/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/halt
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/ireadreq
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemREN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/datomic
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/dreadreq
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemREN
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/dwritereq
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/ruif/dhit
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/flushed
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemstore
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/ctif/halt
add wave -noupdate /system_tb/DUT/CPU/DP/ctif/dreadreq
add wave -noupdate /system_tb/DUT/CPU/DP/ctif/dwritereq
add wave -noupdate /system_tb/DUT/CPU/DP/ctif/writeReg
add wave -noupdate /system_tb/DUT/CPU/DP/ctif/MemtoReg
add wave -noupdate /system_tb/DUT/CPU/DP/ctif/ExtOp
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP} /system_tb/DUT/CPU/DP/opcode
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP} /system_tb/DUT/CPU/DP/rd
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP} /system_tb/DUT/CPU/DP/rs
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP} /system_tb/DUT/CPU/DP/rt
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP} /system_tb/DUT/CPU/DP/rw
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ctif/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ctif} /system_tb/DUT/CPU/DP/ctif/RegDst
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ctif/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ctif} /system_tb/DUT/CPU/DP/ctif/RegWDsel
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ctif/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ctif} /system_tb/DUT/CPU/DP/ctif/PCSrc
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ctif/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ctif} /system_tb/DUT/CPU/DP/ctif/ALUSrc
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ctif/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ctif} /system_tb/DUT/CPU/DP/ctif/aluop
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ctif/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ctif} /system_tb/DUT/CPU/DP/ctif/instruction
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ALU1/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ALU1} /system_tb/DUT/CPU/DP/ALU1/result
add wave -noupdate -expand -label sim:/system_tb/DUT/CPU/DP/ALU1/Group1 -group {Region: sim:/system_tb/DUT/CPU/DP/ALU1} /system_tb/DUT/CPU/DP/ALU1/A
add wave -noupdate /system_tb/DUT/CPU/DP/ALU1/B
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {308335 ps} 0}
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
WaveRestoreZoom {283177 ps} {566386 ps}
