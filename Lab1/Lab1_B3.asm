# This program will print "Hello World! (2*integer) where 'integer' is a user input

.data
	out_string: .asciiz "\nHello World! "		# 'Hello World!' is one string 
	ask_string: .asciiz "\nEnter an Integer: "	# string to ask user for an integer
	integer   : .space 4				# allocate 4 bytes for the integer
	
.text
      main:
	
	li $v0, 4					# system call to print string 
	la $a0, ask_string				# load ask_string's address to $a0
	syscall					# call operating system to perform operation specified in $v0 

	li $v0, 5					# system call to read int
	syscall
	
	move $t0, $v0 					# move the address of $v0 to $t0 to save it temporarily
		
	li $v0, 4
	la $a0, out_string				# load out_string's address to $a0
	syscall
	
	add $t0, $t0, $t0				# t0 = t0 + t0 = 2 * t0 
	#sll $t0, $t0, 1				# another way to multiply (if you want to try it this way, uncomment 'sll $t0, $t0, 1'  								# and put in comments 'add $t0, $t0, $t0'
	move $a0, $t0					# move the address of $t0 to $a0 so the integer can be printed
	li $v0, 1					# system call to print string
	syscall
	
	li $v0, 10					# system call to terminate program
	syscall
	
