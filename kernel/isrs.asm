;
; Centrix ISRs Cnfg
;

;
; Declaracao das ISRs
;

[GLOBAL __isr0]
[GLOBAL __isr1]
[GLOBAL __isr2]
[GLOBAL __isr3]
[GLOBAL __isr4]
[GLOBAL __isr5]
[GLOBAL __isr6]
[GLOBAL __isr7]
[GLOBAL __isr8]
[GLOBAL __isr9]
[GLOBAL __isr10]
[GLOBAL __isr11]
[GLOBAL __isr12]
[GLOBAL __isr13]
[GLOBAL __isr14]
[GLOBAL __isr15]
[GLOBAL __isr16]
[GLOBAL __isr17]
[GLOBAL __isr18]
[GLOBAL __isr19]
[GLOBAL __isr20]
[GLOBAL __isr21]
[GLOBAL __isr22]
[GLOBAL __isr23]
[GLOBAL __isr24]
[GLOBAL __isr25]
[GLOBAL __isr26]
[GLOBAL __isr27]
[GLOBAL __isr28]
[GLOBAL __isr29]
[GLOBAL __isr30]
[GLOBAL __isr31]

;
; Exceções
;

;Exception #  	Description  	                   Error Code?
;          0 	 Division By Zero Exception 	        No
;          1 	 Debug Exception 	                    No
;          2 	 Non Maskable Interrupt Exception 	    No
;          3 	 Breakpoint Exception 	                No
;          4 	 Into Detected Overflow Exception 	    No
;          5 	 Out of Bounds Exception 	            No
;          6 	 Invalid Opcode Exception 	            No
;          7 	 No Coprocessor Exception 	            No
;          8 	 Double Fault Exception 	            Yes
;          9 	 Coprocessor Segment Overrun Exception  No
;          10 	 Bad TSS Exception 	                    Yes
;          11 	 Segment Not Present Exception 	        Yes
;          12 	 Stack Fault Exception 	                Yes
;          13 	 General Protection Fault Exception     Yes
;          14 	 Page Fault Exception 	                Yes
;          15 	 Unknown Interrupt Exception 	        No
;          16 	 Coprocessor Fault Exception 	        No
;          17 	 Alignment Check Exception (486+) 	    No
;          18 	 Machine Check Exception (Pentium/586+) No
;19 to 31 	     Reserved Exceptions 	                No

;
; ISRs
;

__isr0:
    cli        
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 0       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr1:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 1       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr2:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 2       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr3:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 3       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr4:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 4       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr5:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 5       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr6:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 6       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr7:
    cli              
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 7       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr8:
    cli       
                      ; nao eh necessario colocar um codigo de erro ( ja que essa exceção tem um proprio )
    push byte 8       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr9:
    cli       
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 9       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr10:
    cli        
    push byte 10       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr11:
    cli        
    push byte 11       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr12:
    cli         
    push byte 12       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr13:
    cli        
    push byte 13       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr14:
    cli        
    push byte 14       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr15:
    cli        
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 15      ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr16:
    cli        
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 16       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr17:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 17       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr18:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 18       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr19:
    cli        
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 19       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr20:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 20       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr21:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 21       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr22:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 22       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr23:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 23      ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr24:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 24       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr25:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 25       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr26:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 26       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr27: 
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 27       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr28:
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 28       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr29: 
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 29       ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr30: 
    cli
    push byte 0       ;codigo de erro ( como nao tem colocamos um zero)
    push byte 30      ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    
__isr31:
    cli
    push byte 0        ;codigo de erro ( como nao tem colocamos um zero)
    push byte 31      ;numero da interrupcao
    jmp  _isrs_hwnd   ;vai para o hwnder de isrs
    




;
; Hanlder das interrupções ( responsavel para direcionar isso para outra parte da kernel )
;

[EXTERN __isrs_hwnd]

; A CPU  salva os registradores SS, EIP, ESP, e CS na pilha
; portanto temos que salvar os outros
_isrs_hwnd:
   pusha         ; salva todos os registradores comuns
   push ds       ; data segment
   push es       ; extra segment
   push fs       ;
   push gs       ;

   mov eax,cr2   ; passa o cr2 para a pilha 
   push eax      ; ( utilizado para obter o endereço de erro quando ocorre uma exceção Page Fault )

   mov ax, 0x10  ; Segmento da kernel ( para caso essa interrupcao tenha ocorrido em outro segmento ) 
   mov ds, ax    ; 
   mov es, ax    ;
   mov fs, ax    ;
   mov gs, ax    ;
   
   mov eax, esp  ; passa a pilha como parametro
   push eax      ;

   mov eax, __isrs_hwnd
   call eax      ; chama a funcao que gerencia as exceções
  
   pop  eax       ;
   pop  eax       ;
   pop  gs        ;
   pop  fs        ;
   pop  es        ;
   pop  ds        ;
   popa           ; 
   add esp, 8     ; limpa o codigo de erro e o numero da interrupcao da pilha
   iret           ; retorno de interrupcao ( restaura da pilha tambem os registradores CS, EIP, EFLAGS, SS, e ESP )
