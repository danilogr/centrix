;
; Centrix IDT Cnfg
;

[GLOBAL _idt_reg]	;registra a IDT

;
; Funcao que registra a IDT
;


[extern __idt] 		; idt
[extern __idtprt]	; ponteiro para a IDT

_idt_reg:
   lidt [__idtprt]	; registra a nova IDT
   ret			; retorna para a funcao de chamada  

;
;  Funcao padrao de erro ( substitui isrs inexistentes)
;
[extern _idterro_hwnd]
[GLOBAL _idt_erro]
_idt_erro:
   cli
   push byte 0
   push byte 0
   pusha         ; salva todos os registradores comuns
   push ds       ; data segment
   push es       ; extra segment
   push fs       ;
   push gs       ;

   mov eax,cr2   ; passa o cr2 para a pilha 
   push eax      ; ( utilizado para obter o endereço de erro quando ocorre uma exceção Page Fault )

   mov ax, 0x10  ; Segmento de dados ring 0 ( para caso essa interrupcao tenha ocorrido em outro segmento ) 
   mov ds, ax    ; 
   mov es, ax    ;
   mov fs, ax    ;
   mov gs, ax    ;
   
   mov eax, esp  ; passa a pilha como parametro
   push eax      ;

   mov eax, _idterro_hwnd
   call eax      ; chama a funcao que gerencia esse erro
  
   pop  eax       ;
   pop  eax       ;   
   pop  gs        ;
   pop  fs        ;
   pop  es        ;
   pop  ds        ;
   popa           ; 
   add esp, 8     ; limpa o codigo de erro e o numero da interrupcao da pilha
   iret           ; retorno de interrupcao ( restaura da pilha tambem os registradores CS, EIP, EFLAGS, SS, e ESP )
    


  
   
