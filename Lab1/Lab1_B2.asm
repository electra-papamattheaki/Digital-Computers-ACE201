# This program will print "Hello your_string World!" where 'your_string' is the user input


.data
	out_string1: .asciiz "\nHello "					# 'Hello' and 'World!' are two different strings
	out_string2: .asciiz " World!"
	ask_string : .asciiz "\nEnter a string (64 characters max.) : "	#  we need a string to ask for a string
	your_string: .space   64              		        	#  allocate 64 bytes space for the string 											
.text
     main:
	
	li $v0, 4								# system call to print ask_string 
	la $a0, ask_string							
	syscall								# call operating system to perform operation specified in $v0 
	
	li $v0, 8								# system call to read string
	la $a0, your_string							# store string to your_string		
	la $a1, 64								# allocate 64 bytes for the string	
	syscall

	li $v0, 4								# system call to read string			
	la $a0, out_string1							# print out_string1
	syscall
	
	la $a0, your_string							# print your_string
	syscall
	
	la $a0, out_string2							# print out_string2
	syscall
	
	li $v0, 10								# terminate program
	syscall
