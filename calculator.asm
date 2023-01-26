.data
# Space sign, which separates parts
space: .byte ' '
# Where the numbers are stored
input: .space 40
num1: .word 0
num2: .word 0
# Welcome message
welcomeMsg: .asciiz "Welcome to my calculator\n"

multiplicationMsg: .asciiz "Multiplying"
divisionMsg: .asciiz "Dividing"
additionMsg: .asciiz "Adding\n"
subtractionMsg: .asciiz "Subtracting"
newline: .byte '\n'

.macro printnum(%num)
	li $v0, 1
	move $a0, %num
	syscall
	
	li $v0, 11
	lb $a0, newline
	syscall
.end_macro

.text
welcome:
	# Print the welcome message
	li $v0, 4
	la $a0, welcomeMsg
	syscall
	
read:
	# Load the input into memory
	li $v0, 8
	la $a0, input
	li $a1, 10
	syscall
	
parseNum1:
	# Prep for parsing input
	li $s0, 0 # Offset in input to read
	lb $s1, space # The space character
	
	loopParseNum1:
		# Parse the first part of the input
		la $t0, input
		addu $t0, $s0, $t0
		lb $t0, ($t0) # Load a byte from (input + offset)
		
		printnum($t0)
		
		beq $t0, $s1, parseNum2 # If we hit a space, jump to num2
		
		addi $t0, $t0 -48 # Convert ASCII to decimal
		lw $t1, num1 # Load the existing numbers in num1
		sb $t0, num1($s0) # Save that byte to num1
		addiu $s0, $s0, 1 # Increment the offset
		j loopParseNum1 # Loop

parseNum2:
	# A second counter for the offset in num2
	li $s2, 0
	# Increment the og counter
	addiu $s0, $s0, 1
	
	loopParseNum2:
		# Parse the rest of the input
		la $t0, input
		addu $t0, $s0, $t0
		lb $t0, ($t0) # Load a byte from (input + offset)
		
		printnum($t0)
		
		beq $t0, $s1, parseSign # If it's a space, start parsing the sign
		
		addi $t0, $t0, -48 # Convert ASCII to decimal
		sb $t0, num2($s2) # Save the byte to num2
		addiu $s0, $s0, 1 # Increment the offset
		addiu $s2, $s2, 1 # Increment the other offset
		j loopParseNum2 # Loop
		
parseSign:
	# Increment the counter
	addiu $s0, $s0, 1
	# Load the sign from input, then branch to the right label
	lb $t0, input($s0)
	# Load the numbers into memory
	lw $s0, num1
	lw $s1, num2
	
	printnum($s0)
	printnum($s1)
	
	beq $t0, 43, addition # 43 is the + symbol in ASCII
	beq $t0, 45, subtraction # 45 is the - symbol in ASCII
	beq $t0, 42, multiplication # 42 is the * symbol in ASCII
	beq $t0, 47, division # 47 is the / symbol in ASCII

multiplication:
	li $v0, 4
	la $a0, multiplicationMsg
	syscall
	mul $v0, $s0, $s1
	j done
division:
	li $v0, 4
	la $a0, divisionMsg
	syscall
	div $v0, $s0, $s1
	j done
addition:
	li $v0, 4
	la $a0, additionMsg
	syscall
	add $v0, $s0, $s1
	j done
subtraction:
	li $v0, 4
	la $a0, subtractionMsg
	syscall
	sub $v0, $s0, $s1
	j done
	
done:
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
