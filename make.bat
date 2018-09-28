@echo off
set /p AsmFile=file (omit extension):
..\bin\ca65 -t apple2enh -v %AsmFile%.asm
..\bin\ld65 -C apple2enh-dev.cfg -o %AsmFile% %AsmFile%.o --lib apple2enh.lib