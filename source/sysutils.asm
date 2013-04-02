;
; Rotinas de auxilo p/ sistema.c
; Essas rotinas estão escritas em asm 
; para manter o código mais rapido
; e mais compacto
;

;
; Esse arquivo faz parte do sistema operacional Centrix
;

[BITS 32]

[global _memsetb]
[global _memsetw]
[global _memsetd]
[global _memcopyb]
[global _memcopyw]

;
; MemSetb
; void *memsetb( posicao, valor, count );
;
;

_memsetb:		; void *memsetb( void *posicao; char valor; int count );
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |          0x10 bytes
 pushfd			; 4 bytes |
 push ebp		; 4 bytes |
 mov  ebp,esp		;
 mov  edi,[ebp + (5*4)] ; posicao aonde sera escrito
 mov  ecx,[ebp + (7*4)] ; "count" ( numero de repeticoes )
 mov  eax,[ebp + (6*4)] ; valor a ser colocado
 and  eax,0x000000FF	; para manter somente o byte
 cld			; Clear Direction Flag ( para poder incrementar EDI ao invez de subtrair )
 rep  stosb		; faz a copia
 mov  eax,[ebp + (5*4)] ; posicao ( para retornar para o usuario
 pop  ebp		; recupera a base pointer ( da stack ) 
 popfd			; recupera as flags
 pop  ecx		; recupera ecx
 pop  edi		; 
 ret			; retorna para a funcao de chamada
  
;
; MemSetW
; void *memsetw( posicao, valor, count );
;
;

_memsetw:
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |          0x10 bytes
 pushfd			; 4 bytes |
 push ebp		; 4 bytes |
 mov  ebp,esp		;
 mov  edi,[ebp + (5*4)] ; posicao aonde sera escrito
 mov  ecx,[ebp + (7*4)] ; "count" ( numero de repeticoes )
 mov  eax,[ebp + (6*4)] ; valor a ser colocado
 and  eax,0x0000FFFF	; para manter somente o byte
 cld			; Clear Direction Flag ( para poder incrementar EDI ao invez de subtrair )
 rep  stosw		; faz a copia
 mov  eax,[ebp + (5*4)] ; posicao ( para retornar para o usuario
 pop  ebp		; recupera a base pointer ( da stack ) 
 popfd			; recupera as flags
 pop  ecx		; recupera ecx
 pop  edi		; 
 ret			; retorna para a funcao de chamada

;
; MemSetD
; void *memsetD( posicao, valor, count );
;
;

_memsetd:
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |          0x10 bytes
 pushfd			; 4 bytes |
 push ebp		; 4 bytes |
 mov  ebp,esp		;
 mov  edi,[ebp + (5*4)] ; posicao aonde sera escrito
 mov  ecx,[ebp + (7*4)] ; "count" ( numero de repeticoes )
 mov  eax,[ebp + (6*4)] ; valor a ser colocado
 cld			; Clear Direction Flag ( para poder incrementar EDI ao invez de subtrair )
 rep  stosd		; faz a copia
 mov  eax,[ebp + (5*4)] ; posicao ( para retornar para o usuario
 pop  ebp		; recupera a base pointer ( da stack ) 
 popfd			; recupera as flags
 pop  ecx		; recupera ecx
 pop  edi		; 
 ret			; retorna para a funcao de chamada


;
; MemCopyB
; void *memcopyb( void *dest, void *source, unsigned long count );
;
;

_memcopyb:
 push esi 		; 4 bytes |
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |       0x14 bytes
 pushfd			; 4 bytes |
 push ebp		; 4 bytes |
 mov  ebp,esp		;
 mov  edi,[ebp + (6*4)]	; Destino
 mov  esi,[ebp + (7*4)] ; Source ( fonte )
 mov  ecx,[ebp + (8*4)] ; contagem
 cld			; Clear direction flag
 rep  movsb		; move apenas bytes
 mov  eax,[ebp + (6*4)]	; O destino ( return dest )
 pop  ebp		;
 popfd			;
 pop  ecx		;
 pop  edi		;
 pop  esi		;
 ret			; returna para a funcao que chamou

;
; MemCopyB
; void *memcopyb( void *dest, void *source, unsigned long count );
;
;

_memcopyw:
 push esi 		; 4 bytes |
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |       0x14 bytes
 pushfd			; 4 bytes |
 push ebp		; 4 bytes |
 mov  ebp,esp		;
 mov  edi,[ebp + (6*4)]	; Destino
 mov  esi,[ebp + (7*4)] ; Source ( fonte )
 mov  ecx,[ebp + (8*4)] ; contagem
 cld			; Clear direction flag
 rep  movsw		; move apenas words
 mov  eax,[ebp + (6*4)]	; O destino ( return dest )
 pop  ebp		;
 popfd			;
 pop  ecx		;
 pop  edi		;
 pop  esi		;
 ret			; returna para a funcao que chamou
 
 