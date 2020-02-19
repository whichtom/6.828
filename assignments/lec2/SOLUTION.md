### Assignment 2

Finding the address of `_start`, the entry point of the kernel.

```
$ nm kernel | grep _start
8010a48c D _binary_entryother_start                                                                  
8010a460 D _binary_initcode_start                                                                    
0010000c T _start
```

So the address of `_start_` is that `0010000c`.

As I am ssh'ing to my ubuntu box from macos via vagrant: `qemu-nox-gdb` runs with serial console and gdb (see [here](https://pdos.csail.mit.edu/6.828/2010/labguide.html)), and `gdb kernel -iex 'add-auto-load-safe-path /`' fixes a weird problem with it being unable to run the `.gdbinit`. 
 
```
$ make qemu-nox-gdb
$ gdb kernel -iex 'add-auto-load-safe-path /
...
The target architecture is assumed to be i8086
[f000:fff0]    0xffff0: ljmp   $0xf000,$0xe05b
0x0000fff0 in ?? ()
+ symbol-file kernel
```

So the BIOS starts at address `0xfff0`.

```
$ (gdb) br * 0x0010000c
Breakpoint 1 at 0x10000c
$ (gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0x10000c:    mov    %cr4,%eax

Thread 1 hit Breakpoint 1, 0x0010000c in ?? ()
```

Now,
```
$ (gdb) x/24x $esp
0x7bdc: 0x00007d8d      0x00000000      0x00000000      0x00000000
0x7bec: 0x00000000      0x00000000      0x00000000      0x00000000
0x7bfc: 0x00007c4d      0x8ec031fa      0x8ec08ed8      0xa864e4d0
0x7c0c: 0xb0fa7502      0xe464e6d1      0x7502a864      0xe6dfb0fa
0x7c1c: 0x16010f60      0x200f7c78      0xc88366c0      0xc0220f01
0x7c2c: 0x087c31ea      0x10b86600      0x8ed88e00      0x66d08ec0
```

The bootloader is composed of `bootasm.s` and `bootmain.c`. The BIOS first loads the bootloader to address `0x7c00`, jumps to it, and starts executing the code in `bootasm.s.`
```
movl	$start, %esp
call	bootmain
```

The value of `$start` is the address of the first instruction of the bootloader, and `esp` first points to `0x7c00`, and then calls bootmain. Thus, `0x7c00` and above are all bootloader code.

The reason of the 28 bytes of 0 and a `0x7d8d` is that after the function calls bootmain, `esp` points to `0x7bfc`, and there is an operation to reduce `esp` by 12 (28 bytes). Looking at the asm code of the bootmain in `bootblock.asm`,
```
7d3b:       55                      push   %ebp
7d3c:       89 e5                   mov    %esp,%ebp
7d3e:       57                      push   %edi
7d3f:       56                      push   %esi
7d40:       53                      push   %ebx
7d41:       83 ec 0c                sub    $0xc,%esp
``` 

## References
- [2011 Yale: Running and debugging xv6](https://web.archive.org/web/20190308091152/http://zoo.cs.yale.edu/classes/cs422/2011/lec/l2-hw)
- [UCI xv6](https://www.ics.uci.edu/~aburtsev/238P/hw/hw2-boot-xv6.html)

The MIT OCW is a little sketchy and not helpful sometimes.







