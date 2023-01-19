.data 0x0
array: .word 7, 18, 84, 65, 4
arraySize: .word 5
sum: .word 0
delimeter: .byte '\n'

.text 0x3000
.globl _main
_main:
	# Get address of array in memory
	la $s0 array
	# Track current index in the array
	li $s1 0

# Gets the next number from array
getNextNum:
	# Calculate the offset: index * 4
	mul $t0, $s1, 4
	# Calculate the current position in memory: (array) + offset
	addu $t0, $s0, $t0
	# Get the number at that address (the array value)
	lw $t0, 0($t0)
	
	# Get the current sum
	lw $t1, sum
	# Add to the sum
	addu $t1, $t1, $t0
	# Store the sum back in memory
	sb $t1, sum
	
	
	# Print the current sum
	move $a0, $t1
	# Syscall 1: Print number in a0
	li $v0, 1
	syscall
	# Print the delimeter
	lb $a0, delimeter
	# Syscall 11: Print char in a0
	li $v0, 11
	syscall
	
	# Move to the next array item
	addi $s1, $s1, 1
	# Get the array size
	lb $t1, arraySize
	# If there's more array items, keep looping
	blt $s1, $t1 getNextNum
	# Otherwise, exit
	j _exit
	
_exit:
	li $v0, 10
	syscall
