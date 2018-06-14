#NoTrayIcon
#include "variables.au3"
#include <MsgBoxConstants.au3>
Global $Title = $Name & " v" & $Version & " Installer"
If Not @Compiled Then Exit MsgBox($MB_ICONWARNING, $Title, "The script must be a compiled exe to work correctly!")
#include <Misc.au3>
#include <WinAPIFiles.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <FileConstants.au3>
#include ".\Neverwinter Invoke Bot\_GUIScrollbars_Ex.au3"
#include ".\Neverwinter Invoke Bot\_UnicodeIni.au3"
#include ".\Neverwinter Invoke Bot\Localization.au3"
Local $Language = LoadLocalizations(1, @ScriptDir & "\" & $Name & "\Localization.ini", 0)

Local $InstallDir = @ProgramFilesDir & "\" & $Name, $RegLocation = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, $InstallLocation = StringRegExpReplace(RegRead($RegLocation, "InstallLocation"), "\\+$", "")

Func GetInstallLocation($dir = $InstallDir)
    Local $GUI = GUICreate($Title, 434, 142)
    Local $Input = GUICtrlCreateInput($dir, 16, 56, 329, 21)
    Local $ButtonChange = GUICtrlCreateButton("Change", 352, 54, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("OK", 168, 104, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", 264, 104, 75, 25)
    Local $Label = GUICtrlCreateLabel(Localize("SelectInstallLocation"), 16, 24, 332, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $ButtonChange
                Local $sFileSelectFolder = FileSelectFolder(Localize("SelectInstallLocation"), StringRegExpReplace(StringRegExpReplace(GUICtrlRead($Input), "\\+$", ""), "\\" & $Name & "$", ""), 0, "", $GUI)
                If @error = 0 Then GUICtrlSetData($Input, StringRegExpReplace($sFileSelectFolder, "\\+$", "") & "\" & $Name)
            Case $ButtonOK
                Local $sCurrInput = StringRegExpReplace(GUICtrlRead($Input), "\\+$", "")
                If StringRegExp($sCurrInput, "\\" & $Name & "$") And FileExists(StringRegExpReplace($sCurrInput, "\\" & $Name & "$", "")) Then
                    GUIDelete()
                    $InstallLocation = RegRead($RegLocation, "InstallLocation")
                    If $InstallLocation <> $sCurrInput And $InstallLocation <> "" Then
                        Local $UninstallString = StringReplace(RegRead($RegLocation, "UninstallString"), '"', "")
                        If StringInStr($UninstallString, $InstallLocation) And FileExists($UninstallString) Then
                            MsgBox($MB_ICONWARNING, $Title, Localize("UninstallPreviousInstallation"))
                            RunWait($UninstallString, $InstallLocation)
                            $InstallLocation = RegRead($RegLocation, "InstallLocation")
                            If $InstallLocation <> "" Then Return GetInstallLocation($InstallLocation)
                            Return GetInstallLocation($sCurrInput)
                        EndIf
                    EndIf
                    Return $sCurrInput
                EndIf
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

If _Singleton($Name & " Installer" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("InstallerAlreadyRunning"))
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("CloseBeforeInstall"))
If _Singleton($Name & ": Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("CloseUnattendedBeforeInstall"))
If _Singleton("Neverwinter Fishing Bot" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("CloseFishingBeforeInstall"))
If $InstallLocation <> "" And StringRegExp($InstallLocation, "\\" & $Name & "$") And FileExists($InstallLocation) Then
    $InstallDir = $InstallLocation
Else
    $InstallDir = GetInstallLocation()
EndIf
Local $SettingsDir = @AppDataDir & "\" & $Name, $OldSettingsDir = @AppDataCommonDir & "\" & $Name
If Not FileExists($SettingsDir) And FileExists($OldSettingsDir) Then DirMove($OldSettingsDir, $SettingsDir)
If _UnicodeIniRead($SettingsDir & "\Settings.ini", "AllAccounts", "Language", "") <> $Language Then
    DirCreate($SettingsDir)
    _UnicodeIniWrite($SettingsDir & "\Settings.ini", "AllAccounts", "Language", $Language)
EndIf
If FileExists($InstallDir & "\images") And Not DirRemove($InstallDir & "\images", 1) Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCleaningUpExistingInstallation"))
If Not DirCopy($Name, $InstallDir, 1) Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCopyingFilesToProgramsFolder"))
If Not RegWrite($RegLocation, "DisplayName", "REG_SZ", $Name) Or Not RegWrite($RegLocation, "DisplayVersion", "REG_SZ", $Version) Or Not RegWrite($RegLocation, "Publisher", "REG_SZ", "BigRedBot") Or Not RegWrite($RegLocation, "DisplayIcon", "REG_SZ", $InstallDir & "\" & $Name & ".exe") Or Not RegWrite($RegLocation, "UninstallString", "REG_SZ", '"' & $InstallDir & '\Uninstall.exe"') Or Not RegWrite($RegLocation, "InstallLocation", "REG_SZ", $InstallDir) Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingUninstallerRegistry"))
If Not FileCreateShortcut($InstallDir & "\" & $Name & ".exe", @DesktopCommonDir & "\" & $Name & ".lnk", $InstallDir) Or Not FileCreateShortcut($InstallDir & "\Neverwinter Fishing Bot.exe", @DesktopCommonDir & "\Neverwinter Fishing Bot.lnk", $InstallDir) Or Not FileCreateShortcut($InstallDir & "\Simple.html", @DesktopCommonDir & "\Simple Bank Referral.lnk", $InstallDir) Or Not FileCreateShortcut($SettingsDir, $InstallDir & "\Settings.lnk", $InstallDir) Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
Local $RunUnattendedOnStartup
If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("RunUnattendedOnStartup")) = $IDYES Then
    If Not FileCreateShortcut($InstallDir & "\Unattended.exe", @StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk", $InstallDir) Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    $RunUnattendedOnStartup = 1
ElseIf FileExists(@StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk") And Not FileDelete(@StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk") Then
    Exit MsgBox($MB_ICONWARNING, $Title, Localize("FailedToDeleteFile", "<FILE>", @StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk"))
EndIf
MsgBox($MB_OK, $Title, Localize("SuccessfullyInstalled", "<VERSION>", $Version) & @CRLF & @CRLF & $InstallDir)

Func _setupFileRead($file)
    Local $fo = FileOpen($file, $FO_READ)
    If $fo <> -1 Then
        Local $r = FileRead($fo)
        FileClose($fo)
        Return $r
    EndIf
    Return ""
EndFunc

Func _setupMsg($txt)
    Local $hGUI = GUICreate($Title, 500, -1)
    GUICtrlCreateLabel($txt, 20, 20, 460, 1000)
    GUISetState()
    _GUIScrollbars_Generate($hGUI, 0, 1000)
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($hGUI)
EndFunc

;MsgBox(0, $Title, _setupFileRead(@ScriptDir & "\" & $Name & "\Message.txt"))
_setupMsg(_setupFileRead(@ScriptDir & "\" & $Name & "\CHANGELOG.txt"))

If $RunUnattendedOnStartup And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("RunUnattendedNow")) = $IDYES Then
    ShellExecute($InstallDir & "\Simple.html")
    Exit ShellExecute($InstallDir & "\Unattended.exe", "", $InstallDir)
EndIf
ShellExecute($InstallDir & "\Simple.html")
