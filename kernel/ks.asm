;
; Centrix Kernel Start
;
 
[BITS 32]			; agora estamos em 32bits e no modo protegido

[global start]
[extern _kmain]			; Kernel Main
 

start:

    call _kmain			; kernel main


pula:				; loop infinito
  jmp pula			;

;
; CONFIGURACOES DA CPU ( GDT, IDT, LDT, IRQs, etc.. )
;

%include "idt.asm"		
%include "isrs.asm"
%include "irq.asm"


SECTION .bss
;nada aqui
; a pilha vai ficar em 0x8400 mesmo