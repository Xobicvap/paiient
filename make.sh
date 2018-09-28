echo "file (omit extension):"
read ASMFILE

# it's assumed since it's easier to add to $PATH in *nix,
# that you have cc65 on your $PATH
ca65 -t apple2enh -v "${ASMFILE}.asm"
ld65 -C apple2enh-dev.cfg -o "${ASMFILE}" "${ASMFILE}.o" --lib apple2enh.lib
