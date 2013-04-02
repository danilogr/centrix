 
mov ebx,edi			  ; passa o valor de EDI p/ EAX
sub ebx,4			  ; reduz em 4 bytes EAX ( EDI )
add ebx,0x100000		  ; adiciona 1 MB 
mov edi,ebx			  ;
   
   
nome db "testando o codigo";