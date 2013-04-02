//
// Este arquivo faz parte do sistema operacional Centrix
// -> Não utilize sem permissão
// -> Você não tem direitos de modificar !
// 

//
// IDT
//

#include <sysutils.h>
#include <idt.h>
#include <isrs.h>

extern void idt_reg();        //registra a IDT

struct idts {
   
   unsigned short    offsetl; //lower part do offset da funcao
   unsigned short    codsel;  // code selector
   unsigned char     always0; // sempre 0
   unsigned char     flags;   //
   unsigned short    offseth; //higher part do offset da funcao
              
} __attribute__((packed));

struct idtp {                 //ponteiro para a IDT
       
    unsigned short limit;
    unsigned int base;
} __attribute__((packed));    


struct idts _idt[256];        //idt
struct idtp _idtprt;          //ponteiro para a IDT

unsigned int idtsize = sizeof(_idt);   //tamanho da IDT

//============================================================================//
//usar idt_adiciona( pos, sel , offset, flags );
// aonde pos = posicao na idt
// sel = é o seletor de código
// offset = posição da ISR na memoria
// flag  = opcoes configuraveis

void idt_adiciona( unsigned char pos, unsigned short sel, unsigned long base, unsigned char flags) {

  _idt[pos].always0 = 0;                               //sempre 0 
  _idt[pos].codsel  = sel;                             //code selector
  _idt[pos].flags   = flags;                           //
  _idt[pos].offsetl = (base & 0x0000FFFF);             //pega a word menos significante
  _idt[pos].offseth = ((base & 0xFFFF0000) >>  16);    //pega a word mais significante   
     
}

extern void idt_erro();                                       //função que gerencia possiveis erros

//============================================================================//

void idt_inicia(){            //inicializa as IDTs

   //configura o ponteiro para a IDT
   _idtprt.limit = (sizeof (struct idts) * 256) - 1;
   _idtprt.base = (unsigned) &_idt;
   
   //zera a IDT ( NAO É MAIS NECESSARIO )
   //memsetb(&_idt, 0x00, sizeof(struct idts) * 256);

   //adicionar futuramente a configuracao das ISRS
   
   
   //registrar a IDT
   idt_reg();                 //registra a IDT  
   
   //ajusta para as rotinas de erro ocorrem ( elas são sobreescritas caso seja necessario
   int i;
   for ( i = 0; i < 256; i++) {
    idt_adiciona( i, 0x08, (unsigned) idt_erro, 0x8E);
   }
}

//============================================================================//

void idterro_hwnd( struct stackmap *regs ) {

 unsigned short antcor;
 antcor = vga_getcolor();
 vga_setcolor(0x04);
 kprint("[Erro] - Interrupcao desconhecida\n");
 vga_setcolor(antcor);
 
}

