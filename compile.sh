MSG=$'Assembling...\n\n'
echo "$MSG"

export A2CLOC="/home/rusty.hamilton/.local/bin"
export CC65CFG="/home/rusty.hamilton/.local/lib/cc65/cfg"
export CC65LIB="/home/rusty.hamilton/.local/lib/cc65/lib"

ca65 -t apple2enh -v constants.asm
ca65 -t apple2enh -v math.asm

ca65 -t apple2enh -v constants.asm
ca65 -t apple2enh -v math.asm
ca65 -t apple2enh -v utilities.asm
ca65 -t apple2enh -v hgr_color_change_handler.asm
ca65 -t apple2enh -v hgr_text_write.asm
ca65 -t apple2enh -v hgr_compute_vram.asm
ca65 -t apple2enh -v hgr_write_vram.asm
ca65 -t apple2enh -v hgr_line.asm
ca65 -t apple2enh -v hgr_menu_handler.asm
ca65 -t apple2enh -v paiient.asm

MSG=$'If no errors occurred, assembly succeeded! Linking...\n'
echo "$MSG"

ld65 -C $CC65CFG/apple2enh-dev.cfg -o paiient --lib $CC65LIB/apple2enh.lib paiient.o constants.o math.o utilities.o hgr_color_change_handler.o hgr_text_write.o hgr_compute_vram.o hgr_write_vram.o hgr_menu_handler.o hgr_line.o

MSG=$'Linked all object files. Assembling disk image...\n\n'
echo "$MSG"

MSG=$'Creating base PAIIent disk image from generic image...\n'
echo "$MSG"

cp MASTER.DSK paiient.dsk

MSG=$'Performing AppleCommander task:\n'
echo "$MSG"

echo "java -jar $A2CLOC/ac.jar -p paiient.dsk PAIIENT B 0x900 < paiient"
java -jar $A2CLOC/ac.jar -p paiient.dsk PAIIENT B 0x900 < paiient
cp paiient.dsk ~/microM8/MyDisks

microm8 -launch paiient.dsk
