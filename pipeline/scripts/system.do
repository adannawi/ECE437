onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/nRST
add wave -noupdate -divider {iCache/dCache Inputs}
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/dcache
add wave -noupdate /system_tb/DUT/CPU/CM/ICACHE/icache
add wave -noupdate -group {dCache Hit Count} /system_tb/DUT/CPU/CM/DCACHE/hit_count
add wave -noupdate -group {dCache Hit Count} /system_tb/DUT/CPU/CM/DCACHE/miss_count
add wave -noupdate -group {dCache Hit Count} /system_tb/DUT/CPU/CM/DCACHE/count
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/halt
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/flushed
add wave -noupdate -divider {Datapath - iCache}
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemREN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemaddr
add wave -noupdate -divider {Datapath - dCache}
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemstore
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemREN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate -divider {dCache to Mem Control}
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/state
add wave -noupdate /system_tb/DUT/CPU/cif0/dwait
add wave -noupdate /system_tb/DUT/CPU/cif0/dREN
add wave -noupdate /system_tb/DUT/CPU/cif0/dWEN
add wave -noupdate /system_tb/DUT/CPU/cif0/daddr
add wave -noupdate /system_tb/DUT/CPU/cif0/dstore
add wave -noupdate /system_tb/DUT/CPU/cif0/dload
add wave -noupdate -divider -height 30 {Cache Data}
add wave -noupdate -label {dCache Data} /system_tb/DUT/CPU/CM/DCACHE/dsets
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/cWEN
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/block_data
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/word_sel
add wave -noupdate -label {iCache Data} /system_tb/DUT/CPU/CM/ICACHE/isets
add wave -noupdate -divider {iCache to Mem Control}
add wave -noupdate /system_tb/DUT/CPU/cif0/iwait
add wave -noupdate /system_tb/DUT/CPU/cif0/iaddr
add wave -noupdate /system_tb/DUT/CPU/cif0/iREN
add wave -noupdate /system_tb/DUT/CPU/cif0/iload
add wave -noupdate -divider RAM
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/state
add wave -noupdate /system_tb/DUT/CPU/CM/DCACHE/cif/dwait
add wave -noupdate /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate -divider {Datapath Calculation}
add wave -noupdate /system_tb/DUT/CPU/DP/ALU1/result
add wave -noupdate /system_tb/DUT/CPU/DP/REG1/regs
add wave -noupdate /system_tb/DUT/CPU/DP/rfif1/rsel1
add wave -noupdate /system_tb/DUT/CPU/DP/rfif1/rsel2
add wave -noupdate -divider -height 30 {Pipeline Signals}
add wave -noupdate -divider {Pipeline Control Sginals}
add wave -noupdate -label {FE-ID Enable} /system_tb/DUT/CPU/DP/feif/enable
add wave -noupdate -label {FE-ID Flush} /system_tb/DUT/CPU/DP/feif/flush
add wave -noupdate -label {ID-Ex Enable} /system_tb/DUT/CPU/DP/deif/enable
add wave -noupdate -label {ID-EX Flush} /system_tb/DUT/CPU/DP/deif/flush
add wave -noupdate -label {EX-MEM Enable} /system_tb/DUT/CPU/DP/exif/enable
add wave -noupdate -label {EX-MEM Flush} /system_tb/DUT/CPU/DP/exif/flush
add wave -noupdate -label {MEM-WB Enable} /system_tb/DUT/CPU/DP/mmif/enable
add wave -noupdate -label {MEM-WB Flush} /system_tb/DUT/CPU/DP/mmif/flush
add wave -noupdate /system_tb/DUT/CPU/DP/bubble
add wave -noupdate /system_tb/DUT/CPU/DP/normal_op
add wave -noupdate /system_tb/nRST
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /system_tb/DUT/CPU/CLK
add wave -noupdate -label {dCache State} /system_tb/DUT/CPU/CM/DCACHE/state
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate -divider {Pipe Stage Instructions}
add wave -noupdate -label {IF Opcode} /system_tb/DUT/CPU/DP/feif/opcodeIN
add wave -noupdate -label {DE Opcode} /system_tb/DUT/CPU/DP/feif/opcodeOUT
add wave -noupdate -label {EX Opcode} /system_tb/DUT/CPU/DP/exif/opcodeIN
add wave -noupdate -label {MEM Opcode} /system_tb/DUT/CPU/DP/exif/opcodeOUT
add wave -noupdate -label {WB Opcode} /system_tb/DUT/CPU/DP/mmif/opcodeOUT
add wave -noupdate -label {ALU Operation in EX} /system_tb/DUT/CPU/DP/ALU1/aluop
add wave -noupdate -divider Instructions
add wave -noupdate -label {IF Instruction} /system_tb/DUT/CPU/DP/feif/InstructionIN
add wave -noupdate -label {ID Instruction} /system_tb/DUT/CPU/DP/feif/InstructionOUT
add wave -noupdate -label {EX Instruction} /system_tb/DUT/CPU/DP/deif/InstructionOUT
add wave -noupdate -label {MEM Instruction} /system_tb/DUT/CPU/DP/exif/InstructionOUT
add wave -noupdate -label {WB Instruction} /system_tb/DUT/CPU/DP/mmif/InstructionOUT
add wave -noupdate /system_tb/DUT/CPU/DP/normal_op
add wave -noupdate /system_tb/DUT/CPU/DP/bubble
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PCEn
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PC
add wave -noupdate -expand -group PC /system_tb/DUT/CPU/DP/PCNxt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1619107 ps} 1} {{Cursor 2} {296052632 ps} 0} {{Cursor 3} {1523883 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 171
configure wave -valuecolwidth 232
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
WaveRestoreZoom {1209 ns} {2093 ns}
