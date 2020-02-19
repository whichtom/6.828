### Assignment 3

Part one: system call tracing

In `syscall.c`
```c
void
syscall(void)
{
  int num;
  struct proc *curproc = myproc();

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
    switch (num) {
      case SYS_fork:
        cprintf("fork -> ");
	break;
      case SYS_exit:
	cprintf("exit -> ");
	break;
      case SYS_wait:
	cprintf("wait -> ");
	break;
      case SYS_pipe:
	cprintf("pipe -> ");
	break;
      case SYS_read:
        cprintf("read -> ");
        break;
      case SYS_kill:
        cprintf("kill -> ");
        break;
      case SYS_exec:
        cprintf("exec -> ");
        break;
      case SYS_fstat:
        cprintf("fstat -> ");
        break;
      case SYS_chdir:
        cprintf("chdir -> ");
        break;
      case SYS_dup:
        cprintf("dup -> ");
        break;
      case SYS_getpid:
        cprintf("getpid -> ");
        break;
      case SYS_sbrk:
        cprintf("sbrk -> ");
        break;
      case SYS_sleep:
        cprintf("sleep -> ");
        break;
      case SYS_uptime:
        cprintf("uptime -> ");
        break;
      case SYS_open:
        cprintf("open -> ");
        break;
      case SYS_write:
        cprintf("write -> ");
        break;
      case SYS_mknod:
        cprintf("mknod -> ");
        break;
      case SYS_unlink:
        cprintf("unlink -> ");
        break;
      case SYS_link:
        cprintf("link -> ");
        break;
      case SYS_mkdir:
        cprintf("mkdir -> ");
        break;
      case SYS_close:
        cprintf("close -> ");	
	break;
      default:
	panic("Should never even get here\n");
    }
    cprintf("%d\n", curproc->tf->eax);
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
```




Part two: date system call
See `date.c`, `syscall.h`, `syscall.c`, `sysproc.c`, `user.h`, `usys.S`.
