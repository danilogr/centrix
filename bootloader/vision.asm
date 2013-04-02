;
;
;  Centrix Boot ( Vision ) - Parte 1
;
;  -> Carrega o arquivo que esta no primeiro cluster
;  -> Carrega o total de 4 clusters
;
;

[ORG 0x7C00]				; Posição de boot
BITS 16					; real mode

inicioprograma1:

;----------------------------------------------------------------


 jmp short inicio			; dois bytes   - 0xEB
 nop					; nenhuma ação - 0x90 

; Cabeçalho FAT12

%include "fat12.inc"

;----------------------------------------------------------------


inicio: 
  mov [bootdrv],dl			; drive de boot
  
;configurando os segmentos
  
  mov ax,0x0000
  mov ds,ax
  mov es,ax
  mov ss,ax

;configurando a pilha

  mov ax,0x7C00
  mov bp,ax
  mov sp,ax

;escrevendo mensagem "welcome"

  mov  si,loadmsg
  call escreve

;calculando a posicao do primeiro arquivo

  ; NumeroDeSetoresRervados em 0x0E (word) 
  ; SetoresPorFat em 0x16  (word)
  ; NumeroDeFat em 0x10 ( byte)
  ; MaxEntradasRoot em 0x11 ( word )
  ; cada entrada de arquivo tem 32 bytes
  ;
  ; logo, 1º cluster => (NumeroDeSetoresRervados + ( SetoresPorFat * NumeroDeFat )) + ((MaxEntradasRoot * 32 ) / 512 )
  ;

  xor ax,ax
  mov ax,[bp + 0x16]		; SetoresPorFat em 0x16  (word)
  mul byte [bp + 0x10]		; * NumeroDeFat em 0x10 ( byte)
  add ax, [bp + 0x0E]		; + NumeroDeSetoresRervados em 0x0E (word)

  push ax			; salva o valor na pilha

  xor ax,ax
  mov ax, [bp + 0x11] 		; MaxEntradasRoot em 0x11 ( word )
  mov bx, 32			;
  mul bx			; * 32
  mov bx, 512			;
  div bx			; / 512
 
  or dx,dx			; verifica se o resto é zero
  jz naosoma			; se for nao acrescenta 1 setor

   
  inc ax


  naosoma:
  pop bx
  add ax,bx			; soma a posicao do diretorio root + seu tamanho = inicio da area de dados


  mov [dados],ax		; guarda para um possivel uso  ( utopico )

  mov cx, 4			; 4 setores para serem lidos
  mov word [addrss], 0x7E00	; endereco de leitura



  lesetores:
    mov  si,lendop		;mensagem de erro
    call escreve			;  


    push ax			; salva o numero inicial do setor
    push cx
    call lbatochs		; converte para a leitura
    call ledisco		; faz a  leitura do disquete

    pop cx
    pop ax			; recupera o valor de ax
    inc ax			; incrementa 1 setor
    add word [addrss], 0x200	; adiciona 512 bytes ( para ler o proximo setor )

    dec  cx			; decrementa cx
    or cx,cx			;
    jz final			; se for 0 , pula para "final"

   jmp lesetores		; faz o loop


  final:			;pula para o codigo do arquivo

     mov  si,linhas
     call escreve
   
     xor   dx,dx
     mov   dl,[bootdrv]
     push  dx			; passa o drive de boot

     xor   dx,dx
     mov   dx,escreve		; endereco da rotina de escrita
     push  dx			; passa o endereco
 
     xor   dx,dx
     mov   dx,lbatochs		; endereco da rotina que transforma LBA p/ CHS
     push  dx			; passa o endereco


     jmp 0x0000:0x7E00		; aonde começa o arquivo

  mov  si,errojm
  call escreve
  

  bug:  
    jmp bug			; em caso de um erro desconhecido para ir para o codigo
 


;----------------------------------------------------------------

;
; Funcao de escrita 
;

escreve:
  push ax
  push bx
  mov  ah, 0x0E			; funcao de escrita
  mov  bx, 0x0007		;
   .escchar
      lodsb			;pega um byte de DS:SI e coloca em al
      or  al,al			;
      jz  .fim			;se for um valor nulo termina a rotina
      int 0x10			;escreve a caractere na tela
      jmp .escchar		;vai p/ a proxima caractere
   .fim
      pop bx			;recupera o valor de bx
      pop ax			;recupera o valor de ax
      ret			;retorna para a funcao de chamada
    
   

;
; Funcao de leitura ( do disquete )
;

ledisco:
   .reseta:
      xor ax,ax
      mov dl,[bootdrv]
      int 0x13
      jc .erro

   mov bx,[addrss]

   .lesetor:
      mov ax,0x0201		; le um setor
      int 0x13
      jc .erro
      
   ret

  .erro
   mov  si,erromsg		;mensagem de erro
   call escreve			;
   mov  ah,0x00			;
   int  0x16			;espera uma tecla
   jmp .reseta			; xD
 
  
;
; Funcao que transforma LBA p/ CHS
;

;receve AX como o SETOR LBA (BRUTO)
; Input:  ax - LBA value
;
; Output: ax - Sector
;	  bx - Head
;	  cx - Cylinder
; 


lbatochs:
 PUSH dx			; Save the value in dx
 XOR  dx,dx			; Zero dx
 MOV  bx, [bp + 0x18]		; Move into place STP (LBA all ready in place)
 DIV  bx			; Make the divide (ax/bx -> ax,dx)
 inc  dx			; Add one to the remainder (sector value)
 push dx			; Save the sector value on the stack			;DX é o resto da divisao, entao DX + 1 = setor
											; AX é a divisao LBA / SetoresPor trilha

 XOR dx,dx			; Zero dx
 MOV bx, [bp + 0x1a]		; Move NumHeads into place (NumTracks all ready in place)	
 DIV bx				; Make the divide (ax/bx -> ax,dx)

 MOV cx,ax			; Move ax to cx (Cylinder)
 MOV bx,dx			; Move dx to bx (Head)
 POP ax				; Take the last value entered on the stack off.
				; It doesn't need to go into the same register.
				; (Sector)
 POP dx				; Restore dx, just in case something important was
				; originally in there before running this.
 ;abaixo otimiza para ser usado na funcao de leitura da bios
 mov  dh,bl			;passa o valor da cabeca para dh
 mov  ch,cl			;passa o cilindro para ch
 mov  cl,al			;passa o setor para cl 

 RET				; Return to the main function


;----------------------------------------------------------------

;
;  VARIAVEIS
; 

errojm  db 13,10,"Erro desconhecido!",0;
lendop  db ".",0		;
linhas  db 13,10,0  	        ; 
dados   dw 0x0000		;area de dados
erromsg db "Erro na leitura do disco!",13,10,0;
bootdrv db 0			;disco de boot
addrss  dw 0x0000		;endereco aonde sera escrito o arquivo
loadmsg db "Bootando",0		;

;----------------------------------------------------------------
fimprograma1:

; Para terminar
times 510-(fimprograma1-inicioprograma1) db 0	; Preenche o resto do setor com zeros
db 0x55,0xAA		; Põe a assinatura do boot loader no final




