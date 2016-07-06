@ECHO OFF
SET VERSION=6.7.1
SET NAME=Neverwinter Invoke Bot
SET INSTALLER=NeverwinterInvokeBot
SET EXE=Uninstall,ImageCapture,ScreenDetection,ListPID

(
    ECHO [version]
    ECHO version=%VERSION%
) > version.ini

(
    ECHO #include-once
    ECHO Global $Name = "%NAME%"
    ECHO Global $Version = "%VERSION%"
) > .\Install\variables.au3

FOR %%i IN ("%EXE:,=" "%") DO "%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\%%~i.au3" /out ".\Install\%NAME%\%%~i.exe" /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\%NAME%.au3" /out ".\Install\%NAME%\%NAME%.exe" /icon icon.ico /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in .\Install\setup.au3 /out .\Install\setup.exe /nopack /x86

DEL %INSTALLER%.exe
"%ProgramFiles%\7-Zip\7z.exe" a Installer.7z .\Install\* -r -x!Thumbs.db -x!ehthumbs.db -x!Desktop.ini -x!*.au3 -x!*.kxf

(
    ECHO ^;^!@Install@!UTF-8^!
    ECHO Title="%NAME% v%VERSION% Installer"
    ECHO BeginPrompt="Do you want to install %NAME% v%VERSION%?"
    ECHO RunProgram="setup.exe"
    ECHO ^;^!@InstallEnd@^!
) > config.txt

COPY /b 7zS.sfx + config.txt + Installer.7z %INSTALLER%.exe

DEL Installer.7z
DEL config.txt
DEL .\Install\setup.exe
DEL ".\Install\%NAME%\%NAME%.exe"
FOR %%i IN ("%EXE:,=" "%") DO DEL ".\Install\%NAME%\%%~i.exe"

PAUSE
