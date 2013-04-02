#ifndef _PMM_H_
#define _PMM_H_

// Gerenciador de memória fisica
extern void pmm_inicia( void );
extern unsigned long *pmm_allocpage();
extern void pmm_freepage( unsigned long endereco );

#endif 
