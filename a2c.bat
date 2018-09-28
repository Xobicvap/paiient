@echo off
set /p AsmFile=file (omit extension):
set /p FileName=capitalized filename:
copy MASTER.DSK %AsmFile%.dsk
echo "java -jar ..\a2c\ac.jar -p %AsmFile%.dsk %FileName% B 0x900 < %AsmFile%"
java -jar ..\a2c\ac.jar -p %AsmFile%.dsk %FileName% B 0x900 < %AsmFile%

C:\Users\Rusty\Desktop\apple18j\APPLEWIN.exe -d1 %AsmFile%.dsk
