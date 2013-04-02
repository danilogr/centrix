//
// Este arquivo faz parte do sistema operacional Centrix
// -> Não utilize sem permissão
// -> Você não tem direitos de modificar !
// 

//
// IRQ
//

#include <sysutils.h>
#include <idt.h>
#include <irq.h>      
                 

// Declaracao das rotinas das IRQs

extern void _irq0();
extern void _irq1();
extern void _irq2();
extern void _irq3();
extern void _irq4();
extern void _irq5();
extern void _irq6();
extern void _irq7();
extern void _irq8();
extern void _irq9();
extern void _irq10();
extern void _irq11();
extern void _irq12();
extern void _irq13();
extern void _irq14();
extern void _irq15();

// Variaveis de controle

void *irq_rot[16];                       //rotinas de controle das 16 IRQs



// Rotina de instalacao das IRQs

void irq_instala(){
 
    //remapeia as IRQs    
    outportb(0x20, 0x11);
    outportb(0xA0, 0x11);
    outportb(0x21, 0x20);                //endereco IDT inicial das IRQs 0..7
    outportb(0xA1, 0x28);                //endereco IDT inicial das IRQs 8..15
    outportb(0x21, 0x04);
    outportb(0xA1, 0x02);
    outportb(0x21, 0x01);
    outportb(0xA1, 0x01);
    outportb(0x21, 0x0);
    outportb(0xA1, 0x0);
    
    //instalacao na IDT
    
    idt_adiciona(  32, 0x08, (unsigned) _irq0, 0x8E);   
    idt_adiciona(  33, 0x08, (unsigned) _irq1, 0x8E);   
    idt_adiciona(  34, 0x08, (unsigned) _irq2, 0x8E);   
    idt_adiciona(  35, 0x08, (unsigned) _irq3, 0x8E);   
    idt_adiciona(  36, 0x08, (unsigned) _irq4, 0x8E);   
    idt_adiciona(  37, 0x08, (unsigned) _irq5, 0x8E);   
    idt_adiciona(  38, 0x08, (unsigned) _irq6, 0x8E);   
    idt_adiciona(  39, 0x08, (unsigned) _irq7, 0x8E);   
    
    idt_adiciona(  40, 0x08, (unsigned) _irq8, 0x8E);   
    idt_adiciona(  41, 0x08, (unsigned) _irq9, 0x8E);   
    idt_adiciona(  42, 0x08, (unsigned) _irq10, 0x8E);   
    idt_adiciona(  43, 0x08, (unsigned) _irq11, 0x8E);   
    idt_adiciona(  44, 0x08, (unsigned) _irq12, 0x8E);   
    idt_adiciona(  45, 0x08, (unsigned) _irq13, 0x8E);   
    idt_adiciona(  46, 0x08, (unsigned) _irq14, 0x8E);   
    idt_adiciona(  47, 0x08, (unsigned) _irq15, 0x8E);           
    
    //limpando irq_rot[]  ( NAO MAIS NECESSARIO JA QUE AS VARIAVEIS SAO INICIADAS COM 0 )
    //memsetb(&irq_rot, 0x00, sizeof(void) * 16);                  //inicializa as irqs
    
    // ativando as interrupções
    //    __asm__ __volatile__ ("sti");

}



//
// Rotina de controle
//

void _irqs_hwnd( struct stackmap2 *regs) {

  void (*irqhwnd) (struct stackmap2 *regs);   //declaracao de um ponteiro para uma funcao
     
  irqhwnd = irq_rot[regs->irq_no];            //define o hwnd da irq
  
  if (irqhwnd) {                              // se tiver alguma funcao relacionada a ele

      irqhwnd(regs);                         //chama a funcao         
               
  }
  
   if (regs->irq_no >= 8)                    //se for uma irq maior que 8
    {
        outportb(0xA0, 0x20);                //entao como terminou a sua execução envia o FimDeInterrupcao para o CHIP slave
    }

    outportb(0x20, 0x20);                   //de qualquer jeito envia para o chip master
     
}


//
// Rotinas p/ registrar/desregistrar IRQ
//

void irq_registra(char irqn ,void (*irqhwnd) (struct stackmap2 *regs)) {
     
 irq_rot[irqn] = irqhwnd;
     
}

void irq_desregistra(char irqn) {
     
 irq_rot[irqn] = 0;
     
}
