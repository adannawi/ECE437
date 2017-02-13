#----------------------------
#   Basic Multiply Function
#   Noah Petersen
#----------------------------

# Starting address
#  org 0x0000

# Multiply algorithm overview
# -Need to initialize stack (reg 29) to address 0xFFFC
# -Multiplies two UNSIGNED words
#   -Are these supposed to be on stack at start? Would make sense
#   -Multiplication of two bits is same as and
#   -Adjust the order of each bit by shifting up by the order of each bit ->
#   e.g. 1011 x 101 = 1011 + 00000 + 101100
#
#  That known, basic idea should be:
#     For all 16 bits of A:
#       Take LSB of A
#       If 1, shift B by its order (can increment a register to track) (e.g. for the first bit shift by 0, 2nd shift by 1, etc.)
#       Increment register storing bits to shift
#       Add shifted B to running total
#       Shift A right to get next bit as LSB
#     Repeat until register storing value is euqal to 16

         # Go to start of program -> How would we know this??????
         org 0x0000

  # Do I need to push previous register values onto stack??????

         # Set SP (do I need to put previous sp on stack since specifically setting it????
        addi $29, $0, 0xFFFC #Fine for standalone, when being called will
                              # already be modified

        # TC #1
        addi $20, $0, 0x0007
        addi $21, $0, 0x0003

        PUSH $20
        PUSH $21

        jal mult
        POP $22 #Store Res

        # TC #1
        addi $23, $0, 0x0010
        addi $24, $0, 0x0010

        PUSH $23
        PUSH $24

        jal mult
        POP $25 #Store Res

        halt

##########################################3
#Mult Program
##########################################3

  # Pull two args off of stack
        #   A is put in to $2

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
        # Use JAL in calling program to set return address in $31
        JR $31


