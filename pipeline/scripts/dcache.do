onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dcache_tb/CLK
add wave -noupdate /dcache_tb/nRST
add wave -noupdate -expand -label sim:/dcache_tb/cif/Group1 -group {Region: sim:/dcache_tb/cif} /dcache_tb/cif/dwait
add wave -noupdate -expand -label sim:/dcache_tb/cif/Group1 -group {Region: sim:/dcache_tb/cif} /dcache_tb/cif/dREN
add wave -noupdate -expand -label sim:/dcache_tb/cif/Group1 -group {Region: sim:/dcache_tb/cif} /dcache_tb/cif/dWEN
add wave -noupdate -expand -label sim:/dcache_tb/cif/Group1 -group {Region: sim:/dcache_tb/cif} /dcache_tb/cif/dload
add wave -noupdate -expand -label sim:/dcache_tb/cif/Group1 -group {Region: sim:/dcache_tb/cif} /dcache_tb/cif/dstore
add wave -noupdate -expand -label sim:/dcache_tb/cif/Group1 -group {Region: sim:/dcache_tb/cif} /dcache_tb/cif/daddr
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/halt
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/dhit
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/dmemREN
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/dmemWEN
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/flushed
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/dmemload
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/dmemstore
add wave -noupdate -expand -label sim:/dcache_tb/dif/Group1 -group {Region: sim:/dcache_tb/dif} /dcache_tb/dif/dmemaddr
add wave -noupdate -expand -group DCache /dcache_tb/DUT/state
add wave -noupdate -expand -group DCache /dcache_tb/DUT/next_state
add wave -noupdate -expand -group DCache /dcache_tb/DUT/dsets
add wave -noupdate -expand -group DCache /dcache_tb/DUT/dcache.tag
add wave -noupdate -expand -group DCache /dcache_tb/DUT/miss
add wave -noupdate -expand -group DCache /dcache_tb/DUT/count
add wave -noupdate -expand -group DCache /dcache_tb/DUT/miss_count
add wave -noupdate -expand -group DCache /dcache_tb/DUT/hit_count
add wave -noupdate -expand -group DCache /dcache_tb/DUT/lru
add wave -noupdate -expand -group DCache /dcache_tb/DUT/dhit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62 ns} 0}
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
WaveRestoreZoom {0 ns} {45 ns}
