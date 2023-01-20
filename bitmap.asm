.data 0x0000
displayBuffer: .space 0x80000

# How2 bitmap display:
#	Reserve space in .data, then have a register point to it.
#	Write a colour to the address, in the format: 0x00RRGGBB
#	To write to later pixels, add 4 bytes per pixel, eg:
#		Address: The very top left pixel
#		Address + 4 bytes: Top row, 1 from the left
#	Once you hit the edge of the screen, add 4 more bytes to
#		the leftmost column of the next row.

.text
.globl main
main:
	li $s0, 2048
	la $s1, displayBuffer
	la $s2, 0x00FF00FF
	li $t0, 0

fillLoop:
	add $t1, $t0, $s1
	sw $s2, ($t1)
	
	addi $t0, $t0, 4
	beq $t0, $s0, break
	
	j fillLoop

break:
	li $v0, 10
	syscall
