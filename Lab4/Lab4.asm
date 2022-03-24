						  ## - - - Lab 4 - - - ##
		# Ilektra-Despoina Papamatthaiaki (AM: 2018030106) & Magdalini Maragkoudaki (AM: 2017030169) #
# This program is a simple phonebook. It has 10 total spaces. 

# Data Segment		
.data
	message1:    .asciiz "\nPlease determine operation, entry(E), inquiry(I) or quit(Q):\n"
	message2:    .asciiz "\nPlease enter last name:\n"
	message3:    .asciiz "\nPlease enter first name:\n"
	message4:    .asciiz "\nPlease enter phone number:\n"
	message5:    .asciiz "\nThank you, the new entry is the following:\n"
	message6:    .asciiz "\nPlease enter the entry number you wish to retrieve:\n"
	message7:    .asciiz "\nThe number is:\n"
	message8:    .asciiz "\nThere is no such entry in the phonebook. Try again!\n"
	message9:    .asciiz "\nThank you for using the phonebook!\n"
	message10:   .asciiz "\nThe phonebook is full, try another operation.\n"
	             .align 2
	phonebook:   .space 600
	             .align 2

# Text Segment
.text 

#############################################################################################################################
#																 															#
#			    Register Map for main and subroutines phonebook_init and GoTo_Get_Entry				 						#
#																 															#
#	$s0 : This register contains the memory address of phonebook 							 								#
# 	$s1 : This register contains the operation ('E','I','Q') that the user chooses each time				 				#
# 	$s2 : This register is used as a pointer to the memory address of phonebook						 						#
#	$s3 : This register is used as a counter for entries									 								#
#	$s4 : This register is used as a pointer to the start of the memory of phonebook					 					#
#	$s5 : This register is used as a flag (flag = 0 goes to phonebook_init)						 							#
#																 															#
#############################################################################################################################
	
	## main is a function in which the user chooses an operation ##
	main:
	
		beq $s5, 0, phonebook_init				# If flag == 0 goes to phonebook_init, to initialize the phonebook 
		
		jal Prompt_User							# Jump and link in Prompt_User
		
		beq $s1, 69, GoTo_Get_Entry				# If 'operation' is equal to 69 ('E' in ascii code) jump to GoTo_Get_Entry
		beq $s1, 73, GoTo_Print_Entry			# If 'operation' is equal to 73 ('I' in ascii code) jump to GoTo_Print_Entry
		beq $s1, 81, GoTo_Quit					# If 'operation' is equal to 81 ('Q' in ascii code) jump to GoTo_Quit
		
		j main									# Jumps back in main to repeat the process
		
	## Initializes the phonebook ##
	phonebook_init:
	
		la  $s0, phonebook						# Load the address of phonebook in register $s0
		add $s2, $s2, $s0						# Point to the start of phonebook 
		add $s4, $s0, $zero						# Point to the start of phonebook 
		add $s5, $s5, 1							# Make flag == 1 so the initialization happens only once
		j main
		
	## Increases the counter for each entry, checks for overflow (more than 10 entries) and calls Get_Entry ##
	GoTo_Get_Entry:
			
		addi $s3, $s3, 1						# Increases counter by one each time it's called
		
		bgt $s3, 0x0000000A, Error_Message1		# If entries are greater than 10 jump to 'Error_Message1'
		jal Get_Entry							# Jump and link in Get_Entry
		j main

	## Calls Print_Entry ##
	GoTo_Print_Entry:
		
		jal Print_Entry							# Jump and link in Print_Entry
		j main
		
	## Calls Quit ##	
	GoTo_Quit:
	
		jal Quit								# Jump and link in Quit
		j main
	
	## Prints an error message ##
	Error_Message1:
		
		li $v0, 4								# System call to print string
		la $a0, message10
		syscall					
		
		j main
		
#############################################################################################################################
		
	## Asks user to select operation and gets the input ##
	Prompt_User:

		li $v0, 4								# System call to print string
		la $a0, message1
		syscall 
			
		li $v0, 12								# System call to read character
		li $a1, 1
		syscall
		
		move $s1, $v0
			
		jr $ra									# Go back to the address of $ra

	## Jumps and links Get_Last_Name, Get_First_Name, Get_Number, Print_This_Entry ##	
	Get_Entry:
		
		addi $sp, $sp, -4						# allocate 4 bytes in stack
		sw $ra, 0($sp)							# save the $ra to the stack, because it will change after the next jal
				
		jal Get_Last_Name						# Jump and link in Get_Last_Name
			    		
		jal Get_First_Name						# Jump and link in Get_First_Name	    
				
		jal Get_Number							# Jump and link in Get_Number
		
		jal Print_This_Entry					# Jump and link in Print_This_Entry
		
		lw $ra, 0($sp)							# Load back the $ra, that is needed in this function
		addi $sp, $sp, 4						# Free space in stack 
		
		jr $ra									# Go back to the address of $ra
			
#############################################################################################################################
#
#			    Register Map for main and subroutines phonebook_init and GoTo_Get_Entry
#
#	$t0 : This register contains the position of the phonebook (as an integer) that will be printed, if it exists 
# 	$t1 : This register is used to find the correct address according to the user input
# 	$t2 : This register contains the memory address of the phonebook from where the printing starts
#
#############################################################################################################################
	## Prints the entry that the user requests, or prints an error if the requested entry does not exist ##
	Print_Entry:
		
		li $v0, 4								# System call to print string
		la $a0, message6				
		syscall
		
		la $v0, 5								# System call to read integer
		syscall
		
		move $t0, $v0							# Move $v0 to $t0, so it can be used
		
		bgt  $t0, $s3, Error_Message2			# If user input is greater than the current number in counter
												# jump to Error_Message2 to print error message. 
		li $v0, 4
		la $a0, message7
		syscall
		
		li $v0, 1								# System call to print integer
		move $a0, $t0
		syscall

		li $v0, 11								# System call to print character
		li $a0, 0x0000002E						# Load in $a0 the character '.' (2E is the Hex Representation) 
		syscall

		li $a0, 0x00000020						# Load in $a0 the character ' ' (20 is the Hex Representation) 
		syscall
		
												# The equation used to find the correct number is (inputnumber-1)*60
												# where inputnumber is the number that the user enters
		addi $t0, $t0, -1						# First, decrease the inputnumber by 1 
		li   $t1, 0x0000003C
		mul  $t1, $t0, $t1						# Then, multiply the (inputnumber-1) with 60 
		move $t2, $s4							# Make $t2 point to the start of phonebook
		add $t2, $t2, $t1						# (start of the phonebook) + (inputnumber-1)*60
		
		li $v0, 4
		move $a0, $t2							# Move $t2 in $a0 to print the last name
		syscall
		
		addi $t2, $t2, 20						# Add 20 bytes, to point at the first name
		move $a0, $t2							# Move $t2 in $a0 to print the first name
		syscall
		
		addi $t2, $t2, 20						# Add 20 bytes, to point at the phone number
		move $a0, $t2							# Move $t2 in $a0 to print the phone number
		syscall
		
		jr $ra									# Go back to the address of $ra
		
	## Exits the program ##
	Quit:
	
		li $v0, 4
		la $a0, message9
		syscall
				
		li $v0, 10								# System call to terminate program
		syscall 
		
		jr $ra									# Go back to the address of $ra

#############################################################################################################################
	
	## Gets the last name from the user ##
	Get_Last_Name:
	
		li $v0, 4								# System call to print string
		la $a0, message2
		syscall 
			
		li $v0, 8								# System call to read string
		move $a0, $s0							# Load address of $a0 to $s0
		li $a1, 20								# Allocate space for the buffer
		syscall
		
		addi $sp, $sp, -4						# Allocate 4 bytes in stack
		sw $ra, 0($sp)							# Save the $ra to the stack, because it will change after the next jal
		
		jal Remove_New_Line						# Jump and link in Remove_New_Line
		
		lw $ra, 0($sp)							# Load back the $ra, that is needed in this function
		addi $sp, $sp, 4						# Free space in stack
		
		move $a0, $s0							# Load address of $a0 to $s0
		
		addi $s0, $s0, 20						# Move memory address by 20 bytes, for next entry
				
		jr $ra                          		# Jump back to the address of $ra
	
	## Gets the first name from the user ##
	Get_First_Name:
		
		li $v0, 4
		la $a0, message3
		syscall 
		
		li $v0, 8								# System call to read string
		move $a0, $s0
		li $a1, 20								# Allocate space for the buffer
		syscall
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal Remove_New_Line						# Jump and link in Remove_New_Line
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		move $a0, $s0
		
		addi $s0, $s0, 20
				
		jr $ra
	
	## Gets the phone number from the user ##
	Get_Number:
	
		li $v0, 4
		la $a0, message4
		syscall 
		
		li $v0, 8								# System call to read string
		move $a0, $s0
		li $a1, 20								# Allocate space for the buffer
		syscall
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal Remove_New_Line						# Not necessary
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		move $a0, $s0
		
		addi $s0, $s0, 20
		
		jr $ra
		
#############################################################################################################################
#																 															#
#			    Register Map for main and subroutines phonebook_init and GoTo_Get_Entry				 						#
#																 															#
#	$t0 : This register contains the address of the phonebook that will be printed			 		 						# 
#																 															#
#############################################################################################################################	

	## This function prints the entire new entry after it's been inputed ##
	Print_This_Entry:
	
		li $v0, 4								# System call to print string
		la $a0, message5
		syscall
		
		li $v0, 1								# System call to print integer
		move $a0, $s3							# Prints the number in front of entry
		syscall

		li $v0, 11								# System call to print character
		li $a0, 0x0000002E						# Load in $a0 the character '.' (2E is the Hex Representation) 
		syscall

		li $a0, 0x00000020						# Load in $a0 the character ' ' (20 is the Hex Representation) 
		syscall	
		
		move $t0, $s0							# Move the current address of phonebook in $t0, so $s0 won't change
		
		li $v0, 4
		addi $t0, $t0, -60						# Go back 60 bytes, to point at the start of the new entry
		move $a0, $t0							# Move $t0 in $a0 to print the last name
		syscall
	
		addi $t0, $t0, 20						# Add 20 bytes, to point at the first name
		move $a0, $t0							# Move $t0 in $a0 to print the first name
		syscall
		
		addi $t0, $t0, 20						# Add 20 bytes, to point at the number
		move $a0, $t0							# Move $t0 in $a0 to print the number
		syscall
		
		jr $ra						
		
#############################################################################################################################
#																 															#
#			    Register Map for main and subroutines phonebook_init and GoTo_Get_Entry				 						#
#																 															#
#	$t0 : This register contains the address of the string that will be processed			 		 						# 
#	$t1 : This register contains the current loaded byte from each loop and bytes are also stored from there		 		#
#			 	 												 															#
#############################################################################################################################
	
	## Removes the new line('\n') from input string and puts a space(' ') in it's position ## 
	Remove_New_Line:
	
		move $t0, $a0							# Move to $t0 the user input (last name or first name or number) 
												# in order to remove new line(\n) from the string
								
	loop:										# loop until it finds '\n'
		
		lb $t1, ($t0)							# Load byte from $t0 to $t1
		addi $t0, $t0, 1						# Move pointer 
		bne $t1, 10, loop						# If counter != 10 (\n in ascii) jump back to loop 
		addi $t0, $t0, -1						# If counter == 10, move pointer one position back
		li $t1, 0x00000020						# Load in $t1 a space character ('20' in Hex Representation)
		sb $t1, ($t0)							# Store this byte where '\n' was
		
		move $a0, $t0							# Move $t0 back to $a0
		jr $ra
	
	## Prints an error message ##
	Error_Message2:
	
		li $v0, 4
		la $a0, message8
		syscall
		
		j main	
