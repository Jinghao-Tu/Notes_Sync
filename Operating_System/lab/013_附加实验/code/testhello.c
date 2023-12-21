#include <stdio.h>

#define __LIBRARY__
#include <unistd.h>
#include <errno.h>

_syscall0(int, init_hello_table);
_syscall0(int, print_hello_table);

int main()
{
    int a = -2, b = -2;
    a = init_hello_table();
    if (a == -1) {
        printf("init_hello_table error: %d\n", errno);
    } else {
        printf("init_hello_table return %d\n", a);
    }

    b = print_hello_table();
    if (b == -1) {
        printf("print_hello_table error: %d\n", errno);
    } else {
        printf("print_hello_table return %d\n", b);
    }

    return 0;
}