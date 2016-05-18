@ECHO OFF
SET VERSION=5.4.1
SET NAME=Neverwinter Invoke Bot
SET INSTALLER=NeverwinterInvokeBot
SET EXE=%NAME%,Uninstall,ImageCapture,ScreenDetection

(
    ECHO [version]
    ECHO version=%VERSION%
) > version.ini

(
    ECHO #include-once
    ECHO Global $Name = "%NAME%"
    ECHO Global $Version = "%VERSION%"
) > .\Install\variables.au3

FOR %%i IN ("%EXE:,=" "%") DO "%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\%%~i.au3" /out ".\Install\%NAME%\%%~i.exe"
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in .\Install\setup.au3 /out .\Install\setup.exe

DEL %INSTALLER%.exe
"%ProgramFiles%\7-Zip\7z.exe" a Installer.7z .\Install\* -r -x!Thumbs.db -x!ehthumbs.db -x!Desktop.ini -x!*.au3

(
    ECHO ^;^!@Install@!UTF-8^!
    ECHO Title="%NAME% v%VERSION% Installer"
    ECHO BeginPrompt="Do you want to install %NAME% v%VERSION%?"
    ECHO RunProgram="setup.exe"
    ECHO ^;^!@InstallEnd@^!
) > config.txt

COPY /b 7zS.sfx + config.txt + Installer.7z %INSTALLER%.exe

PAUSE
DEL Installer.7z
DEL config.txt
DEL .\Install\setup.exe
FOR %%i IN ("%EXE:,=" "%") DO DEL ".\Install\%NAME%\%%~i.exe"