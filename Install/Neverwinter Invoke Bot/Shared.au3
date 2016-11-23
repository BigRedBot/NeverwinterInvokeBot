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
#include "_UnicodeIni.au3"
#include "Localization.au3"
AutoItSetOption("WinTitleMatchMode", 3)
AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayMenuMode", 3)
AutoItSetOption("TrayOnEventMode", 1)
Global $TrayExitItem = TrayCreateItem("&Exit")
TrayItemSetOnEvent($TrayExitItem, "ExitScript")
TraySetState($TRAY_ICONSTATE_SHOW)
TraySetToolTip($Title)
AutoItSetOption("TrayIconHide", 1)

Func ExitScript()
    Exit
EndFunc

Func LoadDefaults()
    LoadLocalizationDefaults()
    SetDefault("TotalAccounts", 1)
    SetDefault("DefaultStartAtLoop", 1)
    SetDefault("DefaultEndAtLoop", 8)
    SetDefault("DefaultStartAtCharacter", 1)
    SetDefault("TimeOutMinutes", 5)
    SetDefault("TimeOutRetries", 3)
    SetDefault("KeyDelaySeconds", 0.15)
    SetDefault("CharacterSelectionScrollAwayKeyDelaySeconds", 0.15)
    SetDefault("CharacterSelectionScrollTowardKeyDelaySeconds", 0.15)
    SetDefault("MaxLogInAttempts", 3)
    SetDefault("InfiniteLoopDelayMinutes", 480)
    SetDefault("ClaimCofferDelay", 1)
    SetDefault("ClaimVIPAccountRewardDelay", 5)
    SetDefault("OpenInventoryBagDelay", 1.5)
    SetDefault("OpenAnotherInventoryBagDelay", 0.5)
    SetDefault("ProfessionsDelay", 1)
    SetDefault("OptionalAssetsDelay", 0.2)
    SetDefault("LogInSeconds", 16)
    SetDefault("LogOutSeconds", 9)
    SetDefault("LogInDelaySeconds", 3)
    SetDefault("GameClientWidth", 1024)
    SetDefault("GameClientHeight", 768)
    SetDefault("ImageTolerance", 50)
    SetDefault("FishingImageTolerance", 30)
    SetDefault("InventoryBagTabLeftOffset", -66)
    SetDefault("InventoryBagTabTopOffset", -22)
    SetDefault("InventoryBagTabRightOffset", -33)
    SetDefault("InventoryBagTabBottomOffset", 29)
    SetDefault("Coffer", "CofferOfCelestialEnchantments")
    SetDefault("SafeLoginX", 640)
    SetDefault("SafeLoginY", 450)
    SetDefault("UsernameInputX", 230)
    SetDefault("UsernameInputY", 401)
    SetDefault("CharacterSelectionMenuX", 290)
    SetDefault("CharacterSelectionMenuY", 110)
    SetDefault("LogFilesToKeep", 30)
    SetDefault("CheckServerAddress", "patchserver.crypticstudios.com, us1.proxy.crypticstudios.com, eu1.proxy.crypticstudios.com, us2.proxy.crypticstudios.com, eu2.proxy.crypticstudios.com")
    SetDefault("LeadershipOptionalAssets", "Hero|Adventurer|ManatArms|Mercenary|Guard|Footman")
EndFunc

Global $CurrentAccount = 1
If Not IsDeclared("LoadPrivateSettings") Then Assign("LoadPrivateSettings", 0, 2)
Global $SettingsDir = @AppDataDir & "\Neverwinter Invoke Bot"

Global $DeletedString = "DELETED_"
For $i = 1 To 100
    $DeletedString &= Chr(Random(0, 255, 1))
Next

SetAllAccountsValue("Language", LoadLocalizations())
Global $Language = GetValue("Language")

Func SetDefault($name, $value = 0)
    If Not IsDeclared("SETTINGS_Default_" & $name) Then Return Assign("SETTINGS_Default_" & $name, $value, 2)
EndFunc

Func SetAllAccountsValue($name, $value = 0)
    If IsDeclared("SETTINGS_AllAccounts_" & $name) Then Return Assign("SETTINGS_AllAccounts_" & $name, $value)
    Return Assign("SETTINGS_AllAccounts_" & $name, $value, 2)
EndFunc

Func SetAccountValue($name, $value = 0, $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then Return Assign("SETTINGS_Account" & $account & "_" & $name, $value)
    Return Assign("SETTINGS_Account" & $account & "_" & $name, $value, 2)
EndFunc

Func SetCharacterValue($name, $value = 0, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name) Then Return Assign("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name, $value)
    Return Assign("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name, $value, 2)
EndFunc

Func DeleteAllAccountsValue($name)
    If IsDeclared("SETTINGS_AllAccounts_" & $name) Then Return Assign("SETTINGS_AllAccounts_" & $name, $DeletedString)
    Return 1
EndFunc

Func DeleteAccountValue($name, $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_" & $name) Then Return Assign("SETTINGS_Account" & $account & "_" & $name, $DeletedString)
    Return 1
EndFunc

Func DeleteCharacterValue($name, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name) Then Return Assign("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name, $DeletedString)
    Return 1
EndFunc

Func AddAllAccountsCountValue($name, $value = 1)
    Return SetAllAccountsValue($name, GetAllAccountsValue($name) + $value)
EndFunc

Func AddAccountCountValue($name, $value = 1, $account = $CurrentAccount)
    Return SetAccountValue($name, GetAccountValue($name, $account) + $value, $account)
EndFunc

Func AddCharacterCountValue($name, $value = 1, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    Return SetCharacterValue($name, GetCharacterValue($name, $character, $account) + $value, $character, $account)
EndFunc

Func GetValue($name, $account = $CurrentAccount, $character = GetAccountValue("CurrentCharacter", $CurrentAccount))
    If IsDeclared("SETTINGS_AllAccounts_" & $name) And Not ( Eval("SETTINGS_AllAccounts_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_AllAccounts_" & $name)
    If $account And @NumParams > 1 Then
        If IsDeclared("SETTINGS_Account" & $account & "_" & $name) And Not ( Eval("SETTINGS_Account" & $account & "_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Account" & $account & "_" & $name)
        If $character And @NumParams = 3 And IsDeclared("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name) And Not ( Eval("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name)
    Else
        If IsDeclared("SETTINGS_Account" & $CurrentAccount & "_" & $name) And Not ( Eval("SETTINGS_Account" & $CurrentAccount & "_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Account" & $CurrentAccount & "_" & $name)
        If IsDeclared("SETTINGS_Account" & $CurrentAccount & "_Character" & GetAccountValue("CurrentCharacter", $CurrentAccount) & "_" & $name) And Not ( Eval("SETTINGS_Account" & $CurrentAccount & "_Character" & GetAccountValue("CurrentCharacter", $CurrentAccount) & "_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Account" & $CurrentAccount & "_Character" & GetAccountValue("CurrentCharacter", $CurrentAccount) & "_" & $name)
    EndIf
    If IsDeclared("SETTINGS_Default_" & $name) Then Return Eval("SETTINGS_Default_" & $name)
    Return 0
EndFunc

Func GetAllAccountsValue($name)
    If IsDeclared("SETTINGS_AllAccounts_" & $name) And Not ( Eval("SETTINGS_AllAccounts_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_AllAccounts_" & $name)
    If IsDeclared("SETTINGS_Default_" & $name) Then Return Eval("SETTINGS_Default_" & $name)
    Return 0
EndFunc

Func GetAccountValue($name, $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_" & $name) And Not ( Eval("SETTINGS_Account" & $account & "_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Account" & $account & "_" & $name)
    If IsDeclared("SETTINGS_Default_" & $name) Then Return Eval("SETTINGS_Default_" & $name)
    Return 0
EndFunc

Func GetCharacterValue($name, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    If IsDeclared("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name) And Not ( Eval("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Account" & $account & "_Character" & $character & "_" & $name)
    If IsDeclared("SETTINGS_Default_" & $name) Then Return Eval("SETTINGS_Default_" & $name)
    Return 0
EndFunc

Func GetDefaultValue($name)
    If IsDeclared("SETTINGS_Default_" & $name) And Not ( Eval("SETTINGS_Default_" & $name) == $DeletedString ) Then Return Eval("SETTINGS_Default_" & $name)
    Return 0
EndFunc

Func SaveIniAllAccounts($name, $value = "")
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\Settings.ini", "AllAccounts", $name)
    Return _UnicodeIniWrite($SettingsDir & "\Settings.ini", "AllAccounts", $name, $value)
EndFunc

Func GetIniAllAccounts($name)
    Return _UnicodeIniRead($SettingsDir & "\Settings.ini", "AllAccounts", $name, "")
EndFunc

Func DeleteIniAllAccounts($name)
    Return _UnicodeIniDelete($SettingsDir & "\Settings.ini", "AllAccounts", $name)
EndFunc

Func SaveIniAccount($name, $value = "", $account = $CurrentAccount)
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\Settings.ini", "Account" & $account, $name)
    Return _UnicodeIniWrite($SettingsDir & "\Settings.ini", "Account" & $account, $name, $value)
EndFunc

Func GetIniAccount($name, $account = $CurrentAccount)
    Return _UnicodeIniRead($SettingsDir & "\Settings.ini", "Account" & $account, $name, "")
EndFunc

Func DeleteIniAccount($name, $account = $CurrentAccount)
    Return _UnicodeIniDelete($SettingsDir & "\Settings.ini", "Account" & $account, $name)
EndFunc

Func SaveIniCharacter($name, $value = "", $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\Settings.ini", "Account" & $account & "_Character" & $character, $name)
    Return _UnicodeIniWrite($SettingsDir & "\Settings.ini", "Account" & $account & "_Character" & $character, $name, $value)
EndFunc

Func GetIniCharacter($name, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    Return _UnicodeIniRead($SettingsDir & "\Settings.ini", "Account" & $account & "_Character" & $character, $name, "")
EndFunc

Func DeleteIniCharacter($name, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    Return _UnicodeIniDelete($SettingsDir & "\Settings.ini", "Account" & $account & "_Character" & $character, $name)
EndFunc

Func SavePrivateIniAllAccounts($name, $value = "")
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\PrivateSettings.ini", "AllAccounts", $name)
    Return _UnicodeIniWrite($SettingsDir & "\PrivateSettings.ini", "AllAccounts", $name, StringToBinary(String($value), $SB_UTF8))
EndFunc

Func GetPrivateIniAllAccounts($name)
    Return _UnicodeIniRead($SettingsDir & "\PrivateSettings.ini", "AllAccounts", $name, "")
EndFunc

Func SavePrivateIniAccount($name, $value = "", $account = $CurrentAccount)
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name)
    Return _UnicodeIniWrite($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name, StringToBinary(String($value), $SB_UTF8))
EndFunc

Func GetPrivateIniAccount($name, $account = $CurrentAccount)
    Return _UnicodeIniRead($SettingsDir & "\PrivateSettings.ini", "Account" & $account, $name, "")
EndFunc

Func SavePrivateIniCharacter($name, $value = "", $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\PrivateSettings.ini", "Account" & $account & "_Character" & $character, $name)
    Return _UnicodeIniWrite($SettingsDir & "\PrivateSettings.ini", "Account" & $account & "_Character" & $character, $name, StringToBinary(String($value), $SB_UTF8))
EndFunc

Func GetPrivateIniCharacter($name, $character = GetAccountValue("CurrentCharacter", $CurrentAccount), $account = $CurrentAccount)
    Return _UnicodeIniRead($SettingsDir & "\PrivateSettings.ini", "Account" & $account & "_Character" & $character, $name, "")
EndFunc

Func Statistics_SaveIniAllAccounts($name, $value = "")
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\Statistics.ini", "AllAccounts", $name)
    If Not GetAllAccountsValue("StartDate") Then
        Local $Month[13] = [12, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], $Date = $Month[Number(@MON)] & " " & Number(@MDAY) & ", " & @YEAR
        _UnicodeIniWrite($SettingsDir & "\Statistics.ini", "AllAccounts", "StartDate", $Date)
        SetAllAccountsValue("StartDate", $Date)
    EndIf
    Return _UnicodeIniWrite($SettingsDir & "\Statistics.ini", "AllAccounts", $name, $value)
EndFunc

Func Statistics_GetIniAllAccounts($name)
    Return _UnicodeIniRead($SettingsDir & "\Statistics.ini", "AllAccounts", $name, "")
EndFunc

Func Statistics_DeleteIniAllAccounts($name)
    Return _UnicodeIniDelete($SettingsDir & "\Statistics.ini", "AllAccounts", $name)
EndFunc

Func Statistics_SaveIniAccount($name, $value = "", $account = $CurrentAccount)
    If $value == "" Then Return _UnicodeIniDelete($SettingsDir & "\Statistics.ini", "Account" & $account, $name)
    If Not GetAccountValue("StartDate", $account) Then
        Local $Month[13] = [12, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], $Date = $Month[Number(@MON)] & " " & Number(@MDAY) & ", " & @YEAR
        _UnicodeIniWrite($SettingsDir & "\Statistics.ini", "Account" & $account, "StartDate", $Date)
        SetAccountValue("StartDate", $Date, $account)
    EndIf
    Return _UnicodeIniWrite($SettingsDir & "\Statistics.ini", "Account" & $account, $name, $value)
EndFunc

Func Statistics_GetIniAccount($name, $account = $CurrentAccount)
    Return _UnicodeIniRead($SettingsDir & "\Statistics.ini", "Account" & $account, $name, "")
EndFunc

Func Statistics_DeleteIniAccount($name, $account = $CurrentAccount)
    Return _UnicodeIniDelete($SettingsDir & "\Statistics.ini", "Account" & $account, $name)
EndFunc

Func LoadSettings($file)
    Local $sections = IniReadSectionNames($file)
    If @error <> 0 Then Return
    For $i = 1 To $sections[0]
        Local $values = IniReadSection($file, $sections[$i])
        If @error = 0 Then
            For $i2 = 1 To $values[0][0]
                Local $v = _UnicodeIni_BinaryToString($values[$i2][1])
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

Global $WinHandle, $ProcessName
Func FindWindow($p = "GameClient.exe", $c = "CrypticWindowClass", $t = 0)
    $WinHandle = 0
    $ProcessName = $p
    Local $list = ProcessList($p)
    If @error <> 0 Then Return
    For $i = 1 To $list[0][0]
        Local $Data = _WinAPI_EnumProcessWindows($list[$i][1], False)
        If @error = 0 Then
            For $i2 = 1 To $Data[0][0]
                If ( Not $c Or $Data[$i2][1] == $c ) And ( Not $t Or WinGetTitle($Data[$i2][0]) == $t ) And WinExists($Data[$i2][0]) Then
                    $WinHandle = $Data[$i2][0]
                    Return
                EndIf
            Next
        EndIf
    Next
EndFunc

Func Focus($p = "GameClient.exe", $c = "CrypticWindowClass", $t = 0)
    FindWindow($p, $c, $t)
    If Not $WinHandle Then Return 0
    If WinActive($WinHandle) Then Return 1
    WinActivate($WinHandle)
    Sleep(500)
    Return 0
EndFunc

Global $ClientInfo, $ClientSize, $ClientWidth, $ClientHeight, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $ClientWidthCenter, $ClientHeightCenter, $WinWidth, $WinHeight, $WinLeft, $WinTop, $WinRight, $WinBottom, $WinWidthCenter, $WinHeightCenter, $PaddingWidth, $PaddingHeight, $PaddingLeft, $PaddingTop, $PaddingRight, $PaddingBottom, $DeskTopWidth, $DeskTopHeight, $OffsetX = 0, $OffsetY = 0
Func GetPosition()
    If Not $WinHandle Then Return 0
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
    $PaddingLeft = $ClientLeft - $WinLeft
    $PaddingTop = $ClientTop - $WinTop
    $PaddingRight = $WinRight - $ClientRight
    $PaddingBottom = $WinBottom - $ClientBottom
    $DeskTopWidth = @DeskTopWidth
    $DeskTopHeight = @DeskTopHeight
    $OffsetX = $ClientLeft
    $OffsetY = $ClientTop
    Return 1
EndFunc
