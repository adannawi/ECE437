#Test for BNE and BEQ for single cycle
#
#

    org 0x0000
    addi $29, $0, 0xFFFC #idk if we need this but good check

  #Setup two registers for BEQ test
    ori   $7,$zero,0xF0
    ori   $6,$zero,0x80
    addi $2, $0, 0x0001
    addi $3, $0, 0x0001
    beq $6, $7, b1 #Should never be taken
    sw $2, 0($7)
    beq $2, $3, b1 #Shold always be taken
    sw $3, 4($7)
    sw $2, 0($6)
    halt

b1: addi $4, $0, 0x0002
    bne  $2, $3, b2 #Never taken
    sw $2, 0($7)
    bne  $4, $2, b2 #Always Taken
    sw $3, 4($7)
    sw $2, 0($6)
    halt

b2: sll $5, $2, 0x0002
    sw $2, 0($7)
    sw $3, 4($7)
    sw $2, 0($6)
    halt

  org   0x00F0
  cfw   0x7337
  cfw   0x2701
  cfw   0x1337
