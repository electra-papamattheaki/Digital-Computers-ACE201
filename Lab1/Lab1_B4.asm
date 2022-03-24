# The output of this program will be 'Hello World!(Character)' where Character is a character that the user inputs

.data
	out_string1: .asciiz "\nHello World!"		# 'Hello' and 'World!' are one string now
	ask_string : .asciiz "\nEnter a character: "	# string that asks the user for a character
	character  : .space 1				# allocate 1 byte space for the character -this is used as a buffer- 
	#character: .asciiz ""				# another way to declare the character
		
.text
      main:
	
	li $v0, 4					# system call to print ask_string
	la $a0, ask_string				 
	syscall					# call operating system to perform operation specified in $v0
	
	li $v0, 12					# system call to read character
	syscall 					# call operating system to perform operation specified in $v0
	
	move $t0, $v0					# move the address of $v0 to $t0 to save it temporarily  
	
	li $v0, 4					# system call to print 'Hello World!"
	la $a0, out_string1
	syscall					# call operating system to perform operation specified in $v0
	
	move $a0, $t0					# move the address of $t0 to $a0 so the character can be printed
	li $v0, 11					# system call to print character
	syscall                                       # call operating system to perform operation specified in $v0
	
	li $v0, 10					# exit program
	syscall					# call operating system to perform operation specified in $v0
	
