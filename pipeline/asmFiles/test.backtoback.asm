#
# test.backtoback.asm
# Noah Petersen
#
# Test case specifically targeted at dealing with back to back data
# dependencies.
#

org 0x0000
ori $1, $0, 0x0001
ori $2, $0, 0x0002
ori $3, $0, 0x0004
ori $4, $0, 0x000F
ori $10, $0, 0xF0
add $5,$1,$2
add $5,$3,$4
add $6,$5,$4

SW $1, 0($10)
SW $2, 4($10)
SW $3, 8($10)
SW $4, 12($10)
SW $5, 16($10)
SW $6, 20($10)

HALT


org 0x00F0
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
cfw 0xFFFF
