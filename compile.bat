@echo off
..\bin\ca65 -t apple2enh -v constants.asm
..\bin\ca65 -t apple2enh -v math.asm
..\bin\ca65 -t apple2enh -v utilities.asm
..\bin\ca65 -t apple2enh -v hgr_color_change_handler.asm
..\bin\ca65 -t apple2enh -v hgr_text_write.asm
..\bin\ca65 -t apple2enh -v hgr_compute_vram.asm
..\bin\ca65 -t apple2enh -v hgr_write_vram.asm
..\bin\ca65 -t apple2enh -v hgr_menu_handler.asm
..\bin\ca65 -t apple2enh -v paiient.asm

echo If no errors occurred, assembly succeeded! Linking...
set AsmFile=paiient
set FileName=PAIIENT

..\bin\ld65 -C apple2enh-dev.cfg -o paiient --lib apple2enh.lib paiient.o constants.o math.o utilities.o hgr_color_change_handler.o hgr_text_write.o hgr_compute_vram.o hgr_write_vram.o hgr_menu_handler.o 

echo Linked all object files. Assembling disk image...
copy MASTER.DSK paiient.dsk
echo java -jar ..\a2c\ac.jar -p paiient.dsk PAIIENT B 0x900 < paiient
java -jar ..\a2c\ac.jar -p paiient.dsk PAIIENT B 0x900 < paiient
C:\Users\Rusty\Desktop\apple18j\APPLEWIN.exe -d1 paiient.dsk