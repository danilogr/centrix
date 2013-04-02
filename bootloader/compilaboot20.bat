@echo off
set prompt=build - 

ECHO BUILD - Configurando compilador...
chdir C:\centrix\bootloader
set pasta=C:\centrix\bootloader
echo.

ECHO BUILD - Removendo arquivo anterior
del boot2s.bin
echo.

ECHO BUILD - Compilando nova versao
nasm -f bin -o boot2s.bin boot2s_ver1.asm
echo.

echo.
echo Finalizado
pause


set prompt=