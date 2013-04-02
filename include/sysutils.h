#ifndef _SYSUTILS_H_
#define _SYSUTILS_H_

//
// Cabeçalho do arquivo sistema.c
//                  +   sistema.asm
//
// Contém funções básicas de sistema ( algumas para memória também )

extern void *memsetb( void *pos, char valor, unsigned long count );
extern void *memsetw( void *pos, unsigned long valor, unsigned long count );
extern void *memsetd( void *pos, unsigned long valor, unsigned long count );
extern void *memcopyb( void *dest, void *source, unsigned long count );
extern void *memcopyw( void *dest, void *source, unsigned long count );
extern void outportb (unsigned short _port, unsigned char _data);
extern unsigned char inportb (unsigned short _port);


#endif 
