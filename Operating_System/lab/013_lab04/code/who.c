#include <linux/kernel.h>
#include <../include/asm/segment.h>
#include <unistd.h>
#include <errno.h>

#define MAX_LENGTH 23

char whoami[MAX_LENGTH + 1];
int length;

int sys_iam(const char * name)
{
    int res = -1;
    char* addr = name;
    char ch;
    char tmp[MAX_LENGTH + 1];
    int i;
    for(i = 0; ; i++)
    {
        if(i == MAX_LENGTH + 1)
        {
            errno = EINVAL;
            return res;
        }
        ch = get_fs_byte(addr);
        addr++;
        tmp[i] = ch;
        if(ch == '\0')
        {
            length = i;
            break;
        }
    }

    for(i = 0; i < length + 1; i++)
    {
        whoami[i] = tmp[i];
    }

    // printk("%s\n", whoami);
    // printk("Length of the string: %d\n", length);

    res = length;
    return res;
}

int sys_whoami(char* name, unsigned int size)
{
    int len = 0;
    int res = -1;
    char* addr = name;
    for(; whoami[len] != '\0'; len++)
    {
        if(len > size)
        {
            errno = EINVAL;
            return res;
        }
    }
    int i;
    for(i = 0; i < len; i++)
    {
        put_fs_byte(whoami[i], addr);
        addr++;
    }
    // printk("second_try\n");
    res = len;
    return res;
}