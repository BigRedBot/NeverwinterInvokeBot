#NoTrayIcon
#RequireAdmin
#include "..\variables.au3"
Global $Title = $Name & " v" & $Version & " Uninstaller"
#include <MsgBoxConstants.au3>
If Not @Compiled Then Exit MsgBox($MB_ICONWARNING, $Title, "The script must be a compiled exe to work correctly!")
#include <Misc.au3>
#include "Localization.au3"
LoadLocalizations(0, 0, 0)
If _Singleton($Name & " Uninstaller" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("UninstallerAlreadyRunning"))
    Exit
EndIf
#include "_SelfDelete.au3"

If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DoYouWantToUninstall", "<VERSION>", $Version)) <> $IDYES Then
    Exit
EndIf

Local $delete = StringSplit(@StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk," & @DesktopCommonDir & "\" & $Name & ".lnk," & @DesktopCommonDir & "\" & $Name & " Donation.lnk," & $Name & ".exe,ImageCapture.exe,ScreenDetection.exe,Unattended.exe,DonationPrompt.exe", ",")
FileChangeDir(@ScriptDir)
For $i = 1 To $delete[0]
    If FileExists($delete[$i]) And Not FileDelete($delete[$i]) Then
        MsgBox($MB_ICONWARNING, $Title, Localize("FailedToDeleteFile", "<FILE>", $delete[$i]))
        Exit
    EndIf
Next

Local $RegLocation = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name

If ( RegRead($RegLocation, "DisplayName") <> "" Or RegRead($RegLocation, "DisplayVersion") <> "" Or RegRead($RegLocation, "Publisher") <> "" Or RegRead($RegLocation, "DisplayIcon") <> "" Or RegRead($RegLocation, "UninstallString") <> "" Or RegRead($RegLocation, "InstallLocation") <> "" ) And Not RegDelete($RegLocation) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("FailedToDeleteRegistry"))
    Exit
EndIf

If FileExists(@AppDataCommonDir & "\" & $Name) And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("KeepSettingsFiles")) <> $IDYES Then
    DirRemove(@AppDataCommonDir & "\" & $Name, 1)
EndIf

_SelfDelete(5, 1, 1)
If @error = 1 Then Exit MsgBox($MB_ICONWARNING, "_SelfDelete()", "The script must be a compiled exe to work correctly!")
If @error = 2 Then Exit MsgBox($MB_ICONWARNING, "_SelfDelete()", "Unable to create temporary deletion script file!")