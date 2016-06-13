#include "..\variables.au3"
Global $Title = $Name & " v" & $Version & " Uninstaller"
#RequireAdmin
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIFiles.au3>
#include "_SelfDelete.au3"

Global $SettingsDir = @AppDataCommonDir & "\" & $Name

Global $Language = IniRead($SettingsDir & "\Settings.ini", "AllAccounts", "Language", "")

Local $LocalizationFile = @ScriptDir & "\Localization.ini"

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
                        Return
                    EndIf
                Next
        EndSwitch
    WEnd
EndFunc

If $Language = "" Then
    SetLanguage()
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


If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DoYouWantToUninstall", "<VERSION>", $Version)) <> $IDYES Then
    Exit
EndIf

Local $delete = StringSplit("Neverwinter Invoke Bot.exe,ImageCapture.exe,ScreenDetection.exe," & @DesktopCommonDir & "\Neverwinter Invoke Bot.lnk," & @DesktopCommonDir & "\Neverwinter Invoke Bot Donation.lnk", ",")
FileChangeDir(@ScriptDir)
For $i = 1 To $delete[0]
    If FileExists($delete[$i]) And Not FileDelete($delete[$i]) Then
        MsgBox($MB_ICONWARNING, $Title, Localize("FailedToDeleteFile", "<FILE>", $delete[$i]))
        Exit
    EndIf
Next

If ( RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "DisplayName") <> "" Or RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, "UninstallString") <> "" ) And Not RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("FailedToDeleteRegistry"))
    Exit
EndIf

If FileExists(@AppDataCommonDir & "\" & $Name) And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("KeepSettingsFiles")) <> $IDYES Then
    DirRemove(@AppDataCommonDir & "\" & $Name, 1)
EndIf

_SelfDelete(5, 1, 1)
If @error Then
    Exit MsgBox($MB_ICONWARNING, "_SelfDelete()", "The script must be a compiled exe to work correctly!")
EndIf