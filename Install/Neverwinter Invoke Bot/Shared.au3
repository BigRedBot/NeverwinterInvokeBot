#include-once
#include <Misc.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <TrayConstants.au3>
#include <WinAPIFiles.au3>
#include <WinAPIProc.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <Array.au3>
#include "Localization.au3"
AutoItSetOption("WinTitleMatchMode", 3)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)
TrayCreateItem(Localize("Exit"))
TrayItemSetOnEvent(-1, "ExitScript")
TraySetState($TRAY_ICONSTATE_SHOW)

Func ExitScript()
    Exit
EndFunc

Func LoadDefaults()
    LoadLocalizationDefaults()
    SetDefault("TotalAccounts", 1)
    SetDefault("TotalSlots")
    SetDefault("StartAtLoop", 1)
    SetDefault("EndAtLoop", 8)
    SetDefault("StartAt", 1)
    SetDefault("EndAt")
    SetDefault("TimeOutMinutes", 5)
    SetDefault("TimeOutRetries", 3)
    SetDefault("KeyDelaySeconds", 0.15)
    SetDefault("MaxLogInAttempts", 3)
    SetDefault("SkipVIPAccountReward")
    SetDefault("ClaimCofferDelay", 1)
    SetDefault("ClaimVIPAccountRewardDelay", 5)
    SetDefault("LogInSeconds", 16)
    SetDefault("LogOutSeconds", 9)
    SetDefault("LogInDelaySeconds", 3)
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
If Not IsDeclared("LoadPrivateSettings") Then Assign("LoadPrivateSettings", 0, 2)
Global $SettingsDir = @AppDataCommonDir & "\Neverwinter Invoke Bot"

SetValue("Language", LoadLocalizations())

Func SetDefault($name, $value = 0)
    If Not IsDeclared("SETTINGS_Default_" & $name) Then Assign("SETTINGS_Default_" & $name, $value, 2)
EndFunc

Func SetValue($name, $value = 0, $account = 0)
    If $account Then
        If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then Return Assign("SETTINGS_Account" & $account & "_" & $name, $value)
        Return Assign("SETTINGS_Account" & $account & "_" & $name, $value, 2)
    ElseIf IsDeclared("SETTINGS_Account" & $CurrentAccount & "_" & $name) Then
        Return Assign("SETTINGS_Account" & $CurrentAccount & "_" & $name, $value)
    ElseIf IsDeclared("SETTINGS_AllAccounts_" & $name) Then
        Return Assign("SETTINGS_AllAccounts_" & $name, $value)
    EndIf
    Return Assign("SETTINGS_AllAccounts_" & $name, $value, 2)
EndFunc

Func SetAllAccountsValue($name, $value = 0)
    If IsDeclared("SETTINGS_AllAccounts_" & $name) Then Return Assign("SETTINGS_AllAccounts_" & $name, $value)
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
        If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then Return Eval("SETTINGS_Account" & $account & "_" & $name)
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

Func GetDefaultValue($name)
    If IsDeclared("SETTINGS_Default_" & $name) Then Return Eval("SETTINGS_Default_" & $name)
    Return 0
EndFunc

Func SaveIniAllAccounts($name, $value = "")
    If $value == "" Then Return IniDelete($SettingsDir & "\Settings.ini", "AllAccounts", $name)
    Return IniWrite($SettingsDir & "\Settings.ini", "AllAccounts", $name, $value)
EndFunc

Func GetIniAllAccounts($name)
    Return IniRead($SettingsDir & "\Settings.ini", "AllAccounts", $name, "")
EndFunc

Func SaveIniAccount($name, $value = "", $account = $CurrentAccount)
    If $value == "" Then Return IniDelete($SettingsDir & "\Settings.ini", "Account" & $account, $name)
    Return IniWrite($SettingsDir & "\Settings.ini", "Account" & $account, $name, $value)
EndFunc

Func GetIniAccount($name, $account = $CurrentAccount)
    Return IniRead($SettingsDir & "\Settings.ini", "Account" & $account, $name, "")
EndFunc

Func SaveIniPrivate($name, $value = "", $account = $CurrentAccount)
    If $value == "" Then Return IniDelete($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name)
    Return IniWrite($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name, $value)
EndFunc

Func GetIniPrivate($name, $account = $CurrentAccount)
    Return IniRead($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name, "")
EndFunc

Func Statistics_SaveIniAllAccounts($name, $value = "")
    If $value == "" Then Return IniDelete($SettingsDir & "\Statistics.ini", "AllAccounts", $name)
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
    If $value == "" Then Return IniDelete($SettingsDir & "\Statistics.ini", "Account" & $account, $name)
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

Func LoadSettings($file)
    Local $sections = IniReadSectionNames($file)
    If @error <> 0 Then Return
    For $i = 1 To $sections[0]
        Local $values = IniReadSection($file, $sections[$i])
        If @error = 0 Then
            For $i2 = 1 To $values[0][0]
                Local $v = $values[$i2][1]
                If String(Number($v)) = String($v) Or $v = "" Then $v = Number($v)
                If Not IsDeclared("SETTINGS_" & $sections[$i] & "_" & $values[$i2][0]) Then Assign("SETTINGS_" & $sections[$i] & "_" & $values[$i2][0], $v, 2)
            Next
        EndIf
    Next
EndFunc

Func PruneLogs()
    If Not FileExists($SettingsDir & "\Logs") Then Return
    Local $FileList = _FileListToArray($SettingsDir & "\Logs", "Log_????-??-??.txt", $FLTA_FILES)
    If @error = 0 And $FileList[0] > GetValue("LogFilesToKeep") Then
        _ArraySort($FileList)
        For $i = 1 To $FileList[0] - GetValue("LogFilesToKeep")
            FileDelete($SettingsDir & "\Logs" & "\" & $FileList[$i])
        Next
    EndIf
EndFunc

LoadSettings($SettingsDir & "\Statistics.ini")
LoadSettings($SettingsDir & "\Settings.ini")
If $LoadPrivateSettings Then LoadSettings($SettingsDir & "\PrivateSettings.ini")
LoadDefaults()
PruneLogs()

Global $WinHandle
Func FindWindow()
    $WinHandle = 0
    Local $list = ProcessList("GameClient.exe")
    If @error <> 0 Then Return
    For $i = 1 To $list[0][0]
        Local $Data = _WinAPI_EnumProcessWindows($list[$i][1], False)
        If @error = 0 Then
            For $i2 = 1 To $Data[0][0]
                If $Data[$i2][1] == "CrypticWindowClass" And WinExists($Data[$i2][0]) Then
                    $WinHandle = $Data[$i2][0]
                    Return
                EndIf
            Next
        EndIf
    Next
EndFunc

Func Focus()
    FindWindow()
    If $WinHandle And Not WinActive($WinHandle) Then
        WinActivate($WinHandle)
        Sleep(500)
    EndIf
EndFunc

Global $ClientInfo, $ClientSize, $ClientWidth, $ClientHeight, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $ClientWidthCenter, $ClientHeightCenter, $WinWidth, $WinHeight, $WinLeft, $WinTop, $WinRight, $WinBottom, $WinWidthCenter, $WinHeightCenter, $PaddingWidth, $PaddingHeight, $PaddingLeft, $PaddingTop, $PaddingRight, $PaddingBottom, $DeskTopWidth, $DeskTopHeight, $OffsetX = 0, $OffsetY = 0
Func GetPosition()
    $ClientInfo = WinGetPos($WinHandle)
    If @error <> 0 Then Return 0
    $ClientSize = WinGetClientSize($WinHandle)
    If @error <> 0 Then Return 0
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
