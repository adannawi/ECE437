org 0x0000

ori $1, $zero, 1
ori $2, $zero, 0
ori $3, $zero, addr
ori $4, $zero, 0

add $4, $4, $1 #$4 = 0 + 1
lw $6, 4($3) # $6 = 6
lw $5, 0($3) # $5 = 5
add $4, $4, $5 # $4 = 1 + 5
sw $4, 8($3) #308 <= 6 ($4)

halt



org 0x300
addr:
cfw 5
cfw 6
cfw 3
