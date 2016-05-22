#include "variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIFiles.au3>
Global $Title = $Name & " v" & $Version & " Installer"

Global $SettingsDir = @AppDataCommonDir & "\" & $Name

DirCreate($SettingsDir)

Global $Language = IniRead($SettingsDir & "\Settings.ini", "Settings", "Language", "")

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
                        IniWrite($SettingsDir & "\Settings.ini", "Settings", "Language", $Language)
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

Func SetDefault($name, $default = 0)
    If Not IsDeclared($name) Then
        Assign($name, $default, 2)
    EndIf
EndFunc

Func LoadLocalizations($file, $lang)
    Local $values = IniReadSection($file, $lang)
    If @error = 0 Then
        For $i = 1 To $values[0][0]
            Local $v = $values[$i][1]
            If $v = "" Then
                $v = IniRead($file, "English", $values[$i][0], "")
            EndIf
            SetDefault("LOCALIZATION_" & $values[$i][0], StringReplace($v, "<BR>", @CRLF))
        Next
    EndIf
    If $lang <> "English" Then
        LoadLocalizations($file, "English")
    EndIf
EndFunc

LoadLocalizations($LocalizationFile, $Language)


If _Singleton($Name & " Installer" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_InstallerAlreadyRunning)
    Exit
ElseIf _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_CloseBeforeInstall)
    Exit
EndIf
If Not DirCopy($Name, @ProgramFilesDir & "\" & $Name, 1) Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_ErrorCopyingFilesToProgramsFolder)
    Exit
EndIf
If Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayName", "REG_SZ", $Name & " v" & $Version) Or Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "UninstallString", "REG_SZ", '"' & @ProgramFilesDir & "\" & $Name & '\Uninstall.exe"') Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_ErrorCreatingUninstallerRegistry)
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & ".lnk")
If Not FileCreateShortcut(@ProgramFilesDir & "\" & $Name & "\" & $Name & ".exe", @DesktopCommonDir & "\" & $Name & ".lnk", @ProgramFilesDir & "\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_ErrorCreatingShortcut)
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & " Donation.lnk")
If Not FileCreateShortcut(@ProgramFilesDir & "\" & $Name & "\Donation.html", @DesktopCommonDir & "\" & $Name & " Donation.lnk", @ProgramFilesDir & "\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_ErrorCreatingShortcut)
    Exit
EndIf
MsgBox($MB_OK, $Title, StringReplace($LOCALIZATION_SuccessfullyInstalled, "<VERSION>", $Version))