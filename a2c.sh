# here it's assumed java is on your path
# and you have installed AppleCommander at the location specified in the README

echo "file (omit extension)"
read ASMFILE
FILENAME=`echo "${ASMFILE}" | tr a-z A-Z`

cp MASTER.DSK "${ASMFILE}.dsk"
echo "java -jar ../a2c/ac.jar -p ${ASMFILE}.dsk ${FILENAME} B 0x900 < ${ASMFILE}"
java -jar ../a2c/ac.jar -p "${ASMFILE}.dsk ${FILENAME}" B 0x900 < "${ASMFILE}"

# you'll have to do apple iie emulator run yourself below:
