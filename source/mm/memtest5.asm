;
; Rotinas de auxilo p/ a memoria
; Essas rotinas est�o escritas em asm 
; para manter o c�digo mais rapido
; e mais compacto
;

;
; Desenvolvido por Danilo G. Rodrigues
;

[BITS 32]

[global _memget]

;
; MemGet
; unsigned long memget( void *fonte );
;
;
; Nova fun��o de retorno de mem�ria RAM, ainda mais r�pida, l� de 1 em 1 MB
; 
;
;
; Retorna o valor da mem�ria RAM em bytes
; ( normalmente o valor + 8 bytes )
;

_memget:		; void *memsetb( void *posicao; char valor; int count );
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |          0x18 bytes + 4
 push ebx
 pushfd			; 4 bytes |
 mov  eax,cr0		;
 push eax		; 4 bytes |salva cr0 por seguranca ( ja que vamos modificar )
 push ebp		; 4 bytes |

 mov  ebp,esp		;

 mov  edi,[ebp + (7*4)] ; posicao aonde comecara o teste
 mov  ecx,0x1000        ; Como ele le de um em um mega, 1MB em 4096 repeti��es, teremos 4 GB
 
 mov  eax,cr0    	;
 or   eax,0x60000000	; Desabilita cache de memoria e write-back
 mov  cr0,eax		;

 xor  eax,eax		; zera eax
 mov  ebx,eax
 cld			  ; Clear Direction Flag ( para poder incrementar EDI ao invez de subtrair )

  .mmtst: 
 
   inc  eax		  ; incrementa EAX
   stosd		  ; escreve na memoria 4 bytes

   
   cmp 	[edi-4],eax	  ; compara se o ultimo valor � o mesmo 
   jne  .retpoint         ; se nao for retorna

   cmp  eax,0xFFFFFFFD	  ; verifica se eax � menor ou igual a 0xFFFFFFFD
   jle  .looppoint	  ; se for, continua o loop

   xor  eax,eax		  ; se nao for, zera eax e continua o loop
   
   


 .looppoint:   

  xor  ebx,ebx		  ; e tb zera ebx 
 .looppoint2:
  loop .mmtst


 .retpoint:		; ponto de retorno
  cmp ebx,2		; verifica se ebx ja � um
  jge  .fim		; se for maior ou igual termina
  inc ebx		; se nao for, incrementa
  jmp .looppoint2	; continua  o loop



 .fim:


 pop  ebp		; recupera a base pointer ( da pilha ) 
 pop  eax		; recupera cr0
 mov  cr0,eax		;
 popfd			; recupera as flags

 mov  eax,0x3FFFFFFF	; retornar memoria 
 sub  eax,ecx		;                   ram v�lida apos "fonte"
 mov  ecx,4		;
 mul  ecx		;
			;
 pop  ebx		;
 pop  ecx		; recupera ecx
 pop  edi		; 
 ret			; retorna para a funcao de chamada
  

;
;
;

 