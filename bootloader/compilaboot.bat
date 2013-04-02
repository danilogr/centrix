@echo off
set prompt=build - 

ECHO BUILD - Configurando compilador...
set pasta=C:\centrix\bootloader
echo.

ECHO BUILD - Removendo arquivo anterior
del %pasta%\boot2s.bin
echo.

ECHO BUILD - Compilando nova versao
nasm -f bin -o %pasta%\boot2s.bin %pasta%\boot2s.asm
echo.

echo.
echo Finalizado
pause


set prompt=