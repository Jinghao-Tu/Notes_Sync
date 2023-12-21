    .file   "hello.s"
gcc_compiled.:
.text
LC0:
    .ascii "Hello, world!\12\0"
    .align 2
.global _main
_main:
    pushl %ebp
    movl %esp,%ebp
    pushl $LC0
    call _printf
    xorl %eax,%eax
    jmp L1
    .align 2
L1:
    leave
    ret