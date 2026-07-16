@echo FreeLaunch Copyright (C) 2026 ALexey Tatuyko
@echo This program comes with ABSOLUTELY NO WARRANTY.
@echo This is free software, and you are welcome to redistribute it under certain conditions.
@echo ============================================
@echo Let's go!
@echo off
if not exist "bin\FLaunch.exe" (
  echo Error: bin\FLaunch.exe not found. Compile FreeLaunch in the IDE first.
  pause
  exit /b 1
)
@echo Cleaning garbage
del /f /q *.zip
del /f /q "bin\*.txt"
del /f /q "bin\*.drc"
del /f /q "bin\*.map"
del /f /q "bin\*.xml"
del /f /q "..\sources\Win32\Debug\*"
del /f /q "..\sources\Win32\Release\*"
rd /s /q "bin\help"
rd /s /q "bin\languages"
rd /s /q "bin\IconCache"
rd /s /q "..\sources\Win32\Debug"
rd /s /q "..\sources\Win32\Release"
rd /s /q "..\sources\Win32"
@echo Copying files
@echo off
xcopy "..\AUTHORS.txt" "bin" /c /q /r /y
xcopy "..\COPYING.txt" "bin" /c /q /r /y
xcopy "..\THANKS.txt" "bin" /c /q /r /y
md bin\languages
xcopy "..\localizations\*.lng" "bin\languages" /c /q /r /y
xcopy "..\docs" "bin\help" /s /c /i /q /r /y
@echo Adding files to archive
7zextra\7za.exe a -tzip freelaunch.zip .\bin\*
@echo Done!
pause