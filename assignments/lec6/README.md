## Assignment 4

Part 1:
In `sysproc.c`, what `sys_sbrk()` looks like after the modification to delete page allocation from the sbrk(n) system call implementation 

```c
int
sys_sbrk(void)
{
	int addr;
	int n;

	if(argint(0, &n) < 0)
		return -1;
	addr = myproc()->sz;
	myproc()->sz += n;
	return addr;
} 
```

After running `$ make qemu-nox`, and then `$ echo hi`:
`
$ echo hi
pid 3 sh: trap 14 err 6 on cpu 0 eip 0x112c addr 0x4004--kill proc
$  
`
which just means a page fault has been caught by the kernel trap handler, at the addr `0x4004`.


Part 2:
Now modifying the code in `trap.c` to respond to a page fault from user space by mapping a newly-allocated page of physical memory at the faulting address, and then returning back to the user space to let the process continue executing. 

```c
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);
...

// assignment 4 
if (tf->trapno == T_PGFLT) {
  char *mem = kalloc();
  if (mem==0) {
    cprintf("allocuvm out of memory\n");
    break;
  }
  memset(mem, 0, PGSIZE);
  if(mappages(myproc()->pgdir, (char*) PGROUNDDOWN(rcr2()), PGSIZE, V2P(mem), PTE_W|PTE_U) <     0) {
    cprintf("allocuvm out of memory (2)\n");
    break;
  }

  return;
}
```


Now re-running `$ make qemu-nox`, and then `$ echo hi`:
`
$ echo hi
hi
`

