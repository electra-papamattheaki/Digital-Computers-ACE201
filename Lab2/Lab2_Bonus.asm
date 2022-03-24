# This program takes two hexadecimal number from the user and the operation that they want to execute (+,-,*,/) and prints the result

# data declaration section

.data

	string1: .asciiz "\nPlease enter the 1st number (in Hexadecimal Form): \n"
	string2: .asciiz "\nPlease enter the operation: \n"
	string3: .asciiz "\nPlease enter the 2nd number (in Hexadecimal Form): \n"
	string4: .asciiz "\nThe LSB of the Hexadecimal number is: "
	error1 : .asciiz "\nThe operation you entered is invalid. The program will terminate.\n"
	error2 : .asciiz "\nYou can not divide a number with zero.\n"

# text declaration section
	
.text

     main:
     
     		li $v0, 4					# system call to print string1
     		la $a0, string1
     		syscall 
     		
     		li $v0, 12					# system call to read character, we have to read the hex number as a character
     		#la $a1, 1					# load character's byte to $a1
     		syscall 
     								
   		move $t0, $v0					# Moving the integer input to another register to store it temporarily
     		
     		li $v0, 4					# system call to print string2
     		la $a0, string2
     		syscall
     		
     		li $v0, 12					# system call to read character
     		#la $a1, 1					# load character's byte to $a1
     		syscall 
     		
     		move $t1, $v0					# Moving character into another register to store it temporarily
     		
     		li $v0, 4					# system call to print string3
     		la $a0, string3
     		syscall 
     		
     		li $v0, 12					# system call to read the 2nd number as a character
     		#la $a1, 1					# load character's byte to $a1
     		syscall 
     		
     		move $t2, $v0					# Moving the integer input to another register to store it temporarily
     		
     		ble $t0, '9', case1				# if the 1st number is equal or less than 9 go to label 'case1'
     		addi $t0, $t0, -55				# else if the 1st number entered is from A to F then to convert it to a 									# Hexadecimal we have to subtract 55 from it, which is '' in ascii code
     		j conversion2					# then jumb to convert the 2nd number
     		
     case1:
     
     		addi $t0, $t0, -48				# If the 1st number entered is from 0 to 9 then to convert it to a Hexadecimal
     								# we have to subtract 48 from it, which is '0' in ascii code
     		
     conversion2:
     
     	        ble $t2, '9', case2
     		addi $t2, $t2, -55
     		j operations					# jumb to 'operations' to execute the correct one
     		
     case2:
     
     		addi $t2, $t2, -48
     		
     		
     		# code to compare the character and determine which operation should be executed ( +, -, * , / )
     operations:
     		
     		beq $t1, 43, addition				# if operation is '+', which is 43 in ascii code go to label 'addition'
     		beq $t1, 45, subtraction			# if operation is '-', which is 45 in ascii code go to label 'subtraction'
     		beq $t1, 42, multiplication			# if operation is '*', which is 42 in ascii code go to label 'multiplication'
     		beq $t1, 47, division				# if operation is '/', which is 47 in ascii code go to label 'division'
     		
     		j Operation_Error				# jump to 'Operation_Error' if the operation is invalid
     		
     addition: 
     	
     		add $t0, $t0, $t2
     		j conversion_hex				# jump to convert the number back to hex form
     	    	        
     subtraction:  
         
     		sub $t0, $t0, $t2
     		j conversion_hex
     	    	        
     multiplication:  
      
		mul $t0, $t0, $t2
		j conversion_hex
			
     division: 
     
      		beq $t2, 0, Division_Error			# check if 2nd number is zero, because the you get an error
      		       
      		div $t0, $t0, $t2
     	    	j conversion_hex
     	    	
     	    	# code to convert the int result back to hexadecimal form
     conversion_hex:
     		
     		addi $t1, $zero, 16				# load 16 into a register
     		div  $t0, $t1					# devide th result with 16
     		mfhi $t1 					# reminder to $t1	
     		mflo $t3					# quotidient to $t3
     		
     		ble  $t1, 9, hex_result			# if the result of the division is equal or less than '9'  								        # go to'hex_result'		
     		addi $t1, $t1, 55				# add 55 to get the final result
     		j out

     hex_result:
               
     		addi $t1, $t1, 48				# add 48 to get the final result
     		j out
     		
     out:
     	    
      		li $v0, 4					# system call to print string4
     		la $a0, string4
     		syscall
     		
     		move $a0, $t1
     		li $v0, 11
     		syscall
     		j exit						# jump to 'exit', to terminate program
     			
     Operation_Error:
     
     		li $v0, 4					# system call to print error1
     		la $a0, error1
     		syscall
     		j exit						# jump to 'exit', to terminate program
     			
     Division_Error:
     
     	        li $v0, 4					# system call to print error2
     	        la $a0, error2
     		syscall
     		j exit						# jump to 'exit', to terminate program
     		
     exit:
     
     		li $v0, 10					# system call to terminate program
     		syscall   
