//
// Este arquivo faz parte do sistema operacional Centrix
// -> Não utilize sem permissão
// -> Você não tem direitos de modificar !
// 

//
// ISRs
//

#include <sysutils.h>
#include <idt.h>
#include <isrs.h>
#include <vga.h>

//
// Isrs declaradas em "isrs.asm"
//

extern void _isr0();
extern void _isr1();
extern void _isr2();
extern void _isr3();
extern void _isr4();
extern void _isr5();
extern void _isr6();
extern void _isr7();
extern void _isr8();
extern void _isr9();
extern void _isr10();
extern void _isr11();
extern void _isr12();
extern void _isr13();
extern void _isr14();
extern void _isr15();
extern void _isr16();
extern void _isr17();
extern void _isr18();
extern void _isr19();
extern void _isr20();
extern void _isr21();
extern void _isr22();
extern void _isr23();
extern void _isr24();
extern void _isr25();
extern void _isr26();
extern void _isr27();
extern void _isr28();
extern void _isr29();
extern void _isr30();
extern void _isr31();

//
// Configuracao das isrs
//

void isrs_cnfg() {
 //           pos  seg        offset       flags
 // seg = 0x08 ( segmento de codigo da kernel )
idt_adiciona(  0, 0x08, (unsigned) _isr0, 0x8E);    
idt_adiciona(  1, 0x08, (unsigned) _isr1, 0x8E);    
idt_adiciona(  2, 0x08, (unsigned) _isr2, 0x8E);    
idt_adiciona(  3, 0x08, (unsigned) _isr3, 0x8E);    
idt_adiciona(  4, 0x08, (unsigned) _isr4, 0x8E);    
idt_adiciona(  5, 0x08, (unsigned) _isr5, 0x8E);    
idt_adiciona(  6, 0x08, (unsigned) _isr6, 0x8E);    
idt_adiciona(  7, 0x08, (unsigned) _isr7, 0x8E);    
idt_adiciona(  8, 0x08, (unsigned) _isr8, 0x8E);    
idt_adiciona(  9, 0x08, (unsigned) _isr9, 0x8E);    
idt_adiciona( 10, 0x08, (unsigned) _isr10, 0x8E);    
idt_adiciona( 11, 0x08, (unsigned) _isr11, 0x8E);    
idt_adiciona( 12, 0x08, (unsigned) _isr12, 0x8E);    
idt_adiciona( 13, 0x08, (unsigned) _isr13, 0x8E);    
idt_adiciona( 14, 0x08, (unsigned) _isr14, 0x8E);    
idt_adiciona( 15, 0x08, (unsigned) _isr15, 0x8E);    
idt_adiciona( 16, 0x08, (unsigned) _isr16, 0x8E);    
idt_adiciona( 17, 0x08, (unsigned) _isr17, 0x8E);    
idt_adiciona( 18, 0x08, (unsigned) _isr18, 0x8E);    
idt_adiciona( 19, 0x08, (unsigned) _isr19, 0x8E);    
idt_adiciona( 20, 0x08, (unsigned) _isr20, 0x8E);    
idt_adiciona( 21, 0x08, (unsigned) _isr21, 0x8E);    
idt_adiciona( 22, 0x08, (unsigned) _isr22, 0x8E);    
idt_adiciona( 23, 0x08, (unsigned) _isr23, 0x8E);    
idt_adiciona( 24, 0x08, (unsigned) _isr24, 0x8E);    
idt_adiciona( 25, 0x08, (unsigned) _isr25, 0x8E);    
idt_adiciona( 26, 0x08, (unsigned) _isr26, 0x8E);    
idt_adiciona( 27, 0x08, (unsigned) _isr27, 0x8E);    
idt_adiciona( 28, 0x08, (unsigned) _isr28, 0x8E);    
idt_adiciona( 29, 0x08, (unsigned) _isr29, 0x8E);    
idt_adiciona( 30, 0x08, (unsigned) _isr30, 0x8E);    
idt_adiciona( 31, 0x08, (unsigned) _isr31, 0x8E);    

}

//
// mensagens de erro ( de acordo com a interrupção
//

char *_isrs_msgs[] = {
         
	 "Divisao por zero",
	 "Debug Exception",
	 "Non Maskable Interrupt Exception",
	 "Breakpoint Exception",      
	 "Into Detected Overflow Exception",
	 "Out of Bounds Exception",
	 "Invalid Opcode Exception",
	 "No Coprocessor Exception",
	 "Double Fault Exception",
	 "Coprocessor Segment Overrun Exception",
	 "Bad TSS Exception",
	 "Segment Not Present Exception",
	 "Stack Fault Exception",
	 "General Protection Fault Exception",
	 "Page Fault Exception",
	 "Unknown Interrupt Exception",
	 "Coprocessor Fault Exception",
	 "Alignment Check Exception (486+)",
	 "Machine Check Exception (Pentium/586+)",
	 "Erro desconhecido!"
	 
  };
	 
    
     


//
// handler universal das isrs
//

void _isrs_hwnd( struct stackmap *regs ) {

 if ((regs->int_no >= 0 ) && (regs->int_no <= 18)) {      

  vga_gotoxy(vga_rect(0,6,80,19,0x40));
  kprint("\n\n");
  vga_setcolor(0x4E);							//coloca fundo vermelho
  kprint("                                  ERRO FATAL\n");		//meio que centraliza xD
  kprint(" Erro => ");
  kprint(_isrs_msgs[regs->int_no]); 		 	//coloca a mensagem de erro
  kprint(" ( ");
  vga_hexword(regs->int_no,8);
  kprint(" - ");
  vga_hexword(regs->err_code,8);
  kprint(" ) ");
  kprint("\n\n");
  
  vga_setcolor(0x4E);	
  kprint(" EAX: ");
  vga_setcolor(0x40);	
  vga_hexword(regs->eax,8);
  
  vga_setcolor(0x4E);
  kprint("      EBX: ");
  vga_setcolor(0x40);
  vga_hexword(regs->ebx,8);

  vga_setcolor(0x4E);
  kprint("      ECX: ");
  vga_setcolor(0x40);
  vga_hexword(regs->ecx,8);

  vga_setcolor(0x4E);
  kprint("      EDX: ");
  vga_setcolor(0x40);
  vga_hexword(regs->edx,8);

   //===========================//
  kprint("\n");
  vga_setcolor(0x4E);	
  kprint(" EDI: ");
  vga_setcolor(0x40);	
  vga_hexword(regs->edi,8);
  
  vga_setcolor(0x4E);
  kprint("      ESI: ");
  vga_setcolor(0x40);
  vga_hexword(regs->esi,8);

  vga_setcolor(0x4E);
  kprint("      EBP: ");
  vga_setcolor(0x40);
  vga_hexword(regs->ebp,8);

  vga_setcolor(0x4E);
  kprint("      ESP: ");
  vga_setcolor(0x40);
  vga_hexword(regs->esp,8);

   //===========================//
  kprint("\n");
  vga_setcolor(0x4E);	
  kprint("  GS: ");
  vga_setcolor(0x40);	
  vga_hexword(regs->gs,8);
  
  vga_setcolor(0x4E);
  kprint("       FS: ");
  vga_setcolor(0x40);
  vga_hexword(regs->fs,8);

  vga_setcolor(0x4E);
  kprint("       ES: ");
  vga_setcolor(0x40);
  vga_hexword(regs->es,8);
   
  vga_setcolor(0x4E);
  kprint("       DS: ");
  vga_setcolor(0x40);
  vga_hexword(regs->ds,8);

  //===========================//

  kprint("\n");
  vga_setcolor(0x4E);	
  kprint("  CS: ");
  vga_setcolor(0x40);	
  vga_hexword(regs->cs,8);
  
  vga_setcolor(0x4E);
  kprint("       SS: ");
  vga_setcolor(0x40);
  vga_hexword(regs->ss,8);
   
  vga_setcolor(0x4E);
  kprint("      EIP: ");
  vga_setcolor(0x40);
  vga_hexword(regs->eip,8);

  //===========================//

  kprint("\n");
  vga_setcolor(0x4E);
  kprint(" Eflags: ");
  vga_setcolor(0x40);
  vga_hexword(regs->eflags,8);

  vga_setcolor(0x4E);
  kprint("  Useresp: ");
  vga_setcolor(0x40);
  vga_hexword(regs->useresp,8);

  vga_setcolor(0x4E);
  kprint("  CR2: ");
  vga_setcolor(0x40);
  vga_hexword(regs->cr2,8);

  //vga_setcolor(0x04);                  
  //kprint("\n[Erro Fatal] - ");
  //kprint(_isrs_msgs[regs->int_no]);
                   
 } else if ((regs->int_no >= 19 ) && (regs->int_no <= 31)) {
        
  vga_setcolor(0x04);                  
  kprint("\n[Erro Fatal] - Erro desconhecido. Pane no sistema");

 }

 
 for (;;);
     
}


