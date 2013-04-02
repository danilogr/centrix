;
; Rotinas de auxilo p/ a memoria
; Essas rotinas estão escritas em asm 
; para manter o código mais rapido
; e mais compacto
;

;
; Desenvolvido por Danilo G. Rodrigues
; danilod100@gmail.com
;

;
; Versao 0.0002
;

[BITS 32]

[global _memget]

;
; MemGet
; unsigned long memget( void *fonte );
;
;
; Retorna o valor da memória RAM em megabytes
;

_memget:		; void *memsetb( void *posicao; char valor; int count );
 push edi		; 4 bytes | Total =
 push ecx		; 4 bytes |          0x18 bytes + 4
 push ebx		;
 pushfd			; 4 bytes |
 mov  eax,cr0	;
 push eax		; 4 bytes |salva cr0 por seguranca ( ja que vamos modificar )
 push ebp		; 4 bytes |

 mov  ebp,esp			; ponteiro da pilha

 mov  edi,[ebp + (7*4)] ; posicao aonde comecara o teste
 mov  ecx,0x1000   		; "count" ( numero maximo de repeticoes ) - no caso 4GB  -- 4096 MB
 
 mov  eax,cr0    		;
 or   eax,0x60000000	; Desabilita cache de memoria e write-back
 mov  cr0,eax			;

 xor  eax,eax			; zera eax
 mov  ebx,eax			; zera ebx
 cld			  		; Clear Direction Flag ( para poder incrementar EDI ao invez de subtrair )

  .mmtst: 
 
   inc  eax		  		  ; incrementa EAX
   stosd		  		  ; escreve na memoria 4 bytes

   
   cmp 	[edi-4],eax	  	  ; compara se o ultimo valor é o mesmo 
   jne  .fim		      ; se nao for retorna
   
   ;caso for
	mov ebx,edi			  ; passa o valor de EDI p/ EAX
	sub ebx,4			  ; reduz em 4 bytes EAX ( EDI )
	add ebx,0x100000		  ; adiciona 1 MB 
	mov edi,ebx			  ;

 .looppoint2:
  loop .mmtst


 .fim:
 dec  eax				; subtrai um, pois EAX é incrementada sempre antes de fazer a leitura
 xchg eax,ecx			; Troca o valor tornando ECX => EAX e ao mesmo tempo EAX => ECX
 
 pop  ebp				; recupera a base pointer ( da pilha ) 
 pop  eax				; recupera cr0
 mov  cr0,eax			;
 popfd					; recupera as flags

 ;mov  eax,0x1000		; retornar memoria 			| Subtrai CX = (4096 -  MBs lidos) de AX = 4096 MB 
 ;sub  eax,ecx			; ram válida apos "fonte"	| assim o resultado é o numero de MBs lidos
 mov  eax,ecx			; recupera o número de MBs lidos
 mov  ecx,0x100000		; multiplica por 1024x1024 bytes
 mul  ecx				; retornando assim o número de bytes da memória RAM
						;
 pop  ebx				;
 pop  ecx				; recupera ecx
 pop  edi				; 
 ret					; retorna para a funcao de chamada
  

;
;
;

 