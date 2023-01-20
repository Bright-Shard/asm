# ARRAYLIB
# A library for working with arrays. It assumes each value can be stored in a sinlge <word>, or 4 bytes.
# Arrays are indexed starting at 0.
#
# USAGE
# Put the appropriate values in a0->a3 as arguments, then use the command 'jal <function>' to use one
# of the functions below. Functions will return values in v0, or v1 if it returns two values.
# Each function documents itself with regards to arguments and return values. Just scroll down.
# Both regular and 2D arrays are supported, be sure you use the correct methods for your array!
#	e.g. some methods only support regular arrays, while others will only support 2D arrays.
#
# NOTES
# These functions may use $t0->$t9. Store important values in $s0->$s7 so they don't get overwritten.
# These functions will return a null byte if the operation fails.
# This library offsets indexes by 1 (eg when you index element 0, it returns element 1).
#	The reason for this is it stores the array's size in element 0. The array's elements actually start at element 1.
# 2D arrays are stored "flatly" - it's actually just each column stored side by side.
# Array sizes are stored as bytes, so an array can't have more than 256 rows or columns.



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

# get2DOffset: Calculates the offset of a 2D array's index
# Arguments:
#	%row: The row to index
#	%column: The column to index
#	%rows: The number of rows in the array
#	%columns: The number of columns in the array
#	%output: Where to store the result
# Returns:
#	%output: The offset of the index
.macro get2DOffset(%row, %column, %rows, %columns, %output)
	# Multiply the target row by the columns
	mulu %output, %row, %columns
	# Now add the column
	addu %output, %output, %column
	# Add 4 bytes to offset the first array value (the array's size)
	addu %output, %output, 4
	# Convert to bytes: Multiply by 4
	mulu %output, %output, 4
.end_macro

# newArray: Makes a new array at runtime
# Arguments:
#	a0: Size of the array
# Returns:
#	v0: The array's address in memory
.globl newArray
newArray:
	# Copy a0 to t0 before it gets overwritten (has to be overwritten for the syscall)
	move $t0, $a0
	# Calculate how much space to reserve by getting the offset of the array's last element
	getOffset($a0, $a0)
	# Syscall 9: Reserve $a0 bytes in memory & return it's address in v0
	li $v0, 9
	syscall
	# Store the array's size in the array's 0th element
	sb $t0, ($v0)
	
	jr $ra

# new2DArray: Makes a new, 2D array at runtime
# Arguments:
#	a0: Rows in the array
#	a1: Columns in the array
# Returns:
#	v0: The array's address in memory
.globl new2DArray
new2DArray:
	# Copy the rows and columns to temp values
	move $t0, $a0
	move $t1, $a1
	# Get the array's size by calculating the offset of the last element
	get2DOffset($a0, $a1, $a0, $a1, $a0)
	# Syscall 9: Reserve $a0 bytes in memory, return the address in v0
	li $v0, 9
	syscall
	# Store the array's rows and columns as bytes in it's 0th element
	sb $t0, ($v0)
	sb $t1, 1($v0)
	
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
	bge $a1, $t0, error
	# Calculate the offset of that index in memory, stored in $t0
	getOffset($a1, $t0)
	# Add the array's address and the offset, store in $t0
	addu $t0, $a0, $t0
	# Load the value into $v0 to return it
	lw $v0, ($t0)
	
	jr $ra

# get2DArrayIndex: Gets an item from a 2D array
# Arguments:
#	a0: The array's address in memory
#	a1: The row to index
#	a2: The column to index
# Returns:
#	v0: The indexed item from the array
.globl get2DArrayIndex
get2DArrayIndex:
	# Fetch the array's size
	lbu $t0, ($a0)
	lbu $t1, 1($a0)
	# If the index is outside the array's size, error out
	bge $a1, $t0, error
	bge $a2, $t1, error
	# Calculate the offset of that index in memory and store it in $t2
	get2DOffset($a1, $a2, $t0, $t1, $t2)
	# Add the array's address and offset
	addu $t2, $a0, $t2
	# Load the value into $v0 to return it
	lw $v0, ($t2)
	
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
	bge $a1, $t0, error
	# Calculate the offset and store it in $t0
	getOffset($a1, $t0)
	# Add the array's address and the offset
	addu $t0, $a0, $t0
	# Insert the value into the array
	sw $a2, ($t0)
	# Copy 1 into v0 (succeeded) and return
	li $v0, 1
	
	jr $ra
	
# insert2DArrayIndex: Inserts an item into a 2D array
# Arguments:
#	a0: The array's address in memory
#	a1: The row to insert into
#	a2: The column to insert into
#	a3: What to insert into the index
# Returns:
#	v0: 1 if the operation succeeded, 0 if it failed
.globl insert2DArrayIndex
insert2DArrayIndex:
	# Store the array's size
	lbu $t0, ($a0)
	lbu $t1, 1($a0)
	# Ensure we're writing to valid indexes
	bge $a1, $t0, error
	bge $a2, $t1, error
	# Get the offset of the index, store it in $t2
	get2DOffset($a1, $a2, $t0, $t1, $t2)
	# Add the array's address and offset
	addu $t2, $t2, $a0
	# Insert the value into the array
	sw $a3, ($t2)
	# Copy 1 into v0 and return
	li $v0, 1
	
	jr $ra


# Error: Returns 0 if an operation fails
error:
	li $v0, 0x00
	jr $ra
	
	
	
# For the guard at the top of the file
_arraylib_guard:
