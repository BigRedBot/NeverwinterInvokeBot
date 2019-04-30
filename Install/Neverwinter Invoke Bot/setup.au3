#NoTrayIcon
#include "variables.au3"
#include <MsgBoxConstants.au3>
Global $Title = $Name & " v" & $Version & " Installer"
If Not @Compiled Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, "The script must be a compiled exe to work correctly!")
#include <Misc.au3>
#include <WinAPIFiles.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <File.au3>
#include <FileConstants.au3>
#include "_GUIScrollbars_Ex.au3"
#include "Localization.au3"
Local $Language = LoadLocalizations(1, @ScriptDir & "\" & $Name & "\Localization.ini", 0)

Local $InstallDir = @ProgramFilesDir & "\" & $Name, $RegLocation = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, $InstallLocation = StringRegExpReplace(RegRead($RegLocation, "InstallLocation"), "\\+$", "")

Func GetInstallLocation($dir = $InstallDir)
    Local $GUI = GUICreate($Title, 434, 142, -1, -1, -1, $WS_EX_TOPMOST)
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
                            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UninstallPreviousInstallation"))
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

If _Singleton("Neverwinter Invoke Bot Installer" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("InstallerAlreadyRunning"))
If _Singleton("Neverwinter Invoke Bot" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("CloseBeforeInstall"))
If _Singleton("Neverwinter Invoke Bot: Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("CloseUnattendedBeforeInstall"))
If _Singleton("Neverwinter Fishing Bot" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("CloseFishingBeforeInstall"))
If _Singleton("Neverwinter Invoke Bot: Auction" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("CloseAuctionBeforeInstall"))
If _Singleton("Neverwinter Invoke Bot: Mail" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("CloseMailBeforeInstall"))
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
If FileExists($InstallDir) Then
    If FileExists($InstallDir & "\images") And Not DirRemove($InstallDir & "\images", 1) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ErrorCleaningUpExistingInstallation"))
    Local $delete = _FileListToArray($InstallDir, "*", $FLTA_FILES)
    If @error <> 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ErrorCleaningUpExistingInstallation"))
    For $i = 1 To $delete[0]
        If $delete[$i] <> "Install.exe" And Not FileDelete($InstallDir & "\" & $delete[$i]) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteFile", "<FILE>", $InstallDir & "\" & $delete[$i]))
    Next
EndIf
Local $XMLFile = $InstallDir & "\ScheduledStartUp.xml"
Local $deleteshortcuts = StringSplit(@DesktopCommonDir & "\Neverwinter Fishing Bot.lnk" & "|" & @StartupCommonDir & "\Neverwinter Invoke Bot Unattended Launcher.lnk" & "|" & @StartupCommonDir & "\" & $Name & ".lnk" & "|" & @DesktopCommonDir & "\Simple Bank Referral.lnk" & "|" & $XMLFile, "|")
For $i = 1 To $deleteshortcuts[0]
    If FileExists($deleteshortcuts[$i]) And Not FileDelete($deleteshortcuts[$i]) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteFile", "<FILE>", $deleteshortcuts[$i]))
Next
If Not DirCopy($Name, $InstallDir, 1) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ErrorCopyingFilesToProgramsFolder"))
If Not RegWrite($RegLocation, "DisplayName", "REG_SZ", $Name) Or Not RegWrite($RegLocation, "DisplayVersion", "REG_SZ", $Version) Or Not RegWrite($RegLocation, "Publisher", "REG_SZ", "BigRedBot") Or Not RegWrite($RegLocation, "DisplayIcon", "REG_SZ", $InstallDir & "\Unattended.exe") Or Not RegWrite($RegLocation, "UninstallString", "REG_SZ", '"' & $InstallDir & '\Uninstall.exe"') Or Not RegWrite($RegLocation, "InstallLocation", "REG_SZ", $InstallDir) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ErrorCreatingUninstallerRegistry"))
If Not FileCreateShortcut($InstallDir & "\Unattended.exe", @DesktopCommonDir & "\" & $Name & ".lnk", $InstallDir) Or Not FileCreateShortcut($SettingsDir, $InstallDir & "\Settings.lnk", $InstallDir) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ErrorCreatingShortcut"))
Local $RunUnattendedOnStartup
If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_TOPMOST, $Title, Localize("RunUnattendedOnStartup")) = $IDYES Then
    If Not RunWait('schtasks /query /tn "Neverwinter Invoke Bot Start Up"', "", @SW_HIDE) And RunWait('schtasks /delete /tn "Neverwinter Invoke Bot Start Up" /f', "", @SW_HIDE) Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteStartUpTask"))
    Local $XMLText = _
    '<?xml version="1.0" encoding="UTF-16"?>' & @CRLF & _
    '<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">' & @CRLF & _
    '<RegistrationInfo>' & @CRLF & _
    '  <Author>SYSTEM</Author>' & @CRLF & _
    '  <URI>\Neverwinter Invoke Bot Start Up</URI>' & @CRLF & _
    '</RegistrationInfo>' & @CRLF & _
    '<Triggers>' & @CRLF & _
    '  <LogonTrigger>' & @CRLF & _
    '    <Enabled>true</Enabled>' & @CRLF & _
    '  </LogonTrigger>' & @CRLF & _
    '</Triggers>' & @CRLF & _
    '<Principals>' & @CRLF & _
    '  <Principal id="Author">' & @CRLF & _
    '    <LogonType>InteractiveToken</LogonType>' & @CRLF & _
    '    <RunLevel>HighestAvailable</RunLevel>' & @CRLF & _
    '  </Principal>' & @CRLF & _
    '</Principals>' & @CRLF & _
    '<Settings>' & @CRLF & _
    '  <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>' & @CRLF & _
    '  <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>' & @CRLF & _
    '  <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>' & @CRLF & _
    '  <AllowHardTerminate>true</AllowHardTerminate>' & @CRLF & _
    '  <StartWhenAvailable>false</StartWhenAvailable>' & @CRLF & _
    '  <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>' & @CRLF & _
    '  <IdleSettings>' & @CRLF & _
    '    <StopOnIdleEnd>true</StopOnIdleEnd>' & @CRLF & _
    '    <RestartOnIdle>false</RestartOnIdle>' & @CRLF & _
    '  </IdleSettings>' & @CRLF & _
    '  <AllowStartOnDemand>true</AllowStartOnDemand>' & @CRLF & _
    '  <Enabled>true</Enabled>' & @CRLF & _
    '  <Hidden>false</Hidden>' & @CRLF & _
    '  <RunOnlyIfIdle>false</RunOnlyIfIdle>' & @CRLF & _
    '  <WakeToRun>false</WakeToRun>' & @CRLF & _
    '  <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>' & @CRLF & _
    '  <Priority>7</Priority>' & @CRLF & _
    '</Settings>' & @CRLF & _
    '<Actions Context="Author">' & @CRLF & _
    '  <Exec>' & @CRLF & _
    '      <Command>cmd.exe</Command>' & @CRLF & _
    '      <Arguments>/c start "" "' & $InstallDir & "\Unattended.exe" & '"</Arguments>' & @CRLF & _
    '  </Exec>' & @CRLF & _
    '</Actions>' & @CRLF & _
    '</Task>'
    If Not FileWrite($XMLFile, $XMLText) Then Return Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToCreateStartUpTask"))
    If RunWait('schtasks /create /xml "' & $XMLFile & '" /tn "Neverwinter Invoke Bot Start Up"', "", @SW_HIDE) Then
        FileDelete($XMLFile)
        Return Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToCreateStartUpTask"))
    Else
        FileDelete($XMLFile)
    EndIf
    $RunUnattendedOnStartup = 1
ElseIf Not RunWait('schtasks /query /tn "Neverwinter Invoke Bot Start Up"', "", @SW_HIDE) And RunWait('schtasks /delete /tn "Neverwinter Invoke Bot Start Up" /f', "", @SW_HIDE) Then
    Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("FailedToDeleteStartUpTask"))
EndIf
MsgBox($MB_OK + $MB_TOPMOST, $Title, Localize("SuccessfullyInstalled", "<VERSION>", $Version) & @CRLF & @CRLF & $InstallDir)

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
    Local $hGUI = GUICreate($Title, 500, -1, -1, -1, -1, $WS_EX_TOPMOST)
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

If FileExists(@ScriptDir & "\" & $Name & "\Message.txt") Then MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TOPMOST, $Title, _setupFileRead(@ScriptDir & "\" & $Name & "\Message.txt"))
_setupMsg(_setupFileRead(@ScriptDir & "\" & $Name & "\CHANGELOG.txt"))

If $RunUnattendedOnStartup And MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_TOPMOST, $Title, Localize("RunUnattendedNow")) = $IDYES Then
    Exit ShellExecute($InstallDir & "\Unattended.exe", "", $InstallDir)
EndIf
