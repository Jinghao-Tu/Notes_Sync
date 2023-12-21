---
author: '013-涂靖昊'
---

# 附加实验--- `Hello, world!` 的一生

## 1 准备部分

这一部分主要阐述希望采用什么方法来跟踪 `hello` 进程的进展, 并且不会受到其他进程的干扰.

### 1.1 跟踪方法

结合课程实验 "系统调用" 和 "进程运行轨迹的跟踪与统计", 总结出这样一个方法.

在内核空间中创建一个变量用于存储 `hello` 进程, 用户态下通过自编写的系统调用与之交互;
内核态下 (主要都是这一部分), 进程的关键函数通过其他的函数与之交互.

那么定义这样一个结构体来记录关键节点的时间和描述.

```c
struct hello_node {
    long time;
    char description[64];
};
```

在 `include/kernel.h` 中定义这样一个结构体数组 `extern struct hello_node hello_table[256];`,
就可以记录下 `hello` 进程完整的过程.

一个很重要的考量是, 和打印字符串这样的 IO 操作相比, 给变量赋值是一件非常迅速的时间.
而且不用阻塞进程, 造成不必要的影响, 比如改变进程的运行顺序、阻塞进程的运行等. 我希望尽可能看到
`hello` 程序的真实运行过程.

与之相应的是交互函数.

`sys_init_hello_table()` 和 `sys_print_hello_table()` 两个函数作为系统调用在 `include/linux/sys.h` 和 `include/unistd.h` 中声明.

它们的作用分别是初始化数组、记录下 `pid` 号和打印数组结果.

添加记录的函数不需要是一个系统调用, 所以声明: `extern int push_hello_table(long time, const char * description, ...);`,
这里模仿 `init/main.c` 中的 `printf()` 来实现, 因为要载入字符串和一些必要的变量.

函数的具体实现如下: `kernel/hellohit.c`

```c
#include <asm/segment.h>
#include <errno.h>
#include <linux/sched.h>
#include <linux/kernel.h>
#include <stdarg.h>
#include <stddef.h>

struct hello_node hello_table[256] = {0};
long hello_pid = -1;
int hello_count = -1;

int sys_init_hello_table()
{
    // printk("Now we're in sys_init_hello_table()\n");
    hello_pid = current->pid;
    push_hello_table(0, "init: hello pid=%d", hello_pid);
    return 0;
}

int sys_print_hello_table()
{
    // printk("Now we're in sys_print_hello_table()\n");
    fprintk(3, "Time\tDesc\n");
    int i;
    for (i = 0; i <= hello_count; i++)
    {
        fprintk(3, "%ld\t%s\n", hello_table[i].time, hello_table[i].description);
    }
    return 0;
}

extern int vsprintf(char *buf, const char *fmt, va_list args);
int push_hello_table(long time, const char *description, ...)
{
    if (hello_count >= 511)
    {
        printk("hello table is full\n");
        return -1;
    }
    hello_count++;
    hello_table[hello_count].time = time;

    va_list args;
    va_start(args, description);
    vsprintf(hello_table[hello_count].description, description, args);
    va_end(args);

    return 0;
}
```

### 1.2 其他变量和函数的声明

定义了表的尾指针和记录 `hello` 进程 `pid` 的变量.

```c
extern long hello_pid;
extern int hello_count;
```

这里我参考了前一个实验的 `fprintk` 函数, 用来在 `sys_print_hello_table()` 打印日志到 `/var/hellohit.log` 文件中.

### 1.3 说明

为了记录下进程的 `pid` 号以方便记录运行过程, `hello` 程序的跟踪必须在 `fork()` 执行之后开始.

考虑到 `shell` 中创建进程的过程是先进行 `fork()` 和 `execve()`后, 才真正开始执行. 而大部分准备工作都是在
`execve()` 中完成的, `fork()` 只是简单创建了一个进程, 于是我决定编写一个文件, 用来执行 `fork()` 和
`execve()` 以及其他必要的函数, 模拟 `hello` 程序在 `shell` 中的运行, 也方便跟踪和打印日志.

`exhello.c` 如下

```c
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
```

此外, 大部分的内核文件都包含 `linux/kernel.h` 和 `linux/sched.h`. 所以为了方便, 我把本实验需要的声明都写在了
`linux/kernel` 中.

## 2 修改的文件、函数列表以及必要的说明

绝大部分修改过的部分都形如

```c
/* hellohit begin */
......
/* hellohit end */
```

使用文件搜索功能很容易找到修改的内容.

以下说明也包含在 `include/linux/kernel.h` 中. 可以用作参考.

---

准备部分

```c
/** 修改的文件列表, 准备部分
 * 1. kernel/hellohit.c
 * 2. kernel/printk.c
 * 3. init/main.c
 * 4. include/linux/kernel.h
 * 5. include/linux/sys.h
 * 6. include/unistd.h
 * 7. kernel/Makefile
 * 8. kernel/system_call.s
*/
```

进程管理部分

```c
/** 进程管理部分
 * 1. kernel/fork.c 不处理, 因为要先 fork() 之后再开始跟踪
 * 2. fs/exec.c 作为跟踪的起点, 在 do_execve() 中添加
 * 3. kernel/exit.c 作为跟踪的终点, 在 do_exit() 中添加
 * 4. kernel/sched.c 需要跟踪
*/
```

内存部分

```c
/** 内存部分
 * 1. fs/exec.c 中加载可执行文件到内存中, 并将进程跳转到目标代码段去执行.
 *  这里会得到 m_inode, 这是内存中的 i 节点.
 *  以下是来自 《注释》 的解释:
 *  首先执行对参数和环境参数空间页面的初始化;
 *  然后根据执行文件开始部分的头数据结构, 对其中信息进行处理;
 *  对当前调用进程进行运行新文件前初始化操作;
 *  最后替换堆栈上原调用 execve(), 程序的返回地址为新执行程序地址, 运行新加载的程序.
*/
```

块设备部分

```c
/** 块设备部分 (因为 hello 程序保存在硬盘中, 所以我们先只考虑硬盘)
 * 1. kernel/blk_drv/ll_rw_blk.c 是所有块设备的通用驱动程序
 *  ll_rw_block() 用于创建请求项并将其插入请求队列中, 函数链是 ll_rw_block() -> make_request() -> add_request();
 *  dev->request_fn() 用于处理请求项, 与设备相关
 * 2. kernel/blk_drv/hd.c 用于向硬盘控制器发出读写中断, 也就是实际的读写操作发生在这里
 *  这里有 do_hd_request(), read_intr(), write_intr() 三个主要的函数
 *  它们的意义分别是向硬盘控制器发出读写请求, 控制器完成读写后会发出相应的中断信号; 处理读中断; 处理写中断
 *  这里不用跟踪, 因为读写请求的处理与当前进程无关.
*/
```

I/O 部分 - printf()

```c
/** I/O 部分 - printf
 * 1. 根据 gcc 编译出的汇编代码, 对 _printf 进行跟踪. 可以在 init/main.c 中找到 printf()
 *  main.c 的 include 中并未包含 kernel.h, 随意添加会对内核造成影响 :)
 *  这里多加了两个判断条件, 目的是安全运行. tty 也相同.
 *  问题在于汇编中的 call _printf 似乎不是这里的 printf()
 *  Good News! Everyone! 这里的 printf() 是 stdio.h 中的,
 *  在 linux-0.11 的硬盘文件中, /usr/include/stdio.h 中有 printf() 的声明
 *  那么就放弃对 printf() 的跟踪吧, 但是还是要跟踪 tty_write()
*/
```

附上 `linux-0.11` 中编译得到的 `hello.s`

```s
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
```

字符设备部分

```c
/** 字符设备部分
 * 这里我们主要考虑 tty 相关代码, 因为 hello 程序的输出是通过 tty 设备的
 * 1. kernel/chr_dev/console.c 控制终端显示屏, 在这里可以跟踪 hello 字符串的输出. con_write()
 * 2. kernel/chr_dev/tty_io.c 用于处理字符设备的读写, 这里主要是 tty_write() 要跟踪
 *  安全需求同 printf() :)
*/
```

缓冲部分

```c
/** 缓冲部分
 * fs/buffer.c
 * 1. get_blk()
 * 2. brelse()
 * 3. bread()
 * 4. bread_page()
 * 5. breada()
 * 以上是 buffer.c 中主要用到的函数
*/
```

## 3 输出日志与分析

### 3.1 进程创建部分

```log
0	init: hello pid=7
```

这里是执行 `sys_init_hello_table()` 得到的. 时间 0 没有意义, 仅仅表示一个开始.
可以看到这里 `hello` 进程的 `pid` 号是 7.

```log
11349	do_execve
11349	bread(): dev=769, block=659
11349	begin getblk(): dev=769, block=659
11349	brelse(): dev=769, block=659
11349	bread(): dev=769, block=9861
11349	begin getblk(): dev=769, block=9861
11349	brelse(): dev=769, block=9861
11349	bread(): dev=769, block=14045
11349	begin getblk(): dev=769, block=14045
11349	brelse(): dev=769, block=14045
11349	bread(): dev=769, block=13
11349	begin getblk(): dev=769, block=13
11349	brelse(): dev=769, block=13
11349	do_execve: get m_inode
11349		i_size: 20591
11349		i_num: 2
11350		i_dev: 769
11350		i_zone[0]: 687
11350		i_zone[1]: 662
11350		i_zone[2]: 663
11350		i_zone[3]: 664
11350		i_zone[4]: 665
11350		i_zone[5]: 670
11350		i_zone[6]: 671
11350		i_zone[7]: 672
11350		i_zone[8]: 0
11350	bread(): dev=769, block=672
11350	begin getblk(): dev=769, block=672
11350	end getblk(): find!
11350	ll_rw_block():rw=0 major=3
11350		bh->b_dev=769 bh->b_blocknr=672
11350	sleep on
11350	is switched by 0
11350	wake_up()
11350		i_zone[7][0]: 673
11350		i_zone[7][1]: 674
11350		i_zone[7][2]: 675
11350		i_zone[7][3]: 676
11350		i_zone[7][4]: 677
11350		i_zone[7][5]: 678
11350		i_zone[7][6]: 679
11350		i_zone[7][7]: 680
11350		i_zone[7][8]: 681
11350		i_zone[7][9]: 682
11350		i_zone[7][10]: 683
11350		i_zone[7][11]: 684
11350		i_zone[7][12]: 685
11350		i_zone[7][13]: 686
11350	brelse(): dev=769, block=672
11350	bread(): dev=769, block=687
11350	begin getblk(): dev=769, block=687
11350	end getblk(): find!
11350	ll_rw_block():rw=0 major=3
11350		bh->b_dev=769 bh->b_blocknr=687
11350	brelse(): dev=769, block=687
11351	do_execve: update inode, tcb and context
11351	do_execve: update eip, new entry eip[0]: 0
```

然后这里开始首先进入到 `do_exec()` 函数, 这个是 `execve()` 实际执行的部分.

从这一直到 `do_execve: get m_inode` 之间的部分都是在寻找 `/usr/root/hello` 的文件,

然后加载好 i 节点(内存中的) 后, 可以看到一些内容: 比如这里用到一级索引块. 我顺便把一级索引块的内容给打印出来了.
可以看到进程请求了 672 号块上的内容, 这里就是在请求一级索引块.

然后进程请求 687 号块上的内容, 因为这是第一个块, 代码的入口程序也在这个块上.

最后更新 tcb, 上下文和返回地址(即新的程序入口)

### 3.2 进程运行部分

这里有大量的读文件, 暂且略过. 大部分都是程序的运行所必需执行的.

然后是 tty 的打印部分.

```log
11355	tty_write(0, 000034C0, 14)
11355	con_write() nr=15. tty is printing!
```

这里可以看到, 程序通过 `tty_write()` 和 `con_write()` 向 tty 打印 15 个字符.

正好是 `hello.s` 中 `.ascii "Hello, world!\12\0"` 这个字符串的长度.

那么到此位置, `"Hello, world!\12\0"` 顺利打印.

### 3.3 进程结束部分

```log
11355	exit
11356	bread(): dev=769, block=13
11356	begin getblk(): dev=769, block=13
11356	brelse(): dev=769, block=13
11356	is switched by 4
```

进程进入到 `do_exit()` 中退出, 随后加载了一些需要执行的代码. 最后被切换到进程 4.

### 3.4 完整日志

以下是得到的完整日志: `/var/hellohit.log`

```log
Time	Desc
0	    init: hello pid=7
11349	do_execve
11349	bread(): dev=769, block=659
11349	begin getblk(): dev=769, block=659
11349	brelse(): dev=769, block=659
11349	bread(): dev=769, block=9861
11349	begin getblk(): dev=769, block=9861
11349	brelse(): dev=769, block=9861
11349	bread(): dev=769, block=14045
11349	begin getblk(): dev=769, block=14045
11349	brelse(): dev=769, block=14045
11349	bread(): dev=769, block=13
11349	begin getblk(): dev=769, block=13
11349	brelse(): dev=769, block=13
11349	do_execve: get m_inode
11349		i_size: 20591
11349		i_num: 2
11350		i_dev: 769
11350		i_zone[0]: 687
11350		i_zone[1]: 662
11350		i_zone[2]: 663
11350		i_zone[3]: 664
11350		i_zone[4]: 665
11350		i_zone[5]: 670
11350		i_zone[6]: 671
11350		i_zone[7]: 672
11350		i_zone[8]: 0
11350	bread(): dev=769, block=672
11350	begin getblk(): dev=769, block=672
11350	end getblk(): find!
11350	ll_rw_block():rw=0 major=3
11350		bh->b_dev=769 bh->b_blocknr=672
11350	sleep on
11350	is switched by 0
11350	wake_up()
11350		i_zone[7][0]: 673
11350		i_zone[7][1]: 674
11350		i_zone[7][2]: 675
11350		i_zone[7][3]: 676
11350		i_zone[7][4]: 677
11350		i_zone[7][5]: 678
11350		i_zone[7][6]: 679
11350		i_zone[7][7]: 680
11350		i_zone[7][8]: 681
11350		i_zone[7][9]: 682
11350		i_zone[7][10]: 683
11350		i_zone[7][11]: 684
11350		i_zone[7][12]: 685
11350		i_zone[7][13]: 686
11350	brelse(): dev=769, block=672
11350	bread(): dev=769, block=687
11350	begin getblk(): dev=769, block=687
11350	end getblk(): find!
11350	ll_rw_block():rw=0 major=3
11350		bh->b_dev=769 bh->b_blocknr=687
11350	brelse(): dev=769, block=687
11351	do_execve: update inode, tcb and context
11351	do_execve: update eip, new entry eip[0]: 0
11351	bread_page(): address=16355328, dev=769
11351		b[0]=662, b[1]=663, b[2]=664, b[3]=665
11351	begin getblk(): dev=769, block=662
11351	end getblk(): find!
11351	ll_rw_block():rw=0 major=3
11351		bh->b_dev=769 bh->b_blocknr=662
11351	begin getblk(): dev=769, block=663
11351	end getblk(): find!
11352	ll_rw_block():rw=0 major=3
11352		bh->b_dev=769 bh->b_blocknr=663
11352	begin getblk(): dev=769, block=664
11352	end getblk(): find!
11352	ll_rw_block():rw=0 major=3
11352		bh->b_dev=769 bh->b_blocknr=664
11352	begin getblk(): dev=769, block=665
11352	end getblk(): find!
11352	ll_rw_block():rw=0 major=3
11352		bh->b_dev=769 bh->b_blocknr=665
11352	brelse(): dev=769, block=662
11352	brelse(): dev=769, block=663
11352	brelse(): dev=769, block=664
11352	brelse(): dev=769, block=665
11352	bread(): dev=769, block=672
11352	begin getblk(): dev=769, block=672
11352	brelse(): dev=769, block=672
11352	bread(): dev=769, block=672
11352	begin getblk(): dev=769, block=672
11352	brelse(): dev=769, block=672
11352	bread(): dev=769, block=672
11352	begin getblk(): dev=769, block=672
11352	brelse(): dev=769, block=672
11352	bread(): dev=769, block=672
11352	begin getblk(): dev=769, block=672
11352	brelse(): dev=769, block=672
11352	bread_page(): address=16314368, dev=769
11352		b[0]=679, b[1]=680, b[2]=681, b[3]=682
11352	begin getblk(): dev=769, block=679
11353	end getblk(): find!
11353	ll_rw_block():rw=0 major=3
11353		bh->b_dev=769 bh->b_blocknr=679
11353	begin getblk(): dev=769, block=680
11353	end getblk(): find!
11353	ll_rw_block():rw=0 major=3
11353		bh->b_dev=769 bh->b_blocknr=680
11353	begin getblk(): dev=769, block=681
11353	end getblk(): find!
11353	ll_rw_block():rw=0 major=3
11353		bh->b_dev=769 bh->b_blocknr=681
11353	begin getblk(): dev=769, block=682
11353	end getblk(): find!
11353	ll_rw_block():rw=0 major=3
11353		bh->b_dev=769 bh->b_blocknr=682
11353	brelse(): dev=769, block=679
11353	brelse(): dev=769, block=680
11353	brelse(): dev=769, block=681
11353	brelse(): dev=769, block=682
11353	bread(): dev=769, block=672
11353	begin getblk(): dev=769, block=672
11353	brelse(): dev=769, block=672
11353	bread(): dev=769, block=672
11353	begin getblk(): dev=769, block=672
11353	brelse(): dev=769, block=672
11353	bread_page(): address=16310272, dev=769
11353		b[0]=670, b[1]=671, b[2]=673, b[3]=674
11353	begin getblk(): dev=769, block=670
11353	end getblk(): find!
11353	ll_rw_block():rw=0 major=3
11354		bh->b_dev=769 bh->b_blocknr=670
11354	begin getblk(): dev=769, block=671
11354	end getblk(): find!
11354	ll_rw_block():rw=0 major=3
11354		bh->b_dev=769 bh->b_blocknr=671
11354	begin getblk(): dev=769, block=673
11354	end getblk(): find!
11354	ll_rw_block():rw=0 major=3
11354		bh->b_dev=769 bh->b_blocknr=673
11354	begin getblk(): dev=769, block=674
11354	end getblk(): find!
11354	ll_rw_block():rw=0 major=3
11354		bh->b_dev=769 bh->b_blocknr=674
11354	brelse(): dev=769, block=670
11354	brelse(): dev=769, block=671
11354	brelse(): dev=769, block=673
11354	brelse(): dev=769, block=674
11354	bread(): dev=769, block=672
11354	begin getblk(): dev=769, block=672
11354	brelse(): dev=769, block=672
11354	bread(): dev=769, block=672
11354	begin getblk(): dev=769, block=672
11354	brelse(): dev=769, block=672
11354	bread(): dev=769, block=672
11354	begin getblk(): dev=769, block=672
11354	brelse(): dev=769, block=672
11354	bread(): dev=769, block=672
11354	begin getblk(): dev=769, block=672
11354	brelse(): dev=769, block=672
11354	bread_page(): address=16306176, dev=769
11354		b[0]=675, b[1]=676, b[2]=677, b[3]=678
11355	begin getblk(): dev=769, block=675
11355	end getblk(): find!
11355	ll_rw_block():rw=0 major=3
11355		bh->b_dev=769 bh->b_blocknr=675
11355	begin getblk(): dev=769, block=676
11355	end getblk(): find!
11355	ll_rw_block():rw=0 major=3
11355		bh->b_dev=769 bh->b_blocknr=676
11355	begin getblk(): dev=769, block=677
11355	end getblk(): find!
11355	ll_rw_block():rw=0 major=3
11355		bh->b_dev=769 bh->b_blocknr=677
11355	begin getblk(): dev=769, block=678
11355	end getblk(): find!
11355	ll_rw_block():rw=0 major=3
11355		bh->b_dev=769 bh->b_blocknr=678
11355	brelse(): dev=769, block=675
11355	brelse(): dev=769, block=676
11355	brelse(): dev=769, block=677
11355	brelse(): dev=769, block=678
11355	tty_write(0, 000034C0, 14)
11355	con_write() nr=15. tty is printing!
11355	exit
11356	bread(): dev=769, block=13
11356	begin getblk(): dev=769, block=13
11356	brelse(): dev=769, block=13
11356	is switched by 4
```