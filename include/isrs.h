#ifndef _ISRS_H_
#define _ISRS_H_

//
// Cabeçalho do arquivo isrs.h
// Contem as funcoes para configurar as ISRs

struct stackmap {                    //mapa da pilha no momento em que ocorre a interrupção
       
    unsigned int cr2, gs, fs, es, ds;                     /* registradores passados por ultimo */
    unsigned int edi, esi, ebp, esp, ebx, edx, ecx, eax;  /* registradores passados por "pusha" */
    unsigned int int_no, err_code;                        /* numero da interrupcao e codigo de erro */
    unsigned int eip, cs, eflags, useresp, ss;            /* passados pela CPU automaticamente */ 
       
};

extern void isrs_cnfg();

#endif 
