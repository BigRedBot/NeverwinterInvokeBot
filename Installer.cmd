@ECHO OFF
IF "%~1" == "" EXIT
IF "%~2" == "" EXIT
IF "%~3" == "" EXIT
SET VERSION=%~1
SET NAME=%~2
SET INSTALLER=%~3
ECHO Compiling: %NAME% v%VERSION%

IF "%~4" == "Beta" GOTO Beta

(
    ECHO [version]
    ECHO version=%VERSION%
) > version.ini

:Beta

(
    ECHO #include-once
    ECHO Global $Name = "%NAME%"
    ECHO Global $Version = "%VERSION%"
) > .\Install\variables.au3

COPY CHANGELOG.md ".\Install\%NAME%\CHANGELOG.txt" /Y

"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\%NAME%.au3" /out ".\Install\%NAME%\%NAME%.exe" /icon ".\Install\%NAME%\images\red.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\Unattended.au3" /out ".\Install\%NAME%\Unattended.exe" /icon ".\Install\%NAME%\images\blue.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\ScreenDetection.au3" /out ".\Install\%NAME%\ScreenDetection.exe" /icon ".\Install\%NAME%\images\black.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\ScreenDetectionProfessions.au3" /out ".\Install\%NAME%\ScreenDetectionProfessions.exe" /icon ".\Install\%NAME%\images\black.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\ScreenDetectionFishing.au3" /out ".\Install\%NAME%\ScreenDetectionFishing.exe" /icon ".\Install\%NAME%\images\black.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\Neverwinter Fishing Bot.au3" /out ".\Install\%NAME%\Neverwinter Fishing Bot.exe" /icon ".\Install\%NAME%\images\green.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\ImageCapture.au3" /out ".\Install\%NAME%\ImageCapture.exe" /icon ".\Install\%NAME%\images\purple.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\Uninstall.au3" /out ".\Install\%NAME%\Uninstall.exe" /icon ".\Install\%NAME%\images\yellow.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\OpenProfessionBags.au3" /out ".\Install\%NAME%\OpenProfessionBags.exe" /icon ".\Install\%NAME%\images\teal.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\PullRPFromGuildBank.au3" /out ".\Install\%NAME%\PullRPFromGuildBank.exe" /icon ".\Install\%NAME%\images\teal.ico" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in ".\Install\%NAME%\DonationPrompt.au3" /out ".\Install\%NAME%\DonationPrompt.exe" /comp 0 /nopack /x86
"%ProgramFiles(x86)%\AutoIt3\Aut2Exe\Aut2exe.exe" /in .\Install\setup.au3 /out .\Install\setup.exe /comp 0 /nopack /x86

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

PAUSE

DEL Installer.7z
DEL config.txt
DEL .\Install\*.exe
DEL ".\Install\%NAME%\*.exe"
