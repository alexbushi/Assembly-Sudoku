.data
newline:.asciiz "\n"		# useful for printing commands
here:.asciiz "We are here!!!!\n"
star:	.asciiz "*"
GRIDSIZE: .word 3
GRID_SQUARED: .word 9
board1: .word 128 511 511 16 511 511 4 2 511 64 511 4 1 511 511 8 511 511 1 2 511 511 511 256 511 511 128 32 16 511 511 256 4 511 128 511 511 256 511 511 511 511 511 1 511 511 128 511 32 2 511 511 256 4 2 511 511 8 511 511 511 32 64 511 511 32 511 511 128 1 511 2 511 64 8 511 511 32 511 511 16
board2: .word 128 8 256 16 32 64 4 2 1 64 32 4 1 128 2 8 16 256 1 2 16 4 8 256 32 64 128 32 16 1 64 256 4 2 128 8 4 256 2 128 16 8 64 1 32 8 128 64 32 2 1 16 256 4 2 1 128 8 4 16 256 32 64 16 4 32 256 64 128 1 8 2 256 64 8 2 1 32 128 4 16
	
.text
# main function
main:
	sub  	$sp, $sp, 4
	sw   	$ra, 0($sp) # save $ra on stack

	# test singleton (true case)
	li	$a0, 0x010
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1

	# test singleton (false case)
	li	$a0, 0x10b

	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# test get_singleton 
	li	$a0, 0x010
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 4

	# test get_singleton 
	li	$a0, 0x008
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 3

	# test board_done (true case)
	la	$a0, board2
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1
	
	# test board_done (false case)
	la	$a0, board1
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# print a newline
	li	$v0, 4
	la	$a0, newline
	syscall	

	# test print_board
	la	$a0, board1
	jal	print_board

	# should print the following:
	# 8**5**32*
	# 7*31**4**
	# 12***9**8
	# 65**93*8*
	# *9*****1*
	# *8*62**93
	# 2**4***67
	# **6**81*2
	# *74**6**5

	lw   	$ra, 0($sp) 	# restore $ra from stack
	add  	$sp, $sp, 4
	jr	$ra

print_int_and_space:
	li   	$v0, 1         	# load the syscall option for printing ints
	syscall              	# print the element

	li   	$a0, 32        	# print a black space (ASCII 32)
	li   	$v0, 11        	# load the syscall option for printing chars
	syscall              	# print the char
	
	jr      $ra          	# return to the calling procedure

print_int:
	li   	$v0, 1         	# load the syscall option for printing ints
	syscall              	# print the element
	
	jr      $ra          	# return to the calling procedure

print_newline:
	li	$v0, 4		# at the end of a line, print a newline char.
	la	$a0, newline
	syscall	    
	jr	$ra

print_star:
	li	$v0, 4		# print a "*"
	la	$a0, star
	syscall
	jr	$ra
	
	
# ALL your code goes below this line.
#
# We will delete EVERYTHING above the line; DO NOT delete 
# the line.
#
# ---------------------------------------------------------------------
	
## bool singleton(int value) {  // This function checks whether
##   return (value != 0) && !(value & (value - 1));
## }
singleton:

	sub $sp, $sp, 8
	sw $s0, 0($sp)
	sw $s1, 4($sp)

	beq $a0, $0, returnfalse

	sub $s0, $a0, 1
	and $s1, $s0, $a0
	beq $s1, $0, returntrue
	j returnfalse

	returntrue:
		li $v0, 1
		j exit1

	returnfalse:
		li $v0, 0
		j exit1

	exit1:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		add $sp, $sp, 8
		jr $ra


## int get_singleton(int value) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 if (value == (1<<i)) {
## 		return i;
## 	 }
##   }
##   return 0;
## }
get_singleton:

	sub $sp, $sp, 20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)

	##s0 is i
	li $s0, 0
	li $s2, 1
	loop:
		slti $s1, $s0, 9
		##s1 will be 1 if i < GRID_SQUARED, so break and return 0 if s1 is 0
		beq $s1, $0, returnzero

		srl $s3, $a0, $s0
		and $s4, $s3, $s2
		beq $s4, $s2, returni

		addi $s0, $s0, 1
		j loop

	returnzero:
		li $v0, 0
		j exit2

	returni:
		add $v0, $0, $s0
		j exit2

	exit2:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		add $sp, $sp, 20
		jr $ra


## bool
## board_done(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		if (!singleton(board[i][j])) {
## 		  return false;
## 		}
## 	 }
##   }
##   return true;
## }

board_done:

	##i=0
	li $s0,-1

	outerloop:
		##j=0
		li $s1, 0
		addi $s0, $s0, 1
		slti $s2, $s0, 9
		##s2 will be 1 if i < GRID_SQUARED, so break and return 0 if s1 is 0
		beq $s2, $0, returntruee

		innerloop:
			slti $s3, $s1, 9
			beq $s3, $0, outerloop

			##36i
			mul $s5, $s0, 36
			##4j
			mul $s6, $s1, 4
			##36i + 4j
			add $s5, $s5, $s6
			##A[0][0] + 36i + 4j
			add $s4, $a0, $s5
			##s4 should be address of A[i][j]
			move $s7, $a0
			##a0 should have value at address of A[i][j]
			lw $a0, 0($s4)

			sub $sp, $sp, 4
			sw $ra, 0($sp)
			jal singleton
			lw $ra, 0($sp)
			add $sp, $sp, 4

			##if not a singleton
			beq $v0, $0, returnfalsee
			##get original value of a0 or A[0][0]
			move $a0, $s7

			addi $s1, $s1, 1
			j innerloop

	returntruee:
		li $v0, 1
		j exit3

	returnfalsee:
		li $v0, 0
		j exit3

	exit3:
		jr	$ra
	
## void
## print_board(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		int value = board[i][j];
## 		char c = '*';
## 		if (singleton(value)) {
## 		  c = get_singleton(value) + '1';
## 		}
## 		printf("%c", c);
## 	 }
## 	 printf("\n");
##   }
## }

print_board:

	##i=0
	li $s0,-1
	
	outerloop2:
		##j=0
		li $s1, 0
		addi $s0, $s0, 1
		slti $s2, $s0, 9
		beq $s2, $0, exit4

		sub $sp, $sp, 12
		sw $ra, 0($sp)
		sw $v0, 4($sp)
		sw $a0, 8($sp)
		# print a newline
		##li	$v0, 4
		##la	$a0, newline
		##syscall	
		jal print_newline
		lw $ra, 0($sp)
		lw $v0, 4($sp)
		lw $a0, 8($sp)
		add $sp, $sp, 12

		innerloop2:
			slti $s3, $s1, 9
			beq $s3, $0, outerloop2

			##36i
			mul $s5, $s0, 36
			##4j
			mul $s6, $s1, 4
			##36i + 4j
			add $s5, $s5, $s6
			##A[0][0] + 36i + 4j
			add $s4, $a0, $s5
			##s4 should be address of A[i][j]
			move $s7, $a0
			##a0 is value
			lw $a0, 0($s4)

			sub $sp, $sp, 4
			sw $ra, 0($sp)
			jal singleton
			lw $ra, 0($sp)
			add $sp, $sp, 4

			##c = '*', s0 is star
			sub $sp, $sp, 4
			sw $s0, 0($sp)
			la $s0, star
			
			##if a singleton
			bne $v0, $0, gettingsingleton
			##else just fall thru to printstar

		printst:
			##get original value of a0 or A[0][0]
			move $a0, $s7
			sub $sp, $sp, 12
			sw $ra, 0($sp)
			sw $v0, 4($sp)
			sw $a0, 8($sp)
			jal print_star
			##move	$a0, $s0
			##jal	print_int
			lw $ra, 0($sp)
			lw $v0, 4($sp)
			lw $a0, 8($sp)
			add $sp, $sp, 12

			##get original value of i before looping again
			lw $s0, 0($sp)
			add $sp, $sp, 4

			addi $s1, $s1, 1
			j innerloop2
		
		printc:
			##get original value of a0 or A[0][0]
			move $a0, $s7
			sub $sp, $sp, 12
			sw $ra, 0($sp)
			sw $v0, 4($sp)
			sw $a0, 8($sp)
			move	$a0, $s0
			jal	print_int
			lw $ra, 0($sp)
			lw $v0, 4($sp)
			lw $a0, 8($sp)
			add $sp, $sp, 12

			##get original value of i before looping again
			lw $s0, 0($sp)
			add $sp, $sp, 4

			addi $s1, $s1, 1
			j innerloop2

		gettingsingleton:
			sub $sp, $sp, 4
			sw $ra, 0($sp)
			jal get_singleton
			lw $ra, 0($sp)
			add $sp, $sp, 4
			##get_singleton(value) + 1
			addi $s0, $v0, 1
			j printc

	exit4:
		jr	$ra

