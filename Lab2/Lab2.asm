# This program takes two integers from the user and the operation that they want to execute (+,-,*,/) and prints the result

# data declaration section

.data

	string1: .asciiz "\nPlease enter the 1st number: \n"
	string2: .asciiz "\nPlease enter the operation: \n"
	string3: .asciiz "\nPlease enter the 2nd number: \n"
	string4: .asciiz "\nThe result is: "
	error1 : .asciiz "\nThe operation you entered is invalid. The program will terminate.\n"
	error2 : .asciiz "\nYou can not divide a number with zero.\n"
	
.text

     main:
     		li $v0, 4					# system call to print string1
     		la $a0, string1
     		syscall 
     		
     		li $v0, 5					# system call to read integer
     		syscall 
     								
   		move $t0, $v0					# Moving the integer input to another register to store it temporarily
     		
     		li $v0, 4					# system call to print string2
     		la $a0, string2
     		syscall
     		
     		li $v0, 12					# system call to read character
     		la $a1, 1					# load character's byte to $a1
     		syscall 
     		
     		move $t1, $v0					# Moving character into another register to store it temporarily
     		
     		li $v0, 4					# system call to print string3
     		la $a0, string3
     		syscall 
     		
     		li $v0, 5					# system call to read the 2nd integer
     		syscall 
     		
     		move $t2, $v0					# Moving the integer input to another register to store it temporarily
     		
     		# code to compare the character and determine which operation should be executed ( +, -, * , / )
     		
     		beq $t1, 0x0000002b, addition			# if operation is '+', which is 2b in ascii code go to label 'addition'
     		beq $t1, 0x0000002d, subtraction		# if operation is '-', which is 2d in ascii code go to label 'subtraction'
     		beq $t1, 0x0000002a, multiplication		# if operation is '*', which is 2a in ascii code go to label 'multiplication'
     		beq $t1, 0x0000002f, division			# if operation is '/', which is 2f in ascii code go to label 'division'
     		
     		j Operation_Error				# go to Operation_Error if the operation is invalid
     		
     addition: 	
     			add $t0, $t0, $t2
     			j out					# jump to print the result
     	    	        
     subtraction:      
     			sub $t0, $t0, $t2
     			j out
     	    	        
     multiplication:   
			mul $t0, $t0, $t2
			j out
			
     division: 
      		        beq $t2, 0, Division_Error		# check if 2nd number is zero, because the you get an error
      		       
      		        div $t0, $t0, $t2
     	    	        #j out
     		
     out:
     	    
      			li $v0, 4				# system call to print string4
     			la $a0, string4
     			syscall
     		
     			move $a0, $t0
     			li $v0, 1
     			syscall
     			j exit					# jump to exit, to terminate program
     			
     Operation_Error:
     			li $v0, 4				# system call to print error1
     			la $a0, error1
     			syscall
     			j exit					# jump to exit, to terminate program
     		
     Division_Error:
     	        	li $v0, 4				# system call to print error2
     	        	la $a0, error2
     			syscall
     			j exit					# jump to exit, to terminate program
     		
     exit:
     			li $v0, 10				# system call to terminate program
     			syscall 
     
