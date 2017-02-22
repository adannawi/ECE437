# Ziad Dannawi
# ASM file to test Jumps, Jals, JRs, and some branches in addition to loading
#

org 0x0000

ori $7, $zero, 0
ori $6, $zero, addr # For addresses
ori $5, $zero, 0
ori $4, $zero, 0
ori $3, $zero, 0
ori $2, $zero, 10
ori $1, $zero, 1
J loop

jtest:
addi $3, $3, 5
J jaltest

loop:
addu $3, $3, $1
subu $2, $2, $1
bne $2, $zero, loop

J jtest

jaltest:
JAL jallink1
J loadstore



jallink1:
 add $4, $4, $1
 add $5, $5, $4
 JR $ra

loadstore:
sw $4, 0($6)
sw $5, 4($6)
lw $4, 0($6)
lw $5, 4($6) # 2
lw $7, 0($6) # 1

add $5, $5, $1
add $5, $5, $7

lw $7, 8($6) # 3

add $5, $5, $7
J end


org 0x300

addr:
cfw 1
cfw 2
cfw 3
cfw 4

end:
halt
