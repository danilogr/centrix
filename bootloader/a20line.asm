;
;
; Ativa "A20 Line" ( A20 GATE )
;
;

;
;
; -> Algumas informações do teclado
;
; Port 64h: Interface: data and control
;    -------------------------------------
;    Read: Statusport
;    ----------------
;	bit 0: 1: Keyboard data is in buffer
;	       0: Output buffer empty -> use it to check for results
;	    1: 1: User data is in buffer
;	       0: Command buffer is empty -> time to send a command
;	    2: 1: Selftest successful
;	       0: Reset (?)
;	    3: 1: 64h was last accessed port
;	       0: 60h was last accessed port
;	    4: 1: Keyboard enabled
;	       0: Keyboard locked
;	    5: PS/2: Mouse interface
;	    6: 1: Time-out error occurred: Keyboard or PS/2 mouse didn't
;		  react. Use the Resend command to retry fetching the data
;		  byte. This could happen when trying to get a XT keyboard
;		  to do something :).
;	    7: 1: Last transmission had a parity error
;
; d0h: Puts the outputport on the buffer. Layout:
;
;	     bit 0: 1: Reset processor
;		 1: 1: A20 gate enable
;		 2: PS/2 mouse data out
;		 3: PS/2 mouse clock signal
;		 4: 1: Output buffer full
;		 5: 1: Output buffer PS/2 mouse full
;		 6: Keyboard clock signal
;		 7: Keyboard data out
;
;	 Bit 0 and 1 are quite important for high memory and
;	 286-extended-memory access.
;
;
;
; adh: Deactivate keyboard
;
; aeh: Activate keyboard
;
; d1h: Write the following data byte to the outputport
;
;
; Literalmente, utilizar a porta 0x64 para mandar comando
;               utilizar a porta 0x60 para mandar o complemento do comando ( tipo um byte de dados )
;               utilizar a porta 0x60 para receber respostas de comandos 
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
  call escreve

 fim:
  jmp fim
 
 


 a20ativo:			; rotina executada quando o a20 está ativo

sti				; ativa as interrupcoes	 
 




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


erroagate db "ERRO [ 1 ] - A20 GATE falho!",13,10,0;

escreve:
