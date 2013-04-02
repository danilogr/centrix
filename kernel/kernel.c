//
// Centrix Kernel Main ( Centro da kernel, aonde todos os codigos sao reunidos e executados )
// VER.: 0.001
// 
//


#include <sysutils.h>
#include <vga.h>
#include <idt.h>
#include <isrs.h>
#include <irq.h>
#include <mm/pmm.h>

void kmain( void ) {

//limpando a sessão BSS

  extern unsigned long sbss;
  extern unsigned long ebss;
 
  unsigned long ssbss;
   ssbss = (unsigned long)&sbss;            //inicio da sessao BSS
   ssbss;
  unsigned long eebss;
   eebss = (unsigned long)&ebss;            //fim da sessa BSS
   
 memsetb( (void *) ssbss, 0, eebss - ssbss );

//fim da limpeza
    
  vga_init();	    	//inicia o video 80x25
  vga_setcolor(0x09);	//cor azul claro
 
  kprint("[] - Centrix 0.0001 - [] \n"); 
  vga_setcolor(0x0F);	//cor branca

  //
  // Inicializacao básica
  //  
  
  idt_inicia();
  isrs_cnfg();
  irq_instala();

  // Memoria
  
  pmm_inicia();
  
  //
  // Outras inicializações
  //
    

  vga_setcolor(0x07);	
  
  unsigned long *endereco;
  
  //ativa interrupções
  __asm__ __volatile__ ("sti");
  
  
  //vamos causar uma exceção
  int a;
  a = 0;
  
  int b;
  b = 10/a;
  


}



 
