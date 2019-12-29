
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 60 18 10 f0 	movl   $0xf0101860,(%esp)
f0100055:	e8 80 08 00 00       	call   f01008da <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 c5 06 00 00       	call   f010074c <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 7c 18 10 f0 	movl   $0xf010187c,(%esp)
f0100092:	e8 43 08 00 00       	call   f01008da <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 44 a9 11 f0       	mov    $0xf011a944,%eax
f01000a8:	2d 00 a3 11 f0       	sub    $0xf011a300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 a3 11 f0 	movl   $0xf011a300,(%esp)
f01000c0:	e8 2a 13 00 00       	call   f01013ef <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 6c 04 00 00       	call   f0100536 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 97 18 10 f0 	movl   $0xf0101897,(%esp)
f01000d9:	e8 fc 07 00 00       	call   f01008da <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 60 06 00 00       	call   f0100756 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 40 a9 11 f0 00 	cmpl   $0x0,0xf011a940
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 40 a9 11 f0    	mov    %esi,0xf011a940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 b2 18 10 f0 	movl   $0xf01018b2,(%esp)
f010012c:	e8 a9 07 00 00       	call   f01008da <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 6a 07 00 00       	call   f01008a7 <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 ee 18 10 f0 	movl   $0xf01018ee,(%esp)
f0100144:	e8 91 07 00 00       	call   f01008da <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 01 06 00 00       	call   f0100756 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 ca 18 10 f0 	movl   $0xf01018ca,(%esp)
f0100176:	e8 5f 07 00 00       	call   f01008da <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 1d 07 00 00       	call   f01008a7 <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 ee 18 10 f0 	movl   $0xf01018ee,(%esp)
f0100191:	e8 44 07 00 00       	call   f01008da <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    

f010019c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010019f:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a4:	ec                   	in     (%dx),%al
f01001a5:	ec                   	in     (%dx),%al
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001a8:	5d                   	pop    %ebp
f01001a9:	c3                   	ret    

f01001aa <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001aa:	55                   	push   %ebp
f01001ab:	89 e5                	mov    %esp,%ebp
f01001ad:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b3:	a8 01                	test   $0x1,%al
f01001b5:	74 08                	je     f01001bf <serial_proc_data+0x15>
f01001b7:	b2 f8                	mov    $0xf8,%dl
f01001b9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ba:	0f b6 c0             	movzbl %al,%eax
f01001bd:	eb 05                	jmp    f01001c4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001c4:	5d                   	pop    %ebp
f01001c5:	c3                   	ret    

f01001c6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001c6:	55                   	push   %ebp
f01001c7:	89 e5                	mov    %esp,%ebp
f01001c9:	53                   	push   %ebx
f01001ca:	83 ec 04             	sub    $0x4,%esp
f01001cd:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001cf:	eb 29                	jmp    f01001fa <cons_intr+0x34>
		if (c == 0)
f01001d1:	85 c0                	test   %eax,%eax
f01001d3:	74 25                	je     f01001fa <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001d5:	8b 15 24 a5 11 f0    	mov    0xf011a524,%edx
f01001db:	88 82 20 a3 11 f0    	mov    %al,-0xfee5ce0(%edx)
f01001e1:	8d 42 01             	lea    0x1(%edx),%eax
f01001e4:	a3 24 a5 11 f0       	mov    %eax,0xf011a524
		if (cons.wpos == CONSBUFSIZE)
f01001e9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ee:	75 0a                	jne    f01001fa <cons_intr+0x34>
			cons.wpos = 0;
f01001f0:	c7 05 24 a5 11 f0 00 	movl   $0x0,0xf011a524
f01001f7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001fa:	ff d3                	call   *%ebx
f01001fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ff:	75 d0                	jne    f01001d1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100201:	83 c4 04             	add    $0x4,%esp
f0100204:	5b                   	pop    %ebx
f0100205:	5d                   	pop    %ebp
f0100206:	c3                   	ret    

f0100207 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100207:	55                   	push   %ebp
f0100208:	89 e5                	mov    %esp,%ebp
f010020a:	57                   	push   %edi
f010020b:	56                   	push   %esi
f010020c:	53                   	push   %ebx
f010020d:	83 ec 1c             	sub    $0x1c,%esp
f0100210:	89 c6                	mov    %eax,%esi
f0100212:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100217:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100218:	a8 20                	test   $0x20,%al
f010021a:	75 19                	jne    f0100235 <cons_putc+0x2e>
f010021c:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100221:	bf fd 03 00 00       	mov    $0x3fd,%edi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100226:	e8 71 ff ff ff       	call   f010019c <delay>
f010022b:	89 fa                	mov    %edi,%edx
f010022d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010022e:	a8 20                	test   $0x20,%al
f0100230:	75 03                	jne    f0100235 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100232:	4b                   	dec    %ebx
f0100233:	75 f1                	jne    f0100226 <cons_putc+0x1f>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100235:	89 f7                	mov    %esi,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100237:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010023c:	89 f0                	mov    %esi,%eax
f010023e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010023f:	b2 79                	mov    $0x79,%dl
f0100241:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100242:	84 c0                	test   %al,%al
f0100244:	78 17                	js     f010025d <cons_putc+0x56>
f0100246:	bb 00 32 00 00       	mov    $0x3200,%ebx
		delay();
f010024b:	e8 4c ff ff ff       	call   f010019c <delay>
f0100250:	ba 79 03 00 00       	mov    $0x379,%edx
f0100255:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100256:	84 c0                	test   %al,%al
f0100258:	78 03                	js     f010025d <cons_putc+0x56>
f010025a:	4b                   	dec    %ebx
f010025b:	75 ee                	jne    f010024b <cons_putc+0x44>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010025d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100262:	89 f8                	mov    %edi,%eax
f0100264:	ee                   	out    %al,(%dx)
f0100265:	b2 7a                	mov    $0x7a,%dl
f0100267:	b0 0d                	mov    $0xd,%al
f0100269:	ee                   	out    %al,(%dx)
f010026a:	b0 08                	mov    $0x8,%al
f010026c:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010026d:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100273:	75 06                	jne    f010027b <cons_putc+0x74>
		c |= 0x0700;
f0100275:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010027b:	89 f0                	mov    %esi,%eax
f010027d:	25 ff 00 00 00       	and    $0xff,%eax
f0100282:	83 f8 09             	cmp    $0x9,%eax
f0100285:	74 78                	je     f01002ff <cons_putc+0xf8>
f0100287:	83 f8 09             	cmp    $0x9,%eax
f010028a:	7f 0b                	jg     f0100297 <cons_putc+0x90>
f010028c:	83 f8 08             	cmp    $0x8,%eax
f010028f:	0f 85 9e 00 00 00    	jne    f0100333 <cons_putc+0x12c>
f0100295:	eb 10                	jmp    f01002a7 <cons_putc+0xa0>
f0100297:	83 f8 0a             	cmp    $0xa,%eax
f010029a:	74 39                	je     f01002d5 <cons_putc+0xce>
f010029c:	83 f8 0d             	cmp    $0xd,%eax
f010029f:	0f 85 8e 00 00 00    	jne    f0100333 <cons_putc+0x12c>
f01002a5:	eb 36                	jmp    f01002dd <cons_putc+0xd6>
	case '\b':
		if (crt_pos > 0) {
f01002a7:	66 a1 34 a5 11 f0    	mov    0xf011a534,%ax
f01002ad:	66 85 c0             	test   %ax,%ax
f01002b0:	0f 84 e2 00 00 00    	je     f0100398 <cons_putc+0x191>
			crt_pos--;
f01002b6:	48                   	dec    %eax
f01002b7:	66 a3 34 a5 11 f0    	mov    %ax,0xf011a534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002bd:	0f b7 c0             	movzwl %ax,%eax
f01002c0:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002c6:	83 ce 20             	or     $0x20,%esi
f01002c9:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
f01002cf:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002d3:	eb 78                	jmp    f010034d <cons_putc+0x146>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002d5:	66 83 05 34 a5 11 f0 	addw   $0x50,0xf011a534
f01002dc:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002dd:	66 8b 0d 34 a5 11 f0 	mov    0xf011a534,%cx
f01002e4:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002e9:	89 c8                	mov    %ecx,%eax
f01002eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01002f0:	66 f7 f3             	div    %bx
f01002f3:	66 29 d1             	sub    %dx,%cx
f01002f6:	66 89 0d 34 a5 11 f0 	mov    %cx,0xf011a534
f01002fd:	eb 4e                	jmp    f010034d <cons_putc+0x146>
		break;
	case '\t':
		cons_putc(' ');
f01002ff:	b8 20 00 00 00       	mov    $0x20,%eax
f0100304:	e8 fe fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100309:	b8 20 00 00 00       	mov    $0x20,%eax
f010030e:	e8 f4 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100313:	b8 20 00 00 00       	mov    $0x20,%eax
f0100318:	e8 ea fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010031d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100322:	e8 e0 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100327:	b8 20 00 00 00       	mov    $0x20,%eax
f010032c:	e8 d6 fe ff ff       	call   f0100207 <cons_putc>
f0100331:	eb 1a                	jmp    f010034d <cons_putc+0x146>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100333:	66 a1 34 a5 11 f0    	mov    0xf011a534,%ax
f0100339:	0f b7 c8             	movzwl %ax,%ecx
f010033c:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
f0100342:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100346:	40                   	inc    %eax
f0100347:	66 a3 34 a5 11 f0    	mov    %ax,0xf011a534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010034d:	66 81 3d 34 a5 11 f0 	cmpw   $0x7cf,0xf011a534
f0100354:	cf 07 
f0100356:	76 40                	jbe    f0100398 <cons_putc+0x191>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100358:	a1 30 a5 11 f0       	mov    0xf011a530,%eax
f010035d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100364:	00 
f0100365:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010036b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010036f:	89 04 24             	mov    %eax,(%esp)
f0100372:	e8 c2 10 00 00       	call   f0101439 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100377:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010037d:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100382:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100388:	40                   	inc    %eax
f0100389:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010038e:	75 f2                	jne    f0100382 <cons_putc+0x17b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100390:	66 83 2d 34 a5 11 f0 	subw   $0x50,0xf011a534
f0100397:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100398:	8b 0d 2c a5 11 f0    	mov    0xf011a52c,%ecx
f010039e:	b0 0e                	mov    $0xe,%al
f01003a0:	89 ca                	mov    %ecx,%edx
f01003a2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003a3:	66 8b 35 34 a5 11 f0 	mov    0xf011a534,%si
f01003aa:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003ad:	89 f0                	mov    %esi,%eax
f01003af:	66 c1 e8 08          	shr    $0x8,%ax
f01003b3:	89 da                	mov    %ebx,%edx
f01003b5:	ee                   	out    %al,(%dx)
f01003b6:	b0 0f                	mov    $0xf,%al
f01003b8:	89 ca                	mov    %ecx,%edx
f01003ba:	ee                   	out    %al,(%dx)
f01003bb:	89 f0                	mov    %esi,%eax
f01003bd:	89 da                	mov    %ebx,%edx
f01003bf:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003c0:	83 c4 1c             	add    $0x1c,%esp
f01003c3:	5b                   	pop    %ebx
f01003c4:	5e                   	pop    %esi
f01003c5:	5f                   	pop    %edi
f01003c6:	5d                   	pop    %ebp
f01003c7:	c3                   	ret    

f01003c8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003c8:	55                   	push   %ebp
f01003c9:	89 e5                	mov    %esp,%ebp
f01003cb:	53                   	push   %ebx
f01003cc:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cf:	ba 64 00 00 00       	mov    $0x64,%edx
f01003d4:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003d5:	a8 01                	test   $0x1,%al
f01003d7:	0f 84 d8 00 00 00    	je     f01004b5 <kbd_proc_data+0xed>
f01003dd:	b2 60                	mov    $0x60,%dl
f01003df:	ec                   	in     (%dx),%al
f01003e0:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003e2:	3c e0                	cmp    $0xe0,%al
f01003e4:	75 11                	jne    f01003f7 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003e6:	83 0d 28 a5 11 f0 40 	orl    $0x40,0xf011a528
		return 0;
f01003ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f2:	e9 c3 00 00 00       	jmp    f01004ba <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f01003f7:	84 c0                	test   %al,%al
f01003f9:	79 33                	jns    f010042e <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003fb:	8b 0d 28 a5 11 f0    	mov    0xf011a528,%ecx
f0100401:	f6 c1 40             	test   $0x40,%cl
f0100404:	75 05                	jne    f010040b <kbd_proc_data+0x43>
f0100406:	88 c2                	mov    %al,%dl
f0100408:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010040b:	0f b6 d2             	movzbl %dl,%edx
f010040e:	8a 82 20 19 10 f0    	mov    -0xfefe6e0(%edx),%al
f0100414:	83 c8 40             	or     $0x40,%eax
f0100417:	0f b6 c0             	movzbl %al,%eax
f010041a:	f7 d0                	not    %eax
f010041c:	21 c1                	and    %eax,%ecx
f010041e:	89 0d 28 a5 11 f0    	mov    %ecx,0xf011a528
		return 0;
f0100424:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100429:	e9 8c 00 00 00       	jmp    f01004ba <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f010042e:	8b 0d 28 a5 11 f0    	mov    0xf011a528,%ecx
f0100434:	f6 c1 40             	test   $0x40,%cl
f0100437:	74 0e                	je     f0100447 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100439:	88 c2                	mov    %al,%dl
f010043b:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010043e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100441:	89 0d 28 a5 11 f0    	mov    %ecx,0xf011a528
	}

	shift |= shiftcode[data];
f0100447:	0f b6 d2             	movzbl %dl,%edx
f010044a:	0f b6 82 20 19 10 f0 	movzbl -0xfefe6e0(%edx),%eax
f0100451:	0b 05 28 a5 11 f0    	or     0xf011a528,%eax
	shift ^= togglecode[data];
f0100457:	0f b6 8a 20 1a 10 f0 	movzbl -0xfefe5e0(%edx),%ecx
f010045e:	31 c8                	xor    %ecx,%eax
f0100460:	a3 28 a5 11 f0       	mov    %eax,0xf011a528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100465:	89 c1                	mov    %eax,%ecx
f0100467:	83 e1 03             	and    $0x3,%ecx
f010046a:	8b 0c 8d 20 1b 10 f0 	mov    -0xfefe4e0(,%ecx,4),%ecx
f0100471:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100475:	a8 08                	test   $0x8,%al
f0100477:	74 18                	je     f0100491 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100479:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010047c:	83 fa 19             	cmp    $0x19,%edx
f010047f:	77 05                	ja     f0100486 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100481:	83 eb 20             	sub    $0x20,%ebx
f0100484:	eb 0b                	jmp    f0100491 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100486:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100489:	83 fa 19             	cmp    $0x19,%edx
f010048c:	77 03                	ja     f0100491 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010048e:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100491:	f7 d0                	not    %eax
f0100493:	a8 06                	test   $0x6,%al
f0100495:	75 23                	jne    f01004ba <kbd_proc_data+0xf2>
f0100497:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010049d:	75 1b                	jne    f01004ba <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f010049f:	c7 04 24 e4 18 10 f0 	movl   $0xf01018e4,(%esp)
f01004a6:	e8 2f 04 00 00       	call   f01008da <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004ab:	ba 92 00 00 00       	mov    $0x92,%edx
f01004b0:	b0 03                	mov    $0x3,%al
f01004b2:	ee                   	out    %al,(%dx)
f01004b3:	eb 05                	jmp    f01004ba <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004b5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004ba:	89 d8                	mov    %ebx,%eax
f01004bc:	83 c4 14             	add    $0x14,%esp
f01004bf:	5b                   	pop    %ebx
f01004c0:	5d                   	pop    %ebp
f01004c1:	c3                   	ret    

f01004c2 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004c2:	55                   	push   %ebp
f01004c3:	89 e5                	mov    %esp,%ebp
f01004c5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004c8:	80 3d 00 a3 11 f0 00 	cmpb   $0x0,0xf011a300
f01004cf:	74 0a                	je     f01004db <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004d1:	b8 aa 01 10 f0       	mov    $0xf01001aa,%eax
f01004d6:	e8 eb fc ff ff       	call   f01001c6 <cons_intr>
}
f01004db:	c9                   	leave  
f01004dc:	c3                   	ret    

f01004dd <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004dd:	55                   	push   %ebp
f01004de:	89 e5                	mov    %esp,%ebp
f01004e0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004e3:	b8 c8 03 10 f0       	mov    $0xf01003c8,%eax
f01004e8:	e8 d9 fc ff ff       	call   f01001c6 <cons_intr>
}
f01004ed:	c9                   	leave  
f01004ee:	c3                   	ret    

f01004ef <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ef:	55                   	push   %ebp
f01004f0:	89 e5                	mov    %esp,%ebp
f01004f2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004f5:	e8 c8 ff ff ff       	call   f01004c2 <serial_intr>
	kbd_intr();
f01004fa:	e8 de ff ff ff       	call   f01004dd <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ff:	8b 15 20 a5 11 f0    	mov    0xf011a520,%edx
f0100505:	3b 15 24 a5 11 f0    	cmp    0xf011a524,%edx
f010050b:	74 22                	je     f010052f <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010050d:	0f b6 82 20 a3 11 f0 	movzbl -0xfee5ce0(%edx),%eax
f0100514:	42                   	inc    %edx
f0100515:	89 15 20 a5 11 f0    	mov    %edx,0xf011a520
		if (cons.rpos == CONSBUFSIZE)
f010051b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100521:	75 11                	jne    f0100534 <cons_getc+0x45>
			cons.rpos = 0;
f0100523:	c7 05 20 a5 11 f0 00 	movl   $0x0,0xf011a520
f010052a:	00 00 00 
f010052d:	eb 05                	jmp    f0100534 <cons_getc+0x45>
		return c;
	}
	return 0;
f010052f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100534:	c9                   	leave  
f0100535:	c3                   	ret    

f0100536 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100536:	55                   	push   %ebp
f0100537:	89 e5                	mov    %esp,%ebp
f0100539:	57                   	push   %edi
f010053a:	56                   	push   %esi
f010053b:	53                   	push   %ebx
f010053c:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010053f:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100546:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010054d:	5a a5 
	if (*cp != 0xA55A) {
f010054f:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100555:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100559:	74 11                	je     f010056c <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010055b:	c7 05 2c a5 11 f0 b4 	movl   $0x3b4,0xf011a52c
f0100562:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100565:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010056a:	eb 16                	jmp    f0100582 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010056c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100573:	c7 05 2c a5 11 f0 d4 	movl   $0x3d4,0xf011a52c
f010057a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010057d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100582:	8b 0d 2c a5 11 f0    	mov    0xf011a52c,%ecx
f0100588:	b0 0e                	mov    $0xe,%al
f010058a:	89 ca                	mov    %ecx,%edx
f010058c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010058d:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100590:	89 da                	mov    %ebx,%edx
f0100592:	ec                   	in     (%dx),%al
f0100593:	0f b6 f8             	movzbl %al,%edi
f0100596:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100599:	b0 0f                	mov    $0xf,%al
f010059b:	89 ca                	mov    %ecx,%edx
f010059d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010059e:	89 da                	mov    %ebx,%edx
f01005a0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005a1:	89 35 30 a5 11 f0    	mov    %esi,0xf011a530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005a7:	0f b6 d8             	movzbl %al,%ebx
f01005aa:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005ac:	66 89 3d 34 a5 11 f0 	mov    %di,0xf011a534
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b3:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005b8:	b0 00                	mov    $0x0,%al
f01005ba:	89 da                	mov    %ebx,%edx
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	b2 fb                	mov    $0xfb,%dl
f01005bf:	b0 80                	mov    $0x80,%al
f01005c1:	ee                   	out    %al,(%dx)
f01005c2:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005c7:	b0 0c                	mov    $0xc,%al
f01005c9:	89 ca                	mov    %ecx,%edx
f01005cb:	ee                   	out    %al,(%dx)
f01005cc:	b2 f9                	mov    $0xf9,%dl
f01005ce:	b0 00                	mov    $0x0,%al
f01005d0:	ee                   	out    %al,(%dx)
f01005d1:	b2 fb                	mov    $0xfb,%dl
f01005d3:	b0 03                	mov    $0x3,%al
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	b2 fc                	mov    $0xfc,%dl
f01005d8:	b0 00                	mov    $0x0,%al
f01005da:	ee                   	out    %al,(%dx)
f01005db:	b2 f9                	mov    $0xf9,%dl
f01005dd:	b0 01                	mov    $0x1,%al
f01005df:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e0:	b2 fd                	mov    $0xfd,%dl
f01005e2:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e3:	3c ff                	cmp    $0xff,%al
f01005e5:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005e9:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005ec:	a2 00 a3 11 f0       	mov    %al,0xf011a300
f01005f1:	89 da                	mov    %ebx,%edx
f01005f3:	ec                   	in     (%dx),%al
f01005f4:	89 ca                	mov    %ecx,%edx
f01005f6:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f7:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005fb:	75 0c                	jne    f0100609 <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f01005fd:	c7 04 24 f0 18 10 f0 	movl   $0xf01018f0,(%esp)
f0100604:	e8 d1 02 00 00       	call   f01008da <cprintf>
}
f0100609:	83 c4 2c             	add    $0x2c,%esp
f010060c:	5b                   	pop    %ebx
f010060d:	5e                   	pop    %esi
f010060e:	5f                   	pop    %edi
f010060f:	5d                   	pop    %ebp
f0100610:	c3                   	ret    

f0100611 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100617:	8b 45 08             	mov    0x8(%ebp),%eax
f010061a:	e8 e8 fb ff ff       	call   f0100207 <cons_putc>
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <getchar>:

int
getchar(void)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100627:	e8 c3 fe ff ff       	call   f01004ef <cons_getc>
f010062c:	85 c0                	test   %eax,%eax
f010062e:	74 f7                	je     f0100627 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <iscons>:

int
iscons(int fdnum)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100635:	b8 01 00 00 00       	mov    $0x1,%eax
f010063a:	5d                   	pop    %ebp
f010063b:	c3                   	ret    

f010063c <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010063c:	55                   	push   %ebp
f010063d:	89 e5                	mov    %esp,%ebp
f010063f:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100642:	c7 04 24 30 1b 10 f0 	movl   $0xf0101b30,(%esp)
f0100649:	e8 8c 02 00 00       	call   f01008da <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010064e:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100655:	00 
f0100656:	c7 04 24 bc 1b 10 f0 	movl   $0xf0101bbc,(%esp)
f010065d:	e8 78 02 00 00       	call   f01008da <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100662:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100669:	00 
f010066a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 e4 1b 10 f0 	movl   $0xf0101be4,(%esp)
f0100679:	e8 5c 02 00 00       	call   f01008da <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010067e:	c7 44 24 08 4e 18 10 	movl   $0x10184e,0x8(%esp)
f0100685:	00 
f0100686:	c7 44 24 04 4e 18 10 	movl   $0xf010184e,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 08 1c 10 f0 	movl   $0xf0101c08,(%esp)
f0100695:	e8 40 02 00 00       	call   f01008da <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010069a:	c7 44 24 08 00 a3 11 	movl   $0x11a300,0x8(%esp)
f01006a1:	00 
f01006a2:	c7 44 24 04 00 a3 11 	movl   $0xf011a300,0x4(%esp)
f01006a9:	f0 
f01006aa:	c7 04 24 2c 1c 10 f0 	movl   $0xf0101c2c,(%esp)
f01006b1:	e8 24 02 00 00       	call   f01008da <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006b6:	c7 44 24 08 44 a9 11 	movl   $0x11a944,0x8(%esp)
f01006bd:	00 
f01006be:	c7 44 24 04 44 a9 11 	movl   $0xf011a944,0x4(%esp)
f01006c5:	f0 
f01006c6:	c7 04 24 50 1c 10 f0 	movl   $0xf0101c50,(%esp)
f01006cd:	e8 08 02 00 00       	call   f01008da <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006d2:	b8 43 ad 11 f0       	mov    $0xf011ad43,%eax
f01006d7:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006dc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006e1:	89 c2                	mov    %eax,%edx
f01006e3:	85 c0                	test   %eax,%eax
f01006e5:	79 06                	jns    f01006ed <mon_kerninfo+0xb1>
f01006e7:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006ed:	c1 fa 0a             	sar    $0xa,%edx
f01006f0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006f4:	c7 04 24 74 1c 10 f0 	movl   $0xf0101c74,(%esp)
f01006fb:	e8 da 01 00 00       	call   f01008da <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100700:	b8 00 00 00 00       	mov    $0x0,%eax
f0100705:	c9                   	leave  
f0100706:	c3                   	ret    

f0100707 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100707:	55                   	push   %ebp
f0100708:	89 e5                	mov    %esp,%ebp
f010070a:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010070d:	c7 44 24 08 49 1b 10 	movl   $0xf0101b49,0x8(%esp)
f0100714:	f0 
f0100715:	c7 44 24 04 67 1b 10 	movl   $0xf0101b67,0x4(%esp)
f010071c:	f0 
f010071d:	c7 04 24 6c 1b 10 f0 	movl   $0xf0101b6c,(%esp)
f0100724:	e8 b1 01 00 00       	call   f01008da <cprintf>
f0100729:	c7 44 24 08 a0 1c 10 	movl   $0xf0101ca0,0x8(%esp)
f0100730:	f0 
f0100731:	c7 44 24 04 75 1b 10 	movl   $0xf0101b75,0x4(%esp)
f0100738:	f0 
f0100739:	c7 04 24 6c 1b 10 f0 	movl   $0xf0101b6c,(%esp)
f0100740:	e8 95 01 00 00       	call   f01008da <cprintf>
	return 0;
}
f0100745:	b8 00 00 00 00       	mov    $0x0,%eax
f010074a:	c9                   	leave  
f010074b:	c3                   	ret    

f010074c <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074c:	55                   	push   %ebp
f010074d:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f010074f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100754:	5d                   	pop    %ebp
f0100755:	c3                   	ret    

f0100756 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	57                   	push   %edi
f010075a:	56                   	push   %esi
f010075b:	53                   	push   %ebx
f010075c:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010075f:	c7 04 24 c8 1c 10 f0 	movl   $0xf0101cc8,(%esp)
f0100766:	e8 6f 01 00 00       	call   f01008da <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010076b:	c7 04 24 ec 1c 10 f0 	movl   $0xf0101cec,(%esp)
f0100772:	e8 63 01 00 00       	call   f01008da <cprintf>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100777:	8d 7d a8             	lea    -0x58(%ebp),%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f010077a:	c7 04 24 7e 1b 10 f0 	movl   $0xf0101b7e,(%esp)
f0100781:	e8 ca 09 00 00       	call   f0101150 <readline>
f0100786:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100788:	85 c0                	test   %eax,%eax
f010078a:	74 ee                	je     f010077a <monitor+0x24>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010078c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100793:	be 00 00 00 00       	mov    $0x0,%esi
f0100798:	eb 04                	jmp    f010079e <monitor+0x48>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010079a:	c6 03 00             	movb   $0x0,(%ebx)
f010079d:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010079e:	8a 03                	mov    (%ebx),%al
f01007a0:	84 c0                	test   %al,%al
f01007a2:	74 64                	je     f0100808 <monitor+0xb2>
f01007a4:	0f be c0             	movsbl %al,%eax
f01007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ab:	c7 04 24 82 1b 10 f0 	movl   $0xf0101b82,(%esp)
f01007b2:	e8 e7 0b 00 00       	call   f010139e <strchr>
f01007b7:	85 c0                	test   %eax,%eax
f01007b9:	75 df                	jne    f010079a <monitor+0x44>
			*buf++ = 0;
		if (*buf == 0)
f01007bb:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007be:	74 48                	je     f0100808 <monitor+0xb2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007c0:	83 fe 0f             	cmp    $0xf,%esi
f01007c3:	75 16                	jne    f01007db <monitor+0x85>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007c5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007cc:	00 
f01007cd:	c7 04 24 87 1b 10 f0 	movl   $0xf0101b87,(%esp)
f01007d4:	e8 01 01 00 00       	call   f01008da <cprintf>
f01007d9:	eb 9f                	jmp    f010077a <monitor+0x24>
			return 0;
		}
		argv[argc++] = buf;
f01007db:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007df:	46                   	inc    %esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01007e0:	8a 03                	mov    (%ebx),%al
f01007e2:	84 c0                	test   %al,%al
f01007e4:	75 09                	jne    f01007ef <monitor+0x99>
f01007e6:	eb b6                	jmp    f010079e <monitor+0x48>
			buf++;
f01007e8:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007e9:	8a 03                	mov    (%ebx),%al
f01007eb:	84 c0                	test   %al,%al
f01007ed:	74 af                	je     f010079e <monitor+0x48>
f01007ef:	0f be c0             	movsbl %al,%eax
f01007f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007f6:	c7 04 24 82 1b 10 f0 	movl   $0xf0101b82,(%esp)
f01007fd:	e8 9c 0b 00 00       	call   f010139e <strchr>
f0100802:	85 c0                	test   %eax,%eax
f0100804:	74 e2                	je     f01007e8 <monitor+0x92>
f0100806:	eb 96                	jmp    f010079e <monitor+0x48>
			buf++;
	}
	argv[argc] = 0;
f0100808:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010080f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100810:	85 f6                	test   %esi,%esi
f0100812:	0f 84 62 ff ff ff    	je     f010077a <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100818:	c7 44 24 04 67 1b 10 	movl   $0xf0101b67,0x4(%esp)
f010081f:	f0 
f0100820:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100823:	89 04 24             	mov    %eax,(%esp)
f0100826:	e8 04 0b 00 00       	call   f010132f <strcmp>
f010082b:	85 c0                	test   %eax,%eax
f010082d:	74 1b                	je     f010084a <monitor+0xf4>
f010082f:	c7 44 24 04 75 1b 10 	movl   $0xf0101b75,0x4(%esp)
f0100836:	f0 
f0100837:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010083a:	89 04 24             	mov    %eax,(%esp)
f010083d:	e8 ed 0a 00 00       	call   f010132f <strcmp>
f0100842:	85 c0                	test   %eax,%eax
f0100844:	75 2c                	jne    f0100872 <monitor+0x11c>
f0100846:	b0 01                	mov    $0x1,%al
f0100848:	eb 05                	jmp    f010084f <monitor+0xf9>
f010084a:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010084f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100852:	01 d0                	add    %edx,%eax
f0100854:	8b 55 08             	mov    0x8(%ebp),%edx
f0100857:	89 54 24 08          	mov    %edx,0x8(%esp)
f010085b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010085f:	89 34 24             	mov    %esi,(%esp)
f0100862:	ff 14 85 1c 1d 10 f0 	call   *-0xfefe2e4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100869:	85 c0                	test   %eax,%eax
f010086b:	78 1d                	js     f010088a <monitor+0x134>
f010086d:	e9 08 ff ff ff       	jmp    f010077a <monitor+0x24>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100872:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100875:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100879:	c7 04 24 a4 1b 10 f0 	movl   $0xf0101ba4,(%esp)
f0100880:	e8 55 00 00 00       	call   f01008da <cprintf>
f0100885:	e9 f0 fe ff ff       	jmp    f010077a <monitor+0x24>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010088a:	83 c4 5c             	add    $0x5c,%esp
f010088d:	5b                   	pop    %ebx
f010088e:	5e                   	pop    %esi
f010088f:	5f                   	pop    %edi
f0100890:	5d                   	pop    %ebp
f0100891:	c3                   	ret    
	...

f0100894 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100894:	55                   	push   %ebp
f0100895:	89 e5                	mov    %esp,%ebp
f0100897:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010089a:	8b 45 08             	mov    0x8(%ebp),%eax
f010089d:	89 04 24             	mov    %eax,(%esp)
f01008a0:	e8 6c fd ff ff       	call   f0100611 <cputchar>
	*cnt++;
}
f01008a5:	c9                   	leave  
f01008a6:	c3                   	ret    

f01008a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008a7:	55                   	push   %ebp
f01008a8:	89 e5                	mov    %esp,%ebp
f01008aa:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01008ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01008b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01008be:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c9:	c7 04 24 94 08 10 f0 	movl   $0xf0100894,(%esp)
f01008d0:	e8 44 04 00 00       	call   f0100d19 <vprintfmt>
	return cnt;
}
f01008d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008d8:	c9                   	leave  
f01008d9:	c3                   	ret    

f01008da <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008da:	55                   	push   %ebp
f01008db:	89 e5                	mov    %esp,%ebp
f01008dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01008ea:	89 04 24             	mov    %eax,(%esp)
f01008ed:	e8 b5 ff ff ff       	call   f01008a7 <vcprintf>
	va_end(ap);

	return cnt;
}
f01008f2:	c9                   	leave  
f01008f3:	c3                   	ret    

f01008f4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01008f4:	55                   	push   %ebp
f01008f5:	89 e5                	mov    %esp,%ebp
f01008f7:	57                   	push   %edi
f01008f8:	56                   	push   %esi
f01008f9:	53                   	push   %ebx
f01008fa:	83 ec 10             	sub    $0x10,%esp
f01008fd:	89 c3                	mov    %eax,%ebx
f01008ff:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100902:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100905:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100908:	8b 0a                	mov    (%edx),%ecx
f010090a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010090d:	8b 00                	mov    (%eax),%eax
f010090f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100912:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100919:	eb 77                	jmp    f0100992 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f010091b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010091e:	01 c8                	add    %ecx,%eax
f0100920:	bf 02 00 00 00       	mov    $0x2,%edi
f0100925:	99                   	cltd   
f0100926:	f7 ff                	idiv   %edi
f0100928:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010092a:	eb 01                	jmp    f010092d <stab_binsearch+0x39>
			m--;
f010092c:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010092d:	39 ca                	cmp    %ecx,%edx
f010092f:	7c 1d                	jl     f010094e <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100931:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100934:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100939:	39 f7                	cmp    %esi,%edi
f010093b:	75 ef                	jne    f010092c <stab_binsearch+0x38>
f010093d:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100940:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100943:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100947:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f010094a:	73 18                	jae    f0100964 <stab_binsearch+0x70>
f010094c:	eb 05                	jmp    f0100953 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010094e:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100951:	eb 3f                	jmp    f0100992 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100953:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100956:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100958:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010095b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100962:	eb 2e                	jmp    f0100992 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100964:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100967:	76 15                	jbe    f010097e <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100969:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010096c:	4f                   	dec    %edi
f010096d:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100973:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100975:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f010097c:	eb 14                	jmp    f0100992 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010097e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100981:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100984:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100986:	ff 45 0c             	incl   0xc(%ebp)
f0100989:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010098b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100992:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100995:	7e 84                	jle    f010091b <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100997:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010099b:	75 0d                	jne    f01009aa <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f010099d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009a0:	8b 02                	mov    (%edx),%eax
f01009a2:	48                   	dec    %eax
f01009a3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01009a6:	89 01                	mov    %eax,(%ecx)
f01009a8:	eb 22                	jmp    f01009cc <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01009ad:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009af:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009b2:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009b4:	eb 01                	jmp    f01009b7 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01009b6:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009b7:	39 c1                	cmp    %eax,%ecx
f01009b9:	7d 0c                	jge    f01009c7 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01009bb:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f01009be:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f01009c3:	39 f2                	cmp    %esi,%edx
f01009c5:	75 ef                	jne    f01009b6 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f01009c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009ca:	89 02                	mov    %eax,(%edx)
	}
}
f01009cc:	83 c4 10             	add    $0x10,%esp
f01009cf:	5b                   	pop    %ebx
f01009d0:	5e                   	pop    %esi
f01009d1:	5f                   	pop    %edi
f01009d2:	5d                   	pop    %ebp
f01009d3:	c3                   	ret    

f01009d4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01009d4:	55                   	push   %ebp
f01009d5:	89 e5                	mov    %esp,%ebp
f01009d7:	57                   	push   %edi
f01009d8:	56                   	push   %esi
f01009d9:	53                   	push   %ebx
f01009da:	83 ec 2c             	sub    $0x2c,%esp
f01009dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01009e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01009e3:	c7 03 2c 1d 10 f0    	movl   $0xf0101d2c,(%ebx)
	info->eip_line = 0;
f01009e9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01009f0:	c7 43 08 2c 1d 10 f0 	movl   $0xf0101d2c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01009f7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01009fe:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a01:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a08:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100a0e:	76 12                	jbe    f0100a22 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a10:	b8 22 f1 10 f0       	mov    $0xf010f122,%eax
f0100a15:	3d d1 64 10 f0       	cmp    $0xf01064d1,%eax
f0100a1a:	0f 86 92 01 00 00    	jbe    f0100bb2 <debuginfo_eip+0x1de>
f0100a20:	eb 1c                	jmp    f0100a3e <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a22:	c7 44 24 08 36 1d 10 	movl   $0xf0101d36,0x8(%esp)
f0100a29:	f0 
f0100a2a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100a31:	00 
f0100a32:	c7 04 24 43 1d 10 f0 	movl   $0xf0101d43,(%esp)
f0100a39:	e8 ba f6 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100a3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a43:	80 3d 21 f1 10 f0 00 	cmpb   $0x0,0xf010f121
f0100a4a:	0f 85 6e 01 00 00    	jne    f0100bbe <debuginfo_eip+0x1ea>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a50:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a57:	b8 d0 64 10 f0       	mov    $0xf01064d0,%eax
f0100a5c:	2d 64 1f 10 f0       	sub    $0xf0101f64,%eax
f0100a61:	c1 f8 02             	sar    $0x2,%eax
f0100a64:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100a6a:	48                   	dec    %eax
f0100a6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a6e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a72:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100a79:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a7c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a7f:	b8 64 1f 10 f0       	mov    $0xf0101f64,%eax
f0100a84:	e8 6b fe ff ff       	call   f01008f4 <stab_binsearch>
	if (lfile == 0)
f0100a89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100a91:	85 d2                	test   %edx,%edx
f0100a93:	0f 84 25 01 00 00    	je     f0100bbe <debuginfo_eip+0x1ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100a99:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100a9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100aa2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aa6:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100aad:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ab0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ab3:	b8 64 1f 10 f0       	mov    $0xf0101f64,%eax
f0100ab8:	e8 37 fe ff ff       	call   f01008f4 <stab_binsearch>

	if (lfun <= rfun) {
f0100abd:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100ac0:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100ac3:	7f 2e                	jg     f0100af3 <debuginfo_eip+0x11f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ac5:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100ac8:	8d 90 64 1f 10 f0    	lea    -0xfefe09c(%eax),%edx
f0100ace:	8b 80 64 1f 10 f0    	mov    -0xfefe09c(%eax),%eax
f0100ad4:	b9 22 f1 10 f0       	mov    $0xf010f122,%ecx
f0100ad9:	81 e9 d1 64 10 f0    	sub    $0xf01064d1,%ecx
f0100adf:	39 c8                	cmp    %ecx,%eax
f0100ae1:	73 08                	jae    f0100aeb <debuginfo_eip+0x117>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100ae3:	05 d1 64 10 f0       	add    $0xf01064d1,%eax
f0100ae8:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100aeb:	8b 42 08             	mov    0x8(%edx),%eax
f0100aee:	89 43 10             	mov    %eax,0x10(%ebx)
f0100af1:	eb 06                	jmp    f0100af9 <debuginfo_eip+0x125>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100af3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100af6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100af9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100b00:	00 
f0100b01:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b04:	89 04 24             	mov    %eax,(%esp)
f0100b07:	e8 c1 08 00 00       	call   f01013cd <strfind>
f0100b0c:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b0f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100b15:	39 d7                	cmp    %edx,%edi
f0100b17:	7c 5d                	jl     f0100b76 <debuginfo_eip+0x1a2>
	       && stabs[lline].n_type != N_SOL
f0100b19:	89 f8                	mov    %edi,%eax
f0100b1b:	6b cf 0c             	imul   $0xc,%edi,%ecx
f0100b1e:	80 b9 68 1f 10 f0 84 	cmpb   $0x84,-0xfefe098(%ecx)
f0100b25:	75 16                	jne    f0100b3d <debuginfo_eip+0x169>
f0100b27:	eb 2e                	jmp    f0100b57 <debuginfo_eip+0x183>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b29:	4f                   	dec    %edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b2a:	39 fa                	cmp    %edi,%edx
f0100b2c:	7f 48                	jg     f0100b76 <debuginfo_eip+0x1a2>
	       && stabs[lline].n_type != N_SOL
f0100b2e:	89 f8                	mov    %edi,%eax
f0100b30:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0100b33:	80 3c 8d 68 1f 10 f0 	cmpb   $0x84,-0xfefe098(,%ecx,4)
f0100b3a:	84 
f0100b3b:	74 1a                	je     f0100b57 <debuginfo_eip+0x183>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b3d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b40:	8d 04 85 64 1f 10 f0 	lea    -0xfefe09c(,%eax,4),%eax
f0100b47:	80 78 04 64          	cmpb   $0x64,0x4(%eax)
f0100b4b:	75 dc                	jne    f0100b29 <debuginfo_eip+0x155>
f0100b4d:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100b51:	74 d6                	je     f0100b29 <debuginfo_eip+0x155>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b53:	39 fa                	cmp    %edi,%edx
f0100b55:	7f 1f                	jg     f0100b76 <debuginfo_eip+0x1a2>
f0100b57:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100b5a:	8b 87 64 1f 10 f0    	mov    -0xfefe09c(%edi),%eax
f0100b60:	ba 22 f1 10 f0       	mov    $0xf010f122,%edx
f0100b65:	81 ea d1 64 10 f0    	sub    $0xf01064d1,%edx
f0100b6b:	39 d0                	cmp    %edx,%eax
f0100b6d:	73 07                	jae    f0100b76 <debuginfo_eip+0x1a2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b6f:	05 d1 64 10 f0       	add    $0xf01064d1,%eax
f0100b74:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b76:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b79:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b7c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b81:	39 ca                	cmp    %ecx,%edx
f0100b83:	7d 39                	jge    f0100bbe <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
f0100b85:	42                   	inc    %edx
f0100b86:	39 d1                	cmp    %edx,%ecx
f0100b88:	7e 34                	jle    f0100bbe <debuginfo_eip+0x1ea>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b8a:	6b f2 0c             	imul   $0xc,%edx,%esi
f0100b8d:	80 be 68 1f 10 f0 a0 	cmpb   $0xa0,-0xfefe098(%esi)
f0100b94:	75 28                	jne    f0100bbe <debuginfo_eip+0x1ea>
		     lline++)
			info->eip_fn_narg++;
f0100b96:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100b99:	42                   	inc    %edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b9a:	39 d1                	cmp    %edx,%ecx
f0100b9c:	7e 1b                	jle    f0100bb9 <debuginfo_eip+0x1e5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b9e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100ba1:	80 3c 85 68 1f 10 f0 	cmpb   $0xa0,-0xfefe098(,%eax,4)
f0100ba8:	a0 
f0100ba9:	74 eb                	je     f0100b96 <debuginfo_eip+0x1c2>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bab:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bb0:	eb 0c                	jmp    f0100bbe <debuginfo_eip+0x1ea>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100bb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb7:	eb 05                	jmp    f0100bbe <debuginfo_eip+0x1ea>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bbe:	83 c4 2c             	add    $0x2c,%esp
f0100bc1:	5b                   	pop    %ebx
f0100bc2:	5e                   	pop    %esi
f0100bc3:	5f                   	pop    %edi
f0100bc4:	5d                   	pop    %ebp
f0100bc5:	c3                   	ret    
	...

f0100bc8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bc8:	55                   	push   %ebp
f0100bc9:	89 e5                	mov    %esp,%ebp
f0100bcb:	57                   	push   %edi
f0100bcc:	56                   	push   %esi
f0100bcd:	53                   	push   %ebx
f0100bce:	83 ec 3c             	sub    $0x3c,%esp
f0100bd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100bd4:	89 d7                	mov    %edx,%edi
f0100bd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bd9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bdf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100be2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100be5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100be8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bed:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100bf0:	72 0f                	jb     f0100c01 <printnum+0x39>
f0100bf2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bf5:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100bf8:	76 07                	jbe    f0100c01 <printnum+0x39>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100bfa:	4b                   	dec    %ebx
f0100bfb:	85 db                	test   %ebx,%ebx
f0100bfd:	7f 4f                	jg     f0100c4e <printnum+0x86>
f0100bff:	eb 5a                	jmp    f0100c5b <printnum+0x93>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c01:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100c05:	4b                   	dec    %ebx
f0100c06:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100c0a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c0d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c11:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100c15:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100c19:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100c20:	00 
f0100c21:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c24:	89 04 24             	mov    %eax,(%esp)
f0100c27:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2e:	e8 cd 09 00 00       	call   f0101600 <__udivdi3>
f0100c33:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100c37:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100c3b:	89 04 24             	mov    %eax,(%esp)
f0100c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c42:	89 fa                	mov    %edi,%edx
f0100c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c47:	e8 7c ff ff ff       	call   f0100bc8 <printnum>
f0100c4c:	eb 0d                	jmp    f0100c5b <printnum+0x93>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c52:	89 34 24             	mov    %esi,(%esp)
f0100c55:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c58:	4b                   	dec    %ebx
f0100c59:	75 f3                	jne    f0100c4e <printnum+0x86>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c5b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100c63:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c66:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100c71:	00 
f0100c72:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c75:	89 04 24             	mov    %eax,(%esp)
f0100c78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7f:	e8 9c 0a 00 00       	call   f0101720 <__umoddi3>
f0100c84:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c88:	0f be 80 51 1d 10 f0 	movsbl -0xfefe2af(%eax),%eax
f0100c8f:	89 04 24             	mov    %eax,(%esp)
f0100c92:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100c95:	83 c4 3c             	add    $0x3c,%esp
f0100c98:	5b                   	pop    %ebx
f0100c99:	5e                   	pop    %esi
f0100c9a:	5f                   	pop    %edi
f0100c9b:	5d                   	pop    %ebp
f0100c9c:	c3                   	ret    

f0100c9d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100c9d:	55                   	push   %ebp
f0100c9e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100ca0:	83 fa 01             	cmp    $0x1,%edx
f0100ca3:	7e 0e                	jle    f0100cb3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100ca5:	8b 10                	mov    (%eax),%edx
f0100ca7:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100caa:	89 08                	mov    %ecx,(%eax)
f0100cac:	8b 02                	mov    (%edx),%eax
f0100cae:	8b 52 04             	mov    0x4(%edx),%edx
f0100cb1:	eb 22                	jmp    f0100cd5 <getuint+0x38>
	else if (lflag)
f0100cb3:	85 d2                	test   %edx,%edx
f0100cb5:	74 10                	je     f0100cc7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100cb7:	8b 10                	mov    (%eax),%edx
f0100cb9:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100cbc:	89 08                	mov    %ecx,(%eax)
f0100cbe:	8b 02                	mov    (%edx),%eax
f0100cc0:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cc5:	eb 0e                	jmp    f0100cd5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100cc7:	8b 10                	mov    (%eax),%edx
f0100cc9:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100ccc:	89 08                	mov    %ecx,(%eax)
f0100cce:	8b 02                	mov    (%edx),%eax
f0100cd0:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100cd5:	5d                   	pop    %ebp
f0100cd6:	c3                   	ret    

f0100cd7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100cd7:	55                   	push   %ebp
f0100cd8:	89 e5                	mov    %esp,%ebp
f0100cda:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100cdd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100ce0:	8b 10                	mov    (%eax),%edx
f0100ce2:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ce5:	73 08                	jae    f0100cef <sprintputch+0x18>
		*b->buf++ = ch;
f0100ce7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100cea:	88 0a                	mov    %cl,(%edx)
f0100cec:	42                   	inc    %edx
f0100ced:	89 10                	mov    %edx,(%eax)
}
f0100cef:	5d                   	pop    %ebp
f0100cf0:	c3                   	ret    

f0100cf1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100cf1:	55                   	push   %ebp
f0100cf2:	89 e5                	mov    %esp,%ebp
f0100cf4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100cf7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100cfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cfe:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d01:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d0f:	89 04 24             	mov    %eax,(%esp)
f0100d12:	e8 02 00 00 00       	call   f0100d19 <vprintfmt>
	va_end(ap);
}
f0100d17:	c9                   	leave  
f0100d18:	c3                   	ret    

f0100d19 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d19:	55                   	push   %ebp
f0100d1a:	89 e5                	mov    %esp,%ebp
f0100d1c:	57                   	push   %edi
f0100d1d:	56                   	push   %esi
f0100d1e:	53                   	push   %ebx
f0100d1f:	83 ec 4c             	sub    $0x4c,%esp
f0100d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d25:	8b 75 10             	mov    0x10(%ebp),%esi
f0100d28:	eb 12                	jmp    f0100d3c <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d2a:	85 c0                	test   %eax,%eax
f0100d2c:	0f 84 8e 03 00 00    	je     f01010c0 <vprintfmt+0x3a7>
				return;
			putch(ch, putdat);
f0100d32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d36:	89 04 24             	mov    %eax,(%esp)
f0100d39:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100d3c:	0f b6 06             	movzbl (%esi),%eax
f0100d3f:	46                   	inc    %esi
f0100d40:	83 f8 25             	cmp    $0x25,%eax
f0100d43:	75 e5                	jne    f0100d2a <vprintfmt+0x11>
f0100d45:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100d49:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100d50:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100d55:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100d5c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100d61:	eb 26                	jmp    f0100d89 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d63:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100d66:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100d6a:	eb 1d                	jmp    f0100d89 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100d6f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100d73:	eb 14                	jmp    f0100d89 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d75:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100d78:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d7f:	eb 08                	jmp    f0100d89 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100d81:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100d84:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d89:	0f b6 16             	movzbl (%esi),%edx
f0100d8c:	8d 46 01             	lea    0x1(%esi),%eax
f0100d8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d92:	8a 06                	mov    (%esi),%al
f0100d94:	83 e8 23             	sub    $0x23,%eax
f0100d97:	3c 55                	cmp    $0x55,%al
f0100d99:	0f 87 fd 02 00 00    	ja     f010109c <vprintfmt+0x383>
f0100d9f:	0f b6 c0             	movzbl %al,%eax
f0100da2:	ff 24 85 e0 1d 10 f0 	jmp    *-0xfefe220(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100da9:	8d 7a d0             	lea    -0x30(%edx),%edi
				ch = *fmt;
f0100dac:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0100db0:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100db3:	83 fa 09             	cmp    $0x9,%edx
f0100db6:	77 3f                	ja     f0100df7 <vprintfmt+0xde>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100db8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100dbb:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
f0100dbc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100dbf:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100dc3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100dc6:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100dc9:	83 fa 09             	cmp    $0x9,%edx
f0100dcc:	76 ed                	jbe    f0100dbb <vprintfmt+0xa2>
f0100dce:	eb 2a                	jmp    f0100dfa <vprintfmt+0xe1>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100dd0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dd3:	8d 50 04             	lea    0x4(%eax),%edx
f0100dd6:	89 55 14             	mov    %edx,0x14(%ebp)
f0100dd9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ddb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100dde:	eb 1a                	jmp    f0100dfa <vprintfmt+0xe1>

		case '.':
			if (width < 0)
f0100de0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100de4:	78 8f                	js     f0100d75 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100de6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100de9:	eb 9e                	jmp    f0100d89 <vprintfmt+0x70>
f0100deb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100dee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0100df5:	eb 92                	jmp    f0100d89 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100df7:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100dfa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100dfe:	79 89                	jns    f0100d89 <vprintfmt+0x70>
f0100e00:	e9 7c ff ff ff       	jmp    f0100d81 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e05:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e06:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100e09:	e9 7b ff ff ff       	jmp    f0100d89 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e0e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e11:	8d 50 04             	lea    0x4(%eax),%edx
f0100e14:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e1b:	8b 00                	mov    (%eax),%eax
f0100e1d:	89 04 24             	mov    %eax,(%esp)
f0100e20:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e23:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100e26:	e9 11 ff ff ff       	jmp    f0100d3c <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e2e:	8d 50 04             	lea    0x4(%eax),%edx
f0100e31:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e34:	8b 00                	mov    (%eax),%eax
f0100e36:	85 c0                	test   %eax,%eax
f0100e38:	79 02                	jns    f0100e3c <vprintfmt+0x123>
f0100e3a:	f7 d8                	neg    %eax
f0100e3c:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e3e:	83 f8 06             	cmp    $0x6,%eax
f0100e41:	7f 0b                	jg     f0100e4e <vprintfmt+0x135>
f0100e43:	8b 04 85 38 1f 10 f0 	mov    -0xfefe0c8(,%eax,4),%eax
f0100e4a:	85 c0                	test   %eax,%eax
f0100e4c:	75 23                	jne    f0100e71 <vprintfmt+0x158>
				printfmt(putch, putdat, "error %d", err);
f0100e4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e52:	c7 44 24 08 69 1d 10 	movl   $0xf0101d69,0x8(%esp)
f0100e59:	f0 
f0100e5a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e5e:	8b 55 08             	mov    0x8(%ebp),%edx
f0100e61:	89 14 24             	mov    %edx,(%esp)
f0100e64:	e8 88 fe ff ff       	call   f0100cf1 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e69:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100e6c:	e9 cb fe ff ff       	jmp    f0100d3c <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100e71:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e75:	c7 44 24 08 72 1d 10 	movl   $0xf0101d72,0x8(%esp)
f0100e7c:	f0 
f0100e7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e81:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e84:	89 04 24             	mov    %eax,(%esp)
f0100e87:	e8 65 fe ff ff       	call   f0100cf1 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e8f:	e9 a8 fe ff ff       	jmp    f0100d3c <vprintfmt+0x23>
f0100e94:	89 f9                	mov    %edi,%ecx
f0100e96:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100e99:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e9c:	8d 50 04             	lea    0x4(%eax),%edx
f0100e9f:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ea2:	8b 00                	mov    (%eax),%eax
f0100ea4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100ea7:	85 c0                	test   %eax,%eax
f0100ea9:	75 07                	jne    f0100eb2 <vprintfmt+0x199>
				p = "(null)";
f0100eab:	c7 45 d4 62 1d 10 f0 	movl   $0xf0101d62,-0x2c(%ebp)
			if (width > 0 && padc != '-')
f0100eb2:	85 f6                	test   %esi,%esi
f0100eb4:	7e 3b                	jle    f0100ef1 <vprintfmt+0x1d8>
f0100eb6:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100eba:	74 35                	je     f0100ef1 <vprintfmt+0x1d8>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ebc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ec0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100ec3:	89 14 24             	mov    %edx,(%esp)
f0100ec6:	e8 6d 03 00 00       	call   f0101238 <strnlen>
f0100ecb:	29 c6                	sub    %eax,%esi
f0100ecd:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100ed0:	85 f6                	test   %esi,%esi
f0100ed2:	7e 1d                	jle    f0100ef1 <vprintfmt+0x1d8>
					putch(padc, putdat);
f0100ed4:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0100ed8:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0100edb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ede:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ee2:	89 34 24             	mov    %esi,(%esp)
f0100ee5:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ee8:	4f                   	dec    %edi
f0100ee9:	75 f3                	jne    f0100ede <vprintfmt+0x1c5>
f0100eeb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100eee:	8b 7d d8             	mov    -0x28(%ebp),%edi
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ef1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100ef4:	0f be 02             	movsbl (%edx),%eax
f0100ef7:	85 c0                	test   %eax,%eax
f0100ef9:	75 43                	jne    f0100f3e <vprintfmt+0x225>
f0100efb:	eb 33                	jmp    f0100f30 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
f0100efd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f01:	74 18                	je     f0100f1b <vprintfmt+0x202>
f0100f03:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100f06:	83 fa 5e             	cmp    $0x5e,%edx
f0100f09:	76 10                	jbe    f0100f1b <vprintfmt+0x202>
					putch('?', putdat);
f0100f0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f0f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100f16:	ff 55 08             	call   *0x8(%ebp)
f0100f19:	eb 0a                	jmp    f0100f25 <vprintfmt+0x20c>
				else
					putch(ch, putdat);
f0100f1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f1f:	89 04 24             	mov    %eax,(%esp)
f0100f22:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f25:	ff 4d e4             	decl   -0x1c(%ebp)
f0100f28:	0f be 06             	movsbl (%esi),%eax
f0100f2b:	46                   	inc    %esi
f0100f2c:	85 c0                	test   %eax,%eax
f0100f2e:	75 12                	jne    f0100f42 <vprintfmt+0x229>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100f34:	7f 15                	jg     f0100f4b <vprintfmt+0x232>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f36:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f39:	e9 fe fd ff ff       	jmp    f0100d3c <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f3e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100f41:	46                   	inc    %esi
f0100f42:	85 ff                	test   %edi,%edi
f0100f44:	78 b7                	js     f0100efd <vprintfmt+0x1e4>
f0100f46:	4f                   	dec    %edi
f0100f47:	79 b4                	jns    f0100efd <vprintfmt+0x1e4>
f0100f49:	eb e5                	jmp    f0100f30 <vprintfmt+0x217>
f0100f4b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f4e:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100f51:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f55:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100f5c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f5e:	4e                   	dec    %esi
f0100f5f:	75 f0                	jne    f0100f51 <vprintfmt+0x238>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f61:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f64:	e9 d3 fd ff ff       	jmp    f0100d3c <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100f69:	83 f9 01             	cmp    $0x1,%ecx
f0100f6c:	7e 10                	jle    f0100f7e <vprintfmt+0x265>
		return va_arg(*ap, long long);
f0100f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f71:	8d 50 08             	lea    0x8(%eax),%edx
f0100f74:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f77:	8b 30                	mov    (%eax),%esi
f0100f79:	8b 78 04             	mov    0x4(%eax),%edi
f0100f7c:	eb 26                	jmp    f0100fa4 <vprintfmt+0x28b>
	else if (lflag)
f0100f7e:	85 c9                	test   %ecx,%ecx
f0100f80:	74 12                	je     f0100f94 <vprintfmt+0x27b>
		return va_arg(*ap, long);
f0100f82:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f85:	8d 50 04             	lea    0x4(%eax),%edx
f0100f88:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f8b:	8b 30                	mov    (%eax),%esi
f0100f8d:	89 f7                	mov    %esi,%edi
f0100f8f:	c1 ff 1f             	sar    $0x1f,%edi
f0100f92:	eb 10                	jmp    f0100fa4 <vprintfmt+0x28b>
	else
		return va_arg(*ap, int);
f0100f94:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f97:	8d 50 04             	lea    0x4(%eax),%edx
f0100f9a:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f9d:	8b 30                	mov    (%eax),%esi
f0100f9f:	89 f7                	mov    %esi,%edi
f0100fa1:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100fa4:	85 ff                	test   %edi,%edi
f0100fa6:	78 0a                	js     f0100fb2 <vprintfmt+0x299>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100fa8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fad:	e9 ac 00 00 00       	jmp    f010105e <vprintfmt+0x345>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0100fb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fb6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100fbd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0100fc0:	f7 de                	neg    %esi
f0100fc2:	83 d7 00             	adc    $0x0,%edi
f0100fc5:	f7 df                	neg    %edi
			}
			base = 10;
f0100fc7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fcc:	e9 8d 00 00 00       	jmp    f010105e <vprintfmt+0x345>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100fd1:	89 ca                	mov    %ecx,%edx
f0100fd3:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fd6:	e8 c2 fc ff ff       	call   f0100c9d <getuint>
f0100fdb:	89 c6                	mov    %eax,%esi
f0100fdd:	89 d7                	mov    %edx,%edi
			base = 10;
f0100fdf:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0100fe4:	eb 78                	jmp    f010105e <vprintfmt+0x345>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0100fe6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fea:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100ff1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0100ff4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ff8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100fff:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0101002:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101006:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010100d:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101010:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101013:	e9 24 fd ff ff       	jmp    f0100d3c <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0101018:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010101c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101023:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101026:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010102a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101031:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101034:	8b 45 14             	mov    0x14(%ebp),%eax
f0101037:	8d 50 04             	lea    0x4(%eax),%edx
f010103a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010103d:	8b 30                	mov    (%eax),%esi
f010103f:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101044:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101049:	eb 13                	jmp    f010105e <vprintfmt+0x345>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010104b:	89 ca                	mov    %ecx,%edx
f010104d:	8d 45 14             	lea    0x14(%ebp),%eax
f0101050:	e8 48 fc ff ff       	call   f0100c9d <getuint>
f0101055:	89 c6                	mov    %eax,%esi
f0101057:	89 d7                	mov    %edx,%edi
			base = 16;
f0101059:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010105e:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0101062:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101066:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101069:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010106d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101071:	89 34 24             	mov    %esi,(%esp)
f0101074:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101078:	89 da                	mov    %ebx,%edx
f010107a:	8b 45 08             	mov    0x8(%ebp),%eax
f010107d:	e8 46 fb ff ff       	call   f0100bc8 <printnum>
			break;
f0101082:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101085:	e9 b2 fc ff ff       	jmp    f0100d3c <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010108a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010108e:	89 14 24             	mov    %edx,(%esp)
f0101091:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101094:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101097:	e9 a0 fc ff ff       	jmp    f0100d3c <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010109c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010a0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01010a7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01010aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01010ae:	0f 84 88 fc ff ff    	je     f0100d3c <vprintfmt+0x23>
f01010b4:	4e                   	dec    %esi
f01010b5:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01010b9:	75 f9                	jne    f01010b4 <vprintfmt+0x39b>
f01010bb:	e9 7c fc ff ff       	jmp    f0100d3c <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01010c0:	83 c4 4c             	add    $0x4c,%esp
f01010c3:	5b                   	pop    %ebx
f01010c4:	5e                   	pop    %esi
f01010c5:	5f                   	pop    %edi
f01010c6:	5d                   	pop    %ebp
f01010c7:	c3                   	ret    

f01010c8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01010c8:	55                   	push   %ebp
f01010c9:	89 e5                	mov    %esp,%ebp
f01010cb:	83 ec 28             	sub    $0x28,%esp
f01010ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01010d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01010d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01010d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01010db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01010de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01010e5:	85 c0                	test   %eax,%eax
f01010e7:	74 30                	je     f0101119 <vsnprintf+0x51>
f01010e9:	85 d2                	test   %edx,%edx
f01010eb:	7e 33                	jle    f0101120 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01010ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010f4:	8b 45 10             	mov    0x10(%ebp),%eax
f01010f7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01010fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101102:	c7 04 24 d7 0c 10 f0 	movl   $0xf0100cd7,(%esp)
f0101109:	e8 0b fc ff ff       	call   f0100d19 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010110e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101111:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101114:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101117:	eb 0c                	jmp    f0101125 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101119:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010111e:	eb 05                	jmp    f0101125 <vsnprintf+0x5d>
f0101120:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101125:	c9                   	leave  
f0101126:	c3                   	ret    

f0101127 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101127:	55                   	push   %ebp
f0101128:	89 e5                	mov    %esp,%ebp
f010112a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010112d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101130:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101134:	8b 45 10             	mov    0x10(%ebp),%eax
f0101137:	89 44 24 08          	mov    %eax,0x8(%esp)
f010113b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010113e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101142:	8b 45 08             	mov    0x8(%ebp),%eax
f0101145:	89 04 24             	mov    %eax,(%esp)
f0101148:	e8 7b ff ff ff       	call   f01010c8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010114d:	c9                   	leave  
f010114e:	c3                   	ret    
	...

f0101150 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101150:	55                   	push   %ebp
f0101151:	89 e5                	mov    %esp,%ebp
f0101153:	57                   	push   %edi
f0101154:	56                   	push   %esi
f0101155:	53                   	push   %ebx
f0101156:	83 ec 1c             	sub    $0x1c,%esp
f0101159:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010115c:	85 c0                	test   %eax,%eax
f010115e:	74 10                	je     f0101170 <readline+0x20>
		cprintf("%s", prompt);
f0101160:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101164:	c7 04 24 72 1d 10 f0 	movl   $0xf0101d72,(%esp)
f010116b:	e8 6a f7 ff ff       	call   f01008da <cprintf>

	i = 0;
	echoing = iscons(0);
f0101170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101177:	e8 b6 f4 ff ff       	call   f0100632 <iscons>
f010117c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010117e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101183:	e8 99 f4 ff ff       	call   f0100621 <getchar>
f0101188:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010118a:	85 c0                	test   %eax,%eax
f010118c:	79 17                	jns    f01011a5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010118e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101192:	c7 04 24 54 1f 10 f0 	movl   $0xf0101f54,(%esp)
f0101199:	e8 3c f7 ff ff       	call   f01008da <cprintf>
			return NULL;
f010119e:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a3:	eb 69                	jmp    f010120e <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01011a5:	83 f8 08             	cmp    $0x8,%eax
f01011a8:	74 05                	je     f01011af <readline+0x5f>
f01011aa:	83 f8 7f             	cmp    $0x7f,%eax
f01011ad:	75 17                	jne    f01011c6 <readline+0x76>
f01011af:	85 f6                	test   %esi,%esi
f01011b1:	7e 13                	jle    f01011c6 <readline+0x76>
			if (echoing)
f01011b3:	85 ff                	test   %edi,%edi
f01011b5:	74 0c                	je     f01011c3 <readline+0x73>
				cputchar('\b');
f01011b7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01011be:	e8 4e f4 ff ff       	call   f0100611 <cputchar>
			i--;
f01011c3:	4e                   	dec    %esi
f01011c4:	eb bd                	jmp    f0101183 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01011c6:	83 fb 1f             	cmp    $0x1f,%ebx
f01011c9:	7e 1d                	jle    f01011e8 <readline+0x98>
f01011cb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01011d1:	7f 15                	jg     f01011e8 <readline+0x98>
			if (echoing)
f01011d3:	85 ff                	test   %edi,%edi
f01011d5:	74 08                	je     f01011df <readline+0x8f>
				cputchar(c);
f01011d7:	89 1c 24             	mov    %ebx,(%esp)
f01011da:	e8 32 f4 ff ff       	call   f0100611 <cputchar>
			buf[i++] = c;
f01011df:	88 9e 40 a5 11 f0    	mov    %bl,-0xfee5ac0(%esi)
f01011e5:	46                   	inc    %esi
f01011e6:	eb 9b                	jmp    f0101183 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01011e8:	83 fb 0a             	cmp    $0xa,%ebx
f01011eb:	74 05                	je     f01011f2 <readline+0xa2>
f01011ed:	83 fb 0d             	cmp    $0xd,%ebx
f01011f0:	75 91                	jne    f0101183 <readline+0x33>
			if (echoing)
f01011f2:	85 ff                	test   %edi,%edi
f01011f4:	74 0c                	je     f0101202 <readline+0xb2>
				cputchar('\n');
f01011f6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01011fd:	e8 0f f4 ff ff       	call   f0100611 <cputchar>
			buf[i] = 0;
f0101202:	c6 86 40 a5 11 f0 00 	movb   $0x0,-0xfee5ac0(%esi)
			return buf;
f0101209:	b8 40 a5 11 f0       	mov    $0xf011a540,%eax
		}
	}
}
f010120e:	83 c4 1c             	add    $0x1c,%esp
f0101211:	5b                   	pop    %ebx
f0101212:	5e                   	pop    %esi
f0101213:	5f                   	pop    %edi
f0101214:	5d                   	pop    %ebp
f0101215:	c3                   	ret    
	...

f0101218 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101218:	55                   	push   %ebp
f0101219:	89 e5                	mov    %esp,%ebp
f010121b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010121e:	80 3a 00             	cmpb   $0x0,(%edx)
f0101221:	74 0e                	je     f0101231 <strlen+0x19>
f0101223:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101228:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101229:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010122d:	75 f9                	jne    f0101228 <strlen+0x10>
f010122f:	eb 05                	jmp    f0101236 <strlen+0x1e>
f0101231:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101236:	5d                   	pop    %ebp
f0101237:	c3                   	ret    

f0101238 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101238:	55                   	push   %ebp
f0101239:	89 e5                	mov    %esp,%ebp
f010123b:	53                   	push   %ebx
f010123c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010123f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101242:	85 c9                	test   %ecx,%ecx
f0101244:	74 1a                	je     f0101260 <strnlen+0x28>
f0101246:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101249:	74 1c                	je     f0101267 <strnlen+0x2f>
f010124b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0101250:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101252:	39 ca                	cmp    %ecx,%edx
f0101254:	74 16                	je     f010126c <strnlen+0x34>
f0101256:	42                   	inc    %edx
f0101257:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f010125c:	75 f2                	jne    f0101250 <strnlen+0x18>
f010125e:	eb 0c                	jmp    f010126c <strnlen+0x34>
f0101260:	b8 00 00 00 00       	mov    $0x0,%eax
f0101265:	eb 05                	jmp    f010126c <strnlen+0x34>
f0101267:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f010126c:	5b                   	pop    %ebx
f010126d:	5d                   	pop    %ebp
f010126e:	c3                   	ret    

f010126f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010126f:	55                   	push   %ebp
f0101270:	89 e5                	mov    %esp,%ebp
f0101272:	53                   	push   %ebx
f0101273:	8b 45 08             	mov    0x8(%ebp),%eax
f0101276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101279:	ba 00 00 00 00       	mov    $0x0,%edx
f010127e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101281:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101284:	42                   	inc    %edx
f0101285:	84 c9                	test   %cl,%cl
f0101287:	75 f5                	jne    f010127e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101289:	5b                   	pop    %ebx
f010128a:	5d                   	pop    %ebp
f010128b:	c3                   	ret    

f010128c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010128c:	55                   	push   %ebp
f010128d:	89 e5                	mov    %esp,%ebp
f010128f:	53                   	push   %ebx
f0101290:	83 ec 08             	sub    $0x8,%esp
f0101293:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101296:	89 1c 24             	mov    %ebx,(%esp)
f0101299:	e8 7a ff ff ff       	call   f0101218 <strlen>
	strcpy(dst + len, src);
f010129e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012a1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012a5:	01 d8                	add    %ebx,%eax
f01012a7:	89 04 24             	mov    %eax,(%esp)
f01012aa:	e8 c0 ff ff ff       	call   f010126f <strcpy>
	return dst;
}
f01012af:	89 d8                	mov    %ebx,%eax
f01012b1:	83 c4 08             	add    $0x8,%esp
f01012b4:	5b                   	pop    %ebx
f01012b5:	5d                   	pop    %ebp
f01012b6:	c3                   	ret    

f01012b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012b7:	55                   	push   %ebp
f01012b8:	89 e5                	mov    %esp,%ebp
f01012ba:	56                   	push   %esi
f01012bb:	53                   	push   %ebx
f01012bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01012bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012c2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012c5:	85 f6                	test   %esi,%esi
f01012c7:	74 15                	je     f01012de <strncpy+0x27>
f01012c9:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01012ce:	8a 1a                	mov    (%edx),%bl
f01012d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01012d3:	80 3a 01             	cmpb   $0x1,(%edx)
f01012d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012d9:	41                   	inc    %ecx
f01012da:	39 f1                	cmp    %esi,%ecx
f01012dc:	75 f0                	jne    f01012ce <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01012de:	5b                   	pop    %ebx
f01012df:	5e                   	pop    %esi
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    

f01012e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012ee:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01012f1:	85 f6                	test   %esi,%esi
f01012f3:	74 31                	je     f0101326 <strlcpy+0x44>
		while (--size > 0 && *src != '\0')
f01012f5:	83 fe 01             	cmp    $0x1,%esi
f01012f8:	74 21                	je     f010131b <strlcpy+0x39>
f01012fa:	8a 0b                	mov    (%ebx),%cl
f01012fc:	84 c9                	test   %cl,%cl
f01012fe:	74 1f                	je     f010131f <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0101300:	83 ee 02             	sub    $0x2,%esi
f0101303:	89 f8                	mov    %edi,%eax
f0101305:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010130a:	88 08                	mov    %cl,(%eax)
f010130c:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010130d:	39 f2                	cmp    %esi,%edx
f010130f:	74 10                	je     f0101321 <strlcpy+0x3f>
f0101311:	42                   	inc    %edx
f0101312:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0101315:	84 c9                	test   %cl,%cl
f0101317:	75 f1                	jne    f010130a <strlcpy+0x28>
f0101319:	eb 06                	jmp    f0101321 <strlcpy+0x3f>
f010131b:	89 f8                	mov    %edi,%eax
f010131d:	eb 02                	jmp    f0101321 <strlcpy+0x3f>
f010131f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101321:	c6 00 00             	movb   $0x0,(%eax)
f0101324:	eb 02                	jmp    f0101328 <strlcpy+0x46>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101326:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
f0101328:	29 f8                	sub    %edi,%eax
}
f010132a:	5b                   	pop    %ebx
f010132b:	5e                   	pop    %esi
f010132c:	5f                   	pop    %edi
f010132d:	5d                   	pop    %ebp
f010132e:	c3                   	ret    

f010132f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010132f:	55                   	push   %ebp
f0101330:	89 e5                	mov    %esp,%ebp
f0101332:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101335:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101338:	8a 01                	mov    (%ecx),%al
f010133a:	84 c0                	test   %al,%al
f010133c:	74 11                	je     f010134f <strcmp+0x20>
f010133e:	3a 02                	cmp    (%edx),%al
f0101340:	75 0d                	jne    f010134f <strcmp+0x20>
		p++, q++;
f0101342:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101343:	8a 41 01             	mov    0x1(%ecx),%al
f0101346:	84 c0                	test   %al,%al
f0101348:	74 05                	je     f010134f <strcmp+0x20>
f010134a:	41                   	inc    %ecx
f010134b:	3a 02                	cmp    (%edx),%al
f010134d:	74 f3                	je     f0101342 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010134f:	0f b6 c0             	movzbl %al,%eax
f0101352:	0f b6 12             	movzbl (%edx),%edx
f0101355:	29 d0                	sub    %edx,%eax
}
f0101357:	5d                   	pop    %ebp
f0101358:	c3                   	ret    

f0101359 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101359:	55                   	push   %ebp
f010135a:	89 e5                	mov    %esp,%ebp
f010135c:	53                   	push   %ebx
f010135d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101363:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0101366:	85 c0                	test   %eax,%eax
f0101368:	74 1b                	je     f0101385 <strncmp+0x2c>
f010136a:	8a 1a                	mov    (%edx),%bl
f010136c:	84 db                	test   %bl,%bl
f010136e:	74 24                	je     f0101394 <strncmp+0x3b>
f0101370:	3a 19                	cmp    (%ecx),%bl
f0101372:	75 20                	jne    f0101394 <strncmp+0x3b>
f0101374:	48                   	dec    %eax
f0101375:	74 15                	je     f010138c <strncmp+0x33>
		n--, p++, q++;
f0101377:	42                   	inc    %edx
f0101378:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101379:	8a 1a                	mov    (%edx),%bl
f010137b:	84 db                	test   %bl,%bl
f010137d:	74 15                	je     f0101394 <strncmp+0x3b>
f010137f:	3a 19                	cmp    (%ecx),%bl
f0101381:	74 f1                	je     f0101374 <strncmp+0x1b>
f0101383:	eb 0f                	jmp    f0101394 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101385:	b8 00 00 00 00       	mov    $0x0,%eax
f010138a:	eb 05                	jmp    f0101391 <strncmp+0x38>
f010138c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101391:	5b                   	pop    %ebx
f0101392:	5d                   	pop    %ebp
f0101393:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101394:	0f b6 02             	movzbl (%edx),%eax
f0101397:	0f b6 11             	movzbl (%ecx),%edx
f010139a:	29 d0                	sub    %edx,%eax
f010139c:	eb f3                	jmp    f0101391 <strncmp+0x38>

f010139e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010139e:	55                   	push   %ebp
f010139f:	89 e5                	mov    %esp,%ebp
f01013a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013a7:	8a 10                	mov    (%eax),%dl
f01013a9:	84 d2                	test   %dl,%dl
f01013ab:	74 19                	je     f01013c6 <strchr+0x28>
		if (*s == c)
f01013ad:	38 ca                	cmp    %cl,%dl
f01013af:	75 07                	jne    f01013b8 <strchr+0x1a>
f01013b1:	eb 18                	jmp    f01013cb <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013b3:	40                   	inc    %eax
		if (*s == c)
f01013b4:	38 ca                	cmp    %cl,%dl
f01013b6:	74 13                	je     f01013cb <strchr+0x2d>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013b8:	8a 50 01             	mov    0x1(%eax),%dl
f01013bb:	84 d2                	test   %dl,%dl
f01013bd:	75 f4                	jne    f01013b3 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
f01013bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01013c4:	eb 05                	jmp    f01013cb <strchr+0x2d>
f01013c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013cb:	5d                   	pop    %ebp
f01013cc:	c3                   	ret    

f01013cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013cd:	55                   	push   %ebp
f01013ce:	89 e5                	mov    %esp,%ebp
f01013d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01013d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013d6:	8a 10                	mov    (%eax),%dl
f01013d8:	84 d2                	test   %dl,%dl
f01013da:	74 11                	je     f01013ed <strfind+0x20>
		if (*s == c)
f01013dc:	38 ca                	cmp    %cl,%dl
f01013de:	75 06                	jne    f01013e6 <strfind+0x19>
f01013e0:	eb 0b                	jmp    f01013ed <strfind+0x20>
f01013e2:	38 ca                	cmp    %cl,%dl
f01013e4:	74 07                	je     f01013ed <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01013e6:	40                   	inc    %eax
f01013e7:	8a 10                	mov    (%eax),%dl
f01013e9:	84 d2                	test   %dl,%dl
f01013eb:	75 f5                	jne    f01013e2 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
f01013ed:	5d                   	pop    %ebp
f01013ee:	c3                   	ret    

f01013ef <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013ef:	55                   	push   %ebp
f01013f0:	89 e5                	mov    %esp,%ebp
f01013f2:	57                   	push   %edi
f01013f3:	56                   	push   %esi
f01013f4:	53                   	push   %ebx
f01013f5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013fe:	85 c9                	test   %ecx,%ecx
f0101400:	74 30                	je     f0101432 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101402:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101408:	75 25                	jne    f010142f <memset+0x40>
f010140a:	f6 c1 03             	test   $0x3,%cl
f010140d:	75 20                	jne    f010142f <memset+0x40>
		c &= 0xFF;
f010140f:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101412:	89 d3                	mov    %edx,%ebx
f0101414:	c1 e3 08             	shl    $0x8,%ebx
f0101417:	89 d6                	mov    %edx,%esi
f0101419:	c1 e6 18             	shl    $0x18,%esi
f010141c:	89 d0                	mov    %edx,%eax
f010141e:	c1 e0 10             	shl    $0x10,%eax
f0101421:	09 f0                	or     %esi,%eax
f0101423:	09 d0                	or     %edx,%eax
f0101425:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101427:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010142a:	fc                   	cld    
f010142b:	f3 ab                	rep stos %eax,%es:(%edi)
f010142d:	eb 03                	jmp    f0101432 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010142f:	fc                   	cld    
f0101430:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101432:	89 f8                	mov    %edi,%eax
f0101434:	5b                   	pop    %ebx
f0101435:	5e                   	pop    %esi
f0101436:	5f                   	pop    %edi
f0101437:	5d                   	pop    %ebp
f0101438:	c3                   	ret    

f0101439 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101439:	55                   	push   %ebp
f010143a:	89 e5                	mov    %esp,%ebp
f010143c:	57                   	push   %edi
f010143d:	56                   	push   %esi
f010143e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101441:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101444:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101447:	39 c6                	cmp    %eax,%esi
f0101449:	73 34                	jae    f010147f <memmove+0x46>
f010144b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010144e:	39 d0                	cmp    %edx,%eax
f0101450:	73 2d                	jae    f010147f <memmove+0x46>
		s += n;
		d += n;
f0101452:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101455:	f6 c2 03             	test   $0x3,%dl
f0101458:	75 1b                	jne    f0101475 <memmove+0x3c>
f010145a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101460:	75 13                	jne    f0101475 <memmove+0x3c>
f0101462:	f6 c1 03             	test   $0x3,%cl
f0101465:	75 0e                	jne    f0101475 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101467:	83 ef 04             	sub    $0x4,%edi
f010146a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010146d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101470:	fd                   	std    
f0101471:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101473:	eb 07                	jmp    f010147c <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101475:	4f                   	dec    %edi
f0101476:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101479:	fd                   	std    
f010147a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010147c:	fc                   	cld    
f010147d:	eb 20                	jmp    f010149f <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010147f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101485:	75 13                	jne    f010149a <memmove+0x61>
f0101487:	a8 03                	test   $0x3,%al
f0101489:	75 0f                	jne    f010149a <memmove+0x61>
f010148b:	f6 c1 03             	test   $0x3,%cl
f010148e:	75 0a                	jne    f010149a <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101490:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101493:	89 c7                	mov    %eax,%edi
f0101495:	fc                   	cld    
f0101496:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101498:	eb 05                	jmp    f010149f <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010149a:	89 c7                	mov    %eax,%edi
f010149c:	fc                   	cld    
f010149d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010149f:	5e                   	pop    %esi
f01014a0:	5f                   	pop    %edi
f01014a1:	5d                   	pop    %ebp
f01014a2:	c3                   	ret    

f01014a3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014a3:	55                   	push   %ebp
f01014a4:	89 e5                	mov    %esp,%ebp
f01014a6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01014a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01014ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ba:	89 04 24             	mov    %eax,(%esp)
f01014bd:	e8 77 ff ff ff       	call   f0101439 <memmove>
}
f01014c2:	c9                   	leave  
f01014c3:	c3                   	ret    

f01014c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014c4:	55                   	push   %ebp
f01014c5:	89 e5                	mov    %esp,%ebp
f01014c7:	57                   	push   %edi
f01014c8:	56                   	push   %esi
f01014c9:	53                   	push   %ebx
f01014ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01014cd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014d0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014d3:	85 ff                	test   %edi,%edi
f01014d5:	74 31                	je     f0101508 <memcmp+0x44>
		if (*s1 != *s2)
f01014d7:	8a 03                	mov    (%ebx),%al
f01014d9:	8a 0e                	mov    (%esi),%cl
f01014db:	38 c8                	cmp    %cl,%al
f01014dd:	74 18                	je     f01014f7 <memcmp+0x33>
f01014df:	eb 0c                	jmp    f01014ed <memcmp+0x29>
f01014e1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
f01014e5:	42                   	inc    %edx
f01014e6:	8a 0c 16             	mov    (%esi,%edx,1),%cl
f01014e9:	38 c8                	cmp    %cl,%al
f01014eb:	74 10                	je     f01014fd <memcmp+0x39>
			return (int) *s1 - (int) *s2;
f01014ed:	0f b6 c0             	movzbl %al,%eax
f01014f0:	0f b6 c9             	movzbl %cl,%ecx
f01014f3:	29 c8                	sub    %ecx,%eax
f01014f5:	eb 16                	jmp    f010150d <memcmp+0x49>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014f7:	4f                   	dec    %edi
f01014f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01014fd:	39 fa                	cmp    %edi,%edx
f01014ff:	75 e0                	jne    f01014e1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101501:	b8 00 00 00 00       	mov    $0x0,%eax
f0101506:	eb 05                	jmp    f010150d <memcmp+0x49>
f0101508:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010150d:	5b                   	pop    %ebx
f010150e:	5e                   	pop    %esi
f010150f:	5f                   	pop    %edi
f0101510:	5d                   	pop    %ebp
f0101511:	c3                   	ret    

f0101512 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101512:	55                   	push   %ebp
f0101513:	89 e5                	mov    %esp,%ebp
f0101515:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101518:	89 c2                	mov    %eax,%edx
f010151a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010151d:	39 d0                	cmp    %edx,%eax
f010151f:	73 12                	jae    f0101533 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101521:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0101524:	38 08                	cmp    %cl,(%eax)
f0101526:	75 06                	jne    f010152e <memfind+0x1c>
f0101528:	eb 09                	jmp    f0101533 <memfind+0x21>
f010152a:	38 08                	cmp    %cl,(%eax)
f010152c:	74 05                	je     f0101533 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010152e:	40                   	inc    %eax
f010152f:	39 d0                	cmp    %edx,%eax
f0101531:	75 f7                	jne    f010152a <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101533:	5d                   	pop    %ebp
f0101534:	c3                   	ret    

f0101535 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101535:	55                   	push   %ebp
f0101536:	89 e5                	mov    %esp,%ebp
f0101538:	57                   	push   %edi
f0101539:	56                   	push   %esi
f010153a:	53                   	push   %ebx
f010153b:	8b 55 08             	mov    0x8(%ebp),%edx
f010153e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101541:	eb 01                	jmp    f0101544 <strtol+0xf>
		s++;
f0101543:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101544:	8a 02                	mov    (%edx),%al
f0101546:	3c 20                	cmp    $0x20,%al
f0101548:	74 f9                	je     f0101543 <strtol+0xe>
f010154a:	3c 09                	cmp    $0x9,%al
f010154c:	74 f5                	je     f0101543 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010154e:	3c 2b                	cmp    $0x2b,%al
f0101550:	75 08                	jne    f010155a <strtol+0x25>
		s++;
f0101552:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101553:	bf 00 00 00 00       	mov    $0x0,%edi
f0101558:	eb 13                	jmp    f010156d <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010155a:	3c 2d                	cmp    $0x2d,%al
f010155c:	75 0a                	jne    f0101568 <strtol+0x33>
		s++, neg = 1;
f010155e:	8d 52 01             	lea    0x1(%edx),%edx
f0101561:	bf 01 00 00 00       	mov    $0x1,%edi
f0101566:	eb 05                	jmp    f010156d <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101568:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010156d:	85 db                	test   %ebx,%ebx
f010156f:	74 05                	je     f0101576 <strtol+0x41>
f0101571:	83 fb 10             	cmp    $0x10,%ebx
f0101574:	75 28                	jne    f010159e <strtol+0x69>
f0101576:	8a 02                	mov    (%edx),%al
f0101578:	3c 30                	cmp    $0x30,%al
f010157a:	75 10                	jne    f010158c <strtol+0x57>
f010157c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101580:	75 0a                	jne    f010158c <strtol+0x57>
		s += 2, base = 16;
f0101582:	83 c2 02             	add    $0x2,%edx
f0101585:	bb 10 00 00 00       	mov    $0x10,%ebx
f010158a:	eb 12                	jmp    f010159e <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010158c:	85 db                	test   %ebx,%ebx
f010158e:	75 0e                	jne    f010159e <strtol+0x69>
f0101590:	3c 30                	cmp    $0x30,%al
f0101592:	75 05                	jne    f0101599 <strtol+0x64>
		s++, base = 8;
f0101594:	42                   	inc    %edx
f0101595:	b3 08                	mov    $0x8,%bl
f0101597:	eb 05                	jmp    f010159e <strtol+0x69>
	else if (base == 0)
		base = 10;
f0101599:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010159e:	b8 00 00 00 00       	mov    $0x0,%eax
f01015a3:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015a5:	8a 0a                	mov    (%edx),%cl
f01015a7:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01015aa:	80 fb 09             	cmp    $0x9,%bl
f01015ad:	77 08                	ja     f01015b7 <strtol+0x82>
			dig = *s - '0';
f01015af:	0f be c9             	movsbl %cl,%ecx
f01015b2:	83 e9 30             	sub    $0x30,%ecx
f01015b5:	eb 1e                	jmp    f01015d5 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01015b7:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01015ba:	80 fb 19             	cmp    $0x19,%bl
f01015bd:	77 08                	ja     f01015c7 <strtol+0x92>
			dig = *s - 'a' + 10;
f01015bf:	0f be c9             	movsbl %cl,%ecx
f01015c2:	83 e9 57             	sub    $0x57,%ecx
f01015c5:	eb 0e                	jmp    f01015d5 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01015c7:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01015ca:	80 fb 19             	cmp    $0x19,%bl
f01015cd:	77 12                	ja     f01015e1 <strtol+0xac>
			dig = *s - 'A' + 10;
f01015cf:	0f be c9             	movsbl %cl,%ecx
f01015d2:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01015d5:	39 f1                	cmp    %esi,%ecx
f01015d7:	7d 0c                	jge    f01015e5 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01015d9:	42                   	inc    %edx
f01015da:	0f af c6             	imul   %esi,%eax
f01015dd:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01015df:	eb c4                	jmp    f01015a5 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01015e1:	89 c1                	mov    %eax,%ecx
f01015e3:	eb 02                	jmp    f01015e7 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01015e5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01015e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015eb:	74 05                	je     f01015f2 <strtol+0xbd>
		*endptr = (char *) s;
f01015ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015f0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01015f2:	85 ff                	test   %edi,%edi
f01015f4:	74 04                	je     f01015fa <strtol+0xc5>
f01015f6:	89 c8                	mov    %ecx,%eax
f01015f8:	f7 d8                	neg    %eax
}
f01015fa:	5b                   	pop    %ebx
f01015fb:	5e                   	pop    %esi
f01015fc:	5f                   	pop    %edi
f01015fd:	5d                   	pop    %ebp
f01015fe:	c3                   	ret    
	...

f0101600 <__udivdi3>:
f0101600:	55                   	push   %ebp
f0101601:	57                   	push   %edi
f0101602:	56                   	push   %esi
f0101603:	83 ec 10             	sub    $0x10,%esp
f0101606:	8b 74 24 20          	mov    0x20(%esp),%esi
f010160a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f010160e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101612:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0101616:	89 cd                	mov    %ecx,%ebp
f0101618:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f010161c:	85 c0                	test   %eax,%eax
f010161e:	75 2c                	jne    f010164c <__udivdi3+0x4c>
f0101620:	39 f9                	cmp    %edi,%ecx
f0101622:	77 68                	ja     f010168c <__udivdi3+0x8c>
f0101624:	85 c9                	test   %ecx,%ecx
f0101626:	75 0b                	jne    f0101633 <__udivdi3+0x33>
f0101628:	b8 01 00 00 00       	mov    $0x1,%eax
f010162d:	31 d2                	xor    %edx,%edx
f010162f:	f7 f1                	div    %ecx
f0101631:	89 c1                	mov    %eax,%ecx
f0101633:	31 d2                	xor    %edx,%edx
f0101635:	89 f8                	mov    %edi,%eax
f0101637:	f7 f1                	div    %ecx
f0101639:	89 c7                	mov    %eax,%edi
f010163b:	89 f0                	mov    %esi,%eax
f010163d:	f7 f1                	div    %ecx
f010163f:	89 c6                	mov    %eax,%esi
f0101641:	89 f0                	mov    %esi,%eax
f0101643:	89 fa                	mov    %edi,%edx
f0101645:	83 c4 10             	add    $0x10,%esp
f0101648:	5e                   	pop    %esi
f0101649:	5f                   	pop    %edi
f010164a:	5d                   	pop    %ebp
f010164b:	c3                   	ret    
f010164c:	39 f8                	cmp    %edi,%eax
f010164e:	77 2c                	ja     f010167c <__udivdi3+0x7c>
f0101650:	0f bd f0             	bsr    %eax,%esi
f0101653:	83 f6 1f             	xor    $0x1f,%esi
f0101656:	75 4c                	jne    f01016a4 <__udivdi3+0xa4>
f0101658:	39 f8                	cmp    %edi,%eax
f010165a:	bf 00 00 00 00       	mov    $0x0,%edi
f010165f:	72 0a                	jb     f010166b <__udivdi3+0x6b>
f0101661:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0101665:	0f 87 ad 00 00 00    	ja     f0101718 <__udivdi3+0x118>
f010166b:	be 01 00 00 00       	mov    $0x1,%esi
f0101670:	89 f0                	mov    %esi,%eax
f0101672:	89 fa                	mov    %edi,%edx
f0101674:	83 c4 10             	add    $0x10,%esp
f0101677:	5e                   	pop    %esi
f0101678:	5f                   	pop    %edi
f0101679:	5d                   	pop    %ebp
f010167a:	c3                   	ret    
f010167b:	90                   	nop
f010167c:	31 ff                	xor    %edi,%edi
f010167e:	31 f6                	xor    %esi,%esi
f0101680:	89 f0                	mov    %esi,%eax
f0101682:	89 fa                	mov    %edi,%edx
f0101684:	83 c4 10             	add    $0x10,%esp
f0101687:	5e                   	pop    %esi
f0101688:	5f                   	pop    %edi
f0101689:	5d                   	pop    %ebp
f010168a:	c3                   	ret    
f010168b:	90                   	nop
f010168c:	89 fa                	mov    %edi,%edx
f010168e:	89 f0                	mov    %esi,%eax
f0101690:	f7 f1                	div    %ecx
f0101692:	89 c6                	mov    %eax,%esi
f0101694:	31 ff                	xor    %edi,%edi
f0101696:	89 f0                	mov    %esi,%eax
f0101698:	89 fa                	mov    %edi,%edx
f010169a:	83 c4 10             	add    $0x10,%esp
f010169d:	5e                   	pop    %esi
f010169e:	5f                   	pop    %edi
f010169f:	5d                   	pop    %ebp
f01016a0:	c3                   	ret    
f01016a1:	8d 76 00             	lea    0x0(%esi),%esi
f01016a4:	89 f1                	mov    %esi,%ecx
f01016a6:	d3 e0                	shl    %cl,%eax
f01016a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016ac:	b8 20 00 00 00       	mov    $0x20,%eax
f01016b1:	29 f0                	sub    %esi,%eax
f01016b3:	89 ea                	mov    %ebp,%edx
f01016b5:	88 c1                	mov    %al,%cl
f01016b7:	d3 ea                	shr    %cl,%edx
f01016b9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01016bd:	09 ca                	or     %ecx,%edx
f01016bf:	89 54 24 08          	mov    %edx,0x8(%esp)
f01016c3:	89 f1                	mov    %esi,%ecx
f01016c5:	d3 e5                	shl    %cl,%ebp
f01016c7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f01016cb:	89 fd                	mov    %edi,%ebp
f01016cd:	88 c1                	mov    %al,%cl
f01016cf:	d3 ed                	shr    %cl,%ebp
f01016d1:	89 fa                	mov    %edi,%edx
f01016d3:	89 f1                	mov    %esi,%ecx
f01016d5:	d3 e2                	shl    %cl,%edx
f01016d7:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01016db:	88 c1                	mov    %al,%cl
f01016dd:	d3 ef                	shr    %cl,%edi
f01016df:	09 d7                	or     %edx,%edi
f01016e1:	89 f8                	mov    %edi,%eax
f01016e3:	89 ea                	mov    %ebp,%edx
f01016e5:	f7 74 24 08          	divl   0x8(%esp)
f01016e9:	89 d1                	mov    %edx,%ecx
f01016eb:	89 c7                	mov    %eax,%edi
f01016ed:	f7 64 24 0c          	mull   0xc(%esp)
f01016f1:	39 d1                	cmp    %edx,%ecx
f01016f3:	72 17                	jb     f010170c <__udivdi3+0x10c>
f01016f5:	74 09                	je     f0101700 <__udivdi3+0x100>
f01016f7:	89 fe                	mov    %edi,%esi
f01016f9:	31 ff                	xor    %edi,%edi
f01016fb:	e9 41 ff ff ff       	jmp    f0101641 <__udivdi3+0x41>
f0101700:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101704:	89 f1                	mov    %esi,%ecx
f0101706:	d3 e2                	shl    %cl,%edx
f0101708:	39 c2                	cmp    %eax,%edx
f010170a:	73 eb                	jae    f01016f7 <__udivdi3+0xf7>
f010170c:	8d 77 ff             	lea    -0x1(%edi),%esi
f010170f:	31 ff                	xor    %edi,%edi
f0101711:	e9 2b ff ff ff       	jmp    f0101641 <__udivdi3+0x41>
f0101716:	66 90                	xchg   %ax,%ax
f0101718:	31 f6                	xor    %esi,%esi
f010171a:	e9 22 ff ff ff       	jmp    f0101641 <__udivdi3+0x41>
	...

f0101720 <__umoddi3>:
f0101720:	55                   	push   %ebp
f0101721:	57                   	push   %edi
f0101722:	56                   	push   %esi
f0101723:	83 ec 20             	sub    $0x20,%esp
f0101726:	8b 44 24 30          	mov    0x30(%esp),%eax
f010172a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f010172e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0101732:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101736:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010173a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010173e:	89 c7                	mov    %eax,%edi
f0101740:	89 f2                	mov    %esi,%edx
f0101742:	85 ed                	test   %ebp,%ebp
f0101744:	75 16                	jne    f010175c <__umoddi3+0x3c>
f0101746:	39 f1                	cmp    %esi,%ecx
f0101748:	0f 86 a6 00 00 00    	jbe    f01017f4 <__umoddi3+0xd4>
f010174e:	f7 f1                	div    %ecx
f0101750:	89 d0                	mov    %edx,%eax
f0101752:	31 d2                	xor    %edx,%edx
f0101754:	83 c4 20             	add    $0x20,%esp
f0101757:	5e                   	pop    %esi
f0101758:	5f                   	pop    %edi
f0101759:	5d                   	pop    %ebp
f010175a:	c3                   	ret    
f010175b:	90                   	nop
f010175c:	39 f5                	cmp    %esi,%ebp
f010175e:	0f 87 ac 00 00 00    	ja     f0101810 <__umoddi3+0xf0>
f0101764:	0f bd c5             	bsr    %ebp,%eax
f0101767:	83 f0 1f             	xor    $0x1f,%eax
f010176a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010176e:	0f 84 a8 00 00 00    	je     f010181c <__umoddi3+0xfc>
f0101774:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101778:	d3 e5                	shl    %cl,%ebp
f010177a:	bf 20 00 00 00       	mov    $0x20,%edi
f010177f:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0101783:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101787:	89 f9                	mov    %edi,%ecx
f0101789:	d3 e8                	shr    %cl,%eax
f010178b:	09 e8                	or     %ebp,%eax
f010178d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0101791:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101795:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0101799:	d3 e0                	shl    %cl,%eax
f010179b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010179f:	89 f2                	mov    %esi,%edx
f01017a1:	d3 e2                	shl    %cl,%edx
f01017a3:	8b 44 24 14          	mov    0x14(%esp),%eax
f01017a7:	d3 e0                	shl    %cl,%eax
f01017a9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01017ad:	8b 44 24 14          	mov    0x14(%esp),%eax
f01017b1:	89 f9                	mov    %edi,%ecx
f01017b3:	d3 e8                	shr    %cl,%eax
f01017b5:	09 d0                	or     %edx,%eax
f01017b7:	d3 ee                	shr    %cl,%esi
f01017b9:	89 f2                	mov    %esi,%edx
f01017bb:	f7 74 24 18          	divl   0x18(%esp)
f01017bf:	89 d6                	mov    %edx,%esi
f01017c1:	f7 64 24 0c          	mull   0xc(%esp)
f01017c5:	89 c5                	mov    %eax,%ebp
f01017c7:	89 d1                	mov    %edx,%ecx
f01017c9:	39 d6                	cmp    %edx,%esi
f01017cb:	72 67                	jb     f0101834 <__umoddi3+0x114>
f01017cd:	74 75                	je     f0101844 <__umoddi3+0x124>
f01017cf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01017d3:	29 e8                	sub    %ebp,%eax
f01017d5:	19 ce                	sbb    %ecx,%esi
f01017d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01017db:	d3 e8                	shr    %cl,%eax
f01017dd:	89 f2                	mov    %esi,%edx
f01017df:	89 f9                	mov    %edi,%ecx
f01017e1:	d3 e2                	shl    %cl,%edx
f01017e3:	09 d0                	or     %edx,%eax
f01017e5:	89 f2                	mov    %esi,%edx
f01017e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01017eb:	d3 ea                	shr    %cl,%edx
f01017ed:	83 c4 20             	add    $0x20,%esp
f01017f0:	5e                   	pop    %esi
f01017f1:	5f                   	pop    %edi
f01017f2:	5d                   	pop    %ebp
f01017f3:	c3                   	ret    
f01017f4:	85 c9                	test   %ecx,%ecx
f01017f6:	75 0b                	jne    f0101803 <__umoddi3+0xe3>
f01017f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01017fd:	31 d2                	xor    %edx,%edx
f01017ff:	f7 f1                	div    %ecx
f0101801:	89 c1                	mov    %eax,%ecx
f0101803:	89 f0                	mov    %esi,%eax
f0101805:	31 d2                	xor    %edx,%edx
f0101807:	f7 f1                	div    %ecx
f0101809:	89 f8                	mov    %edi,%eax
f010180b:	e9 3e ff ff ff       	jmp    f010174e <__umoddi3+0x2e>
f0101810:	89 f2                	mov    %esi,%edx
f0101812:	83 c4 20             	add    $0x20,%esp
f0101815:	5e                   	pop    %esi
f0101816:	5f                   	pop    %edi
f0101817:	5d                   	pop    %ebp
f0101818:	c3                   	ret    
f0101819:	8d 76 00             	lea    0x0(%esi),%esi
f010181c:	39 f5                	cmp    %esi,%ebp
f010181e:	72 04                	jb     f0101824 <__umoddi3+0x104>
f0101820:	39 f9                	cmp    %edi,%ecx
f0101822:	77 06                	ja     f010182a <__umoddi3+0x10a>
f0101824:	89 f2                	mov    %esi,%edx
f0101826:	29 cf                	sub    %ecx,%edi
f0101828:	19 ea                	sbb    %ebp,%edx
f010182a:	89 f8                	mov    %edi,%eax
f010182c:	83 c4 20             	add    $0x20,%esp
f010182f:	5e                   	pop    %esi
f0101830:	5f                   	pop    %edi
f0101831:	5d                   	pop    %ebp
f0101832:	c3                   	ret    
f0101833:	90                   	nop
f0101834:	89 d1                	mov    %edx,%ecx
f0101836:	89 c5                	mov    %eax,%ebp
f0101838:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f010183c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0101840:	eb 8d                	jmp    f01017cf <__umoddi3+0xaf>
f0101842:	66 90                	xchg   %ax,%ax
f0101844:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0101848:	72 ea                	jb     f0101834 <__umoddi3+0x114>
f010184a:	89 f1                	mov    %esi,%ecx
f010184c:	eb 81                	jmp    f01017cf <__umoddi3+0xaf>
