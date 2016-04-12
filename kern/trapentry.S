/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(divide_trap, T_DIVIDE)
	TRAPHANDLER_NOEC(debug_trap, T_DEBUG)
	TRAPHANDLER_NOEC(nmi_trap, T_NMI)
	TRAPHANDLER_NOEC(brkpt_trap, T_BRKPT)
	TRAPHANDLER_NOEC(oflow_trap, T_OFLOW)
	TRAPHANDLER_NOEC(bound_trap, T_BOUND)
	TRAPHANDLER_NOEC(illop_trap, T_ILLOP)
	TRAPHANDLER_NOEC(device_trap, T_DEVICE)
	TRAPHANDLER(dblflt_trap, T_DBLFLT)
	TRAPHANDLER(tss_trap, T_TSS)
	TRAPHANDLER(segnp_trap, T_SEGNP)
	TRAPHANDLER(stack_trap, T_STACK)
	TRAPHANDLER(gpflt_trap, T_GPFLT)
	TRAPHANDLER(pgflt_trap, T_PGFLT)
	TRAPHANDLER_NOEC(fperr_trap, T_FPERR)
	TRAPHANDLER(align_trap, T_ALIGN)
	TRAPHANDLER_NOEC(mchk_trap, T_MCHK)
	TRAPHANDLER_NOEC(simderr_trap, T_SIMDERR)
	TRAPHANDLER_NOEC(syscall_intr, T_SYSCALL)


/*
 * Lab 3: Your code here for _alltraps
 */

//The sequence for command pushal: %eax->%ecx->%edx->%ebx->%esp->%ebp->%esi->%edi
//The sequence for command popal: reverse the sequence of command pushal
//The sequence for command iret: %ip->%cs->%flags (if the return is to another privilege level) ->%esp->%ss 
//struct PushRegs {
//	/* registers as pushed by pusha */
//	uint32_t reg_edi;
//	uint32_t reg_esi;
//	uint32_t reg_ebp;
//	uint32_t reg_oesp;		/* Useless */
//	uint32_t reg_ebx;
//	uint32_t reg_edx;
//	uint32_t reg_ecx;
//	uint32_t reg_eax;
//} __attribute__((packed));
//
//struct Trapframe {
//	struct PushRegs tf_regs;
//	uint16_t tf_es;
//	uint16_t tf_padding1;
//	uint16_t tf_ds;
//	uint16_t tf_padding2;
//	uint32_t tf_trapno;
//	/* below here defined by x86 hardware */
//	uint32_t tf_err;
//	uintptr_t tf_eip;
//	uint16_t tf_cs;
//	uint16_t tf_padding3;
//	uint32_t tf_eflags;
//	/* below here only when crossing rings, such as from user to kernel */
//	uintptr_t tf_esp;
//	uint16_t tf_ss;
//	uint16_t tf_padding4;
//} __attribute__((packed));

_alltraps:
	pushw	$0x00
	pushw	%ds
	pushw	$0x00
	pushw	%es
	pushal

	movl	$GD_KD, %eax

	movw	%ax, %ds
	movw	%ax, %es

	pushl	%esp

	call 	trap

