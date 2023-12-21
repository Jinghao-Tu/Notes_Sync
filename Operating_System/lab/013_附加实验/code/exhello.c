#include <stdio.h>

#define __LIBRARY__
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>

_syscall0(int, init_hello_table);
_syscall0(int, print_hello_table);

int main()
{
    int a = -1, b = -1;
    int pid;
    pid = fork();
    if (pid == 0) {
        a = init_hello_table();
        execve("/usr/root/hello", NULL, NULL);
    } else {
        waitpid(pid, NULL, 0);
        b = print_hello_table();
    }
}
