#include "variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
Global $Title = $Name & " v" & $Version & " Installer"
If _Singleton($Name & " Installer" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, $Name & " Installer" & " is already running!")
    Exit
ElseIf _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, $Name & " is currently running and needs to be shut down before you may install!")
    Exit
EndIf
If Not DirCopy($Name, @ProgramFilesDir & "\" & $Name, 1) Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while copying files to the programs folder!")
    Exit
EndIf
If Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayName", "REG_SZ", $Name & " v" & $Version) Or Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "UninstallString", "REG_SZ", '"' & @ProgramFilesDir & "\" & $Name & '\Uninstall.exe"') Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while creating the uninstaller registry keys!")
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & ".lnk")
If Not FileCreateShortcut(@ProgramFilesDir & "\" & $Name & "\" & $Name & ".exe", @DesktopCommonDir & "\" & $Name & ".lnk", @ProgramFilesDir & "\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while creating a shortcut to the desktop!")
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & " Donation.lnk")
If Not FileCreateShortcut(@ProgramFilesDir & "\" & $Name & "\Donation.html", @DesktopCommonDir & "\" & $Name & " Donation.lnk", @ProgramFilesDir & "\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, "An error occurred while creating a shortcut to the desktop!")
    Exit
EndIf
MsgBox($MB_OK, $Title, "Successfully installed " & $Name & " v" & $Version & ".")