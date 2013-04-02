#ifndef _SYSUTILS_H_
#define _SYSUTILS_H_

//
// Cabe�alho do arquivo sistema.c
//                  +   sistema.asm
//
// Cont�m fun��es b�sicas de sistema ( algumas para mem�ria tamb�m )

extern void *memsetb( void *pos, char valor, unsigned long count );
extern void *memsetw( void *pos, unsigned long valor, unsigned long count );
extern void *memsetd( void *pos, unsigned long valor, unsigned long count );
extern void *memcopyb( void *dest, void *source, unsigned long count );
extern void *memcopyw( void *dest, void *source, unsigned long count );
extern void outportb (unsigned short _port, unsigned char _data);
extern unsigned char inportb (unsigned short _port);


#endif 
