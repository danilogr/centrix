;
;
; Vision 2.0
; -> Carrega vários arquivos
; -> No modo protegido
;


;|----------------------[  INICIALIZAÇÃO  ]----------------------|

[ORG 0x7E00]		;posicao aonde esta carregado
BITS 16			; 16 bits

;
; Arrumando os segmentos
;

xor ax,ax
mov ss,ax
mov ds,ax
mov es,ax

;
;
; Obtendo informacoes
;
;

pop dx			; recupera a funcao que transforma lba p/ chs
mov [lbatochs],dx	;

pop dx			; recupera a funcao de escrita
mov [escreve],dx	;

pop dx			; recupera informacoes do disco
mov [bootdrv],dl	;


;
; Arrumando a pilha
;
; -> Caso tivesse alguma coisa pode haver "perda de dados" ( do q estava na piha )
;

xor ax,ax
mov ax,0x7C00		; Endereco do boot ( para pegar informacoes  FAT )
mov bp,ax
mov sp,ax

;
; Calculando a posicao do diretorio root ( setor )
;
; root = SETORES_RESERVADOS + ( SETORES_POR_FAT * NUMERO_DE_FATS )
;
; Calculando também o numero maximo de setores root
;
; nmax = (maxdeentradas * 32) / 512

mov ax,  [bp + 0x11]	; numero maximo de entradas no diretorio root
mov bl,0x20
mul bl			; multiplica por 32
mov bx,0x200
div bx			; divide por 512
or  dx,dx		; verifica se o resultante é zero
jz  naosoma		; se for nao incrementa +1 em ax

inc ax			; incrementa o numero de setores

naosoma:
mov [maxsect],ax	; xd


mov ax,  [bp + 0x16]	; Numero de setores por fat		
mul byte [bp + 0x10]	; Multiplica ax pelo numero de fats	
add ax,  [bp + 0x0e]	; Numero de setores reservados		

push ax
mov [rootdir], ax	; salva o número maximo de entradas no diretório root
add word [maxsect], ax  ; se maxsect=14 e rootdir=19, logo maxsect = 33
pop  ax

mov [setorl],ax

;_________________________________________________________________________________


;
; Ativar o acesso a 1MB da memoria
;

fileok:


;
; Ativa o gate A20 ( FAZ 16 tentativas utilizando 3 métodos )
;


ativagate:
cli				;desativa interrupções por motivo de segurança

 mov cx,10			; 10 tentativas
 tentativa1:			;primeira tentativa de ativar o a20 ( metodo garantido na maioria dos PCs )
 call cmdbuffempt		; espera o buffer de comando estar livre
 mov  al,0xAD			; desativa o teclado
 out  0x64,al			;
 
 call cmdbuffempt		;espera o buffer de comando estar livre
 mov  al,0xD0			;
 out  0x64,al			;  envia um comando

 call outbufffull		;espera o buffer de resposta estar cheio ( para pegar a atual configuracao )
 in   al,0x60			;recebe da porta 0x60
 push ax			; salva o valor na pilha

 call cmdbuffempt		;caso o buffer de comando ainda tenha algum comando
 mov  al,0xD1			;escreve um byte de informacoes para o teclado
 out  0x64,al			;

 call cmdbuffempt		; espera o teclado estar pronto para receber outro comando
 pop  ax			; recupera o valor
 or   al,2			; ativa o bit 2 ( ou mantem ativo caso estivesse ativado ) - A20 gate
 out  0x60,al			; envia para a porta dados 

 call cmdbuffempt		; espera o teclado estar pronto para receber outro comando
 mov  al,0xAE			; ativa o teclado ( que estaja desativado anteriormente )
 out  0x64,al			;

 ;verificacao se esta ativado
 call cmdbuffempt		;espera o buffer estar limpo 
 mov  al,0xD0			;
 out  0x64,al			;  envia um comando

 call outbufffull		;espera o buffer de resposta estar cheio ( para pegar a atual configuracao )
 in   al,0x60			;recebe da porta 0x60
 and  al, 2			;
 jnz  a20ativo			; caso nao for zero quer dizer que o a20 está ativo

 loop tentativa1		; tenta 10 vezes esse método
 
 ;caso o primeiro metodo falhou
 ;vamos para a segunda tentaiva

 mov cx,5			; 5 tentativas

 tentativa2:			; metodo desconhecido " achado na internet "
 mov AL, 0xDF			; tenta ativar
 out 64h, AL			; o A20 GATE


 ;verificacao se esta ativado
 call cmdbuffempt		;espera o buffer estar limpo 
 mov  al,0xD0			;
 out  0x64,al			;  envia um comando

 call outbufffull		;espera o buffer de resposta estar cheio ( para pegar a atual configuracao )
 in   al,0x60			;recebe da porta 0x60
 and  al, 2			;
 jnz  a20ativo			; caso nao for zero quer dizer que o a20 está ativo

 loop tentativa2		; tenta 5 vezes esse método

 ; o método abaixo é tentado somente 1 vez!!!

 tentativa3:			; método FAST A20, nao suportado em todos PCs ( alguns faz a tela limpar xD )
 in al, 0x92			; se vai funcionar
 or al, 2			; ou nao
 out 0x92, al			; eu nao sei

 call cmdbuffempt		; espera o buffer estar limpo
 mov  al,0xD0			;
 out  0x64,al			;  envia um comando

 call outbufffull		;espera o buffer de resposta estar cheio ( para pegar a atual configuracao )
 in   al,0x60			;recebe da porta 0x60
 and  al, 2			;
 jnz  a20ativo			; caso nao for zero quer dizer que o a20 está ativo
 jmp  agateerro			; caso contrario da erro ( 3 metodos diferentes em 16 tentativas e nao deu certo )
  

 agateerro:
  mov  si, erroagate		
  call [escreve]

 loopinf:
  jmp loopinf
 
 

 a20ativo:			; rotina executada quando o a20 está ativo

sti				; ativa as interrupcoes	 

;|=================================|;
;|								   |;
;|  Procurar e carregar arquivos   |;
;|								   |;
;|=================================|;

mov  si,loadarq				; Mensagem
call [escreve]				; "Carregando arquivos:"


;
; kernel32.bin
;

mov  si,file1				; Mensagem
call [escreve]				; "kernel.bin"

mov  word [nome],nome1		; arquivo a ser lido
call pesquisa				; procura o arquivo

mov  cx,20					; 20 clusters = 10 KB
mov  word [addrss],0x0010	; Endereço
mov  ax,0xFFFF				;          de leitura
mov  es,ax					; 0xFFFF:0x0010 = 0x100000
call carregaarquivo			; carrega o arquivo

;tst2.bin

;mov  word [filecls],0x0000  		; limpa o ultimo cluster lido
;mov  si,file2				; Mensagem
;call [escreve]				; "kernel.bin"

;mov  word [nome],nome2			; arquivo a ser lido
;call pesquisa				; procura o arquivo

;mov  cx,2				; 2 clusters = 1 KB ( só para teste )
;mov  word [addrss],0x8E00		; Endereço
;xor  ax,ax
;mov  es,ax				;          de leitura
;call carregaarquivo			; carrega o arquivo


;
; Hora de ir p/ o modo protegido
;

;
; Mover a GDT para 0x500
;

 xor ax,ax
 xor cx,cx
 mov es,ax
 mov ds,ax
 mov si,iniciogdt	 ; source ( fonte )
 mov di,0x500		 ; dest. ( destino )
 mov cx,[GDTsiz]	 ; tamanho da GDT
 cld			 ; Limpa a flag de direcao
 rep movsb		 ; faz a copia



;
; Ativar o modo protegido
;

cli

lgdt [gdtdt]		; carrega a gdt

   mov eax,cr0		;
   or eax,1		; seta o bit do modo protegido
   mov cr0,eax		; passa p/ cr0

;agora estamos no modo protegido
jmp 0x08:limpapipe      	; seta cs como 0x08



;_________________________________________________________________________________

;|----------------------[ DADOS DINAMICOS ]----------------------|

escreve  dw 0x0000		; |
lbatochs dw 0x0000		; | -> Ponteiros p/ rotinas dinamicamente carregadas 

bootdrv   db 0x00		; Disco que esta sendo usado


;|-------------------------[ FUNÇÕES ]---------------------------|

;
; Funcoes para utilizacao do teclado na ativacao do A20
;

cmdbuffempt:			;espera o buffer de comando ficar livre
 in  al,0x64			; porta de comando do teclado
 and al,00000010b		; verifica o bit 1 
 jnz cmdbuffempt		; se al nao for zero quer dizer que este bit esta setado, logo, repete a rotina
 ret				;retorna para a rotina de chamada


outbufffull:			;espera o buffer do teclado ( buffer de resposta ) estar cheio
 in  al,0x64			; porta de comando do teclado
 and al,00000001b		; verifica o bit 0
 jz  outbufffull		; se al for zero quer dizer que o buffer de dados esta vazio ( nao recevemos dados nenhum )
 ret				; caso al for diferente de 0 quer dizer que podemos receber dados

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
   call [escreve]		;
   mov  ah,0x00			;
   int  0x16			;espera uma tecla
   jmp .reseta			; xD
    

;
; Funcao de pesquisa de arquivo ( dentro do diretorio root );
;

pesquisa:

   mov  ax,[setorl]
   mov  [setorb],ax	; salva o setor
   mov  bx,0x8400	;Por mais setores que o bootloader leia
   mov  [addrss],bx	;só ocupara 512bytes de memória ram
   call [lbatochs]	;transforma LBA para CHS
   call ledisco		;faz uma leitura do disco na posição da memória indicada em [addrss]
   mov  cx,16		; sao 16 nomes por setor, caso o arquivo seja encontrado primeiro não será necessario o loop de 16 vezes

     procuranome:	   	;faz a procura do nome desejado


      mov bx,[addrss]		;endereco de pesquisa

       cmp byte [bx],0x00	;verifica se é uma entrada nula
       je  fim			;fim de pesquisa, caso chegar aqui sem arquivo encontrado , entao o arquivo nao existe


       cmp byte [bx], 0xE5	;verifica se eh um arquivo deletado
       je  proximo		;se for, vai para o proximo arquivo

       ;ate aqui o arquivo atendeu as nossas expectativas
       ;hora de verificar o nome 
   
       pusha			;salva os registradores que estavam sendo utilizados anteriormente


       xor cx,cx		; cx sera o contador de string 
       push edi			; Destino
       push esi			; Fonte
 

                  

         verificastring:

           cld
           mov edi,[addrss]	     ; nome lido no disquete
           mov esi,[nome]	     ; nome do arquivo a ser procurado ( apontado pela variavel nome )

           mov  cx,10		     ; 10 leituras           
           rep cmpsb 		     ; faz a comparacao
           jne ncontinua	     ; se nao for igual, vai para ncontinua
           


           ;se estiver aqui entao todas as caracteres sao iguais
      
           mov bx, [addrss]
           mov bx, [bx +0x1a]
           mov word [filecls], bx    ; salva em filecls


           pop esi		     ; Recupera
           pop edi	             ;   os  
           popa			     ;     registradores ( acertando assim a pilha )
                                     ; 

           jmp fim		     ; vai para o fim
       
           
         ncontinua:

           pop esi
           pop edi
           
           popa			     ; recupera os registradores
                                     ; e automaticamente vai para a proxima tentativa

 
                                                   
     proximo:
       dec cx			; decrementa o cx ( contador de loop )
       or  cx,cx		; verifica se é igual a zero
       jz  pesquisar		; se for faz pesquisa novamente ( le outro setor )
       add word [addrss],32	; se nao for vai para o proximo arquivo
       jmp procuranome

     pesquisar:
       mov ax,[setorl]
       inc ax
       mov [setorl],ax        
       cmp ax, [maxsect]	; compara com o maximo de setores que podems ser lidos
       jnle fim
       jmp pesquisa
       

     fim:
      cmp word [filecls],0	; verifica se o cluster é 0 ( o que não é possivel mesmo se for o primeiro arquivo )
      jne .fileok		; se nao for vai para "fileok" que inicia a leitura do arquivo
      mov si,filemsg		; "FileNoFound"
      call [escreve]
      jmp  repete		; vai para o loop infinito

    .fileok:
      push ax
      mov  ax,[setorb]
      mov  [setorl],ax ; restaura o setor
      pop  ax
      ret			  ; retorna para a função de chamada

;
; Função de leitura do arquivo
;

carregaarquivo:

;;
;; Faz a leitura em ES:[addrss]
;; Sendo CX o número de leituras

  mov ax, [filecls]		;
  sub ax, 2			; subtrai dois setores
  add ax, 33			; adiciona maximo de setores

  .carregaarquivon:

  mov  si,lendop		; mensagem de leitura
  call [escreve]		;

  push ax
  push cx

  call [lbatochs]		;transforma LBA para CHS, e coloca nos registrados AX,BX,CX
  call ledisco			;le um setor do arquivo

  pop  cx
  pop  ax

  dec  cx
  inc  ax
  add word [addrss], 0x200	; adiciona 512 bytes ( para ler o proximo setor )
  or   cx,cx			; se cx, que é o contadador
  jz   .fimleitura		; for 0 entao vai para a GDT
  jmp  .carregaarquivon		; se nao for, entao le outro cluster

.fimleitura
 mov  si,linhas
 call [escreve]
 ret				; Retorna para a função de chamada

;|-----------------------[ VARIAVEIS ]---------------------------|

maxsect dw 0			 ; variavel para guardar o número máximo de setores a serem lidos ( p/ o dir. root )
rootdir dw 0			 ; localização do diretório root
filecls dw 0			 ; cluster do arquivo a ser lido



nome    dw 0x0000	 	 ; ponteiro para o nome a ser lido
nome1   db "KERNEL32BIN",0x21	 ; kernel
;nome2   db "TSTE2   BIN",0x20	 ; driver 1

erromsg   db "ERRO [ 1 ] - Falha na leitura de disco. Pressione qualquer tecla para continuar...",13,10,0
filemsg   db 13,10,"ERRO [ 2 ] - Arquivo nao encontrado!",13,10,0
erroagate db "ERRO [ 3 ] - A20 GATE falho!",13,10,0
loadarq   db "Carregando arquivos:",13,10,0
file1     db "kernel.bin",0
;file2     db "tste2.bin",0

lendop  db ".",0		;
linhas  db 13,10,0  	        ; 
setorl  dw 0x0000
setorb  dw 0x0000
addrss  dw 0x0000

;-----------------------------------------------------------------;

;Loop Infinito

repete:
  jmp repete

;|----------------------[ CODIGO 32BITS ]---------------------------|

[BITS 32]

limpapipe:

;atualiza todos os registradores
mov eax,0x10			; configura
mov ds,eax			;   todos
mov es,eax			;     os
mov fs,eax			;  segmentos
mov gs,eax			;     de
mov ss,eax			;   dados

mov eax,0x7C00			;  Ajusta a pilha
mov esp,eax			;  p/ o mesmo endereco
mov ebp,eax			;  da bootloader

;
; passar p/ kernel informações aqui
;


; Sem informações até agora xD


;
; Pular para a kernel
;

jmp 0x08:0x100000

hlt

;|----------------------[ DESCRIPTOR ]---------------------------|

iniciogdt:

 segmento0:		;reservado pela intel
      dd     0
      dd     0
 segmento1:		;segmento de codigo ; 4GB Flat Code at 0x0 with max 0xFFFFF limit
      DW     0xFFFF     ; Limit(2):0xFFFF
      DW     0x0        ; Base(3)
      DB     0x0        ; Base(2)
      DB     10011010b  ; Type: present,ring0,code,exec/read/accessed (10011000) 10011010b
      DB     0xCF       ; Limit(1):0xF | Flags:4Kb inc,32bit (11001111)
      DB     0x0        ; Base(1)

 segmento2:		;segmento de dados ; 4GB Flat Data at 0x0 with max 0xFFFFF limit
      DW     0xFFFF     ; Limit(2):0xFFFF
      DW     0x0        ; Base(3)
      DB     0x0        ; Base(2)
      DB     0x92       ; Type: present,ring0,data/stack,read/write (10010010) 
      DB     0xCF       ;Limit(1):0xF | Flags:4Kb inc,32bit (11001111)
      DB     0x0        ; Base(1)

fimgdt:

gdtdt:
GDTsiz dw fimgdt-iniciogdt-1	; tamanho, ou 0x518 - 0x500 -1
GDTpos dd 0x500			; posicao na memoria ( ele sera colocado ai )

times 2048-($-$$) db 0		;garantir que o arquivo terá 2 KB