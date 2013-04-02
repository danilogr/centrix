@echo off
set prompt=build - 

ECHO BUILD - Configurando compilador...
chdir C:\centrix
set pasta=C:\centrix
echo.

ECHO BUILD - Removendo arquivos antigos
del %pasta%\*.o
del %pasta%\kernel32.bin
echo.

ECHO BUILD - Compilando kernel start ( ks.asm )
nasm -f aout -I %pasta%\kernel\ -o %pasta%\ks.o %pasta%\kernel\ks.asm
echo.

ECHO BUILD - Compilando kernel ( kernel.c )
REM gcc -Wall -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -B %pasta%\ -c -o %pasta%\kernel\kernel.o %pasta%\kernel\kernel.c
gcc -c %pasta%\kernel\kernel.c -o %pasta%\kernel.o -B C:\centrix\
echo.

echo.
echo #########################################################
echo #		 	        			#
echo #		 	 Sources		        #
echo #		 	  	        		#
echo #########################################################
echo.

ECHO BUILD - Compilando sysutils ( sysutils.asm )
nasm -f aout -o %pasta%\sysutils.o %pasta%\source\sysutils.asm
echo.

ECHO BUILD - Compilando VGA ( vga.c )
REM gcc -Wall -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -B %pasta% -c -o %pasta%\source\vga.o %pasta%\source\vga.c
gcc -c %pasta%\source\vga.c -o %pasta%\vga.o -B C:\centrix\
echo.

ECHO BUILD - Compilando sysutils2 ( sysutils.c )
gcc -c %pasta%\source\sysutils.c -o %pasta%\sysutils2.o -B C:\centrix\
echo.

ECHO BUILD - Compilando IDT ( idt.c )
gcc -c %pasta%\source\cpu\idt.c -o %pasta%\idt.o -B C:\centrix\
echo.

ECHO BUILD - Compilando ISRS ( isrs.c )
gcc -c %pasta%\source\cpu\isrs.c -o %pasta%\isrs.o -B C:\centrix\
echo.

ECHO BUILD - Compilando IRQ ( irq.c )
gcc -c %pasta%\source\irq.c -o %pasta%\irq.o -B C:\centrix\
echo.

ECHO BUILD - Compilando memtest ( memtest.asm )
nasm -f aout -o %pasta%\memtest.o %pasta%\source\mm\memtest.asm
echo.

ECHO BUILD - Compilando pmm ( pmm.c )
gcc -c %pasta%\source\mm\pmm.c -o %pasta%\pmm.o -B C:\centrix\
echo.



ECHO BUILD - Linkando a kernel
ld -T link.ld -o kernel32.bin ks.o kernel.o sysutils.o sysutils2.o vga.o idt.o isrs.o irq.o memtest.o pmm.o
echo.

ECHO BUILD - Salvando no disquete

attrib -S -H +A -R a:\kernel32.bin
copy %pasta%\kernel32.bin a:\
attrib +S +H +A +R a:\kernel32.bin

set prompt=

pause
