# parser.asm - Parses the ASCII string as math

# File guard
beqz $ra, _parser_guard

# parseDouble: Runs parseNumber, then converts it to a double if it's not already one
# Arguments:
#	a0: A pointer to the text to parse
# Returns:
#	f0: The parsed double
# Runtime variables:
#	t0->t5: Used by parseNumber
#	t6: Backs up $ra for after parseNumber
.globl parseDouble
parseDouble:
	# Backup $ra
	move $t6, $ra
	
	# Parse the text
	jal parseNumber
	# Test if the number is a double; if not, convert it
	bne $v1, 0xFFFFFFFF, convertNumberToDouble
	
	jr $t6
	
	convertNumberToDouble:
		# Move the number to coproc 1, where it can be stored as a double
		mtc1.d $v0, $f0
		# Convert it to a double
		cvt.d.w $f0, $f0
		
		jr $t6

# parseNumber: Converts null-terminated ASCII text to a 32-bit integer
# Arguments:
#	a0: A pointer to the text to parse
# Returns:
#	v0: The parsed integer, or 0 if parsing failed, or 0xFFFFFFFF if the value is a decimal
#	v1: Command status - 0 if ok, 1 if failed, 0xFFFFFFFF if float
#	f0: The parsed decimal, if the value is a decimal
# Runtime variables:
#	t0: The current sum of numbers from the ASCII text
#	t1: Stores the current char read from the string
#	t2: Stores number of decimals if the ASCII text is a decimal
#	t3: Current sum of decimals if the ASCII text is a decimal
#	t4: Misc temporary values
#	t5: Track if the number is negative or not
#	f0: Used for float operations if the number is a decimal
#	f1: Used for float operations if the number is a decimal
#	f2: Used for float operations if the number is a decimal
#	f3: Used for float operations if the number is a decimal
.globl parseNumber
parseNumber:
	# Clear out needed variables
	li $v0, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 1
	mtc1.d $0, $f0
	mtc1.d $0, $f1
	mtc1.d $0, $f2
	mtc1.d $0, $f3
	
	# Parsing loop
	parseNumberLoop:
		# Load a char from the text
		lbu $t1, ($a0)
		# If we hit a null byte, stop parsing - the text has ended
		beq $t1, $0, returnParsedNumber
		# We may also hit a newline instead of a null byte, return then too
		beq $t1, 0x0A, returnParsedNumber
		# If we hit a period, parse as a float
		beq $t1, 0x2E, parseFloat
		# If we hit a negative symbol, make the number negative
		beq $t1, 0x2D, makeNegative
		# If the text isn't an ASCII number, error out
		blt $t1, 48, errorParsedNumber
		bgt $t1, 57, errorParsedNumber
		# Subtract 48 to convert ASCII -> decimal
		subi $t1, $t1, 48
		# This is base 10, so the last parsed number is 10x larger than this one
		#	so we must multiply the existing sum by 10 before adding this number
		mul $t0, $t0, 10
		# Now add the last parsed number
		add $t0, $t0, $t1
		# Go to the next number in the array
		addi $a0, $a0, 1
		j parseNumberLoop
		
	# Makes the parsed number negative
	makeNegative:
		li $t5, -1
		addi $a0, $a0, 1
		j parseNumberLoop
	
	# Parse the number as a float
	parseFloat:
		# Go the the next char in the input
		addi $a0, $a0, 1
		# Counts decimal places
		li $t2, 0
		# Tracks the parsed number
		li $t3, 0
		
		parseFloatLoop:
			# Load a char from the text
			lbu $t1, ($a0)
			# If we hit a null byte, stop parsing - the text has ended
			beq $t1, $0, returnParsedFloat
			# We may also hit a newline instead of a null byte, return then too
			beq $t1, 0x0A, returnParsedFloat
			# If the text isn't an ASCII number, error out
			blt $t1, 48, errorParsedNumber
			bgt $t1, 57, errorParsedNumber
			# Subtract 48 to convert ASCII -> decimal
			subi $t1, $t1, 48
			# This is base 10, so the last parsed number is 10x larger than this one
			#	so we must multiply the existing sum by 10 before adding this number
			mul $t3, $t3, 10
			# Now add the last parsed number
			add $t3, $t3, $t1
			# Increase the decimal place counter
			addi $t2, $t2, 1
			# Go the the next char in the input
			addi $a0, $a0, 1
			j parseFloatLoop
	# Return the parsed float
	returnParsedFloat:
		# Load the decimal places as a float so we can shrink it to the right place
		mtc1.d $t3, $f0
		cvt.d.w $f0, $f0
		
		# Now we need a loop up to $t2 (the number of decimal places)
		# For each iteration, divider $f0 by 10 (converting it to a decimal)
		li $t4, 10
		mtc1.d $t4, $f2
		cvt.d.w $f2, $f2
		shiftDecimalPlaces:
			# Divide $f0 by 10
			div.d $f0, $f0, $f2
			# Decrement $t2 (how many more places to shift)
			subi $t2, $t2, 1
			# If $t2 isn't 0, keep looping
			bnez $t2, shiftDecimalPlaces
		
		# Add the non-decimal places to the decimal places
		mtc1.d $t0, $f2
		cvt.d.w $f2, $f2
		add.d $f0, $f0, $f2
		# Multiply by $t5 in case it's negative
		mtc1.d $t5, $f2
		cvt.d.w $f2, $f2
		mul.d $f0, $f0, $f2
		# Set $v1 to 0xFFFFFFFF to show it's a float and not a number
		li $v1, 0xFFFFFFFF
		# Return
		jr $ra
	
	# Return the number that was parsed
	returnParsedNumber:
		# Multiply by t5 in case it's negative
		mul $t0, $t0, $t5
		move $v0, $t0
		li $v1, 1
		jr $ra
	# Return 0, AKA error out
	errorParsedNumber:
		li $v1, 0
		jr $ra

# File guard
_parser_guard:
