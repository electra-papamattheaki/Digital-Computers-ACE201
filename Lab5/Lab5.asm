## ----------------------------- Lab 5 ----------------------------- ##

# Data Segment
.data

	message1: .asciiz "\nPlease enter a number in the range 0-24, or -1 to quit:\n"
	message2: .asciiz "\nThis number is outside the allowable range.\n"
	message3: .asciiz "\nThe Fibonacci number F   is "
	message4: .asciiz "\nProgram Terminated\n" 
	
# Text Segment
.text

##########################################################################################################
                                # - - -  Register Map in main - - -#

        #   $s0: This register contains the integer taken from the user
        #   $t0: This register is used to load input in stack
##########################################################################################################
                            
    main:
        
	 	jal PromptUser                      # Jump and Link in PromptUser

        jal QuitCheck                       # Jump and Link in QuitCheck

        bgt  $s0, 24, Error                 # If input(in $s0) is greater than 24, jump in Error

        add  $t0, $s0, $zero                # Load $s0 to a temporary register to process it 
        addi $sp, $sp, -4                   # Allocate space in stack 
        sw   $t0, 0($sp)                    # Store user input

        jal Fibonacci                       # Jump and Link in Fibonacci

        jal ConvertIntToString              # Jump and Link in ConvertIntToString

        lw   $t0, 0($sp)                    # Load from top of stack the returned value from Fibonacci function
        addi $sp, $sp, 4                    # Free the stack
        
        li   $v0, 4                         # System call to print string
        la   $a0, message3
        syscall                             # First syscall

        li   $v0, 1                         # System call to print integer
        add  $a0, $t0, $zero
        syscall                             # Second syscall , everything good!!

        j main                              # Loop in main until quit

##########################################################################################################
                                        # - - -  Code in C - - - #

        #       int fibbonacci(int n) 									
        #       {				      										
        #           if (n < 2) 					      					
        #           return n;					     					
        #    						      	     				    
        #           return (fibbonacci(n-1) + fibbonacci(n-2));	        
        #       }

                                # - - -  Register map in Fibonacci - - - #
        
        #   $t0: This register contains the parameter 'n' each time the function is called,
        #        also the return value of Fibonacci: f(n) = f(n-1) + f(n-2)
        #   $t1: This register is used to create 'n-1' and after the return of the function,
        #        it contains the return value from the first Fibonacci: f(n-1)
        #   $t2: This register is used to create 'n-2' and after the return of the function,
        #        it contains the return value from the first Fibonacci: f(n-2)
##########################################################################################################

    ## Function that calculates the Fibonacci number of the given number ##
    Fibonacci:

    	lw   $t0, 0($sp)                    # Take the parameter 'n' from top of stack

        addi $t1, $t0, -1                   # Make parameter 'n-1'	

		addi $sp, $sp, -8                   # Allocate space for $ra and 'n-1'		
        sw   $t1, 0 ($sp)                   # Save 'n-1' to the stack
        sw   $ra, 4 ($sp)                   # Save return address to the stack

		blt  $t0, 2, Return                 # Jump to Return because when n<2, f(0)=0 and f(1)=0 
		
		jal Fibonacci                       # Jump and Link in Fibonacci (Recursion time)

		lw   $t0, 8 ($sp)                   # Restore fresh $t0 from stack
        addi $t2, $t0, -2                   # Make parameter 'n-2'
		
        addi $sp, $sp, -4                   # Registers $ra and f(n-1) are still in stack because we still need their values
                                            # so allocate space for one more value, 'n-2'
        sw   $t2, 0 ($sp)                   # Save 'n-2' to the stack
        
        jal Fibonacci                       # Jump and Link in Fibonacci (Recursion time 2)

		lw   $ra, 8 ($sp)                   # Restore return address from stack
        lw   $t1, 4 ($sp)                   # Restore return value from stack, re-using $t1 for storing f(n-1)
		lw   $t2, 0 ($sp)                   # Restore return value from stack, re-using $t2 for storing f(n-2)
    	addi $sp, $sp, 12                   # Shrink the stack to its former size, as three words are no longer needed  
          
        add  $t0, $t1, $t2                  # Re-using $t0 to calculate the final result, f(n)
        sw   $t0, 0($sp)                    # Store it to the stack 

        jr   $ra                            # Go back to the address of $ra

    ## Subroutine that helps the Fibonacci function, f(0)=0 and f(1)=0 ##
	Return:

        lw   $ra, 4 ($sp)                   # Restore return address from stack      
        addi $sp, $sp, 8                    # Shrink stack to it's former size  
		jr   $ra                            # Go back to the address of $ra

    ## Function that gets an input string from the user ##
    PromptUser:

 		li   $v0, 4                         # System call to print string
		la   $a0, message1
		syscall
	
		li   $v0, 5                         # System call to read integer
		syscall
		
        add  $s0, $v0, $zero                # Store in $s0 the user input
		jr   $ra                            # Go back to the address of $ra

    ## Function that checks if the user input is '-1' or less ## 
    QuitCheck:

        beq  $s0, 0xffffffff, Quit          # Check if $s0 is '-1' to quit the program
        blt  $s0, 0xffffffff, Error         # Check if $s0 is less than '-1' to detect input error
        jr   $ra                            # Go back to the address of $ra

##########################################################################################################
                        # - - -  Register map in ConvertIntToString - - - #

        # $t0: This register contains the value of $s0 in order to process it, also used as a pointer
        # $t1: This register contains the value of 10
        # $t2: This register contains the quotidient of the division
        # $t3: This register contains the reminder of the division, also used to load a space
##########################################################################################################

    ## Function that converts the given integer to a string and then adjusts message3 using this string ##
    ConvertIntToString:

        add  $t0, $s0, $zero                
        li   $t1, 0x0000000A                # Load '10' (A in Hex Form) in $t1
        div	 $t0, $t1                       # $t0 / $t1
        mflo $t2                            # $t2 = floor($t0 / $t1) 
        mfhi $t3                            # $t3 = $t0 mod $t1 

        addi $t2, $t2, 0x00000030           # Add '48' (30 in Hex Form) to convert it to a string 
        addi $t3, $t3, 0x00000030

        la   $t0, message3                  # Load the address of message3 in $t0
        addi $t0, $t0, 23                   # Point to the 23rd position of message3 
        beq  $t2, 0x00000030, oneDigitCase  # If quotidient is '0' (30 in Hex Form) the number has one digit else
        sb   $t2, ($t0)                     # Store byte in position 23
        addi $t0,  $t0, 1                   # Add 1, to point in 24th position        
        sb   $t3, ($t0)                     # Store byte in position 24
        
        jr   $ra                            # Go back to the address of $ra

    ## Subroutine that adjusts message3 when input has only one digit ##
    oneDigitCase:

        sb   $t3, ($t0)                     # Store byte in position 23
        addi $t0, $t0, 1                    # Add 1, to point in 24th position
        bne  $t0, 0x00000020, addSpace      # To avoid overwriting if the previous number had two digits
        jr   $ra                            # Go back to the address of $ra

    ## Subroutine that adds a space to overwrite previous 24th positon ## 
    addSpace:

        li   $t3, 0x00000020                # Load ' ' (20 in Hex Form) in $t3
        sb   $t3, ($t0)                     # Store byte in position 24                
        jr   $ra                            # Go back to the address of $ra

    ## Prints an error message if user input is out of range ##	
    Error:
	
		li   $v0, 4                         # System call to print string
		la   $a0, message2
		syscall                             # Call operating system to perform operation specified in $v0

		j main                              # Jump back in main 
    
    ## Exits the program ##
	Quit:
	
		li   $v0, 4                         # System call to print string
		la   $a0, message4
		syscall                             # Call operating system to perform operation specified in $v0  

		li   $v0, 10                        # System call to terminate program
		syscall                             # Call operating system to perform operation specified in $v0
