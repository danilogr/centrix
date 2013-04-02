#ifndef _VGA_H_
#define _VGA_H_


// Contém funções básicas de controle de video no modo 80 x 25 ( 16 cores )

struct point {						//ponteiro

  int x;
  int y;

};


extern void vga_init();
extern void vga_cls( short param );
extern void kprint(char *texto);
extern void kprintc(char letra);
extern void vga_setcolor(char cor);
extern char vga_getcolor();
extern void vga_hexword(unsigned long numero, int digitos);
extern void vga_gotoxy( struct point cur );
extern struct point vga_rect( int left, int top, int right , int bottom , char color);

#endif 
