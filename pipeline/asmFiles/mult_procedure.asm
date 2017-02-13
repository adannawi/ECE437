#
# Author: Noah Petersen
#
#   Multiply Procedure for ECE 43700 lab 2
#
#   -place two operands on stack
#   -call multiply
#   -store result at stack location of first operand from mult program
#   -push variable number of operands on stack and mult all until result is top
#       item on stack


# Desired inputs:
# -top of stack: total number of operands
# -followed by all the operands (in any order)
#
# Output:
# -top of stack: result of all mults

# Test shell:

      org 0x0000

      #Set SP
      addi $29, $0, 0xFFFC

      #Test 1: 2 variables
      addi $12, $0, 0x0001
      addi $13, $0, 0x0002 #This doubles as number of things to mult for this tc

      PUSH $12
      PUSH $13
      PUSH $13

      jal nmult
      #HALT
      POP $14 #Result of TC 1 in $14

      #halt

      #Test 2: 3 variables
      addi $15, $0, 0x0010 #This is the only operand here
      addi $16, $0, 0x0003
      #halt
      #Push stuff onto stack
      PUSH $15
      PUSH $15
      PUSH $15
      PUSH $16

      #halt
      jal nmult
      POP $17 #Result 2 should be in $17

      #Test 3: 6 variables
      #Resuse $13 (which has 2) from before
      addi $18, $0, 0x0006
      PUSH $13
      PUSH $13
      PUSH $13
      PUSH $13
      PUSH $13
      PUSH $13
      PUSH $18
      jal nmult
      POP $19   #Store result in $19 for last tc
                #Result should be 2^6 = 64 = 0x00000040
      HALT

# nmult program
#
#   Named as such since it's supposed to multiply n integers
#
#   Register usage:
#   8 - Current total/Operand 1
#   9 - Next operand/Operand 2
#   10- Number of operands
#   11- Running count of mults

nmult:
      addi $28, $0, 0x0003 #test code
      POP $10 # Num Operands

      #BNE $28,$10,t1 #test code
      #halt

t1:   POP $8 #Op1
      POP $9 #Op2
      addi $11,$0,0x0001 #initialize LCV

nloop:#Push return address onto stacq to save
      PUSH $31

      #Push next two operands
      PUSH $8
      PUSH $9


      #BNE $28,$10,t3 #test code
      #halt
t3:
      #Call Mult Subroutine for two integers
      jal mult #Pop 2, push back 1
      POP $8

      #Tacq Return Address bacq
      POP $31

      #Increment LCV
      addi $11,$11,0x0001
      BEQ $10,$11,exit

      #Get next variable for mult
      POP $9

      #Loop back
      BNE $10,$11,nloop


      #Get return address back
exit:
      #POP $31
      #BNE $28,$10,t2
      #halt
      #Push final result onto stack and return
t2:   PUSH $8
      JR $31



####################################################################3
#                       Copied over mult SubR
####################################################################3

mult:
        #addi $29, $0, 0xFFFC #Fine for standalone, when being called will

        POP $2
         #lw $2, 4($29)
         #addi $29, $29, 4

        #   B is put into $3
         POP $3
        #lw $3, 4($29)
         #addi $29, $29, 4

        # Setup counter with 0 -> Is this just meaning I store the value in $0 to $1?
         add $1, $0, $0 # Setup Counter
         add $6, $0, $0 # Setup total
         addi $7, $0, 1 #Store 1 so can use for comparision later
         addi $5, $0, 0x0020 #Initialize to check for max loop repititions

        # Mask LSB to check next bit
loop:    andi $4, $2, 0x0001

        # Branch if stored and != 1
         bne $4, $7, incr

  # Jump if LSB not == 1
  #   Use temps to store running total & counter -> are temps specifically $8 & $9?
  #   Jump if != 0001 by offset of addition instruction size (whatever gets down to addi 0x0001)
        # Addition if == 1
        add $6, $6, $3

        # Increment Counting Register
incr:   addi $1, $1, 0x0001

        #Shift B so it will be ready for the next potential addition

        sll $3, $3, 1 # Shift so new B is ready for next

        # Rotate A right by 1 to get next bit
        srl $2, $2, 0x0001

        # Branch if count is not equal to 16 to go back to loop
        bne $1, $5, loop

        #Push final value back onto stack to finish program
        PUSH $6

        # Standalone End of Program
        #HALT

        # Return to calling address when being used as a function
        JR $31
