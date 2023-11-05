---
author: "013-涂靖昊"
---

# 操作系统实验二报告

013-涂靖昊

> 1.当执行完 `system_interrupt` 函数, 执行 `153` 行 `iret` 时, 记录栈的变化情况.

<figure style="text-align: center;">
  <img src="2_1.png" alt="", width="", height="", >
  <figcaption>图1 执行 iret 前的状态</figcaption>
</figure>

<figure style="text-align: center;">
  <img src="2_2.png" alt="", width="", height="", >
  <figcaption>图2 执行 iret 后的状态</figcaption>
</figure>

可以看到有 5 个寄存器的值发生了变化, 这说明内核栈在执行 `iret` 的过程中发生了 5 次 `pop` 操作  
其中 `esp` 寄存器的值被更改了, 所以可以看到右侧的栈也发生了切换.

> 2.当进入和退出 `system_interrupt` 时, 都发生了模式切换, 请总结模式切换时, 特权级是如何改变的? 栈切换吗? 如何进行切换的?

`cs` 代码段寄存器中所装载段选择子的后两位决定当前特权级 CPL, `00` 表示实模式, `11` 表示保护模式.

<figure style="text-align: center;">
  <img src="2_3.png" alt="", width="", height="", >
  <figcaption>图3 进入 system_interrupt 前的状态</figcaption>
</figure>

从图 3 中可以看到此时 `cs` 寄存器的值为 `0x000f`, 后两位为 `11` 说明此时正在以保护模式 + 特权级 3 在执行任务 0.

<figure style="text-align: center;">
  <img src="2_4.png" alt="", width="", height="", >
  <figcaption>图4 进入 system_interrupt 后的状态</figcaption>
</figure>

从图 4 中可以看到此时执行完 `int 0x80` 后, `cs` 寄存器的值变为 `0x0008`, 后两位为 `00`,
说明此时正在以实模式 + 特权级 0 在执行系统调用 `system_interrupt`.

而退出 `system_interrpt` 所发生的变化可以从图 1 和图 2 中看到, `cs` 寄存器的值从 `0x000f` 变为了 `0x0008`.
这说明 CPL 从实模式又切换到了保护模式, cpu 继续执行用户任务 0.

而关于栈的切换, 从图 3 和 图 4 的对比, 以及图 1 和 图 2 中的对比可以清晰地看到, `esp` 寄存器的值发生了变化.
这说明栈发生了切换. 从 bochs 软件界面的右侧对栈的监视也可以清楚看到栈发生了切换.

> 3.当发生时钟中断时, 进入到 `timer_interrupt` 程序, 请详细记录从任务 `0` 切换到任务 `1` 的过程.

<figure style="text-align: center;">
  <img src="2_5.png" alt="", width="", height="", >
  <figcaption>图5 比较当前的任务是否是任务 1</figcaption>
</figure>

<figure style="text-align: center;">
  <img src="2_6.png" alt="", width="", height="", >
  <figcaption>图6 获取比较的结果, 并设置 eflags 寄存器</figcaption>
</figure>

因为当前是任务 `0`, 所以这里不会跳转.
执行下一条指令 `movl %eax, current`, 即图 6 中的 `mov dword ptr ds:0x0000017d, eax`, 会在变量 `current` 即物理地址 `0x017d` 处修改为值 `1`, 表明现在要进行的是任务 `1`.

接着下一条指令 `ljmp $TSS1_SEL, $0`, 即图 6 中的 `jmpf 0x0030:00000000`, 会加载任务 `1` 的 TSS 段, 跳转到任务 `1` 的代码段开始执行, 地址为 `0x10f4`.

<figure style="text-align: center;">
  <img src="2_7.png" alt="", width="", height="", >
  <figcaption>图7 跳转执行任务 1</figcaption>
</figure>

可以看到大部分寄存器状态都发生了变化, 栈也从 `krn_stack0` 切换到了 `usr_stack1`.

> 4.又过了 `10ms`, 从任务 `1` 切换到任务 `0`, 整个流程是怎样的? `TSS` 是如何变化的? 各个寄存器的值又是如何变化的?

<figure style="text-align: center;">
  <img src="2_8.png" alt="", width="", height="", >
  <figcaption>图8 比较并判断是否跳转</figcaption>
</figure>

这里是在比较得出当前执行的任务是任务 `1`, 然后修改 `eflags` 寄存器的值为 `0x0046`, 并据此跳转到 `0x0152`.

然后修改 `current` 变量的值为 `0`, 表明现在要进行的是任务 `0`.

再执行 `0x015c` 处的指令, 继承上一次任务 `0` 的上下文, 因为上一次任务 `0` 是在 `0x0149` 中断的, 下一条指令地址是 `0x150`, 所以这次会跳转到 `0x0150`处.

<figure style="text-align: center;">
  <img src="2_9.png" alt="", width="", height="", >
  <figcaption>图9 重新执行任务 0</figcaption>
</figure>

从图 9 中可以看到, 寄存器状态和栈都发生了切换, 切换回了任务 `0` 上一刻的状态.

这一次任务 `0` 会从 `0x0150` 继续执行, 然后跳转到 `0x0163` 处, 依次执行 `pop eax`, `pop ds` 和 `iret`.

这也与 `timer_interrupt` 开头的过程, 即执行中断系统调用, 将程序上下文, `ds`, `eax` 依次入栈相对应.

执行 `iret` 后, 就会跳转回任务 `1` 的代码段继续执行.

> 5.请详细总结任务切换的过程.

在执行任务 `0` 的过程中, 定时器触发系统中断, 进入到中断门系统调用 `timer_interrupt`. 然后判断当前任务为任务 `0`,
于是加载任务 `1` 的 TSS 段, 更新任务 `0` 的 TSS 段.然后跳转执行任务 `1`. (这是第一次切换的情况)

任务 `1` 切换到 任务 `0` 的过程与上述类似, 切换回任务 `0` 后会从上一次任务 `0` 被中断的地方继续执行,
也就是继续执行上一次的 `timer_interrupt`.

往后任务 `0` 与任务 `1` 的切换与上述过程基本一致.
