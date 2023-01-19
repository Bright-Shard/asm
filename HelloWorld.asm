.data 0x0
msg: .asciiz "Hello, world!\n"

.text 0x3000
init:
	la $a0, msg
	li $v0, 4
	syscall