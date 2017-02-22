# Ziad Dannawi
# Attempt to break the code with a crapton of jumps 
	org 0x0000
	ori $1, $zero, addr
	ori $2, $zero, 10
	ori $3, $zero, 5
	ori $4, $zero, 0
	ori $5, $zero, 0
start:
	beq $2, $zero, loop2
	addi $2, $2, -1
	j start

loop2:
	addi $3, $3, -1
	bne $3, $zero, loop2
	lw $4, 0($1)
jump1:
	j jump2

jump3:
	j jump4

good:
	jal addme

	lw $4, 4($1)

	ori $3, $zero, 5


########################
# Testing nested loops #
########################
recaddout:
	ori $2, $zero, 10
	addi $3, $3, -1
recaddin:
	addi $2, $2, -1
	addi $5, $5, 1
	bne $2, $zero, recaddin
	bne $3, $zero, recaddout

branchsw1:
	lw $8, 0($1)
	sw $8, 0($1)
	lw $8, 0($1)
	sw $8, 0($1)
	j branchsw3

branchsw2:
	lw $8, 0($1)
	addi $8, $8, 1
	lw $7, 4($1)
	add $8, $8, $7
	sw $8, 0($1)
	j done

branchsw3:
	lw $8, 0($1)
	addi $8, $8, 3
	sw $8, 0($1)
	j branchsw2

done:
	lw $8, 0($1)
	ori $10, $zero, 0
	beq $10, $zero, brst

brst:
	sw $8, 0($1)
	lw $8, 4($1)
	sw $8, 4($1)
	lw $8, 0($1)











	halt

	org 0x3000

jump2:
	j jump3

jump4:
	j good

addme:
	addi $4, $zero, 2
	sw $4, 4($1)
	jr $ra


	org 0x5000
addr:
	cfw 5
	cfw 3
	cfw 2
	cfw 10
	cfw 4
