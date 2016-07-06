#include <Misc.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIFiles.au3>
#include <WinAPIProc.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <Array.au3>
#include "Localization.au3"
AutoItSetOption("WinTitleMatchMode", 3)

Func LoadDefaults()
    LoadLocalizationDefaults()
    SetDefault("TotalAccounts", 1)
    SetDefault("TotalSlots")
    SetDefault("StartAtLoop", 1)
    SetDefault("EndAtLoop", 8)
    SetDefault("StartAt", 1)
    SetDefault("EndAt")
    SetDefault("TimeOutMinutes", 5)
    SetDefault("KeyDelaySeconds", 0.15)
    SetDefault("MaxLogInAttempts", 3)
    SetDefault("SkipVIPAccountReward")
    SetDefault("ClaimCofferDelay", 1)
    SetDefault("ClaimVIPAccountRewardDelay", 5)
    SetDefault("LogInSeconds", 16)
    SetDefault("LogOutSeconds", 9)
    SetDefault("LogInDelaySeconds", 2)
    SetDefault("RestartGameClient", 1)
    SetDefault("GameWidth", 752)
    SetDefault("GameHeight", 522)
    SetDefault("ImageSearchTolerance", 50)
    SetDefault("Coffer", "CofferOfCelestialEnchantments")
    SetDefault("RelativePixelLocation", 1)
    SetDefault("SafeLogInX", 471)
    SetDefault("SafeLogInY", 305)
    SetDefault("UsernameBoxX", 130)
    SetDefault("UsernameBoxY", 266)
    SetDefault("SelectCharacterMenuX", 169)
    SetDefault("SelectCharacterMenuY", 169)
    SetDefault("TopScrollBarX", 313)
    SetDefault("TopScrollBarY", 48)
    SetDefault("TopScrollBarC", "967C44")
    SetDefault("TopSelectedCharacterX", 241)
    SetDefault("TopSelectedCharacterY", 93)
    SetDefault("TopSelectedCharacterC", "CCFFFF")
    SetDefault("BottomScrollBarX", 313)
    SetDefault("BottomScrollBarY", 198)
    SetDefault("BottomScrollBarC", "010A10")
    SetDefault("BottomSelectedCharacterX", 241)
    SetDefault("BottomSelectedCharacterY", 173)
    SetDefault("BottomSelectedCharacterC", "CCFFFF")
    SetDefault("LogFilesToKeep", 30)
    SetDefault("LogInUserName")
    SetDefault("LogInPassword")
    SetDefault("PasswordHash")
EndFunc

Global $CurrentAccount = 1

Global $SettingsDir = @AppDataCommonDir & "\Neverwinter Invoke Bot"

DirCreate($SettingsDir)

SetValue("Language", IniRead($SettingsDir & "\Settings.ini", "AllAccounts", "Language", ""))

If Not IsDeclared("LoadPrivateSettings") Then
    Assign("LoadPrivateSettings", 0, 2)
EndIf

Local $LocalizationFile = @ScriptDir & "\Localization.ini"

Func SetLanguage($default = "English")
    Local $langlist = $default
    Local $sections = IniReadSectionNames($LocalizationFile)
    If @error = 0 Then
        For $i = 1 To $sections[0]
            If Not ($sections[$i] == $default) Then
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
                        SetValue("Language", $sCurrCombo)
                        SaveIniAllAccounts("Language", GetValue("Language"))
                        Return
                    EndIf
                Next
        EndSwitch
    WEnd
EndFunc

If GetValue("Language") = "" Then
    SetLanguage()
EndIf

Func SetDefault($name, $value = 0)
    If Not IsDeclared("SETTINGS_Default_" & $name) Then
        Assign("SETTINGS_Default_" & $name, $value, 2)
    EndIf
EndFunc

Func SetValue($name, $value = 0, $account = 0)
    If $account Then
        If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then
            Return Assign("SETTINGS_Account" & $account & "_" & $name, $value)
        EndIf
        Return Assign("SETTINGS_Account" & $account & "_" & $name, $value, 2)
    ElseIf IsDeclared("SETTINGS_Account" & $CurrentAccount & "_" & $name) Then
        Return Assign("SETTINGS_Account" & $CurrentAccount & "_" & $name, $value)
    ElseIf IsDeclared("SETTINGS_AllAccounts_" & $name) Then
        Return Assign("SETTINGS_AllAccounts_" & $name, $value)
    EndIf
    Return Assign("SETTINGS_AllAccounts_" & $name, $value, 2)
EndFunc

Func SetAllAccountsValue($name, $value = 0)
    If IsDeclared("SETTINGS_AllAccounts_" & $name) Then
        Return Assign("SETTINGS_AllAccounts_" & $name, $value)
    EndIf
    Return Assign("SETTINGS_AllAccounts_" & $name, $value, 2)
EndFunc

Func SetAccountValue($name, $value = 0, $account = $CurrentAccount)
    Return SetValue($name, $value, $account)
EndFunc

Func AddCountValue($name, $value = 1, $account = 0)
    Return SetValue($name, GetValue($name, $account) + $value, $account)
EndFunc

Func AddAccountCountValue($name, $value = 1, $account = $CurrentAccount)
    Return SetValue($name, GetValue($name, $account) + $value, $account)
EndFunc

Func GetValue($name, $account = $CurrentAccount)
    If $account And @NumParams = 2 Then
        If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then
            Return Eval("SETTINGS_Account" & $account & "_" & $name)
        EndIf
    ElseIf IsDeclared("SETTINGS_Account" & $CurrentAccount & "_" & $name) Then
        Return Eval("SETTINGS_Account" & $CurrentAccount & "_" & $name)
    ElseIf IsDeclared("SETTINGS_AllAccounts_" & $name) Then
        Return Eval("SETTINGS_AllAccounts_" & $name)
    ElseIf IsDeclared("SETTINGS_Default_" & $name) Then
        Return Eval("SETTINGS_Default_" & $name)
    EndIf
    Return 0
EndFunc

Func GetAllAccountsValue($name)
    If IsDeclared("SETTINGS_AllAccounts_" & $name) Then
        Return Eval("SETTINGS_AllAccounts_" & $name)
    ElseIf IsDeclared("SETTINGS_Default_" & $name) Then
        Return Eval("SETTINGS_Default_" & $name)
    EndIf
    Return 0
EndFunc

Func GetAccountValue($name, $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then
        Return Eval("SETTINGS_Account" & $account & "_" & $name)
    ElseIf IsDeclared("SETTINGS_Default_" & $name) Then
        Return Eval("SETTINGS_Default_" & $name)
    EndIf
    Return 0
EndFunc

Func SaveIniAllAccounts($name, $value = "")
    Return IniWrite($SettingsDir & "\Settings.ini", "AllAccounts", $name, $value)
EndFunc

Func GetIniAllAccounts($name)
    Return IniRead($SettingsDir & "\Settings.ini", "AllAccounts", $name, "")
EndFunc

Func SaveIniAccount($name, $value = "", $account = $CurrentAccount)
    Return IniWrite($SettingsDir & "\Settings.ini", "Account" & $account, $name, $value)
EndFunc

Func GetIniAccount($name, $account = $CurrentAccount)
    Return IniRead($SettingsDir & "\Settings.ini", "Account" & $account, $name, "")
EndFunc

Func SaveIniPrivate($name, $value = "", $account = $CurrentAccount)
    Return IniWrite($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name, $value)
EndFunc

Func GetIniPrivate($name, $account = $CurrentAccount)
    Return IniRead($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name, "")
EndFunc

Func Statistics_SaveIniAllAccounts($name, $value = "")
    If Not GetAllAccountsValue("StartDate") Then
        Local $Month[13] = [12, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], $Date = $Month[Number(@MON)] & " " & Number(@MDAY) & ", " & @YEAR
        IniWrite($SettingsDir & "\Statistics.ini", "AllAccounts", "StartDate", $Date)
        SetAllAccountsValue("StartDate", $Date)
    EndIf
    Return IniWrite($SettingsDir & "\Statistics.ini", "AllAccounts", $name, $value)
EndFunc

Func Statistics_GetIniAllAccounts($name)
    Return IniRead($SettingsDir & "\Statistics.ini", "AllAccounts", $name, "")
EndFunc

Func Statistics_SaveIniAccount($name, $value = "", $account = $CurrentAccount)
    If Not GetAccountValue("StartDate", $account) Then
        Local $Month[13] = [12, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], $Date = $Month[Number(@MON)] & " " & Number(@MDAY) & ", " & @YEAR
        IniWrite($SettingsDir & "\Statistics.ini", "Account" & $account, "StartDate", $Date)
        SetAccountValue("StartDate", $Date, $account)
    EndIf
    Return IniWrite($SettingsDir & "\Statistics.ini", "Account" & $account, $name, $value)
EndFunc

Func Statistics_GetIniAccount($name, $account = $CurrentAccount)
    Return IniRead($SettingsDir & "\Statistics.ini", "Account" & $account, $name, "")
EndFunc

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

LoadLocalizations($LocalizationFile, GetValue("Language"))

Func Localize($s, $f1=0, $r1=0, $f2=0, $r2=0, $f3=0, $r3=0, $f4=0, $r4=0, $f5=0, $r5=0, $f6=0, $r6=0, $f7=0, $r7=0, $f8=0, $r8=0, $f9=0, $r9=0, $f10=0, $r10=0)
    #forceref $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $f10
    #forceref $r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10
    Local $v = Eval("LOCALIZATION_" & $s)
    For $i = 1 To Int((@NumParams - 1) / 2)
        $v = StringReplace($v, Eval("f" & $i), Eval("r" & $i))
    Next
    Return $v
EndFunc

Func LoadSettings($file)
    Local $sections = IniReadSectionNames($file)
    If @error = 0 Then
        For $i = 1 To $sections[0]
            Local $values = IniReadSection($file, $sections[$i])
            If @error = 0 Then
                For $i2 = 1 To $values[0][0]
                    Local $v = $values[$i2][1]
                    If String(Number($v)) = String($v) Or $v = "" Then
                        $v = Number($v)
                    EndIf
                    If Not IsDeclared("SETTINGS_" & $sections[$i] & "_" & $values[$i2][0]) Then
                        Assign("SETTINGS_" & $sections[$i] & "_" & $values[$i2][0], $v, 2)
                    EndIf
                Next
            EndIf
        Next
    EndIf
EndFunc

Func PruneLogs()
    If FileExists($SettingsDir & "\Logs") Then
        Local $FileList = _FileListToArray($SettingsDir & "\Logs", "Log_????-??-??.txt", $FLTA_FILES)
        If @error = 0 And $FileList[0] > GetValue("LogFilesToKeep") Then
            _ArraySort($FileList)
            For $i = 1 To $FileList[0] - GetValue("LogFilesToKeep")
                FileDelete($SettingsDir & "\Logs" & "\" & $FileList[$i])
            Next
        EndIf
    EndIf
EndFunc

LoadSettings($SettingsDir & "\Statistics.ini")
LoadSettings($SettingsDir & "\Settings.ini")
If $LoadPrivateSettings Then
    LoadSettings($SettingsDir & "\PrivateSettings.ini")
EndIf
LoadDefaults()
PruneLogs()

Global $WinHandle, $WinFound
Func FindWindow()
    $WinHandle = 0
    $WinFound = 0
    Local $list = ProcessList("GameClient.exe")
    If @error = 0 Then
        For $i = 1 To $list[0][0]
            Local $Data = _WinAPI_EnumProcessWindows($list[$i][1], False)
            If @error = 0 Then
                For $i2 = 1 To $Data[0][0]
                    If $Data[$i2][1] == "CrypticWindowClass" And WinExists($Data[$i2][0]) Then
                        $WinHandle = $Data[$i2][0]
                        $WinFound = 1
                        Return
                    EndIf
                Next
            EndIf
        Next
    EndIf
EndFunc

Func Focus()
    FindWindow()
    If $WinFound And Not WinActive($WinHandle) Then
        WinActivate($WinHandle)
        Sleep(500)
    EndIf
EndFunc

Global $ClientInfo, $ClientSize, $ClientWidth, $ClientHeight, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $ClientWidthCenter, $ClientHeightCenter, $WinWidth, $WinHeight, $WinLeft, $WinTop, $WinRight, $WinBottom, $WinWidthCenter, $WinHeightCenter, $PaddingWidth, $PaddingHeight, $PaddingLeft, $PaddingTop, $PaddingRight, $PaddingBottom, $DeskTopWidth, $DeskTopHeight, $OffsetX = 0, $OffsetY = 0
Func GetPosition()
    $ClientInfo = WinGetPos($WinHandle)
    If @error <> 0 Then
        Return 0
    EndIf
    $ClientSize = WinGetClientSize($WinHandle)
    If @error <> 0 Then
        Return 0
    EndIf
    Local $tRect = _WinAPI_GetClientRect($WinHandle)
    Local $ltpoint = DllStructCreate("int Left;int Top")
    DllStructSetData($ltpoint, "Left", 0)
    DllStructSetData($ltpoint, "Top", 0)
    _WinAPI_ClientToScreen($WinHandle, $ltpoint)
    $ClientWidth = $ClientSize[0]
    $ClientHeight = $ClientSize[1]
    $ClientLeft = DllStructGetData($ltpoint, "Left")
    $ClientTop = DllStructGetData($ltpoint, "Top")
    $ClientRight = $ClientLeft + $ClientWidth - 1
    $ClientBottom = $ClientTop + $ClientHeight - 1
    $ClientWidthCenter = $ClientLeft + Round($ClientWidth / 2)
    $ClientHeightCenter = $ClientTop + Round($ClientHeight / 2)
    $WinWidth = $ClientInfo[2]
    $WinHeight = $ClientInfo[3]
    $WinLeft = $ClientInfo[0]
    $WinTop = $ClientInfo[1]
    $WinRight = $WinLeft + $WinWidth - 1
    $WinBottom = $WinTop + $WinHeight - 1
    $WinWidthCenter = $WinLeft + Round($WinWidth / 2)
    $WinHeightCenter = $WinTop + Round($WinHeight / 2)
    $PaddingWidth = $WinWidth - $ClientSize[0]
    $PaddingHeight = $WinHeight - $ClientHeight
    $PaddingLeft = $ClientLeft + 1 - $WinLeft
    $PaddingTop = $ClientTop + 1 - $WinTop
    $PaddingRight = $WinRight + 1 - $ClientRight
    $PaddingBottom = $WinBottom + 1 - $ClientBottom
    $DeskTopWidth = @DeskTopWidth
    $DeskTopHeight = @DeskTopHeight
    If GetValue("RelativePixelLocation") Then
        $OffsetX = $ClientLeft
        $OffsetY = $ClientTop
    EndIf
    Return 1
EndFunc
