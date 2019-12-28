Solutions to 6.828 Operating Systems
====================================
"This course studies fundamental design and implementation ideas in the engineering of operating systems. Lectures are based on a study of UNIX and research papers. Topics include virtual memory, threads, context switches, kernels, interrupts, system calls, interprocess communication, coordination, and the interaction between software and hardware. Individual laboratory assignments involve implementation of a small operating system in C, with some x86 assembly."

[Assignments](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-828-operating-system-engineering-fall-2012/assignments/)
-----------

- [x] lecture 1: shell exercises
- [ ] lecture 2: boot xv6
- [ ] lecture 3: xv6 system calls (system call tracing and halt system call)
- [ ] lecture 4: xv6 lazy page allocation (eliminate allocation from sbrk() and lazy allocation)
- [ ] lecture 5: xv6 CPU alarm
- [ ] lecture 6: threads and locking
- [ ] lecture 7: user level threads
- [ ] lecture 8: barriers
- [ ] lecture 9: bigger files for xv6
- [ ] lecture 10: xv6 log

[Labs](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-828-operating-system-engineering-fall-2012/labs/)
----

- [ ] lab 1: booting a PC
- [ ] lab 2: memory management
- [ ] lab 3: user environments
- [ ] lab 4: preemptive multitasking
- [ ] lab 5: spawn and shell

Tools (macOS)
-----
The tools were installed by following [this](https://pdos.csail.mit.edu/6.828/2014/tools.html) advice, thus my toolchain consists of:
* gmp-5.0.2
* mpfr-4.0.2
* binutils-2.21.1
* gcc-4.6.1
* gdb-7.3.1

Also
* QEMU 4.2.0


Honestly will probably just end up using my Ubuntu VM because the QEMU remote debugger is being annoying.

