#
#	Noah Petersen
#	File intended to test every basic instruction minus branch and jump (done elsewhere)
#   & store result, plus some
#

org 0x0000
ori $2, $2, data
ori $3, $3, storage

#Initializations
lw $4, 0($2)  # 1
lw $5, 4($2)  # 2
lw $6, 8($2)  # 3
lw $7, 12($2)  # 5
lw $8, 16($2)  # 10
lw $9, 20($2)  # 0xFFFFFFFF

#Instructions

#	RTYPES
#	Add Unsinged
addu $10, $4, $5
sw $10, 0($3)  

#	Add
add $10, $4, $9
sw $10, 4($3)   

#	AND
and $10, $6, $9
sw $10, 8($3)  

#	NOR
nor $10, $6, $7 #OR 3 & 5
sw $10, 12($3)   

#	OR
or $10, $6, $7
sw $10, 16($3)   

#	SLT SIGNED
slt $10, $4, $5
sw $10, 20($3)  

slt $10, $5, $4
sw $10, 24($3)

slt $10, $9, $4
sw $10, 28($3)

slt $10, $4, $9
sw $10, 32($3)

#SLT Unsigned
sltu $10, $4, $5  
sw $10, 36($3)

sltu $10, $5, $4  
sw $10, 40($3)

#	SLL
sll $10, $6, 2
sw $10, 44($3)

#	SRL
srl $10, $4, 1
sw $10, 48($3)

#SUBU
subu $10, $4, $5
sw $10, 52($3)

subu $10, $8, $6
sw $10, 56($3)

#SUB
subu $10, $4, $5
sw $10, 60($3)

subu $10, $8, $6
sw $10, 64($3)

#XOR
xor $10, $9, $8
sw $10, 68($3)

#ADDIU
addu $10, $4, $5
sw $10, 72($3) 

#ADDI
addi $10, $4, 10
sw $10, 76($3) 

#ANDI
andi $10, $6, 0xFFFF
sw $10, 80($3) 

#LUI
lui $10, 0xDEAD
sw $10, 84($3) 


#ORI
ori $10, $6, 0xF000
sw $10, 88($3) 

#SLTI
addi $10, $4, 2
sw $10, 92($3) 

addi $10, $6, 0xFFFF
sw $10, 100($3) 

#SLTIU
addi $10, $4, 1
sw $10, 104($3) 

addi $10, $6, 0xFFFF
sw $10, 108($3) 

#XORI 
xori $10, $9, 0xAAAA
sw $10, 68($3)

halt



org 0x0F00
data:
cfw 1
cfw 2
cfw 3
cfw 5
cfw 10
cfw -1

org 0x0FF0
storage:
