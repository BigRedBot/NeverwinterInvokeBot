#NoTrayIcon
#RequireAdmin
#include "variables.au3"
Global $Title = $Name & " v" & $Version & " Uninstaller"
#include <MsgBoxConstants.au3>
If Not @Compiled Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, "The script must be a compiled exe to work correctly!")
#include <Misc.au3>
#include <File.au3>
#include <FileConstants.au3>
#include "Localization.au3"
LoadLocalizations(0, 0, 0)
If _Singleton("Neverwinter Invoke Bot Uninstaller" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UninstallerAlreadyRunning"))
#include "_SelfDelete.au3"

If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_TOPMOST, $Title, Localize("DoYouWantToUninstall", "<VERSION>", $Version)) <> $IDYES Then Exit

Local $deleteshortcuts = StringSplit(@StartupCommonDir & "\" & $Name & ".lnk" & "|" & @StartupCommonDir & "\Neverwinter Invoke Bot Unattended Launcher.lnk" & "|" & @DesktopCommonDir & "\" & $Name & ".lnk" & "|" & @DesktopCommonDir & "\Neverwinter Fishing Bot.lnk" & "|" & @DesktopCommonDir & "\Neverwinter Invoke Bot Donation.lnk" & "|" & @DesktopCommonDir & "\Simple Bank Referral.lnk", "|")
For $i = 1 To $deleteshortcuts[0]
    If FileExists($deleteshortcuts[$i]) And Not FileDelete($deleteshortcuts[$i]) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteFile", "<FILE>", $deleteshortcuts[$i]))
Next

Local $delete = _FileListToArray(@ScriptDir, "*", $FLTA_FILES)
If @error <> 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteFile", "<FILE>", @ScriptDir))
For $i = 1 To $delete[0]
    If $delete[$i] <> "Uninstall.exe" And $delete[$i] <> "Localization.ini" And Not FileDelete(@ScriptDir & "\" & $delete[$i]) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteFile", "<FILE>", @ScriptDir & "\" & $delete[$i]))
Next

Local $RegLocation = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name

If ( RegRead($RegLocation, "DisplayName") <> "" Or RegRead($RegLocation, "DisplayVersion") <> "" Or RegRead($RegLocation, "Publisher") <> "" Or RegRead($RegLocation, "DisplayIcon") <> "" Or RegRead($RegLocation, "UninstallString") <> "" Or RegRead($RegLocation, "InstallLocation") <> "" ) And Not RegDelete($RegLocation) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteRegistry"))

If FileExists(@AppDataDir & "\" & $Name) And MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_TOPMOST, $Title, Localize("KeepSettingsFiles")) <> $IDYES Then DirRemove(@AppDataDir & "\" & $Name, 1)

_SelfDelete(5, 1, 1)
If @error = 1 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, "Self Delete", "The script must be a compiled exe to work correctly!")
If @error = 2 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, "Self Delete", "Unable to create temporary deletion script file!")
