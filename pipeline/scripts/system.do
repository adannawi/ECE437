onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate /system_tb/DUT/RAM/ramif/memREN
add wave -noupdate /system_tb/DUT/RAM/ramif/memWEN
add wave -noupdate /system_tb/DUT/RAM/ramif/memaddr
add wave -noupdate /system_tb/DUT/RAM/ramif/memstore
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider -height 30 {Coherence Controller}
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider -height 30 {Cache Signals}
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider -height 30 {Core 1}
add wave -noupdate -divider {Core 1 Instr}
add wave -noupdate -label {IF Instr} /system_tb/DUT/CPU/DP0/feif/InstructionIN
add wave -noupdate -label {DE Instr} /system_tb/DUT/CPU/DP0/feif/InstructionOUT
add wave -noupdate -label {EX Instr} /system_tb/DUT/CPU/DP0/exif/InstructionIN
add wave -noupdate -label {MEM Instr} /system_tb/DUT/CPU/DP0/exif/InstructionOUT
add wave -noupdate -label {WB Instr} /system_tb/DUT/CPU/DP0/mmif/InstructionOUT
add wave -noupdate -divider {Core 1 Opcodes}
add wave -noupdate -label {IF Opcode} /system_tb/DUT/CPU/DP0/feif/opcodeIN
add wave -noupdate -label {DE Opcode} /system_tb/DUT/CPU/DP0/feif/opcodeOUT
add wave -noupdate -label {EX Opcode} /system_tb/DUT/CPU/DP0/exif/opcodeIN
add wave -noupdate -label {MEM Opcode} /system_tb/DUT/CPU/DP0/exif/opcodeOUT
add wave -noupdate -label {WB Opcode} /system_tb/DUT/CPU/DP0/mmif/opcodeOUT
add wave -noupdate -divider -height 30 {Core 2}
add wave -noupdate -label {IF Instr} /system_tb/DUT/CPU/DP1/feif/InstructionIN
add wave -noupdate -label {DE Instr} /system_tb/DUT/CPU/DP1/feif/InstructionOUT
add wave -noupdate -label {EX Instr} /system_tb/DUT/CPU/DP1/exif/InstructionIN
add wave -noupdate -label {MEM Instr} /system_tb/DUT/CPU/DP1/exif/InstructionOUT
add wave -noupdate -label {WB Instr} /system_tb/DUT/CPU/DP1/mmif/InstructionOUT
add wave -noupdate -divider {Core 2 Opcode}
add wave -noupdate -label {IF Opcode} /system_tb/DUT/CPU/DP1/feif/opcodeIN
add wave -noupdate -label {DE Opcode} /system_tb/DUT/CPU/DP1/feif/opcodeOUT
add wave -noupdate -label {EX Opcode} /system_tb/DUT/CPU/DP1/exif/opcodeIN
add wave -noupdate -label {MEM Opcode} /system_tb/DUT/CPU/DP1/exif/opcodeOUT
add wave -noupdate -label {WB Instr} /system_tb/DUT/CPU/DP1/mmif/opcodeOUT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {513881 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 237
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
WaveRestoreZoom {0 ps} {72239 ps}
