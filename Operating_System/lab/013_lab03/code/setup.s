	.code16
# rewrite with AT&T syntax by falcon <wuzhangjin@gmail.com> at 081012
#
#	setup.s		(C) 1991 Linus Torvalds
#
# setup.s is responsible for getting the system data from the BIOS,
# and putting them into the appropriate places in system memory.
# both setup.s and system has been loaded by the bootblock.
#
# This code asks the bios for memory/disk/other parameters, and
# puts them in a "safe" place: 0x90000-0x901FF, ie where the
# boot-block used to be. It is then up to the protected mode
# syste	.code16
# rewrite with AT&T syntax by falcon <wuzhangjin@gmail.com> at 081012
#
#	setup.s		(C) 1991 Linus Torvalds
#
# setup.s is responsible for getting the system data from the BIOS,
# and putting them into the appropriate places in system memory.
# both setup.s and system has been loaded by the bootblock.
#
# This code asks the bios for memory/disk/other parameters, and
# puts them in a "safe" place: 0x90000-0x901FF, ie where the
# boot-block used to be. It is then up to the protected mode
# system to read them from there before the area is overwritten
# for buffer-blocks.
#

# NOTE! These had better be the same as in bootsect.s!

	.equ INITSEG, 0x9000	# we move boot here - out of the way
	.equ SYSSEG, 0x1000	# system loaded at 0x10000 (65536).
	.equ SETUPSEG, 0x9020	# this is the current segment

	.global _start, begtext, begdata, begbss, endtext, enddata, endbss
	.text
	begtext:
	.data
	begdata:
	.bss
	begbss:
	.text

	ljmp $SETUPSEG, $_start	
_start:
	mov	$SETUPSEG, %ax
	mov	%ax, %es

# print message here.

	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$25, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $msg1, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10

# ok, the read went well so we get current cursor position and save it for
# posterity.

	mov	$INITSEG, %ax	# this is done in bootsect already, but...
	mov	%ax, %ds
	mov	$0x03, %ah	# read cursor pos
	xor	%bh, %bh
	int	$0x10		# save it in known place, con_init fetches
	mov	%dx, %ds:0	# it from 0x90000.
# Get memory size (extended mem, kB)

	mov	$0x88, %ah 
	int	$0x15
	mov	%ax, %ds:2

# Get video-card data:

	mov	$0x0f, %ah
	int	$0x10
	mov	%bx, %ds:4	# bh = display page
	mov	%ax, %ds:6	# al = video mode, ah = window width

# check for EGA/VGA and some config parameters

	mov	$0x12, %ah
	mov	$0x10, %bl
	int	$0x10
	mov	%ax, %ds:8
	mov	%bx, %ds:10
	mov	%cx, %ds:12

# Get hd0 data

	mov	$0x0000, %ax
	mov	%ax, %ds
	lds	%ds:4*0x41, %si
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0080, %di
	mov	$0x10, %cx
	rep
	movsb

# Get hd1 data

	mov	$0x0000, %ax
	mov	%ax, %ds
	lds	%ds:4*0x46, %si
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0090, %di
	mov	$0x10, %cx
	rep
	movsb

# Check that there IS a hd1 :-)

	mov	$0x01500, %ax
	mov	$0x81, %dl
	int	$0x13
	jc	no_disk1
	cmp	$3, %ah
	je	is_disk1
no_disk1:
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0090, %di
	mov	$0x10, %cx
	mov	$0x00, %ax
	rep
	stosb
is_disk1:

# here, we can print the system hardware parameters.

	mov $INITSEG, %ax
	mov %ax, %ss
	mov $0xFF00, %sp

	mov $SETUPSEG, %ax
	mov %ax, %es

print_memorysize:
	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$13, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $Memory, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10

	mov $2, %ax
	mov %ax, %bp

print_2byts:
	mov $4, %cx
	mov (%bp), %dx
print_d:
	rol $4, %dx
	mov $0xE0F, %ax
	and %dl, %al
	add $0x30, %al
	cmp $0x3a, %al
	jl outp
	add $0x07, %al
outp:
	int $0x10
	loop print_d
ptint_KB:
	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$2, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $KB, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10
print_rn:
	mov $0xE0D, %ax
	int $0x10
	mov $0xA, %al
	int $0x10



dead_loop:
	jmp dead_loop	# dead loop here to avoid getting into system.

msg1:
	.byte 13,10
	.ascii "Now we are in SETUP"
	.byte 13,10,13,10

Memory:
	.ascii "Memory Size: "

KB:
	.ascii "KB"

.text
endtext:
.data
enddata:
.bss
endbss:m to read them from there before the area is overwritten
# for buffer-blocks.
#

# NOTE! These had better be the same as in bootsect.s!

	.equ INITSEG, 0x9000	# we move boot here - out of the way
	.equ SYSSEG, 0x1000	# system loaded at 0x10000 (65536).
	.equ SETUPSEG, 0x9020	# this is the current segment

	.global _start, begtext, begdata, begbss, endtext, enddata, endbss
	.text
	begtext:
	.data
	begdata:
	.bss
	begbss:
	.text

	ljmp $SETUPSEG, $_start	
_start:
	mov	$SETUPSEG, %ax
	mov	%ax, %es

# print message here.

	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$25, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $msg1, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10

# ok, the read went well so we get current cursor position and save it for
# posterity.

	mov	$INITSEG, %ax	# this is done in bootsect already, but...
	mov	%ax, %ds
	mov	$0x03, %ah	# read cursor pos
	xor	%bh, %bh
	int	$0x10		# save it in known place, con_init fetches
	mov	%dx, %ds:0	# it from 0x90000.
# Get memory size (extended mem, kB)

	mov	$0x88, %ah 
	int	$0x15
	mov	%ax, %ds:2

# Get video-card data:

	mov	$0x0f, %ah
	int	$0x10
	mov	%bx, %ds:4	# bh = display page
	mov	%ax, %ds:6	# al = video mode, ah = window width

# check for EGA/VGA and some config parameters

	mov	$0x12, %ah
	mov	$0x10, %bl
	int	$0x10
	mov	%ax, %ds:8
	mov	%bx, %ds:10
	mov	%cx, %ds:12

# Get hd0 data

	mov	$0x0000, %ax
	mov	%ax, %ds
	lds	%ds:4*0x41, %si
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0080, %di
	mov	$0x10, %cx
	rep
	movsb

# Get hd1 data

	mov	$0x0000, %ax
	mov	%ax, %ds
	lds	%ds:4*0x46, %si
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0090, %di
	mov	$0x10, %cx
	rep
	movsb

# Check that there IS a hd1 :-)

	mov	$0x01500, %ax
	mov	$0x81, %dl
	int	$0x13
	jc	no_disk1
	cmp	$3, %ah
	je	is_disk1
no_disk1:
	mov	$INITSEG, %ax
	mov	%ax, %es
	mov	$0x0090, %di
	mov	$0x10, %cx
	mov	$0x00, %ax
	rep
	stosb
is_disk1:

# here, we can print the system hardware parameters.

	mov $INITSEG, %ax
	mov %ax, %ss
	mov $0xFF00, %sp

	mov $SETUPSEG, %ax
	mov %ax, %es

print_memorysize:
	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$13, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $Memory, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10

	mov $2, %ax
	mov %ax, %bp

print_2byts:
	mov $4, %cx
	mov (%bp), %dx
print_d:
	rol $4, %dx
	mov $0xE0F, %ax
	and %dl, %al
	add $0x30, %al
	cmp $0x3a, %al
	jl outp
	add $0x07, %al
outp:
	int $0x10
	loop print_d
ptint_KB:
	mov	$0x03, %ah		# read cursor pos
	xor	%bh, %bh
	int	$0x10
	
	mov	$2, %cx
	mov	$0x0007, %bx		# page 0, attribute 7 (normal)
	mov $KB, %bp
	mov	$0x1301, %ax		# write string, move cursor
	int	$0x10
print_rn:
	mov $0xE0D, %ax
	int $0x10
	mov $0xA, %al
	int $0x10



dead_loop:
	jmp dead_loop	# dead loop here to avoid getting into system.

msg1:
	.byte 13,10
	.ascii "Now we are in SETUP"
	.byte 13,10,13,10

Memory:
	.ascii "Memory Size: "

KB:
	.ascii "KB"

.text
endtext:
.data
enddata:
.bss
endbss:
