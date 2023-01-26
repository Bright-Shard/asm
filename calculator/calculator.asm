.data 0x0
# Printable messages
msg: .asciiz "Hello, world! Please type a number: "
msg2: .asciiz "Result: "
# Buffer for the entire user input
buffer: .space 800
# Buffer to store the ASCII numbers before they're converted
num: .space 80

.text 0x3000

.macro print(%text)
	la $a0, %text
	li $v0, 4
	syscall
.end_macro

.globl main
main:
	addiu $sp, $sp, -4
	# Print hello & get user input
	la $a0, msg
	la $a1, buffer
	li $a2, 800
	jal getInput
	
	# Init variables for parsing input
	la $s0, buffer # Buffer address
	la $s1, num # Number buffer address
	li $s2, 0 # Char from input
	# Loop for parsing input
	parse:
		# Get a char from the input
		lb $s2, ($s0)
		# If it's a null byte or newline, stop parsing, the input has ended
		beq $s2, $0, _exit
		beq $s2, 0x0A, _exit
		# Check for math symbols
		beq $s2, 0x2B, addition
		beq $s2, 0x2D, subtraction
		beq $s2, 0x2A, multiplication
		beq $s2, 0x2F, division
		# If we hit a space, parse the buffer
		beq $s2, 0x20, parseBuffer
		# Otherwise, save the current buffer
		j saveBuffer
		
		# Go to the next char in the string
		parseNextChar:
			addi $s0, $s0, 1
			j parse
		
		# Save the current char to the number buffer
		saveBuffer:
			sb $s2, ($s1)
			addi $s1, $s1, 1
			j parseNextChar
			
		# Parse the current number buffer as a double and put the double on the stack
		parseBuffer:
			la $a0, num
			jal parseDouble
			
			j saveDouble
		
		# Pop the two numbers from the stack
		# Stores them in f0 and f2
		popNums:
			l.d $f2, ($sp)
			addiu $sp, $sp, 8
			l.d $f0, ($sp)
			addiu $sp, $sp, 8
			jr $ra
		
		# Save a float to the stack and wipe the number buffer
		saveDouble:
			addiu $sp, $sp -8
			s.d $f0, ($sp)
			
			la $s1, num
			mtc1.d $0, $f0
			mtc1.d $0, $f1
			mtc1.d $0, $f2
			mtc1.d $0, $f3
			
			li $t0, 80
			wipeNumBuffer:
				la $t1, num
				sb $0, num($t0)
				subi $t0, $t0, 1
				bne $t0, $0, wipeNumBuffer
			li $t0, 0
			li $s2, 0
			
			j parseNextChar

		# Math stuffs
		addition:
			jal popNums
			add.d $f0, $f0, $f2
			addi $s0, $s0, 1
			j saveDouble
		subtraction:
			jal popNums
			sub.d $f0, $f0, $f2
			addi $s0, $s0, 1
			j saveDouble
		division:
			jal popNums
			div.d $f0, $f0, $f2
			addi $s0, $s0, 1
			j saveDouble
		multiplication:
			jal popNums
			mul.d $f0, $f0, $f2
			addi $s0, $s0, 1
			j saveDouble
	
_exit:
	l.d $f12, ($sp)
	li $v0, 3
	syscall
	
	li $v0, 10
	syscall
