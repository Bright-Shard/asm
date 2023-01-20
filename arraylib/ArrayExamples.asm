.data
delimeter: .byte '\n'

.text
.include "ArrayLib.asm"

# Printing macro
.macro print(%num)
	# Print the number via syscall 1
	move $a0, %num
	li $v0, 1
	syscall
	
	# Print the delimeter via syscall 11
	lb $a0, delimeter
	li $v0, 11
	syscall
.end_macro

.globl _main
_main:
	# Make an array that holds 5 items
	li $a0, 5
	jal newArray
	# Move the array's address into $s0, so it doesn't get overwritten
	move $s0, $v0
	
	# Get the 1st item
	move $a0, $s0
	li $a1, 0
	jal getArrayIndex
	# Print the output
	print($v0)
	
	# Set item 1 to the value 5
	move $a0, $s0
	li $a1, 0
	li $a2, 5
	jal insertArrayIndex
	# Get item 1
	move $a0, $s0
	li $a1, 0
	jal getArrayIndex
	# Print the output
	print($v0)
	
	# 2D ARRAYS
	# Note: Realistically, you wouldn't need to move $s0 into $a0 each time
	#	because $a0 doesn't get overwritten, I just do it here to show
	#	a good example.
	# 	You could also use a loop here, I just hardcoded it here so they're
	#	all independent examples.
	# Make a 2x2 matrix/2D array
	li $a0, 2
	li $a1, 2
	jal new2DArray
	# Backup the array's address into $s1
	move $s1, $v0
	
	# Set (0, 0) to 1
	move $a0, $s1
	li $a1, 0
	li $a2, 0
	li $a3, 1
	jal insert2DArrayIndex
	
	# Set (0, 1) to 2
	move $a0, $s1
	li $a1, 0
	li $a2, 1
	li $a3, 2
	jal insert2DArrayIndex
	
	# Set (1, 0) to 3
	move $a0, $s1
	li $a1, 1
	li $a2, 0
	li $a3, 3
	jal insert2DArrayIndex
	
	# Set (1, 1) to 4
	move $a0, $s1
	li $a1, 1
	li $a2, 1
	li $a3, 4
	jal insert2DArrayIndex
	
	# Print (0, 0)
	move $a0, $s1
	li $a1, 0
	li $a2, 0
	jal get2DArrayIndex
	print($v0)
	
	# Print (0, 1)
	move $a0, $s1
	li $a1, 0
	li $a2, 1
	jal get2DArrayIndex
	print($v0)
	
	# Print (1, 0)
	move $a0, $s1
	li $a1, 1
	li $a2, 0
	jal get2DArrayIndex
	print($v0)
	
	# Print (1, 1)
	move $a0, $s1
	li $a1, 1
	li $a2, 1
	jal get2DArrayIndex
	print($v0)
	
	# Exit
	j _exit
	
_exit:
	li $v0, 10
	syscall
