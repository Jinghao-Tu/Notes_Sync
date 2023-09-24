---
title: '3-4 周作业'
author: 涂靖昊 2021112369
---

## 作业 1

1. 复习概率论的基本内容
2. 查阅如何用计算机来模拟随机变量生成以及特定概率分布的随机变量生成
3. 使用一种编程语言来生成随机变量和满足特定分布的随机序列

2.解答:  
(1) 计算机模拟随机变量生成的一般方法是使用伪随机数生成器, 伪随机数生成器由两部分组成: 种子和随机数生成算法.
种子是一个整数, 它作为随机数生成算法的输入, 用于初始化算法的状态.
而随机数生成算法是一个确定性的算法, 它接收种子作为输入, 并生成一个数字序列作为输出. 这个数字序列看起来像随机数, 实际上是由算法计算出来的.

(2) 特定概率分布的随机变量生成:

1. 均匀分布: 使用随机数生成函数生成 $[0,1]$ 区间内的随机数, 然后将其缩放到所需的区间.
2. 正态分布: 使用 Box-Muller 转换或 Marsaglia 极化方法将均匀分布的随机数转换为正态分布的随机数.
3. 指数分布: 使用逆变换法, 即使用随机数生成函数生成 $[0,1]$ 区间内的随机数, 然后将其通过指数分布的累积分布函数进行反演.
4. 泊松分布: 使用逆变换法, 即使用随机数生成函数生成 $[0,1]$ 区间内的随机数, 然后将其通过泊松分布的累积分布函数进行反演.
5. 二项分布: 使用 Bernoulli 分布的随机变量和随机数生成函数生成二项分布的随机变量.
6. 其他分布: 对于其他分布, 可以使用逆变换法, 拒绝采样, 重要性采样等方法进行生成.

3.解答:  
(1) 随机变量的生成 (线性同余法):

```python
class LinearCongruentialGenerator:
    def __init__(self, seed, a=1664525, c=1013904223, m=2**32):
        self.seed = seed
        self.a = a
        self.c = c
        self.m = m

    def random(self):
        self.seed = (self.a * self.seed + self.c) % self.m
        return self.seed / self.m
```

(2) 满足特定分布的随机序列:

均匀分布:

```python
class UniformRandomSequenceGenerator:
    def __init__(self, seed, a=1664525, c=1013904223, m=2**32, n=10):
        self.seed = seed
        self.a = a
        self.c = c
        self.m = m
        self.n = n

    def generate(self):
        sequence = []
        for i in range(self.n):
            self.seed = (self.a * self.seed + self.c) % self.m
            sequence.append(self.seed / self.m)
        return sequence
```

正态分布:

```python
import math

class NormalRandomSequenceGenerator:
    def __init__(self, seed, a=1664525, c=1013904223, m=2**32, n=10):
        self.seed = seed
        self.a = a
        self.c = c
        self.m = m
        self.n = n

    def generate(self):
        sequence = []
        # 采用 Box-Muller 转换均匀分布的随机数为正态分布的随机数
        for i in range(self.n):
            u1 = 0
            while u1 == 0:
                self.seed = (self.a * self.seed + self.c) % self.m
                u1 = self.seed / self.m
            self.seed = (self.a * self.seed + self.c) % self.m
            u2 = self.seed / self.m
            z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
            sequence.append(z)
        return sequence
```

指数分布:

```python
import math

class ExponentialRandomSequenceGenerator:
    def __init__(self, seed, a=1664525, c=1013904223, m=2**32, n=10, lambd=1):
        self.seed = seed
        self.a = a
        self.c = c
        self.m = m
        self.n = n
        self.lambd = lambd

    def generate(self):
        sequence = []
        # 采用逆变换法转换均匀分布的随机数为正态分布的随机数
        for i in range(self.n):
            u = 0
            while u == 0:
                self.seed = (self.a * self.seed + self.c) % self.m
                u = self.seed / self.m
            x = -math.log(u) / self.lambd
            sequence.append(x)
        return sequence
```

## 作业 2

1. 假设信源 $X$ 中有 $n$ 个相互独立的符号 $x_i, i = 1, \cdots, n$, 其概率分布分别为 $p_i, i = 1, \cdots, n$, 满足 $\sum_{i=1}^{n} p_i = 1$, 请给出该信源的熵 $H(X)$, 并给出该信源的熵取最大值是什么? 熵取最大值时对应的概率分布是什么, 请给出证明过程.

解答:  
该信源的熵 $H(X)$ 可以通过以下公式计算：$$H(X) = - \sum_{i=1}^{n} p_i \log_2(p_i)$$
根据 $$\begin{equation*}\left\{
    \begin{aligned}
        & H(X) = - \sum_{i=1}^{n} p_i \log_2(p_i)\\
        & \sum_{i=1}^{n} p_i = 1
    \end{aligned}
\right.\end{equation*}$$
构造 $$ L(p_i, \lambda) = - \sum_{i=1}^{n} p_i \log_2(p_i) + \lambda (\sum_{i=1}^{n} p_i - 1) $$
求解: $$\begin{equation*}\left\{
    \begin{aligned}
        & \frac{\partial L(p_i, \lambda)}{\partial p_i} = 0 \\
        & \sum_{i=1}^{n} p_i = 1
    \end{aligned}
\right.\end{equation*}$$
得到 $$ p_i = e^{\lambda - 1} = \frac{1}{n} $$
将 $p_i=\frac{1}{n}$ 带入 $H(X) = - \sum_{i=1}^{n} p_i \log_2(p_i)$ 得到 $H(X)_{max} = \log_2(n)$

## 作业 3

1. 假设二维随机变量 $(X/Y)$ 满足 $\left\{\begin{align*}X = cos \Phi \\Y = sin \Phi\end{align*}\right.$, 其中 $\Phi$ 是在 $[0, 2\pi]$ 上均匀分布的随机变量, 请讨论随机变量 $X, Y$ 的独立性和相关性.
2. 假设随机变量的概率密度函数 $f(x) = \left\{ \begin{align*}&\frac{1}{b-a}, &\quad a \le x \le b \\&0, &\quad \text{其他}\end{align*} \right.$, 则称 $X$ 为在 $[a, b]$ 上的均匀分布的随机变量, 请给出其概率分布函数 $F_x(x)$ 以及其数学期望和方差. 在对信号进行数字化的过程中, 需要对某均匀分布的输入 $X$ 进行步长为 $\Delta$ 的均匀量化, 请分析该量化器的 MSE. 如果将量化步长缩短为 $\frac{\Delta}{2}$, 则信号的信噪比如何变化?
3. 正在对 $n$ 个人进行某疾病检查, 每个人都可以但对监测, 但这会很昂贵. 池化可以降低成本. $k$ 个人的样本可以汇集在一起进行分析. 如果测试结果是阴性的, 这个测试对 $k$ 个人的组是足够的. 如果测试结果是阳性的, 那么 $k$ 个人中的每一个都必须单独测试. 因此是 $k+1$ 次测试. 假设我们创建 $\frac{n}{k}$ 个不相交的 $k$ 人组 ($k$ 整除 $n$), 并使用池化方法. 假设每个人的测试结果都是阳性的概率是 $p$.
   - a. $k$ 个人的集合样本的测试结果为阳性的概率是多少?
   - b. 预计需要进行多少次测试?
   - c. 描述如何找到 $k$ 的最佳值?
   - d. 给出一个不等式描述, 从而说明 $p$ 池化检测的哪些数值会比只测试单个个体好?
4. 假设 $a_1, a_2, \cdots, a_n$ 是 $n$ 个不同数的列表, 例如就是 $1 \sim n$ 的自然数. 如果 $i < j, a_a > a_j$ 则说 $a_i$ 和 $a_j$ 是逆序的. 冒泡排序算法成对交换列表中相邻的逆序数字, 直到没有任何逆序数对存在为止, 这时列表是单项递增的. 假设算法的输入是一个随机排列, 也就是从 $n!$ 个排列中等概率选取的一个.
   - a. 冒泡排序算法中需要反转的数对的期望值是多少?
   - b. 确定需要通过冒泡排序算法来校正的反转数对的方差是多少?

1.解答:  
显然 $X^2 + Y^2 \le 1$, $(x, y)$ 在 $X^2 + Y^2 \le 1$ 内均匀分布, $$ f(x, y) = \left\{\begin{aligned}
    & \frac{1}{2\pi}, &\quad 0 \le x^2 + y^2 \le 1 \\
    & 0, &\quad \text{其他}
\end{aligned}\right. $$
$$ \begin{aligned}
    & f_X(x) = \int_{-\infty}^{+\infty}f(x, y)dy = \int_{-\sqrt{1-x^2}}^{+\sqrt{1-x^2}}\frac{1}{2\pi}dy = \frac{\sqrt{1-x^2}}{\pi}\\
    & f_Y(y) = \frac{\sqrt{1-y^2}}{\pi}
\end{aligned} $$
显然有 $f(x, y) \neq f_X(x)f_Y(y)$, 即 $X$, $Y$ 不独立.

$$ \begin{equation*}
    \begin{aligned}
        \text{Cov}(X, Y) & = \frac{\text{var}(X, Y)}{\sigma_X\sigma_Y} \\
        \\
        \sigma_X &= E(X^2) - E(X)^2\\
        & = \int_0^{2\pi}cos^2\Phi d\Phi - \left(\int_0^{2\pi}cos\Phi d\Phi\right)^2 \\
        & = \pi - 0 \\
        & = \pi \\
        \\
        \sigma_Y & = \pi \\
        \\
        \text{Cov}(X, Y) & = E(XY) - E(X)E(Y) \\
        & = \int_0^{2\pi}cos\Phi sin\Phi d\Phi - 0*0 \\
        & = 0
    \end{aligned}
\end{equation*} $$
可知, $X$, $Y$ 的相关系数为 $0$.

2.解答:  
$$ \begin{equation*}
    F_X(x) = \left\{\begin{aligned}
        & \int_a^x\frac{1}{b-a}dx, & a \le x \le b \\
        & 0, & x < a \\
        & 1, & b < x
    \end{aligned}\right.
    = \left\{\begin{aligned}
        & \frac{x-a}{b-a}, & a \le x \le b \\
        & 0, & x < a \\
        & 1, & b < x
    \end{aligned}\right.
\end{equation*} $$
$$ \begin{equation*}
    \begin{aligned}
        E(X) = \frac{a+b}{2} \\
        D(X) = \frac{(b-a)^2}{12}
    \end{aligned}
\end{equation*} $$
每一个量化步中长生的 MSE 大小相等, 共量化 $\frac{b-a}{\Delta}$ 步  
以第 $i$ 步为例:
$$ \begin{equation*}
    \begin{aligned}
        \text{MSE}_i & = \frac{1}{\Delta}\left(\int_{t-\frac{\Delta}{2}}^t(x-t)^2dx + \int_{t}^{t+\frac{\Delta}{2}}(x-t)^2dx \right) \\
        & = \frac{\Delta^3}{12} \\
        \\
        \text{MSE} & = \frac{\Delta^3}{12}\times \frac{b-a}{\Delta} = \frac{\Delta^2}{12}(b-a)
        \\
        \text{MSE'} & = \frac{1}{4}\text{MSE} = \frac{\Delta^2}{48}(b-a)
    \end{aligned}
\end{equation*} $$

3.解答:  
a. $k$ 个人的集合样本的测试结果为阳性的概率是 $p_\text{阳性} = 1-(1-p)^k$  
b. 每一个组进行 $1$ 次测试的概率为 $p_1 = (1-p)^k$, 进行 $k+1$ 次测试的概率为 $p_2 = 1-(1-p)^k$, 测试数的期望是 $E(X') = k + 1 - k(1-p)^k$. 那么总的测试数的期望是 $E(X) = \frac{n}{k} \cdot (k + 1 - k(1-p)^k) = n + \frac{n}{k} - n(1-p)^k$  
c. 找到 $k$ 的最佳值, 令 $$f(k) = n + \frac{n}{k} - n(1-p)^k \quad, 2 \le k < n$$
得到 $$ \frac{\partial f(k)}{\partial k} = -\frac{n}{k^2} - nk(1-p)^{k-1} < 0 $$
所以当 $k$ 取得 $n$ 的最大余数时, 总测试数的期望最小  
d. 不分组时, $f(1) = n$, 令
$$ g(p) = f(k) - f(1) = \frac{n}{k}- n(1-p)^k = 0, g'(p) < 0, k \text{是} n \text{的最大余数} $$
解得
$$ p_0 = 1 - \sqrt[k]{\frac{1}{k}} $$
当 $p < p_0$ 时, 不分组更好, 当 $p > p_0$ 时, 池化更好.

4.解答:  
(1)  
设 $X$ 是随机序列中数对的交换次数, 是随机变量. 不妨假设随机序列是 $1\sim n$ 的自然数构成的随机数列.  
现在计算 $E(X; n=k)$  
不难想到, $$\begin{aligned}
    E(X;n=k) &= E(\text{把}k\text{移动到最后一位的交换次数}) + E(k\text{排好后, 前}k-1\text{位的交换次数}) \\
    &= \frac{\sum_{i=0}^{k-1}i}{k} + E(X;n=k-1) \\
    & = \frac{k-1}{2} + E(X; n=k-1) \\
    & \cdots \\
    & = \sum_{i=1}^{k}\frac{i-1}{2} \\
    & = \frac{k(k-1)}{4}
\end{aligned} $$
(2)  
对于 (1) 中构造的两个过程 "把 $k$ 移动到最后一位" 和 "$k$ 排好后, 前 $k-1$ 交换". 不难想到, 这两个过程是相互独立的.  
则有
$$ \begin{aligned}
    D(X; n=k) &= D(\text{把}k\text{移动到最后一位的交换次数}) + D(k\text{排好后, 前}k-1\text{位的交换次数}) \\
    &= \frac{\sum_{i=0}^{k-1}i^2}{k} - \left(\frac{k-1}{2}\right)^2 + D(X; n = k-1) \\
    &= \frac{(k-1)(2k-1)}{6} - \frac{k^2-2k+1}{4} + D(X; n = k-1) \\
    & = \frac{k^2-1}{12} + D(X; n = k-1) \\
    \cdots \\
    &= \sum_{i=1}^{k}\frac{i^2-1}{12} \\
    &= \frac{2k^3+3k^2-5k}{72}
\end{aligned} $$
