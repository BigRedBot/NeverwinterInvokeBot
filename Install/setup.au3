#include "variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIFiles.au3>
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

If _Singleton($Name & " Installer" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("InstallerAlreadyRunning"))
    Exit
ElseIf _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("CloseBeforeInstall"))
    Exit
EndIf
If Not DirCopy($Name, @ProgramFilesDir & "\" & $Name, 1) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCopyingFilesToProgramsFolder"))
    Exit
EndIf
If Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayName", "REG_SZ", $Name & " v" & $Version) Or Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayIcon", "REG_SZ", '"' & @ProgramFilesDir & "\" & $Name & "\" & $Name & '.exe"') Or Not RegWrite("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "UninstallString", "REG_SZ", '"' & @ProgramFilesDir & "\" & $Name & '\Uninstall.exe"') Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingUninstallerRegistry"))
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & ".lnk")
If Not FileCreateShortcut(@ProgramFilesDir & "\" & $Name & "\" & $Name & ".exe", @DesktopCommonDir & "\" & $Name & ".lnk", @ProgramFilesDir & "\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & " Donation.lnk")
If Not FileCreateShortcut(@ProgramFilesDir & "\" & $Name & "\Donation.html", @DesktopCommonDir & "\" & $Name & " Donation.lnk", @ProgramFilesDir & "\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    Exit
EndIf
MsgBox($MB_OK, $Title, Localize("SuccessfullyInstalled", "<VERSION>", $Version))