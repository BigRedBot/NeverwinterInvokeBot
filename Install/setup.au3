#NoTrayIcon
#include "variables.au3"
#include <Misc.au3>
#include <WinAPIFiles.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
Global $Title = $Name & " v" & $Version & " Installer"

Global $SettingsDir = @AppDataCommonDir & "\" & $Name

DirCreate($SettingsDir)

Global $Language = IniRead($SettingsDir & "\Settings.ini", "AllAccounts", "Language", "")

Local $LocalizationFile = @ScriptDir & "\" & $Name & "\Localization.ini"

Func SetLanguage($default = "English")
    Local $langlist = $default
    Local $sections = IniReadSectionNames($LocalizationFile)
    If @error = 0 Then
        For $i = 1 To $sections[0]
            If $sections[$i] <> $default Then
                $langlist &= "|" & $sections[$i]
            EndIf
        Next
    EndIf
    Local $hGUI = GUICreate("Language", 200, 85)
    Local $hCombo = GUICtrlCreateCombo("", 25, 15, 150, -1)
    GUICtrlSetData(-1, $langlist, $default)
    Local $hButton = GUICtrlCreateButton("OK", 58, 50, 84, -1, $BS_DEFPUSHBUTTON)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $hButton
                Local $sCurrCombo = GUICtrlRead($hCombo)
                For $i = 1 To $sections[0]
                    If $sections[$i] == $sCurrCombo Then
                        GUIDelete()
                        $Language = $sCurrCombo
                        IniWrite($SettingsDir & "\Settings.ini", "AllAccounts", "Language", $Language)
                        Return
                    EndIf
                Next
        EndSwitch
    WEnd
EndFunc

If $Language = "" Then
    SetLanguage()
Else
    SetLanguage($Language)
EndIf

Func LoadLocalizations($file, $lang)
    Local $values = IniReadSection($file, $lang)
    If @error = 0 Then
        For $i = 1 To $values[0][0]
            Local $v = BinaryToString(StringToBinary($values[$i][1]), 4)
            If $v = "" Then
                $v = BinaryToString(StringToBinary(IniRead($file, "English", $values[$i][0], "")), 4)
            EndIf
            If Not IsDeclared("LOCALIZATION_" & $values[$i][0]) Then
                Assign("LOCALIZATION_" & $values[$i][0], StringReplace($v, "<BR>", @CRLF), 2)
            EndIf
        Next
    EndIf
    If $lang <> "English" Then
        LoadLocalizations($file, "English")
    EndIf
EndFunc

LoadLocalizations($LocalizationFile, $Language)

Func Localize($s, $f1=0, $r1=0, $f2=0, $r2=0, $f3=0, $r3=0, $f4=0, $r4=0, $f5=0, $r5=0, $f6=0, $r6=0, $f7=0, $r7=0, $f8=0, $r8=0, $f9=0, $r9=0, $f10=0, $r10=0)
    #forceref $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $f10
    #forceref $r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10
    Local $v = Eval("LOCALIZATION_" & $s)
    For $i = 1 To Int((@NumParams - 1) / 2)
        $v = StringReplace($v, Eval("f" & $i), Eval("r" & $i))
    Next
    Return $v
EndFunc

Global $InstallDir = @ProgramFilesDir & "\" & $Name, $RegLocation = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, $InstallLocation = StringRegExpReplace(RegRead($RegLocation, "InstallLocation"), "\\+$", "")

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
                If @error = 0 Then
                    GUICtrlSetData($Input, StringRegExpReplace($sFileSelectFolder, "\\+$", "") & "\" & $Name)
                EndIf
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
                            If $InstallLocation <> "" Then
                                Return GetInstallLocation($InstallLocation)
                            EndIf
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

If _Singleton($Name & " Installer" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("InstallerAlreadyRunning"))
    Exit
ElseIf _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("CloseBeforeInstall"))
    Exit
EndIf
If $InstallLocation <> "" And StringRegExp($InstallLocation, "\\" & $Name & "$") And FileExists($InstallLocation) Then
    $InstallDir = $InstallLocation
Else
    $InstallDir = GetInstallLocation()
EndIf
If Not DirCopy($Name, $InstallDir, 1) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCopyingFilesToProgramsFolder"))
    Exit
EndIf
If Not RegWrite($RegLocation, "DisplayName", "REG_SZ", $Name) Or Not RegWrite($RegLocation, "DisplayVersion", "REG_SZ", $Version) Or Not RegWrite($RegLocation, "Publisher", "REG_SZ", "BigRedBot") Or Not RegWrite($RegLocation, "DisplayIcon", "REG_SZ", $InstallDir & "\" & $Name & ".exe") Or Not RegWrite($RegLocation, "UninstallString", "REG_SZ", '"' & $InstallDir & '\Uninstall.exe"') Or Not RegWrite($RegLocation, "InstallLocation", "REG_SZ", $InstallDir) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingUninstallerRegistry"))
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & ".lnk")
If Not FileCreateShortcut($InstallDir & "\" & $Name & ".exe", @DesktopCommonDir & "\" & $Name & ".lnk", $InstallDir) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & " Donation.lnk")
If Not FileCreateShortcut($InstallDir & "\Donation.html", @DesktopCommonDir & "\" & $Name & " Donation.lnk", $InstallDir) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    Exit
EndIf
MsgBox($MB_OK, $Title, Localize("SuccessfullyInstalled", "<VERSION>", $Version) & @CRLF & @CRLF & $InstallDir)