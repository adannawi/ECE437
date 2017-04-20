
##################################
#         CUSTOM CODE            #
##################################


###################################################
# PROCESSOR 1 - Producer, produces random numbers #
###################################################
org 0x0000 

ori $sp, $zero, 0x800   # init stack ptr
ori $s0, $0, 0xece437  	# seed to be used
ori $s1, $0, 10 	    	# set the size of the stack
ori $s2, $0, 0  	     	# current size of stack
ori $s3, $0, 0		     	# total numbers generated
ori $s4, $0, 256	     	# max numbers desired
ori $t6, $0, 0
ori $t7, $0, 0

generate:

 beq $s2, $s1, generate # stack is currently full, do nothing
 beq $s3, $s4, p0done   # if 256 numbers have been generated, done

 ori $a0, $0, lockme  	# move lock value into arg
 jal lock 			      	# try to get the lock

 lw $s2, buffsize($0) 	# load buffer size
 addiu $s2, $s2, 1 		  # increment by one
 sw $s2, buffsize($0) 	# store buffer size


 ori $a0, $s0, 0 		         # move seed to argument for crc
 jal crc32 				           # run the crc function
 lw  $t3, consumerbusy($0)   # lets check if the consumer is busy
 bne $t3, $0, modifyseed     # if the consumer is indeed busy, lets modify the seed to use lower 16 bits
 back:
 ori $s0, $v0, 0 		      # update seed with previous random value
 jal pushm				        # push result on the stack
 addiu $s3, $s3, 1 	 	    # increment total number count by one

 ori $a0, $0, lockme	    # reload lock value before unlocking
 jal unlock 			        # give the lock back for others to use

 j generate

p0done:
 ori $s0, $0, 0xbeef      #  nonzero signal to signify core 1 is done
 sw $s0, imdone($0)       # write it to memory so other core can read it
 halt

modifyseed:               # if the consumer is busy, use the lower 16 bits of the produced number
 andi $v0, $v0, 0xFFFF
 j back



# Lock handling codes

lock:
aquire:
 ll		$t0, 0($a0)
 bne 	$t0, $0, aquire
 addiu 	$t0, $t0, 1
 sc 	$t0, 0($a0)
 beq	$t0, $0, lock
 jr 	$ra

 unlock:
 sw		$0, 0($a0)
 jr		$ra

# Modified push for multicore
# USAGE: $v0 -> stackdata
 pushm:
 lw   $t1, stackptr($0)      # load stack pointer
 sw   $v0, stackdata($t1)    # store data in stackdata
 ori  $t2, $0, 4
 subu $t1, $t1, $t2          # increment stack pointer by 4
 sw   $t1, stackptr($0)      # store new stack pointer
  addi $t6, $t6, 1
 jr   $ra 

 # Modified pop for multicore
 # USAGE: $a1 <- stackdata
 popm:
 lw   $t1, stackptr($0)      # load stack pointer
 lw   $a1, stackdata($t1)    # get data from location
 sw   $zero, stackdata($t1)  # place a zero in its stead
 addiu $t1, $t1, 4
 sw   $t1, stackptr($0)      # store new stack pointer
 addi $t7, $t7, 1
 jr   $ra






###################################################################
# PROCESSOR 2 - Consumer, finds average, min, max of the numbers  #
###################################################################
 org 0x400                 # init pc for core 2
 ori  $s4, $0, 0xFFFF       # min
 ori  $s5, $0, 0x0000       # max
 ori  $s6, $0, 0x0000       # avg

consume:
 lw		$t3, buffsize($0) 	  # load buffer size
 beq	$t3, $0, prelim  	    # if stack is empty, check if core 1 is done
 ori  $t1, $0, 0xece437     # use this as the complete flag, shouldn't matter cause checks for nonzero
 sw   $t1, consumerbusy($0) # store it in the fancy shmancy mem addr
 ori	$a0, $0, lockme 	    # load lock into a0
 jal	lock 				          # try to fetch lock
 jal  popm				          # pop value into a1
 lw		$t3, buffsize($0) 	  # load current buffer size
 ori	$t4, $0, 1 			      # we gonna sub
 subu $t3, $t3, $t4 		    # t3 = t3 - 1
 sw		$t3, buffsize($0) 	  # decreased buffer size by 1

 # $a0 and $a1 are used as arguments for min and max
 # let's use $a1 as current, and $a0 as previous

 #### MIN ####
 ori  $a0, $s4, 0  # set $a0 as old value
 jal  min          # find minimum between $a0 and $a1, returns $v0
 ori  $s4, $v0, 0  # overwrite old $s4 with $v0

 #### MAX ####
 ori  $a0, $s5, 0
 jal  max
 ori  $s5, $v0, 0

 ##### AVG ########
 # 1. Find Sum
 # 2. Divide by 256
 ##################

 addu $s6, $s6, $a1 # keep a running total of all values

 ori  $a0, $0, lockme
 jal	unlock				# unlock
 j 		consume 			# loop


prelim:
 lw		$t0, imdone($0)		# check if core 1's done flag is set
 bne	$t0, $0, finish   # if core 1 is done, lets finish up
 ori  $t1, $0, 0 
 sw   $t1, consumerbusy($0) # core 1 isn't done and we're not busy, so let's put a 0 in that address
 j 		consume

finish:
 sw   $s4, minval($0) #$20
 sw   $s5, maxval($0) #$21
 srl  $s6, $s6, 8 # divide by 256
 sw   $s6, avgval($0) #$22
 lw   $1,  stackptr($0) # for debugging purposes
 halt



org 0x800

####### STACK DATA #########
stackdata:
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
 cfw 0x0
###############################

lockme:
 cfw 0x0 # lock will be stored here

minval:
 cfw 0x0 # minimum value will be stored here

maxval:
 cfw 0x0 # maximum value will be stored here

avgval:
 cfw 0x0 # average will be stored here

buffsize:
 cfw 0x0 # current size of the stack

imdone:
 cfw 0x0 # core 1's done flag for core 2

stackptr:
 cfw 0x824 # current stack pointer

consumerbusy:
 cfw 0x0


##################################
#     SUPPLIED SUBROUTINES       #
##################################




#REGISTERS
#at $1 at
#v $2-3 function returns
#a $4-7 function args
#t $8-15 temps
#s $16-23 saved temps (callee preserved)
#t $24-25 temps
#k $26-27 kernel
#gp $28 gp (callee preserved)
#sp $29 sp (callee preserved)
#fp $30 fp (callee preserved)
#ra $31 return address

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $v0 = crc32($a0)
crc32:
  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $0, $0
  ori $t3, $0, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  srl $t4, $a0, 31
  sll $a0, $a0, 1
  beq $t4, $0, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $0
  jr $ra
#------------------------------------------------------


# registers a0-1,v0-1,t0
# a0 = Numerator
# a1 = Denominator
# v0 = Quotient
# v1 = Remainder

#-divide(N=$a0,D=$a1) returns (Q=$v0,R=$v1)--------
divide:               # setup frame
  push  $ra           # saved return address
  push  $a0           # saved register
  push  $a1           # saved register
  or    $v0, $0, $0   # Quotient v0=0
  or    $v1, $0, $a0  # Remainder t2=N=a0
  beq   $0, $a1, divrtn # test zero D
  slt   $t0, $a1, $0  # test neg D
  bne   $t0, $0, divdneg
  slt   $t0, $a0, $0  # test neg N
  bne   $t0, $0, divnneg
divloop:
  slt   $t0, $v1, $a1 # while R >= D
  bne   $t0, $0, divrtn
  addiu $v0, $v0, 1   # Q = Q + 1
  subu  $v1, $v1, $a1 # R = R - D
  j     divloop
divnneg:
  subu  $a0, $0, $a0  # negate N
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
  beq   $v1, $0, divrtn
  addiu $v0, $v0, -1  # return -Q-1
  j     divrtn
divdneg:
  subu  $a0, $0, $a1  # negate D
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
divrtn:
  pop $a1
  pop $a0
  pop $ra
  jr  $ra
#-divide--------------------------------------------



# registers a0-1,v0,t0
# a0 = a
# a1 = b
# v0 = result

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
max:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a0, $a1
  beq   $t0, $0, maxrtn
  or    $v0, $0, $a1
maxrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
min:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a1, $a0
  beq   $t0, $0, minrtn
  or    $v0, $0, $a1
minrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
#--------------------------------------------------


