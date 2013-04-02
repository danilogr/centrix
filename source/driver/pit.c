//
// Este arquivo faz parte do sistema operacional Centrix
// -> Não utilize sem permissão
// -> Você não tem direitos de modificar !
// 

//
// PIT - Temporizador Programavel
//

#include <sysutils.h>
#include <irq.h>      
#include <vga.h>                  


void pit_hwndr( struct stackmap2 *regs) {
     
     
     
}


void pit_inicia() {

 irq_registra(0,pit_hwndr);              //registra o PIT
 
}
