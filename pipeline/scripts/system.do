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
add wave -noupdate /system_tb/DUT/CPU/CC/state
add wave -noupdate /system_tb/DUT/CPU/CC/nextstate
add wave -noupdate /system_tb/DUT/CPU/CC/servicing
add wave -noupdate /system_tb/DUT/CPU/CC/nextservice
add wave -noupdate /system_tb/DUT/CPU/CC/ireq
add wave -noupdate /system_tb/DUT/CPU/CC/dreq
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/dwait
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/dstore
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/dload
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/daddr
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/dWEN
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/dREN
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/ccwrite
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/ccwait
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/cctrans
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/ccsnoopaddr
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/ccinv
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/iwait
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/iload
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/iaddr
add wave -noupdate /system_tb/DUT/CPU/CC/ccif/iREN
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider -height 30 {Cache Signals}
add wave -noupdate -divider -height 25 {Cache 1}
add wave -noupdate /system_tb/DUT/CPU/cif0/dREN
add wave -noupdate /system_tb/DUT/CPU/cif0/dWEN
add wave -noupdate /system_tb/DUT/CPU/cif0/daddr
add wave -noupdate /system_tb/DUT/CPU/cif0/dload
add wave -noupdate /system_tb/DUT/CPU/cif0/dstore
add wave -noupdate /system_tb/DUT/CPU/cif0/dwait
add wave -noupdate -divider {Cache 1 Snoop}
add wave -noupdate /system_tb/DUT/CPU/cif0/ccwait
add wave -noupdate /system_tb/DUT/CPU/cif0/cctrans
add wave -noupdate /system_tb/DUT/CPU/cif0/ccwrite
add wave -noupdate /system_tb/DUT/CPU/cif0/ccinv
add wave -noupdate /system_tb/DUT/CPU/cif0/ccsnoopaddr
add wave -noupdate -divider -height 25 {Cache 2}
add wave -noupdate /system_tb/DUT/CPU/cif1/dwait
add wave -noupdate /system_tb/DUT/CPU/cif1/dstore
add wave -noupdate /system_tb/DUT/CPU/cif1/dload
add wave -noupdate /system_tb/DUT/CPU/cif1/daddr
add wave -noupdate /system_tb/DUT/CPU/cif1/dWEN
add wave -noupdate /system_tb/DUT/CPU/cif1/dREN
add wave -noupdate -divider {Cache 2 Snoop}
add wave -noupdate /system_tb/DUT/CPU/cif1/ccwait
add wave -noupdate /system_tb/DUT/CPU/cif1/cctrans
add wave -noupdate /system_tb/DUT/CPU/cif1/ccwrite
add wave -noupdate /system_tb/DUT/CPU/cif1/ccinv
add wave -noupdate /system_tb/DUT/CPU/cif1/ccsnoopaddr
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {Coherence States}
add wave -noupdate -label {Coherence Controller State} /system_tb/DUT/CPU/CC/state
add wave -noupdate -label {dCache 1 State} /system_tb/DUT/CPU/CM0/DCACHE/state
add wave -noupdate -label {dCache 2 State} /system_tb/DUT/CPU/CM1/DCACHE/state
add wave -noupdate -divider {Core 1 Opcodes}
add wave -noupdate -label {IF Opcode} /system_tb/DUT/CPU/DP0/feif/opcodeIN
add wave -noupdate -label {DE Opcode} /system_tb/DUT/CPU/DP0/feif/opcodeOUT
add wave -noupdate -label {EX Opcode} /system_tb/DUT/CPU/DP0/exif/opcodeIN
add wave -noupdate -label {MEM Opcode} /system_tb/DUT/CPU/DP0/exif/opcodeOUT
add wave -noupdate -label {WB Opcode} /system_tb/DUT/CPU/DP0/mmif/opcodeOUT
add wave -noupdate -divider {Core 2 Opcode}
add wave -noupdate -label {IF Opcode} /system_tb/DUT/CPU/DP1/feif/opcodeIN
add wave -noupdate -label {DE Opcode} /system_tb/DUT/CPU/DP1/feif/opcodeOUT
add wave -noupdate -label {EX Opcode} /system_tb/DUT/CPU/DP1/exif/opcodeIN
add wave -noupdate -label {MEM Opcode} /system_tb/DUT/CPU/DP1/exif/opcodeOUT
add wave -noupdate -label {WB Instr} /system_tb/DUT/CPU/DP1/mmif/opcodeOUT
add wave -noupdate -divider {Core 1 Instr}
add wave -noupdate -label {IF Instr} /system_tb/DUT/CPU/DP0/feif/InstructionIN
add wave -noupdate -label {DE Instr} /system_tb/DUT/CPU/DP0/feif/InstructionOUT
add wave -noupdate -label {EX Instr} /system_tb/DUT/CPU/DP0/exif/InstructionIN
add wave -noupdate -label {MEM Instr} /system_tb/DUT/CPU/DP0/exif/InstructionOUT
add wave -noupdate -label {WB Instr} /system_tb/DUT/CPU/DP0/mmif/InstructionOUT
add wave -noupdate -divider {Core 2 Instr}
add wave -noupdate -label {IF Instr} /system_tb/DUT/CPU/DP1/feif/InstructionIN
add wave -noupdate -label {DE Instr} /system_tb/DUT/CPU/DP1/feif/InstructionOUT
add wave -noupdate -label {EX Instr} /system_tb/DUT/CPU/DP1/exif/InstructionIN
add wave -noupdate -label {MEM Instr} /system_tb/DUT/CPU/DP1/exif/InstructionOUT
add wave -noupdate -label {WB Instr} /system_tb/DUT/CPU/DP1/mmif/InstructionOUT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {496338 ps} 1} {{Cursor 2} {488932 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 117
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
WaveRestoreZoom {438200 ps} {602200 ps}
