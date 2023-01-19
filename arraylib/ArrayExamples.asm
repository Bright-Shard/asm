.data

.text
.include "ArrayLib.asm"

.globl _main
_main:
	# Make an array that holds 5 items
	li $a0, 5
	jal newArray
	# Move the array's address into $s0, so it doesn't get overwritten
	move $s0, $v0
	
	# Get the 1st item
	move $v0, $a0
	li $a0, 0
	jal getArrayIndex
	# Print the output
	move $a0, $v0
	li $v0, 1
	syscall
	
	# Set item 1 to the value 5
	move $v0, $a0
	li $a1, 0
	li $a2, 5
	jal insertArrayIndex
	# Get item 1
	move $v0, $a0
	li $a0, 0
	# Print the output
	jal getArrayIndex
	move $a0, $v0
	li $v0, 1
	syscall
	
	# Exit
	j _exit
	
_exit:
	li $v0, 10
	syscall
