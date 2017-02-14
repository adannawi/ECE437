onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/prif/ramREN
add wave -noupdate /system_tb/DUT/prif/ramWEN
add wave -noupdate /system_tb/DUT/prif/ramaddr
add wave -noupdate /system_tb/DUT/prif/ramstore
add wave -noupdate /system_tb/DUT/prif/ramload
add wave -noupdate /system_tb/DUT/prif/ramstate
add wave -noupdate /system_tb/DUT/prif/memREN
add wave -noupdate /system_tb/DUT/prif/memWEN
add wave -noupdate /system_tb/DUT/prif/memaddr
add wave -noupdate /system_tb/DUT/prif/memstore
add wave -noupdate -expand -group dpif /system_tb/DUT/CLK
add wave -noupdate -expand -group dpif /system_tb/DUT/CPU/DP/CLK
add wave -noupdate -expand -group dpif /system_tb/nRST
add wave -noupdate -label {Fetch Instr} /system_tb/DUT/CPU/DP/feif/opcodeIN
add wave -noupdate -label {ifid Instr} /system_tb/DUT/CPU/DP/feif/opcodeOUT
add wave -noupdate -label {idex Instr} /system_tb/DUT/CPU/DP/deif/opcodeOUT
add wave -noupdate -label {exmem Instr} /system_tb/DUT/CPU/DP/exif/opcodeOUT
add wave -noupdate -label {memwb Instr} /system_tb/DUT/CPU/DP/mmif/opcodeOUT
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/flushed
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/halt
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemREN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/datomic
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemREN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemstore
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dhit
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/flush
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/enable
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/InstructionIN
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/opcodeIN
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/PCIncIN
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/InstructionOUT
add wave -noupdate -expand -group ifid /system_tb/DUT/CPU/DP/feif/opcodeOUT
add wave -noupdate /system_tb/DUT/CPU/DP/feif/PCIncOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/PCIncIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/writeRegIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/dWENIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/MemtoRegIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/dRENIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/PCSrcIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/RegWDSelIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/RegDstIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/ALUSrcIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/rdIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/rtIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/aluopIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/Ext_datIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/opcodeIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/busAIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/busBIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/InstructionIN
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/PCIncOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/writeRegOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/dWENOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/dRENOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/MemtoRegOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/PCSrcOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/RegWDSelOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/RegDstOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/ALUSrcOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/aluopOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/opcodeOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/Ext_datOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/rdOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/rtOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/busAOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/busBOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/InstructionOUT
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/flush
add wave -noupdate -expand -group idex /system_tb/DUT/CPU/DP/deif/enable
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/PCIncIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/writeRegIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/MemtoRegIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/dWENIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/dRENIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/RegWDSelIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/rwIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/opcodeIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/resultIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/busBIN
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/flush
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/PCIncOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/writeRegOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/MemtoRegOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/dWENOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/dRENOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/RegWDSelOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/enable
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/rwOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/opcodeOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/busBOUT
add wave -noupdate -expand -group exmem /system_tb/DUT/CPU/DP/exif/resultOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/writeRegOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/MemtoRegOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/PCIncOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/rwOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/opcodeOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/RegWDSelOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/resultOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/dmemloadOUT
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/flush
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/writeRegIN
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/MemtoRegIN
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/PCIncIN
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/rwIN
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/opcodeIN
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/RegWDSelIN
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/enable
add wave -noupdate -expand -group memwb /system_tb/DUT/CPU/DP/mmif/resultIN
add wave -noupdate /system_tb/DUT/CPU/DP/mmif/dmemloadIN
add wave -noupdate /system_tb/DUT/CPU/DP/PCNxt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {462924 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
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
WaveRestoreZoom {409312 ps} {697312 ps}
