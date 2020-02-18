Solutions to 6.828 Operating Systems
====================================
"This course studies fundamental design and implementation ideas in the engineering of operating systems. Lectures are based on a study of UNIX and research papers. Topics include virtual memory, threads, context switches, kernels, interrupts, system calls, interprocess communication, coordination, and the interaction between software and hardware. Individual laboratory assignments involve implementation of a small operating system in C, with some x86 assembly."

[Assignments](https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-828-operating-system-engineering-fall-2012/assignments/)
-----------

- [x] lecture 1: shell exercises
- [ ] lecture 2: boot xv6
	* note: ```git clone git://github.com/mit-pdos/xv6-public.git```
	* [This is also very useful](https://web.archive.org/web/20190308091152/http://zoo.cs.yale.edu:80/classes/cs422/2011/lec/l2-hw)
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

Tools (Ubuntu)
-----
Honestly will probably just end up using my Ubuntu VM because the QEMU remote debugger is being annoying, with the following:
* libsdl1.2-dev
* libtool-bin
* libglib2.0-dev
* libz-dev
* libpixman-1-dev



