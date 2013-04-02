//
// pmm.c
//
// Esse arquivo faz parte do sistema operacional skybox
// Gerenciador de memória física
//

// O Bitmap é um mapa de segmentos da memoria do tamanho de 4 KB
// Cada segmento fica representado em apenas um bit, se estiver setado ele esta ocupado
// se nao estiver setado ele está livre
// Ou seja, 1 byte contem 8 bits, logo 8*4 segmentos ( 32 segmentos de 4 KB = 128kb de memoria ram)

#include <mm/memget.h>
#include <mm/pmm.h>
#include <sysutils.h>
#include <vga.h> 
 
unsigned char *pmmBitmap = (char *) 0x7E00;   //posicao do bitmap ( tamanho máximo 0x97FFF bytes ) ( ~ 607 kb )
unsigned long pmmBmpSize;            //tamanho do bitmap de acordo com a memoria ram do usuario
unsigned long pmmBmpIndex;           //posicao em que deve iniciar a busca por mais setores ( em bytes )
unsigned long pmmTotal;              //total de memoria RAM em bytes
 
//==================================================================================//

void pmm_inicia( void ) {
             
 //
 // Iniciando a deteccao de memoria ram
 //

 kprint("[PMM] - Inicializando...\n");
 kprint("[PMM] - Memoria RAM: ");
 pmmTotal = memget((char *) 0x200000)  + 0x200000;
 vga_hexword(pmmTotal,8);

 if ((pmmTotal) <= 0x200000) {
 
  kprint("\n[PMM] - ");
  vga_setcolor(0x04); 
  kprint("Memoria RAM insuficiente");
  for( ; ;);              //trava aqui
 
 }

 // Determinando o tamanho do bitmap
 pmmBmpSize = (pmmTotal - 8) / 4096 / 8;     //tamanho em bytes
 
 kprint("\n[PMM] - Criando Bitmap - "); 
 //Até a posicao 0x200000 estará ocupado pela kernel / outras coisas
 memsetd(pmmBitmap, 0xFFFFFFFF, 16);     //prenche 16*4 bytes ( ou seja , os 64 primeiros bytes )
 pmmBmpIndex = 64;                       //byte 64 representa memoria Ram em ( representa 2 MB ) 2 MB e 800
 
 memsetd(pmmBitmap+64, 0, (pmmBmpSize / 4)-16); //zera todos os outros segmentos
 vga_setcolor(0x09); 
 kprint("(OK)\n");  
 vga_setcolor(0x0F);   
 pmmBitmap[pmmBmpSize] = 0xFF;                   //este está ocupado ( nao da para alocar em 0xMAXRAM)
             
}             

//==================================================================================//

//simples alocador de memória ( aloca paginas de 4kB ) e retorna o endereço
unsigned long *pmm_allocpage() {
  
  //primeiro verificar por um bloco livre
  
    //verificar no index
    //todos os seus bits
    //caso encontar um vazio, retornar o endereco dele e marcar ele como ocupado
    //caso nao encontrar incrementar o index e verificar o proximo
    
    unsigned char okflag = 0;
    
    //busca simples , porém mais rapida do que a busca por bit
    
    while ( (pmmBitmap[pmmBmpIndex] == 0xFF) && (okflag == 0))  {              //verifica se o index aponta para um endereço cheio
          
          if (pmmBmpIndex < pmmBmpSize ) {                                                  
             pmmBmpIndex++;
          } else {
             okflag = 2;                                                         //2 = estado de que esta sem memoria                                      
          }                    
    }
    
    if (okflag == 2) {
    
     return 0;                                                                   //out of memory
               
    }
    
    //agora busca por bit ( ja que encontrou um byte que pode ter no minimo 1 bloco livre )
    
    okflag = 0;                                                                  //inicializa
    unsigned char bitbyte = 0;
    unsigned char idx = 0;
    unsigned char bitnum = 0;
  
    bitbyte = pmmBitmap[pmmBmpIndex];
    
    while ( (okflag == 0) && (idx < 8) ) {
      
     if ( (bitbyte & (0x80 >> idx)) == 0 ) {                                     //procura bloco livre
          
          //se tiver livre
            
          pmmBitmap[pmmBmpIndex] = (bitbyte | (0x80 >> idx));                      // utiliza o OR para marcar o bit

          okflag  = 1;
          bitnum  = idx;    
     }
     
     idx++;
          
    }
    
    //zera e 
    //passa o endereço a ser alocado
    
    
    if (okflag == 1) {
             
               
      //retorna o endereco
      unsigned long endereco;
      
      endereco = (pmmBmpIndex * 32768)  + bitnum * 4096;
      
      memsetb((void *) (endereco), 0, 4095); //zera o segmento de memoria alocado - 4KB
      return  (void *) (endereco);
               
    } else {      //por causa de um erro desconhecido
    
     return 0;
           
    }
    
  
  //fim da verificação           
             
}

//==================================================================================//

void pmm_freepage( unsigned long endereco ) {
         
  unsigned int  blocobyte;       
  unsigned char blocobit;  

          
  //primeiro verificar se eh um endereco valido ( de 4 Kb )
    if ( (endereco % 4096) != 0 ) {
         
		 //ao desalocar o endereço ele nao limpa a memoria
		 //assim, utilziando apenas a memoria física
		 //é possivel alocar uma informação e continuar
		 //utilizando ela após desalocada xD
		 // ( claro que caso essa memoria seja alocada, entao essa informação será perdida )
		 
        blocobyte = endereco / 4096;            
        blocobit  = blocobyte % 8;              //achamos o bit
        blocobyte = blocobyte / 8;              //e o byte
        
        pmmBitmap[blocobyte] = pmmBitmap[blocobyte] - (0x80 >> blocobit);             //desaloca
        
        pmmBmpIndex = blocobyte;
        
        
           
    } else {
        
        kprint("  Endereco nao alinhavel  ");

    } 
}         

//==================================================================================//
