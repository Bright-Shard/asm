# io.asm - Handles user I/O and parsing for the calculator

# Guard to prevent this from running as the main file
beqz $ra, _io_guard

# getInput: Gets user input
# Arguments:
#	a0: A pointer to the prompt text
#	a1: A pointer of where to store the input text
#	a2: The maximum length of text to accept
# Returns:
#	a1: Stores user input
# Runtime Variables:
#	a0: Gets overwritten with $a1 for the input syscall
#	a1: Gets overwritten with $a2 for the input syscall
#	v0: Gets overwritten to make syscalls
.globl getInput
getInput:
	# Print the text in $a0
	li $v0, 4
	syscall
	
	# Get user input
	li $v0, 8
	move $a0, $a1
	move $a1, $a2
	syscall
	
	jr $ra

# printNumber: Prints a number out
# Arguments:
#	a0: The number to print
.globl printNumber
printNumber:
	# Prints number in $a0
	li $v0, 1
	syscall
	
	jr $ra

# printString: Prints a null-terminated string
# Arguments:
#	a0: The address of the string to print
.globl printString
printString:
	# Prints string at address in $a0
	li $v0, 4
	syscall
	
	jr $ra

# File guard
_io_guard:
