						   	 ## - - - Lab 3 - - - ##
		# Ilektra-Despoina Papamatthaiaki (AM: 2018030106) & Magdalini Maragkoudaki (AM: 2017030169) #

# This program gets a user input and then prints the correct processed form of that string 

# Data Segment
.data
	ask_string:    .asciiz "\nPlease Enter your String:\n"	# String that asks the user for input
	out_string:    .asciiz "\nThe Processed String is: \n"	# String needed for output
      	
      	           .align 2	       
	input_string:  .space 100								# This is a buffer
	               .align 2
    processed_str: .space 100								# This is also a buffer
      	
#############################################################################################################################
					                 ## Register Usage ##
					                
	# $s0: This Register contains the address of input_string
	# $s1: This Register contains the address of processed_str
	# $t0: This Register contains the address of the current word
	# $t1: This Register contains the current byte that was masked and will be processed
	# $t2: This Register contains the processed byte to be stored
	# $t3: This Register is used as a counter for the bytes of each word
	# $t4: This Register is used as a flag, if $t4=0 => false (don't store byte) else if $t4=1 => true (store byte) 
	
#############################################################################################################################
	               
# Text Segment	
.text
	main:
	
		jal Get_Input										# Jal to 'Get_Input' function to get the input from user
		
		la $s0, input_string								# Load the address of memory allocated for usr_string 								
		la $s1, processed_str								# Load the address of memory allocated for 
															# input_string and processed_string which are considered as 
															# global variables so they are stored in s registers
											
		jal Process											# Jal to 'Process' function to get the new processed string
		
		
		jal Print_Output									# Jal to 'Print_Outout' to print the new processed string 
			
		li $v0, 10											# System call to exit program
		syscall
		
		#j main												# For infinity loop use, uncomment this part and comment
															# the part that terminates the program (it is right above :D )
									
						   			## Code For Functions ##

	Get_Input:
		
		li $v0, 4											# System call to print string
		la $a0, ask_string
		syscall
		
		li $v0, 8											# System call to read string
		la $a0, input_string
		la $a1, 100											# Load usr_string's bytes to $a1
		syscall
		jr $ra												# Jumps back to the address in register $ra (so.. in main)
				
	Process:
	
		addi $t4, $zero, 1									# Initialize flag when $t4 = 1 true, store the byte
		
	loadword_loop:	
															# While Loop to load each word
		add $t3, $zero, $zero								# Initialize counter $t3=0 every time you enter the loop
		lw  $t0, ($s0)										# Load the first word (4 bytes) of $s0 to $t0 to begin masking
		j masking
		
	masking:
	
		andi $t1, $t0, 0x000000FF							# Mask the last 8 bits
		srl  $t0, $t0, 8									# Shift right for the next time
		j parsing
	
	parsing:
	
		beq $t1, 10 , correct_form							# If it's the '\n' character it means the string has ended so jumb to 
															# store_byte to store it and then your string is finished!
									
		bgt $t1, 122, create_space							# If it's greater than 122 in ascii code it's a character that will 										
															# become a space or it will be ignored because a space already exists
		
		bgt $t1, 96 , correct_form							# If it's greater than 96 (and also from previous comparison equal or 									
															# less than 122 it's from a-z so jumb to store the byte as it is
		
		bgt $t1, 90, create_space							# If it's greater than 90 (and also from previous comparison equal or 									
															# less than 96 go to create_space for the same reason as before
		
		bgt $t1, 64 , letter_case							# If it's greater than 64 (and also from previous comparison equal or 									
															# less than 90 it's from A-Z so go to letter_process to convert them to small ones
									
		bgt $t1, 57 , create_space							# If it's greater than 57 (and also from previous comparison equal or 									
															# less than 64 go to create_space for the same reason as before
		
		bgt $t1, 47 , correct_form							# If it's greater than 47 (and also from previous comparison equal or 									
															# less than 57 it's from 1-9 so go jumb store the byte as it is
		
		j create_space										# If it's less or equal than 47 go to create_space 
															# for the same reason as before
			
	create_space:
	
		beq  $t4, 1, put_space   							# If flag==1 ,true so go to put_space to add space
		j do_nothing										# If flag==0 ignore this character and jump to do_nothing
		
	put_space:	
	
		addi $t2, $zero, 32									# Add '32' which represents the space in ascii code
		addi $t4, $zero, 0									# already has a space now so flag = false
		j store_byte						
		
	letter_case:
								
		addi $t4, $zero, 1									# Make flag = true because we store the letters
		addi $t2, $t1, 32									# Add '32' so the capital letter becomes a small one according to ascii code
		j store_byte
		
	correct_form:
	
		addi $t4, $zero, 1									# Make flag = true 
		add  $t2, $zero, $t1								# Move register $t1 to $t2 as it is			
		j store_byte
		
	store_byte:
	
		sb   $t2, ($s1)										# Store byte from $t2 to the correct address of $s1
		beq  $t2, 10, endProcess							# If $t2=10(\n in ascii) end process because the end
															# of the string was reached
		addi $s1, $s1, 1									# Move the address of $s1 for the next time
		addi $s0, $s0, 1									# Move the address of $s0 so when we go back to loadword_loop 
															# the address will be the correct one
		addi $t3, $t3, 1									# Increase the counter because another byte was read	
		bne  $t3, 4, masking								# Check to find out if the word ended
		j loadword_loop										# Go back to load the next word
		
	do_nothing: 											# Store nothing because a space already exists
	
		addi $s0, $s0, 1									# We also need to increase $s0, $s1, $t3 in this
		addi $t3, $t3, 1									# subroutine to keep up with the addresses in 
		bne  $t3, 4, masking								# case we don't need to store anything
		j loadword_loop	
			
	endProcess:
	
		jr $ra												# Jumps back to the address in register $ra (so.. in main)
		
	Print_Output:
	
		li $v0, 4											# System call to print string
		la $a0, out_string
		syscall
		
		la $a0, processed_str								# Load processed_str to $a0 so it can be printed
		syscall
		
		jr $ra												# Return in main to exit the program
