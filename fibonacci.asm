.data 0x0
numbersToCalculate: .byte 45
delimeter: .byte '\n'

.text 0x3000
init:
	# Last number
	li $s0, 0
	# Current number
	li $s1, 1
	# Next number
	li $s2, 0
	# Current count of numbers calculated
	li $t0, 0
	# Amount of numbers to calculate
	lb $t1, numbersToCalculate

loop:
	# Print the current number
	move $a0, $s1
	# System call 1: Prints a number from a0
	li $v0, 1
	syscall
	
	# Add the numbers
	add $s2, $s0, $s1
	
	# Move the values down (current->last, next->current)
	move $s0, $s1
	move $s1, $s2
	
	# Increment the loop counter
	addi $t0, $t0, 1
	
	# If we've calculated all the numbers, exit
	beq $t0, $t1, exit
	
	# Otherwise, print a delimeter between numbers
	lb $a0, delimeter
	# System call 11: Print a string
	li $v0, 11
	syscall
	
	# Continue the loop
	j loop
	
exit:
	# System call 10: Exit the program
	li $v0, 10
	syscall
