#ifndef _IRQ_H_
#define _IRQ_H_

//
// Cabe�alho do arquivo irq.c
// Contem as funcoes para registrar e gerenciar IRQs

struct stackmap2 {                    //mapa da pilha no momento em que ocorre a interrup��o da irq
       
    unsigned int cr2, gs, fs, es, ds;                     /* registradores passados por ultimo */
    unsigned int edi, esi, ebp, esp, ebx, edx, ecx, eax;  /* registradores passados por "pusha" */
    unsigned int irq_no;                                  /* numero da irq  */
    unsigned int eip, cs, eflags, useresp, ss;            /* passados pela CPU automaticamente */ 
       
};

extern void irq_instala();
extern void irq_registra(char irqn ,void (*irqhwnd) (struct stackmap2 *regs));
extern void irq_desregistra(char irqn);


#endif 
