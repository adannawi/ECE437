# Test file for debugging SW

org 0x000

#Set SP
addi $29, $0, 0xFFFC
ori $4,$0,0xF0
addi $2, $0, 0xdead
addi $3, $0, 0xbeef
SW $2,0($4)
SW $3,4($4)


halt
