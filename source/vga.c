//
// By Danilo G. Rodrigues


// Driver para o modo 80x25 ( 16 cores ), apesar de também funcionar no modo 80x25 preto e branco
//

#include <sysutils.h>
#include <vga.h>

char *vidmem = (char *) 0xb8000;	//memoria de video
char hexbyte[] = "0123456789ABCDEF";   //numero hexadecimais
char color = 0x07;			//cor do texto ( fundo preto, texto branco )

struct point cursor;			//ponteiro

//
//  // utilizar primeiramente void vga_init() {
// Como utilizar, para escrever kprint("texto");
//
//


//======================================================================//
//define a cor
char vga_getcolor() {
  return color;
}

//======================================================================//
//define a cor
void vga_setcolor( char cor ) {
  color = cor;
}

//======================================================================//
//rotina de scroll
void vga_scroll() {

 memcopyb(vidmem,vidmem + 160,3840);	//copia p/ primeira linha, da segunda linha p/ frente
 memsetw(vidmem + 3840,0x0700,160);	//limpa a ultima linha

}

//======================================================================//
//arruma o cursor de video
void vga_upcursor() {
 
unsigned temp;
temp = cursor.y * 80 + cursor.x;

    outportb(0x3D4, 14);
    outportb(0x3D5, temp >> 8);
    outportb(0x3D4, 15);
    outportb(0x3D5, temp);	

}

//======================================================================//

//imprime uma caractere
void kprintc(char letra){

  int i;
  i = (cursor.y * 160) + cursor.x * 2;	// calcula a posicao do cursor na tela

   if( letra == '\n' ) { //se for nova linha
 
      cursor.x = 0;	//volta x em 0
      cursor.y++;	// incrementa uma linha


   } else if (letra == '\b') { // se for backspace
      
      if (cursor.x > 0) {
       cursor.x--;   //volta o ponteiro x

     }
     
   } else {

     vidmem[i] = letra;	//escreve a letra
     i++;
     vidmem[i] = color;	//cor da letra
     i++;

     cursor.x++;	//incrementa x


   }
 
 
  if (cursor.x >= 80) {		//se o cursor X for maior que o número máximo de colunas

   cursor.x = 0;			//então volta ele para o começo
   cursor.y++;			//e incrementa uma linha

  }
  
  if (cursor.y  >= 25) {		//se o cursor Y for maior que o número máximo de linhas

   vga_scroll();			//sobe a tela
   cursor.x = 0;			//volta o cursor para o começo da linha
   cursor.y = 24;			//ultima linha

  }

  vga_upcursor();


}

//======================================================================//
void kprint(char *texto){

  while( *texto != 0x00 ) {	//enquanto nao for um caractere nulo

   kprintc(*texto);
   *texto++;		//incrementa a caractere

  }

  
}


//======================================================================//

//funcao que limpa  atela
void vga_cls( short param){

  memsetw(vidmem, param, 2000);		//limpa com a cor definida
  cursor.x = 0; 			//  volta os cursores para 0 
  cursor.y = 0;				//    inicio da tela
  vga_upcursor(); 			// atualiza o cursor na tela

}

//======================================================================//

//inicia o video, arrumando os ponteiros e limpando a tela
void vga_init() {

  vga_cls(0x0700);	//limpa a  tela com fundo preto, texto branco

}

//======================================================================//
// imprime os numeros
void vga_hexword(unsigned long numero, int digitos) {

 int  i;
 int  term;

 kprintc('0');
 kprintc('x');

 for (i = 0; i < digitos; i++) {
   term = numero >> ((digitos - i -1)*4); //faz a rotacao
   kprintc(hexbyte[(term &  0xF)]);     //elimina o numero extra
 }
     
}

//======================================================================//

struct point vga_rect( int left, int top, int right , int bottom , char color) {

 int i,x,y;
 
 struct point tmp;
 
 for (y = top; y < bottom; y++ ) {		

   for (x = left; x < right; x++ ) {
    i = ( 160 * y ) + 2 * x;			//calcula a posição do ponteiro => ( 80 * 2 * y ) + 2 * x

    vidmem[i] = 0x00;				//ou seja, NADA!!!
    i++;
    vidmem[i] = color;				//a cor
    i++;
   }


 }	

 tmp.x = left;
 tmp.y = top;

 return tmp;					//resulta o ponteiro 


}
//======================================================================//

void vga_gotoxy( struct point cur ) {
 
 cursor.x = cur.x;
 cursor.y = cur.y;
        
}

//======================================================================//
