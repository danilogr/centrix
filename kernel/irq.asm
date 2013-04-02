;
; Centrix IRQ
;

;
; Declaracao das IRQs
;

[GLOBAL __irq0]
[GLOBAL __irq1]
[GLOBAL __irq2]
[GLOBAL __irq3]
[GLOBAL __irq4]
[GLOBAL __irq5]
[GLOBAL __irq6]
[GLOBAL __irq7]
[GLOBAL __irq8]
[GLOBAL __irq9]
[GLOBAL __irq10]
[GLOBAL __irq11]
[GLOBAL __irq12]
[GLOBAL __irq13]
[GLOBAL __irq14]
[GLOBAL __irq15]

;
; Utilizacao ( padrao, mas pode ser modificado* )
; *o que nao esta definido como fixo

;IRQ 0 - Sinal de clock da placa mãe (fixo)
;IRQ 1 - Teclado (fixo)
;IRQ 2 - Cascateador de IRQs (fixo)
;IRQ 3 - Porta serial 2
;IRQ 4 - Porta serial 1
;IRQ 5 - Livre
;IRQ 6 - Drive de disquetes
;IRQ 7 - Porta paralela (impressora)
;IRQ 8 - Relógio do CMOS (fixo)
;IRQ 9 - Placa de vídeo
;IRQ 10 - Livre
;IRQ 11 - Controlador USB
;IRQ 12 - Porta PS/2
;IRQ 13 - Coprocessador aritmético
;IRQ 14 - IDE Primária
;IRQ 15 - IDE Secundária

;
; irqs
;

__irq0:
    cli        
    push byte 0       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq1:
    cli       
    push byte 1       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq2:
    cli       
    push byte 2       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq3:
    cli       
    push byte 3       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq4:
    cli       
    push byte 4       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq5:
    cli       
    push byte 5       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq6:
    cli       
    push byte 6       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq7:
    cli              
    push byte 7       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq8:
    cli       
    push byte 8       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq9:
    cli       
    push byte 9       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq10:
    cli        
    push byte 10       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq11:
    cli        
    push byte 11       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq12:
    cli         
    push byte 12       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq13:
    cli        
    push byte 13       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq14:
    cli        
    push byte 14       ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    
__irq15:
    cli         
    push byte 15      ;numero da irq
    jmp  _irqs_hwnd   ;vai para o hwnder de irqs
    

;
; Hanlder das interrupções ( responsavel para direcionar isso para outra parte da kernel )
;

[EXTERN __irqs_hwnd]

; A CPU  salva os registradores SS, EIP, ESP, e CS na pilha
; portanto temos que salvar os outros
_irqs_hwnd:
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

   mov eax, __irqs_hwnd
   call eax      ; chama a funcao que gerencia as irqs
  
   pop  eax       ;
   pop  eax       ;
   pop  gs        ;
   pop  fs        ;
   pop  es        ;
   pop  ds        ;
   popa           ; 
   add esp, 4     ; limpa o nº da irq da pilha
   iret           ; retorno de interrupcao ( restaura da pilha tambem os registradores CS, EIP, EFLAGS, SS, e ESP )
