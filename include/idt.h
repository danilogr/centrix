#ifndef _IDT_H_
#define _IDT_H_

//
// Cabeçalho do arquivo idt.c
// Contem as funcoes para registrar interrupcoes na IDT e tambem registrar a prorpia IDT


extern void idt_inicia();
extern void idt_adiciona( unsigned char pos, unsigned short sel, unsigned long offset, unsigned char flags);


#endif 
