## 行内公式 

$\Gamma(z) = \int_0^\infty t^{z-1}e^{-t}dt\,.$

## 行间公式

$$\Gamma(z) = \int_0^\infty t^{z-1}e^{-t}dt\,.$$

## 希腊字母表

$$\begin{aligned}
\alpha \quad
\beta \quad
\gamma \quad
\Gamma \quad
\delta \quad
\Delta \quad
\epsilon \quad
\zeta \quad
\eta \quad
\theta \quad
\Theta \quad
\iota \quad
\kappa \quad
\lambda \quad
\Lambda \quad
\mu \quad
\nu \quad \\
\xi \quad
\Xi \quad
\omicron \quad
\pi \quad
\Pi \quad
\rho \quad
\sigma \quad
\Sigma \quad
\tau \quad
\upsilon \quad
\Upsilon \quad
\phi \quad
\Phi \quad
\chi \quad
\psi \quad
\Psi \quad
\omega \quad
\Omega
\end{aligned}$$

## 括号

1.小括号与圆括号$$(x) \quad [x]$$

2.大括号$$\{ x \} \quad \lbrace x \rbrace$$

3.尖括号$$\langle x \rangle$$

4.上取整$$\lceil x \rceil$$

5.下取整$$\lfloor x \rfloor$$

## 求和与积分

1.求和$$\sum_{i=1}^n$$

2.积分$$\begin{aligned}
\int_l^\infty \quad
\iint \quad
\iiint \quad
\iiiint \quad
\oint \quad
...
\end{aligned}$$

3.其他$$\begin{aligned}
\prod \quad
\bigcup \quad
\bigcap
\end{aligned}$$

## 分式与根式

1.分式(两种方法)$$\begin{aligned}
\frac abc \quad
\frac {a}{b} \quad
{a+1 \over b+2}
\end{aligned}$$

$$\begin{aligned}
a+c \quad \lambda \over b+2
\end{aligned}$$

`\frac` 作用于其后的两个组,

`\over`作用于分隔组内前后两部分

2.连分数(建议使用`\cfrac`代替`\frac`)

`\frac`表示如下:$$x=a_0 + \frac {1^2}{a_1 + \frac {2^2}{a_2 + \frac {3^2}{a_3 + \frac {4^2}{a_4 + ...}}}}$$

`\cfrac`表示如下:$$x=a_0 + \cfrac {1^2}{a_1 + \cfrac {2^2}{a_2 + \cfrac {3^2}{a_3 + \cfrac {4^2}{a_4 + ...}}}}$$

3.根式$$\sqrt[\pi]{\frac xy}$$

## 多行表达式

1.多行表达式

使用`\begin{cases}...\end{cases}`来表示多情况. 其中, 使用`\\`来分类换行, 使用`&`指示需要对齐的位置, `\blankspace`表示空格.
$$f(n)=\begin{cases}
\cfrac n2, &if\ n\ is\ even\\
3n + 1, &if\ n\ is\ odd
\end{cases}$$

`\\[2ex]` `\\[3ex]`可以代替\\用来使分类之间的垂直间隔扩大.
$$f(n)=\begin{cases}
\cfrac n2, &if\ n\ is\ even\\[5ex]
3n + 1, &if\ n\ is\ odd
\end{cases}$$

2.多行表达式
`\begin{equation}...\end{equation}`表示方程的开始和结束. `\begin{split}...\end{split}`表示多行公式的开始和结束.$$\begin{equation}\begin{split}
a&=b+c-d \\
&\quad +e-f\\
&=g+h\\
& =i
\end{split}\end{equation}$$

align是环境, 地位与eqution相同, align*除了产生编号外, 其他与align相同  
`\begin{aligned}...\end{aligned}`也能表示多行公式的开始和结束.

aligned通常和eqution环境等配合使用, 其放在equation环境中, 意味着多行公式只占用当前eqution环境的一个编号.   
`\begin{aligned} <空格或者换行> [<任意内容>]`中`<任意内容>`作为`aligned`的可选参数
* t, c, b 三者之一时,分别表示与环境之前的内容进行(top, center, bottom)纵向对齐. 
* 为空时, 同`c`

3\.方程组

(1)使用`\begin{array}...\end{array}`与`\left \{` 和 `\right.`$$\left \{
\begin{array}{c}
a_1x+b_1y+c_1z=d_1 \\
a_2x+b_2y+c_2z=d_2 \\
a_3x+b_3y+c_3z=d_3
\end{array}\right.$$

(2)直接使用`begin{cases}`和`end{cases}`表示

## 特殊函数与符号

1.运算$$\begin{aligned}
\sin x \quad
\arctan y \quad
\times
\end{aligned}$$

2.比较运算符号$$\begin{aligned}
\lt \quad
\gt \quad
\le \quad
\ge \quad
\ne \quad
\not\ \quad
\not\lt \quad
\not\gt \quad
\not\le \quad
\not\ge \quad
\not\ne \quad
\end{aligned}$$

3.集合关系与运算$$\begin{split}
\cup \quad
\cap \quad
\setminus \quad
\subset \quad
\subseteq \quad
\subsetneq \quad
\supset \quad
\in \quad
\notin \quad
\not\in \quad
\emptyset \quad
\varnothing
\end{split}$$

4.组合数$$\begin{split}
\binom{n}{m} \quad
{n \quad \lambda \choose m}
\end{split}$$

5.箭头$$\begin{split}
\to \quad
\rightarrow \quad
\leftarrow \quad
\Rightarrow \quad
\Leftarrow \quad
\mapsto
\end{split}$$

6.逻辑运算符$$\begin{split}
\land \quad
\lor \quad
\lnot \quad
\forall \quad
\exists \quad
\top \quad
\bot \quad
\vdash \quad
\vDash \quad
\because \quad
\therefore \quad
\implies
\end{split}$$

7.操作符$$\begin{split}
\star \quad
\ast \quad
\oplus \quad
\circ \quad
\bullet
\end{split}$$

8.等于$$\begin{split}
\approx \quad
\sim \quad
\cong \quad
\equiv \quad
\prec
\end{split}$$

9.其他$$\begin{split}
\infty \quad
\aleph \quad
\nabla \quad
\partial \quad
\Im \quad
\Re
\end{split}$$

10.模运算$$a \equiv b \pmod n$$

11.点$$\begin{split}
\ldots \quad
\cdots \quad
\ddots \quad
\vdots \quad
\cdot
\end{split}$$

## 顶部符号
$$\begin{split}
\hat x \quad
\widehat xy \quad
\overline x \quad
\vec x \quad
\overrightarrow x \quad
\overleftarrow x \quad
\dot x \quad
\ddot x \quad
\dddot x
\end{split}$$

## 表格
$$\begin{array}{c|lcr}
n & \text{Left} & \text{Center} & \text{Right} \\
\hline
1 & 0.24 & 1 & 125 \\
2 & -1 & 189 & -8 \\
3 & -20 & 2000 & 1+10i \\
\end{array}$$

## 矩阵

1.基本用法$$\begin{matrix}
1 & x & x^2 \\
1 & y & y^2 \\
1 & z & z^2 \\
\end{matrix}$$

2.加括号,将`matrix`换为对应的关键词
> 小括号: pmatrix  
> 中括号: bmatrix  
> 大括号: Bmatrix  
> 行列式: vmatrix  
> 范式: Vmatrix

3.省略元素  
用`\cdots`, `\ddots`, `\vdots`代替即可

4.增广矩阵$$\left[\begin{array}{ccc}
1&2&3\\
4&5&6
\end{array}\right]$$

## 公式标号与引用

标号: `\tag{yourtab}`  
标签: `\label{yourlabel}`  
带括号引用: `eqref{yourlabel}`  
不带括号引用: `ref{yourlabel}`  
$\color{red}{Obsidian(也许是markdown?)中的标签和引用有问题,不要使用}$

## 字体
$\mathbb CHNQRZ$  
$\Bbb CHNQRZ$  
$\mathbf ABCDEFGHIJKLMNOPQRSTUVWXYZ$  
$\mathbf abcdefghijklmnopqrstuvwxyz$  
$\mathtt ABCDEFGHIJKLMNOPQRSTUVWXYZ$  
$\mathtt abcdefghijklmnopqrstuvwxyz$  
$\mathrm ABCDEFGHIJKLMNOPQRSTUVWXYZ$  
$\mathrm abcdefghijklmnopqrstuvwxyz$  
$\mathscr ABCDEFGHIJKLMNOPQRSTUVWXYZ$  
$\mathscr abcdefghijklmnopqrstuvwxyz$  
$\mathfrak ABCDEFGHIJKLMNOPQRSTUVWXYZ$  
$\mathfrak abcdefghijklmnopqrstuvwxyz$

## 颜色
使用`\color{yourcolor}{yourtext}`标签
$$\begin{split}
\color{black}{text} \quad
\color{gray}{text} \quad
\color{silver}{text} \quad
\color{white}{text} \quad
\color{maroon}{text} \quad
\color{red}{text} \quad
\color{yellow}{text} \quad
\color{lime}{text}  \\
\color{olive}{text} \quad
\color{green}{text} \quad
\color{teal}{text} \quad
\color{aqua}{text} \quad
\color{blue}{text} \quad
\color{navy}{text} \quad
\color{purple}{text} \quad
\color{fuchsia}{text}
\end{split}$$