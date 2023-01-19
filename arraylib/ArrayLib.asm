# ARRAYLIB
# A library for working with arrays. It assumes each value can be stored in a sinlge <word>, or 4 bytes.
# Arrays are indexed starting at 0.
#
# USAGE
# Put the appropriate values in a0->a3 as arguments, then use the command 'jal <function>' to use one
# of the functions below. Functions will return values in v0, or v1 if it returns two values.
# Each function documents itself with regards to arguments and return values. Just scroll down.
#
# NOTES
# These functions may use $t0->$t9. Store important values in $s0->$s7 so they don't get overwritten.
# These functions will return a null byte if the operation fails.
# This library offsets indexes by 1 (eg when you index element 0, it returns element 1).
#	The reason for this is it stores the array's size in element 0. The array's elements actually start at element 1.



# A guard to prevent this library from running before the main function
beqz $ra, _arraylib_guard



# getOffset: Calculates the offset of an array's index
# Arguments:
#	%index: The index of the array element to calculate the offset for
#	%output: Where to output the result
# Returns:
#	%output: The actual offset of the element
.macro getOffset(%index, %output)
	# Multiply the index by 4
	mulu %output, %index, 4
	# Add 4 to offset the first element (the array's size)
	addiu %output, %output, 4
.end_macro

# newArray: Instantiates a new array at runtime
# Arguments:
#	a0: Size of the array
# Returns:
#	v0: The array's address in memory
.globl newArray
newArray:
	# Copy a0 to t0 before it gets overwritten
	move $t0, $a0
	# Calculate how much space to reserve by getting the offset of the array's last element
	getOffset($a0, $a0)
	# Syscall 9: Reserve $a0 bytes in memory & return it's address in v0
	li $v0, 9
	syscall
	# Store the array's size in the array's 0th element
	sb $t0, ($v0)
	
	jr $ra

# getArrayIndex: Gets an item from an array
# Arguments:
#	a0: The array's address in memory
#	a1: The index to fetch from the array
# Returns:
#	v0: The item at $a1 in the array
.globl getArrayIndex
getArrayIndex:
	# Store the array's size in t0
	lbu $t0, ($a0)
	# If the index is outside the array's size, error
	blt $a1, $t0, error
	# Calculate the offset of that index in memory, stored in $t0
	getOffset($a1, $t0)
	# Add the array's address and the offset, store in $t0
	addu $t0, $a0, $t0
	# Load the value into $v0 to return it
	lw $v0, ($t0)
	
	jr $ra

# insertArrayIndex: Inserts an item into an array
# Arguments:
#	a0: The array's address in memory
#	a1: The index to write
#	a2: What to write at the index
# Returns:
#	v0: Will be 1 if the operation succeeded, else 0
.globl insertArrayIndex
insertArrayIndex:
	# Store the array's size in t0
	lbu $t0, ($a0)
	# Make sure we're writing a valid index
	blt $a1, $a0, error
	# Calculate the offset and store it in $t0
	getOffset($a1, $t0)
	# Add the array's size and the offset
	addu $t0, $a0, $t0
	# Insert the value into the array
	sw $a2, ($t0)
	# Copy 1 into v0 (succeeded) and return
	li $v0, 1
	
	jr $ra


# Error: Returns 0 if an operation fails
error:
	li $v0, 0x00
	jr $ra
	
	
	
# For the guard at the top of the file
_arraylib_guard: