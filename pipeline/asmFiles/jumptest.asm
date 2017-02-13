    org 0x0000
    addi $29, $0, 0xFFFC #idk if we need this but good check

  #Setup two registers for BEQ test
    ori   $7,$zero,0xF0
    ori   $6,$zero,0x80
    addi $2, $0, 0x0001
    addi $3, $0, 0x0001
    #JAL - jump and linq
    #do a store
    #J - jump
    halt

    #JAL, pretty far off
    sw $2, 0($7) #edit
    #Do some store
    #JR
    #halt

    #Regular Jump, needs to be pretty far off
    bne  $4, $2, b2
    sw $3, 4($7)
    sw $2, 0($6)
    #Jump 2
    halt #in case of failed jump

  org   0x00F0
  cfw   0x7337
  cfw   0x2701
  cfw   0x1337
