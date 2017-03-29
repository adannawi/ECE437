onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /memory_control_tb/tb_CLK
add wave -noupdate /memory_control_tb/tb_nRST
add wave -noupdate -radix decimal -childformat {{{/memory_control_tb/Test_Case[31]} -radix decimal} {{/memory_control_tb/Test_Case[30]} -radix decimal} {{/memory_control_tb/Test_Case[29]} -radix decimal} {{/memory_control_tb/Test_Case[28]} -radix decimal} {{/memory_control_tb/Test_Case[27]} -radix decimal} {{/memory_control_tb/Test_Case[26]} -radix decimal} {{/memory_control_tb/Test_Case[25]} -radix decimal} {{/memory_control_tb/Test_Case[24]} -radix decimal} {{/memory_control_tb/Test_Case[23]} -radix decimal} {{/memory_control_tb/Test_Case[22]} -radix decimal} {{/memory_control_tb/Test_Case[21]} -radix decimal} {{/memory_control_tb/Test_Case[20]} -radix decimal} {{/memory_control_tb/Test_Case[19]} -radix decimal} {{/memory_control_tb/Test_Case[18]} -radix decimal} {{/memory_control_tb/Test_Case[17]} -radix decimal} {{/memory_control_tb/Test_Case[16]} -radix decimal} {{/memory_control_tb/Test_Case[15]} -radix decimal} {{/memory_control_tb/Test_Case[14]} -radix decimal} {{/memory_control_tb/Test_Case[13]} -radix decimal} {{/memory_control_tb/Test_Case[12]} -radix decimal} {{/memory_control_tb/Test_Case[11]} -radix decimal} {{/memory_control_tb/Test_Case[10]} -radix decimal} {{/memory_control_tb/Test_Case[9]} -radix decimal} {{/memory_control_tb/Test_Case[8]} -radix decimal} {{/memory_control_tb/Test_Case[7]} -radix decimal} {{/memory_control_tb/Test_Case[6]} -radix decimal} {{/memory_control_tb/Test_Case[5]} -radix decimal} {{/memory_control_tb/Test_Case[4]} -radix decimal} {{/memory_control_tb/Test_Case[3]} -radix decimal} {{/memory_control_tb/Test_Case[2]} -radix decimal} {{/memory_control_tb/Test_Case[1]} -radix decimal} {{/memory_control_tb/Test_Case[0]} -radix decimal}} -subitemconfig {{/memory_control_tb/Test_Case[31]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[30]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[29]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[28]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[27]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[26]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[25]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[24]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[23]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[22]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[21]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[20]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[19]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[18]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[17]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[16]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[15]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[14]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[13]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[12]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[11]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[10]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[9]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[8]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[7]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[6]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[5]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[4]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[3]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[2]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[1]} {-height 17 -radix decimal} {/memory_control_tb/Test_Case[0]} {-height 17 -radix decimal}} /memory_control_tb/Test_Case
add wave -noupdate -expand -group {Service Logic} /memory_control_tb/DUT/servicing
add wave -noupdate -expand -group {Service Logic} /memory_control_tb/DUT/nextservice
add wave -noupdate -expand -group {Coherence State} /memory_control_tb/DUT/nextstate
add wave -noupdate -expand -group {Coherence State} /memory_control_tb/DUT/state
add wave -noupdate -expand -group RAM /memory_control_tb/DUT/ccif/ramWEN
add wave -noupdate -expand -group RAM /memory_control_tb/DUT/ccif/ramREN
add wave -noupdate -expand -group RAM /memory_control_tb/DUT/ccif/ramstate
add wave -noupdate -expand -group RAM /memory_control_tb/DUT/ccif/ramaddr
add wave -noupdate -expand -group RAM /memory_control_tb/DUT/ccif/ramstore
add wave -noupdate -expand -group RAM /memory_control_tb/DUT/ccif/ramload
add wave -noupdate -expand -group CCIF -group {iCaches' Signals} -radix binary /memory_control_tb/DUT/ccif/iwait
add wave -noupdate -expand -group CCIF -group {iCaches' Signals} -radix binary -childformat {{{/memory_control_tb/DUT/ccif/iREN[1]} -radix binary} {{/memory_control_tb/DUT/ccif/iREN[0]} -radix binary}} -subitemconfig {{/memory_control_tb/DUT/ccif/iREN[1]} {-height 17 -radix binary} {/memory_control_tb/DUT/ccif/iREN[0]} {-height 17 -radix binary}} /memory_control_tb/DUT/ccif/iREN
add wave -noupdate -expand -group CCIF -group {iCaches' Signals} /memory_control_tb/DUT/ccif/iload
add wave -noupdate -expand -group CCIF -group {iCaches' Signals} /memory_control_tb/DUT/ccif/iaddr
add wave -noupdate -expand -group CCIF -group {dCaches' Signals} -radix binary /memory_control_tb/DUT/ccif/dwait
add wave -noupdate -expand -group CCIF -group {dCaches' Signals} -radix binary -childformat {{{/memory_control_tb/DUT/ccif/dREN[1]} -radix binary} {{/memory_control_tb/DUT/ccif/dREN[0]} -radix binary}} -subitemconfig {{/memory_control_tb/DUT/ccif/dREN[1]} {-height 17 -radix binary} {/memory_control_tb/DUT/ccif/dREN[0]} {-height 17 -radix binary}} /memory_control_tb/DUT/ccif/dREN
add wave -noupdate -expand -group CCIF -group {dCaches' Signals} -radix binary -childformat {{{/memory_control_tb/DUT/ccif/dWEN[1]} -radix binary} {{/memory_control_tb/DUT/ccif/dWEN[0]} -radix binary}} -subitemconfig {{/memory_control_tb/DUT/ccif/dWEN[1]} {-height 17 -radix binary} {/memory_control_tb/DUT/ccif/dWEN[0]} {-height 17 -radix binary}} /memory_control_tb/DUT/ccif/dWEN
add wave -noupdate -expand -group CCIF -group {dCaches' Signals} /memory_control_tb/DUT/ccif/dload
add wave -noupdate -expand -group CCIF -group {dCaches' Signals} /memory_control_tb/DUT/ccif/dstore
add wave -noupdate -expand -group CCIF -group {dCaches' Signals} /memory_control_tb/DUT/ccif/daddr
add wave -noupdate -expand -group Coherence -radix binary /memory_control_tb/DUT/ccif/ccwait
add wave -noupdate -expand -group Coherence -radix binary /memory_control_tb/DUT/ccif/ccinv
add wave -noupdate -expand -group Coherence -radix binary /memory_control_tb/DUT/ccif/ccwrite
add wave -noupdate -expand -group Coherence -radix binary /memory_control_tb/DUT/ccif/cctrans
add wave -noupdate -expand -group Coherence /memory_control_tb/DUT/ccif/ccsnoopaddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {368165 ps} 0}
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
WaveRestoreZoom {329 ns} {660 ns}
