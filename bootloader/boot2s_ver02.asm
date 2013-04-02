;
;
;   Vision2 -> Carrega a kernel
;   -> Novo modo de leitura
;  
;   -> ADICIONAR EM BREVE: 
;   -> Leitura dinamica de arquivo, definir nome do arquivo / posicao da memoria  e ler ( somente para discos desfragmentados )
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

;|--------------------------[  CÓDIGO  ]-------------------------|

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

pesquisa:
   mov  ax,[setorl]
   mov  bx,0x8400	;Por mais setores que o bootloader leia
   mov  [addrss],bx	;só ocupara 512bytes de memória ram
   call [lbatochs]	;transforma LBA para CHS
   call ledisco		;faz uma leitura do disco na posição da memória indicada em [addrss]
   mov  cx,16		; sao 16 nomes por setor, caso o arquivo seja encontrado primeiro não será necessario o loop de 16 vezes

     procuranome:	   	;faz a procura do nome desejado


      mov bx,[addrss]		;endereco de pesquisa

       cmp byte [bx],0x00	;verifica se é uma entrada nula
       je  fim			;fim de pesquisa, caso chegar aqui sem arquivo encontrado , entao o arquivo nao existe

       cmp byte [bx + 0x0b],0x27;verifica se é um arquivo, somente leitura,   de sistema  e oculto, 0x27 
       jne proximo		;se nao for refaz a pesquisa
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
           mov esi,nome			     ; nome do arquivo a ser procurado

           mov  cx,10		     ; 10 leituras           
           rep cmpsb 		     ; faz a comparacao
           jne ncontinua	     ; se nao for igual, vai para ncontinua
           


           ;se estiver aqui entao todas as caracteres sao iguais
      
           mov bx, [addrss]
           mov bx, [bx +0x1a]
           mov word [filecls], bx    ; salva em filecls


           ;mov bx,[bx + 0x1c]
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
      jne fileok		; se nao for vai para "fileok" que inicia a leitura do arquivo
      mov si,filemsg		; "FileNoFound"
      call [escreve]
      jmp  repete		; vai para o loop infinito
       

;________________________________________________________________________________

;
; Aqui o arquivo foi encontrado com sucesso !! xD [GAD]
; ->Hora de fazer um loop [ le setor determinado ]
;
; Carrega o arquivo na marca dos 1MB
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


;
; Conseguir algumas informações do computador ( através da BIOS ) para passar para a kernel
;


;
; Nao necessario , por enquanto
;  



;
; Carregar o arquivo em 0x100000 (1º MB da memoria)
;

mov ax,0xFFFF			; Utilizaremos da segmentação para obter
mov es,ax			; os tao queridos 1MB

mov bx,0x0010			; logo 0xFFFF << 4 + 0x0010 => 0xFFFF0 + 0x0010 => 0x100000 ( 1 MB )
mov [addrss],bx			; salva o endereco

mov ax, [filecls]		;
sub ax, 2			; subtrai dois setores
add ax, 33			; adiciona maximo de setores

mov  si,kernelloa		; kernel carregando ...
call [escreve]			;


mov cx, 20			; 20 clusters ( 10 kb )
carregakernel:

  mov  si,lendop		; mensagem de leitura
  call [escreve]

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
  jz   modoprotegido		; for 0 entao vai para a GDT
  jmp  carregakernel		; se nao for, entao le outro cluster



modoprotegido:


     mov  si,linhas
     call [escreve]

;
; Mover a GDT para 0x500
;

 xor ax,ax
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


;________________________________________________________________________________


repete:
  jmp repete		; loop infinito





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
    

;|-----------------------[ VARIAVEIS ]---------------------------|

maxsect dw 0			 ; variavel para guardar o número máximo de setores a serem lidos ( p/ o dir. root )
rootdir dw 0			 ; localização do diretório root
filecls dw 0			 ; cluster do arquivo a ser lido
nome    db "KERNEL32BIN",0x21	 ; Nome do arquivo a ser lido
erromsg   db "ERRO [ 1 ] - Falha na leitura de disco. Pressione qualquer tecla para continuar...",13,10,0
filemsg   db "ERRO [ 2 ] - Arquivo nao encontrado!",13,10,0
erroagate db "ERRO [ 3 ] - A20 GATE falho!",13,10,0
memerrom  db "ERRO [ 4 ] - Erro determinando memoria RAM!",13,10,0
kernelloa db "Carregando kernel",0
lendop  db ".",0		;
linhas  db 13,10,0  	        ; 
setorl  dw 0x0000
addrss  dw 0x0000


;|-----------------[ VARIAVEIS A SEREM PASSADAS]--------------------|
;variaveis que seram passadas através da pilha para a kernel



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
mov ebp,eax			;  da kernel

;
; passar p/ kernel informações aqui
;


;push word [mem_ex1]


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
GDTsiz dw fimgdt-iniciogdt-1		; tamanho, ou 0x518 - 0x500 -1
GDTpos dd 0x500			; posicao na memoria ( ele sera colocado ai )

times 2048-($-$$) db 0		;garantir que o arquivo terá 2 KB

