#NoTrayIcon
#RequireAdmin
Global $LoadPrivateSettings = 1
#include "..\variables.au3"
Global $Title = $Name & " v" & $Version
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    If Not $CmdLine[0] Or Number($CmdLine[1]) <> 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("AlreadyRunning"))
    Exit
EndIf
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\red.ico")
AutoItSetOption("TrayIconHide", 0)
TraySetToolTip($Title)
Global $AllLoginInfoFound = 1, $FirstRun = 1, $SkipAllConfigurations, $UnattendedMode, $UnattendedModeCheckSettings, $EnableProfessions, $MinutesToStart = 0, $ReLogged = 0, $LogInTries = 0, $DoRelogCount = 0, $TimeOutRetries = 0, $DisableRelogCount = 1, $DisableRestartCount = 1, $GamePatched = 0, $CofferTries = 0, $LoopStarted = 0, $RestartLoop = 0, $Restarted = 0, $LogDate = 0, $LogTime = 0, $LogStartDate = 0, $LogStartTime = 0, $LogSessionStart = 1, $LoopDelayMinutes[7] = [6, 0, 15, 30, 45, 60, 90], $MaxLoops = $LoopDelayMinutes[0], $FailedInvoke, $StartTimer, $WaitingTimer, $LoggingIn, $EndTime, $MinutesToEndSaved, $MinutesToEndSavedTimer, $MouseOffset = 5
AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
#include <StringConstants.au3>
#include <ColorConstants.au3>
#include <Math.au3>
#include <Crypt.au3>
#include "_DownloadFile.au3"
#include "_GetUTCMinutes.au3"
#include "_ImageSearch.au3"
#include "_MultilineInputBox.au3"
#include "_GUIScrollbars_Ex.au3"
#Include "_Icons.au3"
#include "Professions.au3"

Func Array($x)
    Return StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($x, $STR_STRIPALL), "^,", ""), ",$", ""), ",")
EndFunc

Global $GameClientInstallLocation = RegRead("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "InstallLocation")
If @error <> 0 Then $GameClientInstallLocation = 0

Func GetClientLauncherPath()
    Local $i = 1
    While 1
        Local $k = RegEnumKey("HKEY_LOCAL_MACHINE\SOFTWARE\Perfect World Entertainment\Core", $i)
        If @error <> 0 Then ExitLoop
        If RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Perfect World Entertainment\Core\" & $k, "APP_ABBR") = "nw" And Number(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Perfect World Entertainment\Core\" & $k, "installed")) Then
            Local $p = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Perfect World Entertainment\Core\" & $k, "INSTALL_PATH")
            If @error = 0 Then
                $p = StringRegExpReplace($p, "\\+$", "")
                If FileExists($p & "\Neverwinter.exe") Then Return $p
            EndIf
        EndIf
        $i += 1
    WEnd
    If $GameClientInstallLocation And FileExists($GameClientInstallLocation & "\Neverwinter.exe") Then Return $GameClientInstallLocation
    Return 0
EndFunc

Global $GameClientLauncherInstallLocation = GetClientLauncherPath()

Func CloseClient($p = "GameClient.exe"); If $RestartLoop Then Return 0
    Local $list = ProcessList($p)
    If @error <> 0 Then Return 0
    Local $CloseClientWaitingTimer = TimerInit()
    For $i = 1 To $list[0][0]
        Local $PID = $list[$i][1]
        While ProcessExists($PID)
            TimeOut($CloseClientWaitingTimer); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            ProcessClose($PID)
            Sleep(100)
        WEnd
    Next
    Return $list[0][0]
EndFunc

Func Position(); If $RestartLoop Then Return 0
While 1
While 1
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        If Not GetValue("DisableRestartGameClient") And GetValue("LogInUserName") And GetValue("LogInPassword") And $GameClientLauncherInstallLocation And FileExists($GameClientLauncherInstallLocation & "\Neverwinter.exe") And ImageExists("LogInScreen") Then
            $LogInTries = 0
            $DisableRelogCount = 1
            Splash("[ " & Localize("NeverwinterNotFound") & " ]")
            CloseClient(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            StartClient(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Return
        EndIf
        Error(Localize("NeverwinterNotFound")); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
    If Not GetValue("GameClientWidth") Or Not GetValue("GameClientHeight") Then Return
    Local $PositionWaitingTimer = TimerInit()
    If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight And ( GetValue("GameClientWidth") <> $DeskTopWidth Or GetValue("GameClientHeight") <> $DeskTopHeight ) Then
        Sleep(10000)
        While 1
            TimeOut($PositionWaitingTimer); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            MyMouseMove($DeskTopWidth - 1, 0)
            SingleClick()
            Sleep(10000)
            Focus()
            If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight And ( GetValue("GameClientWidth") <> $DeskTopWidth Or GetValue("GameClientHeight") <> $DeskTopHeight ) Then
                Send("{ALTDOWN}{TAB}{ALTUP}")
                Sleep(10000)
                Focus()
                If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
                Sleep(10000)
            Else
                ExitLoop
            EndIf
        WEnd
    EndIf
    If $DeskTopWidth < GetValue("GameClientWidth") Or $DeskTopHeight < GetValue("GameClientHeight") Then
        Error(Localize("ResolutionOrHigher", "<RESOLUTION>", GetValue("GameClientWidth") & "x" & GetValue("GameClientHeight"))); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Return
    EndIf
    If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
        While 1
            TimeOut($PositionWaitingTimer); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
                Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
                DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
                DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
                Focus()
                If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            EndIf
            WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
            Focus()
            If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
                Sleep(5000)
                Focus()
                If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            Else
                ExitLoop
            EndIf
        WEnd
        If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
            Error(Localize("UnableToResize")); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
        EndIf
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        While 1
            TimeOut($PositionWaitingTimer); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
                Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
                DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
                DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
                Focus()
                If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            EndIf
            WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
            Focus()
            If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
                Sleep(5000)
                Focus()
                If Not $WinHandle Or Not GetPosition() Then ExitLoop 2
            Else
                ExitLoop
            EndIf
        WEnd
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            Error(Localize("UnableToMove")); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
        EndIf
    EndIf
    WinSetOnTop($WinHandle, "", 1)
Return
WEnd
WEnd
EndFunc

Func SyncValues()
    If GetValue("FinishedLoop") Then
        AddAccountCountValue("CurrentLoop", GetValue("FinishedLoop"))
        DeleteAccountValue("FinishedLoop")
        SetAccountValue("CurrentCharacter", GetValue("StartAtCharacter"))
        DeleteAccountValue("FinishedCharacter")
        $ETAText = ""
    EndIf
    AddAccountCountValue("CurrentCharacter", GetValue("FinishedCharacter"))
    DeleteAccountValue("FinishedCharacter")
EndFunc

Func Loop()
While 1
While 1
    $LoopStarted = 1
    $RestartLoop = 0
    WaitToInvoke(); If $RestartLoop Then Return 0
    If $RestartLoop Then ExitLoop 1
    AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
    If CompletedAccount() Then
        End(); If $RestartLoop Then Return 0
        If $RestartLoop Then ExitLoop 1
        Exit
    EndIf
    Position(); If $RestartLoop Then Return 0
    If $RestartLoop Then ExitLoop 1
    $DisableRestartCount = 0
    Splash()
    FindLogInScreen(); If $RestartLoop Then Return 0
    If $RestartLoop Then ExitLoop 1
    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
    If ImageExists("SelectionScreen") Then
        WaitForScreen("SelectionScreen"); If $RestartLoop Then Return 0
        If $RestartLoop Then ExitLoop 1
    EndIf
    Position(); If $RestartLoop Then Return 0
    If $RestartLoop Then ExitLoop 1
    Local $Start = GetValue("CurrentCharacter"), $CharacterSelectionPositioned = 0
    For $i = $Start To GetValue("EndAtCharacter")
        SetAccountValue("CurrentCharacter", $i)
        DeleteAccountValue("FinishedCharacter")
        If EndNowTime() Then
            SetAllAccountsValue("EndNow", 1)
            ExitLoop
        EndIf
        If Not GetAccountValue("InfiniteLoopsStarted") Or GetValue("EnableProfessions") Then
            WaitToInvoke(); If $RestartLoop Then Return 0
            If $RestartLoop Then ExitLoop 2
            Splash()
            Local $LoopTimer = TimerInit()
            Focus()
            MyMouseMove(GetValue("CharacterSelectionMenuX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("CharacterSelectionMenuY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
            DoubleRightClick()
            MyMouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientHeightCenter + Random(-$MouseOffset, $MouseOffset, 1))
            If $CharacterSelectionPositioned And Not GetValue("DisableSimpleCharacterSelection") Then
                Send("{DOWN}")
            ElseIf GetValue("CurrentCharacter") <= Ceiling(GetValue("TotalSlots") / 2) Then
                AutoItSetOption("SendKeyDownDelay", GetValue("CharacterSelectionScrollAwayKeyDelaySeconds") * 1000)
                For $n = 1 To GetValue("TotalSlots")
                    Send("{UP}")
                Next
                AutoItSetOption("SendKeyDownDelay", GetValue("CharacterSelectionScrollTowardKeyDelaySeconds") * 1000)
                Sleep(1000)
                For $n = 2 To GetValue("CurrentCharacter")
                    Send("{DOWN}")
                    Sleep(50)
                Next
                AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
            Else
                AutoItSetOption("SendKeyDownDelay", GetValue("CharacterSelectionScrollAwayKeyDelaySeconds") * 1000)
                For $n = 1 To GetValue("TotalSlots")
                    Send("{DOWN}")
                Next
                AutoItSetOption("SendKeyDownDelay", GetValue("CharacterSelectionScrollTowardKeyDelaySeconds") * 1000)
                Sleep(1000)
                For $n = 1 To (GetValue("TotalSlots") - GetValue("CurrentCharacter"))
                    Send("{UP}")
                    Sleep(50)
                Next
                AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
            EndIf
            Sleep(1000)
            Send("{ENTER}")
            Sleep(1000)
            If GetValue("SafeLoginX") Then
                MyMouseMove(GetValue("SafeLoginX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("SafeLoginY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
                DoubleClick()
            EndIf
            Splash("[ " & Localize("WaitingForInGameScreen") & " ]")
            If ImageExists("ChangeCharacterButton") Then
                WaitForScreen("ChangeCharacterButton"); If $RestartLoop Then Return 0
                If $RestartLoop Then ExitLoop 2
                Splash()
                Sleep(GetValue("LogInDelaySeconds") * 1000)
            Else
                Sleep(GetValue("LogInSeconds") * 1000)
                Splash()
            EndIf
            If Not GetValue("DisableOverflowXPRewardCollection") And ImageSearch("OverflowXPReward") Then
                MySend(GetValue("CursorModeKey"))
                Sleep(500)
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                SaveItemCount("TotalOverflowXPRewards", 1)
                Sleep(1000)
                ClearWindows(); If $RestartLoop Then Return 0
                If $RestartLoop Then ExitLoop 2
            EndIf
            If Not GetAccountValue("InfiniteLoopsStarted") Then
                $WaitingTimer = TimerInit()
                $CofferTries = 0
                $FailedInvoke = 1
                Invoke(); If $RestartLoop Then Return 0
                If $RestartLoop Then ExitLoop 2
                SetCharacterInfo("CharacterTime", TimerInit())
                SetCharacterInfo("CharacterLoop", GetValue("CurrentLoop"))
                SetAccountValue("FinishedCharacter", 1)
                If GetValue("CurrentCharacter") >= GetValue("EndAtCharacter") Then
                    SetAccountValue("FinishedLoop", 1)
                    If GetValue("CurrentLoop") >= GetValue("EndAtLoop") Then SetAccountValue("CompletedAccountInvokes", 1)
                EndIf
                If $FailedInvoke Then
                    AddAccountCountValue("FailedInvoke")
                    AddCharacterCountInfo("FailedInvoke")
                EndIf
                If GetValue("OpenBagsOnEveryLoop") Or GetValue("CurrentLoop") = GetValue("StartAtLoop") Then
                    OpenInventoryBags("CelestialBagOfRefining"); If $RestartLoop Then Return 0
                    If $RestartLoop Then ExitLoop 2
                EndIf
            EndIf
            GetVIPAccountReward(); If $RestartLoop Then Return 0
            If $RestartLoop Then ExitLoop 2
            GetVIPCharacterReward(); If $RestartLoop Then Return 0
            If $RestartLoop Then ExitLoop 2
            RunProfessions(); If $RestartLoop Then Return 0
            If $RestartLoop Then ExitLoop 2
            Splash()
            If GetAccountValue("InfiniteLoopsStarted") Then
                SetCharacterInfo("CharacterTime", TimerInit())
                SetCharacterInfo("CharacterLoop", GetValue("CurrentLoop"))
                SetAccountValue("FinishedCharacter", 1)
                If GetValue("CurrentCharacter") >= GetValue("EndAtCharacter") Then SetAccountValue("FinishedLoop", 1)
            EndIf
            ChangeCharacter(); If $RestartLoop Then Return 0
            If $RestartLoop Then ExitLoop 2
            $TimeOutRetries = 0
            Local $LogOutTimer = TimerInit()
            Local $RemainingCharacters = GetValue("EndAtCharacter") - GetValue("CurrentCharacter")
            Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
            If ImageExists("SelectionScreen") Then
                WaitForScreen("SelectionScreen"); If $RestartLoop Then Return 0
                If $RestartLoop Then ExitLoop 2
                Splash()
            Else
                Sleep(GetValue("LogOutSeconds") * 1000)
                Splash()
            EndIf
            If GetValue("FinishedLoop") Or CompletedAccount() Then
                ExitLoop
            Else
                Local $AdditionalKeyPressTime = 0
                If GetValue("DisableSimpleCharacterSelection") Then
                    For $n = 1 To $RemainingCharacters
                        If GetValue("CurrentCharacter") + $n <= Ceiling(GetValue("TotalSlots") / 2) Then
                            $AdditionalKeyPressTime += $n * (GetValue("KeyDelaySeconds") * 1000 + 50)
                        ElseIf GetValue("CurrentCharacter") <= Floor(GetValue("TotalSlots") / 2) + 1 Then
                            $AdditionalKeyPressTime -= (GetValue("CurrentCharacter") + $n - Floor(GetValue("TotalSlots") / 2) + 1) * (GetValue("KeyDelaySeconds") * 1000 + 50)
                        Else
                            $AdditionalKeyPressTime -= $n * (GetValue("KeyDelaySeconds") * 1000 + 50)
                        EndIf
                    Next
                EndIf
                Local $LastTime = TimerDiff($LoopTimer)
                Local $RemainingSeconds = ( $RemainingCharacters * $LastTime + $AdditionalKeyPressTime - TimerDiff($LogOutTimer) ) / 1000
                Local $LastTook = "LastInvokeTook"
                If GetAccountValue("InfiniteLoopsStarted") Then $LastTook = "LastProfessionsTook"
                $ETAText = Localize($LastTook, "<SECONDS>", Round($LastTime / 1000, 2)) & @CRLF & Localize("ETAForCurrentLoop", "<MINUTES>", HoursAndMinutes($RemainingSeconds / 60))
            EndIf
            $CharacterSelectionPositioned = 1
        ElseIf GetValue("CurrentCharacter") >= GetValue("EndAtCharacter") Then
            SetAccountValue("FinishedLoop", 1)
        EndIf
    Next
    End(); If $RestartLoop Then Return 0
    If $RestartLoop Then ExitLoop 1
    Exit
Return
WEnd
WEnd
EndFunc

Func StartLoop(); If $RestartLoop Then Return 0
    If $LoopStarted Then
        $RestartLoop = 1
        Return 0
    EndIf
    Loop()
    Exit
EndFunc

Func EndNowTime($waiting = 0)
    If $MinutesToEndSavedTimer And $MinutesToEndSaved - TimerDiff($MinutesToEndSavedTimer) / 60000 <= $waiting + 15 Then Return 1
    Return 0
EndFunc

Func CompletedAccount()
    SyncValues()
    If EndNowTime() Then SetAllAccountsValue("EndNow", 1)
    If GetValue("EndNow") Or ( Not GetAccountValue("InfiniteLoopsStarted") And ( GetValue("CompletedAccountInvokes") Or ( GetValue("CurrentLoop") > $MaxLoops And GetValue("Invoked") = (GetValue("TotalSlots") * $MaxLoops) ) ) ) Then
        SetAccountValue("CompletedAccountInvokes", 1)
        Return 1
    EndIf
    Return 0
EndFunc

Func CheckAccounts()
    Local $CurrentComplete = CompletedAccount(), $old = $CurrentAccount, $oldtime = GetTimeToInvoke(), $oldloop = GetValue("CurrentLoop"), $new = $old, $newtime = $oldtime, $newloop = $oldloop, $allcomplete = 1
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        If GetValue("InfiniteLoops") And $EnableProfessions Then
            Local $oldc = GetValue("CurrentCharacter")
            For $c = GetValue("StartAtCharacter") To GetValue("EndAtCharacter")
                SetAccountValue("CurrentCharacter", $c)
                If GetValue("EnableProfessions") Then
                    SetAllAccountsValue("InfiniteLoopsFound", 1)
                    ExitLoop
                EndIf
            Next
            SetAccountValue("CurrentCharacter", $oldc)
        EndIf
        If Not CompletedAccount() Then
            $allcomplete = 0
            Local $t = GetTimeToInvoke(), $l = GetValue("CurrentLoop")
            If ( $l < $newloop And $t < 1 ) Or ( $CurrentComplete And ( $t < $newtime Or $new = $old ) ) Or ( $oldtime > 1 And ($t + 1) < $oldtime And $t < $newtime ) Then
                $new = $i
                $newtime = $t
                $newloop = $l
            EndIf
        EndIf
    Next
    $CurrentAccount = $old
    If $allcomplete Then Return 0
    Return $new
EndFunc

Func GetTimeToInvoke()
    Local $LastLoop = GetCharacterInfo("CharacterLoop")
    If ( $LastLoop And GetValue("CurrentLoop") > $LastLoop ) Or ( Not $LastLoop And GetValue("CurrentLoop") > GetValue("StartAtLoop") ) Then
        Local $Time = GetCharacterInfo("CharacterTime"), $m
        If Not $Time Then $Time = $StartTimer
        If GetAccountValue("InfiniteLoopsStarted") Then
            If GetValue("InfiniteLoopDelayMinutes") < 80 Then SetAccountValue("InfiniteLoopDelayMinutes", 80)
            $m = GetValue("InfiniteLoopDelayMinutes")
        ElseIf GetValue("CurrentLoop") > $MaxLoops Then
            $m = $LoopDelayMinutes[$MaxLoops]
        Else
            $m = $LoopDelayMinutes[GetValue("CurrentLoop")]
        EndIf
        Local $Minutes = $m - TimerDiff($Time) / 60000
        If $Minutes > 0 Then Return $Minutes
    EndIf
    Return 0
EndFunc

Func WaitToInvoke(); If $RestartLoop Then Return 0
    Local $check = CheckAccounts()
    If $check > 0 Then
        Local $Minutes = GetTimeToInvoke()
        If $Minutes > 1 Or $check <> $CurrentAccount Then
            $ETAText = ""
            Position(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
            $WaitingTimer = TimerInit()
            While Not ( ImageSearch("SelectionScreen") Or ImageSearch("LogInScreen") )
                Sleep(1000)
                TimeOut(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                Position(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
            WEnd
            Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
            If ImageSearch("SelectionScreen") Then
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                Sleep(1000)
                $DisableRelogCount = 1
            EndIf
            $WaitingTimer = TimerInit()
            While Not ImageSearch("LogInScreen")
                Sleep(1000)
                TimeOut(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                Position(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                If ImageSearch("SelectionScreen") Then
                    MyMouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(1000)
                    $DisableRelogCount = 1
                EndIf
            WEnd
            $CurrentAccount = $check
            $Minutes = GetTimeToInvoke()
            If $Minutes <= 0 Then
                StartLoop(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
            EndIf
        EndIf
        If $Minutes > 0 Then
            $ETAText = ""
            Local $WaitingForDelay = "WaitingForInvokeDelay"
            If GetAccountValue("InfiniteLoopsStarted") Then $WaitingForDelay = "WaitingForProfessionsDelay"
            WaitMinutes($Minutes, $WaitingForDelay); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            StartLoop(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
        EndIf
    Else
        End(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Exit
    EndIf
EndFunc

Func Invoke(); If $RestartLoop Then Return 0
    If $CofferTries >= 5 Then Return
    If ImageExists("CongratulationsWindow") Then
        For $n = 1 To 5
            FindLogInScreen(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            MySend(GetValue("InvokeKey"))
            Sleep(500)
            If ImageSearch("Invoked") Then
                If GetValue("CurrentLoop") > $MaxLoops Then
                    $FailedInvoke = 0
                EndIf
                Return
            EndIf
            For $k = 1 To 10
                If ImageSearch("VaultOfPietyButton") Then
                    MyMouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    GetCoffer(); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                    Return
                ElseIf ImageSearch("CongratulationsWindow") Then
                    Sleep(500)
                    If ImageSearch("CongratulationsWindow") Then
                        AddAccountCountValue("Invoked")
                        Statistics_SaveIniAllAccounts("TotalInvoked", Number(Statistics_GetIniAllAccounts("TotalInvoked")) + 1)
                        Statistics_SaveIniAccount("TotalInvoked", Number(Statistics_GetIniAccount("TotalInvoked")) + 1)
                        $FailedInvoke = 0
                        Return
                    EndIf
                EndIf
                FindLogInScreen(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                Sleep(500)
            Next
        Next
    Else
        For $n = 1 To 3
            MySend(GetValue("InvokeKey"))
            Sleep(5000)
        Next
        If ImageSearch("VaultOfPietyButton") Then
            MyMouseMove($_ImageSearchX, $_ImageSearchY)
            SingleClick()
            GetCoffer(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
        EndIf
    EndIf
EndFunc

Func GetVIPAccountReward(); If $RestartLoop Then Return 0
    Local $tried = 0
While 1
While 1
    If Not GetValue("SkipVIPAccountReward") And Not GetValue("CollectedVIPAccountReward") And GetValue("LastVIPAccountRewardTryLoop") < GetValue("CurrentLoop") And ( GetValue("VIPAccountRewardCharacter") < GetValue("StartAtCharacter") Or GetValue("VIPAccountRewardCharacter") > GetValue("EndAtCharacter") Or GetValue("VIPAccountRewardCharacter") = GetValue("CurrentCharacter") ) Then
        If GetValue("VIPAccountRewardTries") < 3 Then
            ClearWindows(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            $tried = 1
            AddAccountCountValue("VIPAccountRewardTries")
            MySend(GetValue("InventoryKey"))
            Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
            If Not ImageSearch("VIPInventory") And ImageSearch("VIPInventoryTab") Then
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                DoubleClick()
                Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
            EndIf
            If Not ImageSearch("VIPInventory") Or Not ImageSearch("VIPAccountRewards", $_ImageSearchLeft, $_ImageSearchBottom, $_ImageSearchRight + 50) Then ExitLoop
            Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop, $right = $_ImageSearchRight, $bottom = $_ImageSearchBottom
            If Not ImageSearch("VIPRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $ClientRight, $_ImageSearchBottom + 20) Then ExitLoop
            $_ImageSearchX = Random($_ImageSearchRight + GetValue("VIPRewardButtonGap") + 6, $_ImageSearchRight + GetValue("VIPRewardButtonGap") + GetValue("VIPRewardButtonWidth") - 5, 1)
            $_ImageSearchY = Random($_ImageSearchHeightCenter + 6 - Ceiling(GetValue("VIPRewardButtonHeight") / 2), $_ImageSearchHeightCenter + Floor(GetValue("VIPRewardButtonHeight") / 2) - 5, 1)
            MyMouseMove($_ImageSearchX, $_ImageSearchY)
            SingleClick()
            Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
            If Not ImageSearch("VIPAccountRewards", $left, $top, $right, $bottom) Then
                SaveItemCount("TotalVIPAccountRewards", 1)
                SetAccountValue("CollectedVIPAccountReward", 1)
            ElseIf ImageSearch("VIPRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $ClientRight, $_ImageSearchBottom + 20) Then
                $_ImageSearchX = Random($_ImageSearchRight + GetValue("VIPRewardButtonGap") + 6, $_ImageSearchRight + GetValue("VIPRewardButtonGap") + GetValue("VIPRewardButtonWidth") - 5, 1)
                $_ImageSearchY = Random($_ImageSearchHeightCenter + 6 - Ceiling(GetValue("VIPRewardButtonHeight") / 2), $_ImageSearchHeightCenter + Floor(GetValue("VIPRewardButtonHeight") / 2) - 5, 1)
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
                If Not ImageSearch("VIPAccountRewards", $left, $top, $right, $bottom) Then
                    SaveItemCount("TotalVIPAccountRewards", 1)
                    SetAccountValue("CollectedVIPAccountReward", 1)
                EndIf
            EndIf
        EndIf
        SetAccountValue("LastVIPAccountRewardTryLoop", GetValue("CurrentLoop"))
        DeleteAccountValue("VIPAccountRewardTries")
        SetAccountValue("TriedVIPAccountReward", 1)
    EndIf
    If $tried Then
        OpenInventoryBags("VIPAccountRewards"); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
Return
WEnd
WEnd
EndFunc

Func GetVIPCharacterReward(); If $RestartLoop Then Return 0
    If Not GetValue("ClaimVIPCharacterReward") Or GetValue("CollectedVIPCharacterReward") Then Return
    ClearWindows(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    MySend(GetValue("InventoryKey"))
    Sleep(GetValue("ClaimVIPCharacterRewardDelay") * 1000)
    If Not ImageSearch("VIPInventory") And ImageSearch("VIPInventoryTab") Then
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("ClaimVIPCharacterRewardDelay") * 1000)
    EndIf
    SetCharacterInfo("FailedVIPCharacterReward", 1)
    If Not ImageSearch("VIPInventory") Or Not ImageSearch("VIPCharacterRewards", $_ImageSearchLeft, $_ImageSearchBottom, $_ImageSearchRight + 50) Then Return
    Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop, $right = $_ImageSearchRight, $bottom = $_ImageSearchBottom
    If Not ImageSearch("VIPRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $ClientRight, $_ImageSearchBottom + 20) Then Return
    $_ImageSearchX = Random($_ImageSearchRight + GetValue("VIPRewardButtonGap") + 6, $_ImageSearchRight + GetValue("VIPRewardButtonGap") + GetValue("VIPRewardButtonWidth") - 5, 1)
    $_ImageSearchY = Random($_ImageSearchHeightCenter + 6 - Ceiling(GetValue("VIPRewardButtonHeight") / 2), $_ImageSearchHeightCenter + Floor(GetValue("VIPRewardButtonHeight") / 2) - 5, 1)
    MyMouseMove($_ImageSearchX, $_ImageSearchY)
    SingleClick()
    Sleep(GetValue("ClaimVIPCharacterRewardDelay") * 1000)
    If Not ImageSearch("VIPCharacterRewards", $left, $top, $right, $bottom) Then
        SaveItemCount("TotalVIPCharacterRewards", 1)
        SetCharacterInfo("FailedVIPCharacterReward", 0)
        SetCharacterValue("CollectedVIPCharacterReward", 1)
    ElseIf ImageSearch("VIPRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $ClientRight, $_ImageSearchBottom + 20) Then
        $_ImageSearchX = Random($_ImageSearchRight + GetValue("VIPRewardButtonGap") + 6, $_ImageSearchRight + GetValue("VIPRewardButtonGap") + GetValue("VIPRewardButtonWidth") - 5, 1)
        $_ImageSearchY = Random($_ImageSearchHeightCenter + 6 - Ceiling(GetValue("VIPRewardButtonHeight") / 2), $_ImageSearchHeightCenter + Floor(GetValue("VIPRewardButtonHeight") / 2) - 5, 1)
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        SingleClick()
        Sleep(GetValue("ClaimVIPCharacterRewardDelay") * 1000)
        If Not ImageSearch("VIPCharacterRewards", $left, $top, $right, $bottom) Then
            SaveItemCount("TotalVIPCharacterRewards", 1)
            SetCharacterInfo("FailedVIPCharacterReward", 0)
            SetCharacterValue("CollectedVIPCharacterReward", 1)
        EndIf
    EndIf
    OpenInventoryBags("VIPCharacterRewards"); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Func OpenInventoryBags($bag); If $RestartLoop Then Return 0
    If GetValue("DisableOpeningBags") Then Return
    ClearWindows(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    MySend(GetValue("InventoryKey"))
    Sleep(GetValue("OpenInventoryBagDelay") * 1000)
    If Not ImageSearch("Inventory") And ImageSearch("InventoryTab") Then
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("OpenInventoryBagDelay") * 1000)
    EndIf
    MyMouseMove($ClientWidthCenter + Random(-50, 50, 1), $ClientBottom)
    If ImageSearch($bag) Then
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("OpenInventoryBagDelay") * 1000)
        MyMouseMove($ClientWidthCenter + Random(-50, 50, 1), $ClientBottom)
        For $i = 1 To 10
            If Not ImageSearch("OpenAnother") Then ExitLoop
            MyMouseMove($_ImageSearchX, $_ImageSearchY)
            SingleClick()
            Sleep(GetValue("OpenAnotherInventoryBagDelay") * 1000)
        Next
    EndIf
EndFunc

Func GetCoffer(); If $RestartLoop Then Return 0
    If $CofferTries >= 5 Then Return
    Sleep(GetValue("ClaimCofferDelay") * 1000)
    If ImageSearch("CelestialSynergyTab") Then
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("ClaimCofferDelay") * 1000)
    EndIf
    If ImageSearch(GetValue("Coffer")) Then
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("ClaimCofferDelay") * 1000)
        If GetValue("Coffer") = "ElixirOfFate" Then
            If ImageSearch("OK") Then
                Send("{BS 2}4")
                Sleep(500)
                If ImageSearch("OK") Then
                    MyMouseMove($_ImageSearchX, $_ImageSearchY)
                    DoubleClick()
                    SaveItemCount("TotalElixirsOfFate", 4)
                EndIf
            EndIf
        ElseIf GetValue("Coffer") = "BlessedProfessionsElementalPack" Then
            Send("{ENTER}")
            Sleep(500)
            Send("{ENTER}")
            Sleep(500)
            Sleep(GetValue("ClaimCofferDelay") * 1000)
            If ImageSearch(GetValue("Coffer")) Then
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                DoubleClick()
                Sleep(GetValue("ClaimCofferDelay") * 1000)
                Send("{ENTER}")
                Sleep(500)
                Send("{ENTER}")
                Sleep(500)
                SaveItemCount("TotalProfessionPacks", 2)
            Else
                SaveItemCount("TotalProfessionPacks", 1)
            EndIf
        Else
            Send("{ENTER}")
            Sleep(500)
            Send("{ENTER}")
            Sleep(500)
            SaveItemCount("TotalCelestialCoffers", 1)
        EndIf
    EndIf
    Sleep(GetValue("ClaimCofferDelay") * 1000)
    ClearWindows(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    $CofferTries += 1
    Invoke(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc


Global $AlternateLogInCommands = 1

Func SearchForChangeCharacterButton()
    If $ChangingCharacter And ImageSearch("ChangeCharacterButton") Then Return 1
    If $AlternateLogInCommands = 2 Or GetValue("GameMenuKey") = "{ESC}" Then
        Send("{ESC}")
    Else
        MySend(GetValue("GameMenuKey"))
    EndIf
    Sleep(1500)
    If $AlternateLogInCommands = 1 Then
        $AlternateLogInCommands = 2
    Else
        $AlternateLogInCommands = 1
    EndIf
    If ImageSearch("ChangeCharacterButton") Then Return 1
    Return 0
EndFunc

Func WaitForChangeCharacterButton(); If $RestartLoop Then Return 0
    If Not ImageExists("ChangeCharacterButton") Then Return
    $AlternateLogInCommands = 1
    $DoLogInCommands = 0
    While Not SearchForChangeCharacterButton()
        TimeOut(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        FindLogInScreen(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    WEnd
EndFunc

Func ClearWindows(); If $RestartLoop Then Return 0
    While 1
        WaitForChangeCharacterButton(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Send("{ESC}")
        Sleep(500)
        If Not ImageSearch("ChangeCharacterButton") Then Return 1
    WEnd
EndFunc

Global $ChangingCharacter = 1

Func ChangeCharacter(); If $RestartLoop Then Return 0
    $WaitingTimer = TimerInit()
    $ChangingCharacter = 1
While 1
While 1
    WaitForChangeCharacterButton(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    If ImageExists("ChangeCharacterButton") Then
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
    Else
        For $n = 1 To 3
            Send("{DOWN}")
            Sleep(GetValue("KeyDelaySeconds") * 1000)
        Next
        Sleep(500)
        Send("{ENTER}")
    EndIf
    Sleep(500)
    If ImageExists("OK") And Not ImageSearch("OK") Then
        Send("{ESC}")
        Sleep(500)
        Send("{ESC}")
        Sleep(1500)
        If ImageSearch("ChangeCharacterButton") Then
            Send("{ESC}")
            Sleep(500)
        EndIf
        ExitLoop
    EndIf
    For $n = 1 To 4
        Send("{ENTER}")
        Sleep(500)
    Next
    If ImageSearch("OK") Then
        Send("{ESC}")
        Sleep(500)
        Send("{ESC}")
        Sleep(1500)
        If ImageSearch("ChangeCharacterButton") Then
            Send("{ESC}")
            Sleep(500)
        EndIf
        ExitLoop
    EndIf
Return
WEnd
WEnd
EndFunc

Func DoubleClick()
    SingleClick()
    SingleClick()
EndFunc

Func SingleClick()
    Sleep(GetValue("KeyDelaySeconds") * 1000)
    MouseDown("primary")
    Sleep(GetValue("KeyDelaySeconds") * 1000)
    MouseUp("primary")
EndFunc

Func DoubleRightClick()
    SingleRightClick()
    SingleRightClick()
EndFunc

Func SingleRightClick()
    Sleep(GetValue("KeyDelaySeconds") * 1000)
    MouseDown("right")
    Sleep(GetValue("KeyDelaySeconds") * 1000)
    MouseUp("right")
EndFunc

Global $SplashWindow, $SplashWindowOnTop = 1, $LastSplashText = "", $SplashStartText = "", $ETAText = "", $SplashLeft = @DesktopWidth - GetValue("SplashWidth") - 70 - 1, $SplashTop = @DesktopHeight - GetValue("SplashHeight") - 50 - 1

Func Splash($s = "", $ontop = 1)
    If $s == 0 Then
        HotKeySet("{F4}")
        FindWindow()
        If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
        If Not GetValue("NoInputBlocking") Then BlockInput(0)
        SplashOff()
        $SplashWindow = 0
        Return
    EndIf
    Local $Message
    If GetAccountValue("InfiniteLoopsStarted") Then
        $Message = Localize("Professions", "<CURRENT>", GetValue("CurrentCharacter"), "<ENDAT>", GetValue("EndAtCharacter")) & @CRLF & $s & @CRLF & $ETAText
    Else
        $Message = Localize("Invoking", "<CURRENT>", GetValue("CurrentCharacter"), "<ENDAT>", GetValue("EndAtCharacter"), "<CURRENTLOOP>", GetValue("CurrentLoop"), "<ENDATLOOP>", GetValue("EndAtLoop")) & @CRLF & $s & @CRLF & $ETAText
    EndIf
    If $SplashWindow And $ontop = $SplashWindowOnTop Then
        $Message = Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & $SplashStartText & $Message
        If Not ($LastSplashText == $Message) Then
            ControlSetText($SplashWindow, "", "Static1", $Message)
            $LastSplashText = $Message
        EndIf
    Else
        HotKeySet("{F4}", "Pause")
        Local $setontop = $DLG_NOTITLE + $DLG_NOTONTOP, $leftlocation = $SplashLeft, $toplocation = $SplashTop
        If $ontop Then
            If GetValue("NoInputBlocking") Then
                $SplashStartText = Localize("ToStopPressF4") & @CRLF & @CRLF & @CRLF
            Else
                BlockInput(1)
                $SplashStartText = Localize("ToStopPressCtrlAltDel") & @CRLF & @CRLF
            EndIf
        Else
            If Not GetValue("NoInputBlocking") Then BlockInput(0)
            $setontop = $DLG_MOVEABLE + $DLG_NOTONTOP
            $toplocation = 50
            $SplashStartText = Localize("ToStopPressF4") & @CRLF & @CRLF & @CRLF
        EndIf
        $Message = Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & $SplashStartText & $Message
        $SplashWindow = SplashTextOn("", $Message, GetValue("SplashWidth"), GetValue("SplashHeight"), $leftlocation, $toplocation, $setontop)
        $LastSplashText = $Message
        WinSetOnTop($SplashWindow, "", 0)
        If $ontop Then
            Focus()
        Else
            FindWindow()
        EndIf
        If $WinHandle Then WinSetOnTop($WinHandle, "", $ontop)
        $SplashWindowOnTop = $ontop
    EndIf
EndFunc

Func WaitForScreen($image); If $RestartLoop Then Return 0
    Local $WaitForScreenWaitingTimer = TimerInit()
    While 1
        Position(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        If ImageSearch($image) Then Return
        FindLogInScreen(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        If Not $DoLogInCommands Or $image <> "ChangeCharacterButton" Then Sleep(500)
        TimeOut($WaitForScreenWaitingTimer); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    WEnd
EndFunc

Func DeclinePromptImageSearch($image)
    If Not ImageSearch($image) Then Return 0
    MyMouseMove($_ImageSearchX, $_ImageSearchY)
    SingleClick()
    Sleep(1000)
    If Not ImageSearch($image) Then Return 1
    MySend(GetValue("CursorModeKey"))
    Sleep(1000)
    MyMouseMove($_ImageSearchX, $_ImageSearchY)
    SingleClick()
    Sleep(1000)
    Return 1
EndFunc

Global $DoLogInCommands = 1

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"), $do = 1)
    If $do And Not ImageExists($image) Then Return 0
    If $do And $image = "ChangeCharacterButton" Then
        If DeclinePromptImageSearch("Later") Or DeclinePromptImageSearch("Decline") Then Return 0
        If $DoLogInCommands Then
            If $DoLogInCommands = 2 Or GetValue("GameMenuKey") = "{ESC}" Then
                Send("{ESC}")
            Else
                MySend(GetValue("GameMenuKey"))
            EndIf
            Sleep(1500)
            If $DoLogInCommands = 1 Then
                $DoLogInCommands = 2
            Else
                $DoLogInCommands = 1
            EndIf
        EndIf
    EndIf
    If _ImageSearch(@ScriptDir & "\images\" & $Language & "\" & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then
        If $do And Not SetImageSearchVariables($image, $left, $top, $right, $bottom, $tolerance) Then Return 0
        Return 1
    EndIf
    Local $i = 2
    While ImageExists($image & "-" & $i)
        If _ImageSearch(@ScriptDir & "\images\" & $Language & "\" & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then
            If $do And Not SetImageSearchVariables($image, $left, $top, $right, $bottom, $tolerance) Then Return 0
            Return $i
        EndIf
        $i += 1
    WEnd
    Return 0
EndFunc

Func SetImageSearchVariables($image, $left, $top, $right, $bottom, $tolerance)
    If $image <> "LogInScreen" And $image <> "InvalidUsernameOrPassword" And $image <> "Mismatch" And $image <> "Idle" And $image <> "OK" Then
        $LoggingIn = 0
        $LogInTries = 0
        If $DoRelogCount And Not $DisableRelogCount Then
            $DoRelogCount = 0
            $DisableRelogCount = 0
            $ReLogged += 1
        EndIf
        If $image = "SelectionScreen" Then
            $DoLogInCommands = 1
            $ChangingCharacter = 0
        ElseIf Not $ChangingCharacter And $DoLogInCommands And $image = "ChangeCharacterButton" Then
            $DoLogInCommands = 2
            Send("{ESC}")
            Sleep(500)
            If ImageSearch($image, $left, $top, $right, $bottom, $tolerance, 0) Then Return 0
            $DoLogInCommands = 0
        EndIf
    EndIf
    Return 1
EndFunc

Func ImageExists($image)
    Return FileExists(@ScriptDir & "\images\" & $Language & "\" & $image & ".png")
EndFunc

Func WaitMinutes($time, $msg); If $RestartLoop Then Return 0
    Local $t = TimerInit(), $left = $time, $lastmin = 0, $leftover
    If EndNowTime($left) Then
        SetAllAccountsValue("EndNow", 1)
        End(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
    SyncValues()
    While $left > 0
        Splash("[ " & Localize($msg, "<MINUTES>", HoursAndMinutes($left)) & " ]", 0)
        If $left > 1 then
            If $lastmin = Ceiling($left) Then
                $leftover = Ceiling(($lastmin - $left) * 60000)
                Sleep($leftover + 1)
            Else
                $lastmin = Ceiling($left)
                Sleep(60000)
            EndIf
        Else
            Sleep(Ceiling($left * 60000))
            ExitLoop
        EndIf
        $left = $time - TimerDiff($t) / 60000
    WEnd
EndFunc

Func FindLogInScreen(); If $RestartLoop Then Return 0
    If ImageSearch("Idle") And ImageSearch("OK") Then
        AddAccountCountValue("IdleLogout")
        AddCharacterCountInfo("IdleLogout")
        SetAccountValue("FinishedCharacter", 1)
        $FailedInvoke = 0
        Splash()
        MyMouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(1000)
    EndIf
    If Not ImageSearch("LogInScreen") Then Return
    Local $FindLogInScreenWaitingTimer = TimerInit()
While 1
While 1
    $DoRelogCount = 1
    $LoggingIn = 1
    $DoLogInCommands = 1
    $ChangingCharacter = 1
    If $LogInTries Then
        $LogInTries = 0
        Position(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        WaitMinutes(Random(20 * 60000, 60 * 60000, 1) / 60000, "WaitingToRetryLogin"); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    Else
        Splash()
        Sleep(1000)
        LogIn(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
        Sleep(1000)
        If ImageExists("SelectionScreen") Then
            While Not ImageSearch("SelectionScreen")
                If ImageSearch("ChangeCharacterButton") Then
                    Splash()
                    ChangeCharacter(); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                    While Not ImageSearch("SelectionScreen")
                        TimeOut($FindLogInScreenWaitingTimer); If $RestartLoop Then Return 0
                        If $RestartLoop Then Return 0
                        If ImageSearch("LogInScreen") Then ExitLoop 3
                        Sleep(500)
                    WEnd
                    ExitLoop
                ElseIf ImageSearch("InvalidUsernameOrPassword") Then
                    Error(Localize("InvalidUsernameOrPassword")); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                ElseIf ImageSearch("Mismatch") And PatchClient() Then; If $RestartLoop Then Return 0
                    ExitLoop
                EndIf
                If $RestartLoop Then Return 0
                TimeOut($FindLogInScreenWaitingTimer); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                If ImageSearch("LogInScreen") Then ExitLoop 2
                If Not $DoLogInCommands Then Sleep(500)
            WEnd
        EndIf
    EndIf
    StartLoop(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
Return
WEnd
WEnd
EndFunc

Func GetLogInServerAddressString()
    Local $r = "", $a = Array(GetValue("LogInServerAddress"))
    If Not $a[1] Or Not IsString($a[1]) Or $a[1] = "" Then Return $r
    TCPStartup()
    For $i = 1 to $a[0]
        Local $ip = TCPNameToIP($a[$i])
        If $ip And $ip <> "" Then
            $r &= " -server " & $ip
        EndIf
    Next
    TCPShutdown()
    Return $r
EndFunc

Func CheckServer()
    Local $a = Array(GetValue("CheckServerAddress"))
    If Not $a[1] Or Not IsString($a[1]) Or $a[1] = "" Then Return
    Ping($a[1])
    If @error = 0 Then Return
    Splash("[ " & Localize("WaitingForGameServer") & " ]", 0)
    While 1
        For $i = 1 to $a[0]
            Ping($a[$i], 10000)
            If @error = 0 Then Return
        Next
        Sleep(10000)
    WEnd
EndFunc

Func StartClient(); If $RestartLoop Then Return 0
While 1
While 1
    CheckServer()
    Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
    $DisableRelogCount = 1
    $DisableRestartCount = 1
    $LogInTries = 0
    $ETAText = ""
    CloseClient(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    If $GameClientLauncherInstallLocation And FileExists($GameClientLauncherInstallLocation & "\Neverwinter.exe") Then
        CloseClient("Neverwinter.exe"); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        If Not Number(RegRead("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "AutoLaunch")) Then
            RegWrite("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "AutoLaunch", "REG_DWORD", 1)
            If Not GetValue("NoAutoLaunch") Then
                SetAllAccountsValue("NoAutoLaunch", 1)
                SaveIniAllAccounts("NoAutoLaunch", 1)
            EndIf
        EndIf
        FileChangeDir($GameClientLauncherInstallLocation)
        Run("Neverwinter.exe", $GameClientLauncherInstallLocation)
        FileChangeDir(@ScriptDir)
        $WaitingTimer = TimerInit()
        While Not ProcessExists("Neverwinter.exe")
            TimeOut(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Sleep(1000)
        WEnd
        $WaitingTimer = TimerInit()
        While 1
            TimeOut(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            FindWindow("Neverwinter.exe", "#32770", GetValue("ConnectionProblemWindowTitle"))
            If $WinHandle Then
                ControlClick($WinHandle, "", "[CLASS:Button; INSTANCE:1]")
                WaitMinutes(Random(20 * 60000, 60 * 60000, 1) / 60000, "WaitingToRetryLogin"); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                ExitLoop 2
            EndIf
            If Focus("Neverwinter.exe", "#32770") And GetPosition() And ImageSearch("LauncherLogin") Then ExitLoop
            Sleep(1000)
        WEnd
        Splash()
        Sleep(1000)
        CheckServer()
        AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
        Send("+{TAB}")
        Sleep(500)
        Send("{BS}")
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", 15)
        Send(GetValue("LogInUserName"), $SEND_RAW)
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
        Send("{TAB}")
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", 15)
        Send(GetValue("LogInPassword"), $SEND_RAW)
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
        Send("{ENTER}")
        Focus("Neverwinter.exe", "#32770")
        GetPosition()
        $WaitingTimer = TimerInit()
        While Not ImageSearch("LauncherPatching")
            TimeOut(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            If ImageSearch("InvalidUsernameOrPassword") Then
                Error(Localize("InvalidUsernameOrPassword")); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
            EndIf
            If ImageSearch("LauncherLogin") Or TimerDiff($WaitingTimer) / 60000 >= 2 Then
                WaitMinutes(Random(20 * 60000, 60 * 60000, 1) / 60000, "WaitingToRetryLogin"); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                ExitLoop 2
            EndIf
            FindWindow("Neverwinter.exe", "#32770", GetValue("VerifyFilesWindowTitle"))
            If $WinHandle Then
                If GetValue("SkipVerifyFiles") Then
                    ControlClick($WinHandle, "", "[CLASS:Button; INSTANCE:2]")
                Else
                    ControlClick($WinHandle, "", "[CLASS:Button; INSTANCE:1]")
                EndIf
            EndIf
            Sleep(1000)
            Focus("Neverwinter.exe", "#32770")
            If Not GetPosition() Then ExitLoop 2
        WEnd
        Splash("[ " & Localize("PatchingGame") & " ]", 0)
        Focus()
        Local $set = 1
        While Not $WinHandle
            If Not ProcessExists("Neverwinter.exe") Or ( Focus("Neverwinter.exe", "#32770") And GetPosition() And Not ImageSearch("LauncherPatching") ) Then
                If $set Then
                    $set = 0
                    $WaitingTimer = TimerInit()
                    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                EndIf
                TimeOut(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
            EndIf
            Focus()
            Sleep(1000)
        WEnd
        Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
        Reset()
        If Not $DisableRestartCount Then $Restarted += 1
        $WaitingTimer = TimerInit()
        While Not ( ImageSearch("SelectionScreen") Or ImageSearch("LogInScreen") )
            Sleep(500)
            TimeOut(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Position(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
        WEnd
    Else
        Error(Localize("NeverwinterNotFound")); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
Return
WEnd
WEnd
EndFunc

Func PatchClient(); If $RestartLoop Then Return 0
    If Not GetValue("DisableRestartGameClient") And GetValue("LogInUserName") And GetValue("LogInPassword") And $GameClientLauncherInstallLocation And FileExists($GameClientLauncherInstallLocation & "\Neverwinter.exe") And ImageExists("LogInScreen") Then
        StartClient(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Splash("", 0)
        $GamePatched = 1
        Return 1
    EndIf
    Return 0
EndFunc

Func LogIn(); If $RestartLoop Then Return 0
    If GetValue("LogInUserName") And GetValue("LogInPassword") Then
        CheckServer()
        Position(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Splash()
        MyMouseMove(GetValue("UsernameInputX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("UsernameInputY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
        DoubleClick()
        AutoItSetOption("SendKeyDownDelay", 5)
        Send("{END}{BS 254}")
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", 15)
        Send(GetValue("LogInUserName"), $SEND_RAW)
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
        Send("{TAB}")
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", 15)
        Send(GetValue("LogInPassword"), $SEND_RAW)
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
        Send("{ENTER}")
        $LogInTries += 1
    Else
        Error(Localize("UsernameAndPasswordNotDefined")); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
EndFunc

Func TimeOut($timer = $WaitingTimer); If $RestartLoop Then Return 0
    If TimerDiff($timer) < GetValue("TimeOutMinutes") * 60000 Then Return
    AddAccountCountValue("TimedOut")
    If Not $LoggingIn Then AddCharacterCountInfo("TimedOut")
    $DisableRelogCount = 1
    If $TimeOutRetries < GetValue("TimeOutRetries") And Not GetValue("DisableRestartGameClient") And GetValue("LogInUserName") And GetValue("LogInPassword") And $GameClientLauncherInstallLocation And FileExists($GameClientLauncherInstallLocation & "\Neverwinter.exe") And ImageExists("LogInScreen") Then
        Reset()
        $TimeOutRetries += 1
        Splash("[ " & Localize("RestartingNeverwinter") & " ]")
        If CloseClient() Then $DisableRestartCount = 1; If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        StartLoop(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    Else
        Error(Localize("OperationTimedOut")); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
EndFunc

Func SaveItemCount($item, $value = 0)
    If $value then SetCharacterInfo($item, $value)
    Local $ItemCount = 0
    Local $ItemStart = GetAllAccountsValue($item)
    For $a = 1 To GetValue("TotalAccounts")
        For $c = 1 To GetAccountValue("TotalSlots", $a)
            $ItemCount += GetCharacterInfo($item, $c, $a)
        Next
    Next
    $ItemCount = $ItemStart + $ItemCount
    If Number(Statistics_GetIniAllAccounts($item)) < $ItemCount Then Statistics_SaveIniAllAccounts($item, $ItemCount)
    $ItemCount = 0
    $ItemStart = GetAccountValue($item)
    For $c = 1 To GetAccountValue("TotalSlots")
        $ItemCount += GetCharacterInfo($item, $c)
    Next
    $ItemCount = $ItemStart + $ItemCount
    If Number(Statistics_GetIniAccount($item)) < $ItemCount Then Statistics_SaveIniAccount($item, $ItemCount)
EndFunc

Func End(); If $RestartLoop Then Return 0
    Local $check = CheckAccounts()
    If $check > 0 Then
        If $check <> $CurrentAccount Then
            $ETAText = ""
            Position(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
            If ImageSearch("SelectionScreen") Then
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                Sleep(1000)
                $DisableRelogCount = 1
            EndIf
            $WaitingTimer = TimerInit()
            While Not ImageSearch("LogInScreen")
                Sleep(500)
                TimeOut(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                Position(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                If ImageSearch("SelectionScreen") Then
                    MyMouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(1000)
                    $DisableRelogCount = 1
                EndIf
            WEnd
            $CurrentAccount = $check
        EndIf
        StartLoop(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
    If Not $EndTime Then $EndTime = HoursAndMinutes(TimerDiff($StartTimer) / 60000)
    Splash()
    If Not GetValue("InfiniteLoopsFound") Or GetValue("EndNow") Then
        Position(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        If ImageSearch("SelectionScreen") Then
            MyMouseMove($_ImageSearchX, $_ImageSearchY)
            SingleClick()
            Sleep(1000)
            $DisableRelogCount = 1
        EndIf
    EndIf
    If Not GetValue("InfiniteLoopsFound") And Not GetValue("DisableCloseClient") And CloseClient() Then $DisableRestartCount = 1; If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    Reset()
    Splash(0)
    Local $old = $CurrentAccount
    If Not $UnattendedMode Then
        For $i = 1 To GetValue("TotalAccounts")
            $CurrentAccount = $i
            If GetValue("InfiniteLoops") And $EnableProfessions Then
                Local $oldc = GetValue("CurrentCharacter")
                For $c = GetValue("StartAtCharacter") To GetValue("EndAtCharacter")
                    SetAccountValue("CurrentCharacter", $c)
                    If GetValue("EnableProfessions") Then
                        $UnattendedMode = 3
                        ExitLoop
                    EndIf
                Next
                SetAccountValue("CurrentCharacter", $oldc)
                If $UnattendedMode Then ExitLoop
            EndIf
        Next
    EndIf
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        If CompletedAccount() And GetValue("CurrentLoop") <= GetValue("EndAtLoop") Then
            If GetValue("CurrentCharacter") = GetValue("StartAtCharacter") Then
                SetAccountValue("EndAtLoop", GetValue("CurrentLoop") - 1)
            Else
                SetAccountValue("EndAtLoop", GetValue("CurrentLoop"))
            EndIf
        EndIf
        SendMessage(Localize("CompletedInvoking", "<STARTAT>", GetValue("StartAtCharacter"), "<ENDAT>", GetValue("EndAtCharacter"), "<STARTATLOOP>", GetValue("StartAtLoop"), "<ENDATLOOP>", GetValue("EndAtLoop")) & @CRLF & @CRLF & Localize("InvokingTook", "<MINUTES>", $EndTime))
        If GetValue("InfiniteLoops") And $EnableProfessions Then
            Local $oldc = GetValue("CurrentCharacter")
            For $c = GetValue("StartAtCharacter") To GetValue("EndAtCharacter")
                SetAccountValue("CurrentCharacter", $c)
                If GetValue("EnableProfessions") Then
                    SetAccountValue("InfiniteLoopsStarted", 1)
                    ExitLoop
                EndIf
            Next
            SetAccountValue("CurrentCharacter", $oldc)
        EndIf
    Next
    $CurrentAccount = $old
    $UnattendedMode = GetValue("UnattendedMode")
    $check = CheckAccounts()
    If $check > 0 Then
        If $check <> $CurrentAccount Then
            $ETAText = ""
            Position(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
            If ImageSearch("SelectionScreen") Then
                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                Sleep(1000)
                $DisableRelogCount = 1
            EndIf
            $WaitingTimer = TimerInit()
            While Not ImageSearch("LogInScreen")
                Sleep(500)
                TimeOut(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                Position(); If $RestartLoop Then Return 0
                If $RestartLoop Then Return 0
                If ImageSearch("SelectionScreen") Then
                    MyMouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(1000)
                    $DisableRelogCount = 1
                EndIf
            WEnd
            $CurrentAccount = $check
        EndIf
        StartLoop(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
    EndIf
    $LogTime = 0
    Exit
EndFunc

Func Reset()
        If GetValue("NoAutoLaunch") Then
            RegWrite("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "AutoLaunch", "REG_DWORD", 0)
            DeleteAllAccountsValue("NoAutoLaunch")
            DeleteIniAllAccounts("NoAutoLaunch")
        EndIf
EndFunc

Func Pause(); only call from hot key
    $LoopStarted = 0
    $RestartLoop = 0
    Message(Localize("Paused")); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Func Error($s); If $RestartLoop Then Return 0
    Message($s, $MB_ICONWARNING, 1); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Func Message($s, $n = $MB_OK, $ontop = 0); If $RestartLoop Then Return 0
    If Not $FirstRun And Not CheckAccounts() Then
        End(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        Exit
    EndIf
    Reset()
    $UnattendedMode = 0
    Splash(0)
    Local $old = $CurrentAccount
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        SendMessage($s, $n, $ontop)
    Next
    $CurrentAccount = $old
    $LogTime = 0
    Start(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    Exit
EndFunc

Func SendMessage($s, $n = $MB_OK, $ontop = 0)
    $ETAText = ""
    Local $text = "    " & Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & $s
    Local $CofferCount = 0, $ProfessionPackCount = 0, $ElixirOfFateCount = 0, $OverflowXPRewardCount = 0, $VIPCharacterRewardCount = 0, $FailedVIPCharacterRewardCount = 0, $FailedVIPCharacterRewardText = "", $VIPAccountRewardCount = 0, $IdleLogoutText = "", $TimedOutText = "", $FailedInvokeText = "", $etext = ""
    If GetAccountValue("InfiniteLoopsStarted") And GetAccountValue("LastMsg") Then
        $text &= GetAccountValue("LastMsg")
    ElseIf GetValue("UnattendedMode") <> 3 Then
        For $i = 1 To GetValue("TotalSlots")
            $CofferCount += GetCharacterInfo("TotalCelestialCoffers", $i)
            $ProfessionPackCount += GetCharacterInfo("TotalProfessionPacks", $i)
            $ElixirOfFateCount += GetCharacterInfo("TotalElixirsOfFate", $i)
            $OverflowXPRewardCount += GetCharacterInfo("TotalOverflowXPRewards", $i)
            $VIPCharacterRewardCount += GetCharacterInfo("TotalVIPCharacterRewards", $i)
            $FailedVIPCharacterRewardCount += GetCharacterInfo("FailedVIPCharacterReward", $i)
            $VIPAccountRewardCount += GetCharacterInfo("TotalVIPAccountRewards", $i)
            If GetCharacterInfo("IdleLogout", $i) Then
                Local $times = ""
                If GetCharacterInfo("IdleLogout", $i) > 1 Then $times = GetCharacterInfo("IdleLogout", $i) & "x"
                If $IdleLogoutText <> "" Then
                    $IdleLogoutText &= ", " & $times & "#" & $i
                Else
                    $IdleLogoutText = $times & "#" & $i
                EndIf
            EndIf
            If GetCharacterInfo("TimedOut", $i) Then
                Local $times = ""
                If GetCharacterInfo("TimedOut", $i) > 1 Then $times = GetCharacterInfo("TimedOut", $i) & "x"
                If $TimedOutText <> "" Then
                    $TimedOutText &= ", " & $times & "#" & $i
                Else
                    $TimedOutText = $times & "#" & $i
                EndIf
            EndIf
            If GetCharacterInfo("FailedInvoke", $i) Then
                Local $times = ""
                If GetCharacterInfo("FailedInvoke", $i) > 1 Then $times = GetCharacterInfo("FailedInvoke", $i) & "x"
                If $FailedInvokeText <> "" Then
                    $FailedInvokeText &= ", " & $times & "#" & $i
                Else
                    $FailedInvokeText = $times & "#" & $i
                EndIf
            EndIf
            If GetCharacterInfo("FailedVIPCharacterReward", $i) Then
                Local $times = ""
                If GetCharacterInfo("FailedVIPCharacterReward", $i) > 1 Then $times = GetCharacterInfo("FailedVIPCharacterReward", $i) & "x"
                If $FailedVIPCharacterRewardText <> "" Then
                    $FailedVIPCharacterRewardText &= ", " & $times & "#" & $i
                Else
                    $FailedVIPCharacterRewardText = $times & "#" & $i
                EndIf
            EndIf
        Next
        If $FailedVIPCharacterRewardText <> "" Then $FailedVIPCharacterRewardText = " ( " & $FailedVIPCharacterRewardText & " )"
        If $IdleLogoutText <> "" Then $IdleLogoutText = " ( " & $IdleLogoutText & " )"
        If $TimedOutText <> "" Then $TimedOutText = " ( " & $TimedOutText & " )"
        If $FailedInvokeText <> "" Then $FailedInvokeText = " ( " & $FailedInvokeText & " )"
        If GetValue("Invoked") Then
            $etext &= @CRLF & @CRLF & Localize("InvokedTimes", "<INVOKED>", GetValue("Invoked"), "<INVOKETOTAL>", GetValue("TotalSlots") * $MaxLoops, "<PERCENT>", Floor((GetValue("Invoked") / (GetValue("TotalSlots") * $MaxLoops)) * 100))
        EndIf
        If $CofferCount Then
            $etext &= @CRLF & @CRLF & Localize("CofferCount", "<COUNT>", $CofferCount)
        EndIf
        If $ProfessionPackCount Then
            $etext &= @CRLF & @CRLF & Localize("ProfessionPackCount", "<COUNT>", $ProfessionPackCount)
        EndIf
        If $ElixirOfFateCount Then
            $etext &= @CRLF & @CRLF & Localize("ElixirOfFateCount", "<COUNT>", $ElixirOfFateCount)
        EndIf
        If $OverflowXPRewardCount Then
            $etext &= @CRLF & @CRLF & Localize("OverflowXPRewardCount", "<COUNT>", $OverflowXPRewardCount)
        EndIf
        If $VIPCharacterRewardCount Then
            $etext &= @CRLF & @CRLF & Localize("VIPCharacterRewardCount", "<COUNT>", $VIPCharacterRewardCount)
        EndIf
        If $FailedVIPCharacterRewardCount Then
            $etext &= @CRLF & @CRLF & Localize("FailedVIPCharacterRewardCount", "<COUNT>", $FailedVIPCharacterRewardCount) & $FailedVIPCharacterRewardText
        EndIf
        If $VIPAccountRewardCount Then
            $etext &= @CRLF & @CRLF & Localize("VIPAccountRewardCount")
        ElseIf GetValue("TriedVIPAccountReward") Then
            $etext &= @CRLF & @CRLF & Localize("FailedVIPAccountReward")
        EndIf
        If GetValue("IdleLogout") Then
            $etext &= @CRLF & @CRLF & Localize("IdleLogoutCount", "<COUNT>", GetValue("IdleLogout")) & $IdleLogoutText
        EndIf
        If GetValue("TimedOut") Then
            $etext &= @CRLF & @CRLF & Localize("TimedOutCount", "<COUNT>", GetValue("TimedOut")) & $TimedOutText
        EndIf
        If GetValue("FailedInvoke") Then
            $etext &= @CRLF & @CRLF & Localize("FailedInvokeCount", "<COUNT>", GetValue("FailedInvoke")) & $FailedInvokeText
        EndIf
        If $ReLogged Then
            $etext &= @CRLF & @CRLF & Localize("ReLoggedCount", "<COUNT>", $ReLogged)
        EndIf
        If $Restarted Then
            $etext &= @CRLF & @CRLF & Localize("RestartedCount", "<COUNT>", $Restarted)
        EndIf
        If $GamePatched Then
            $etext &= @CRLF & @CRLF & Localize("GamePatched")
        EndIf
        If Not CompletedAccount() Then
            $etext &= @CRLF & @CRLF & Localize("Invoking", "<CURRENT>", GetValue("CurrentCharacter"), "<ENDAT>", GetValue("EndAtCharacter"), "<CURRENTLOOP>", GetValue("CurrentLoop"), "<ENDATLOOP>", GetValue("EndAtLoop"))
        EndIf
        SetAccountValue("LastMsg", $etext)
        $text &= $etext
        If $StartTimer Then
            If Not FileExists($SettingsDir & "\Logs") Then DirCreate($SettingsDir & "\Logs")
            Local $LogStart = "", $LogEnd = @CRLF
            If $LogSessionStart Then
                $LogStart = @CRLF & Localize("SessionStart") & @CRLF & $LogStartDate & " " & $LogStartTime & @CRLF & @CRLF
                $LogSessionStart = 0
            EndIf
            If Not $LogTime Then
                $LogDate = @YEAR & "-" & @MON & "-" & @MDAY
                $LogTime = @HOUR & ":" & @MIN & ":" & @SEC
                $LogStart &= $LogDate & " " & $LogTime & @CRLF
            EndIf
            If $CurrentAccount = GetValue("TotalAccounts") Then $LogEnd = @CRLF & @CRLF
            FileWrite($SettingsDir & "\Logs\Log_" & $LogStartDate & ".txt", $LogStart & StringReplace($text, @CRLF & @CRLF, @CRLF) & $LogEnd)
        EndIf
    EndIf
    If Not $UnattendedMode Then
        If $ontop Then
            MsgBox($n, $Title, $text, "", WinGetHandle(AutoItWinGetTitle()) * WinSetOnTop(AutoItWinGetTitle(), "", 1))
        Else
            MsgBox($n, $Title, $text)
        EndIf
    EndIf
EndFunc

Func HoursAndMinutes($n)
    Local $All = Ceiling($n)
    Local $Hours = Floor($All / 60)
    Local $Minutes = $All - $Hours * 60
    If $Hours Then
        If $Hours = 1 Then
            If $Minutes Then
                If $Minutes = 1 Then Return Localize("HourMinute")
                Return Localize("HourMinutes", "<MINUTES>", $Minutes)
            EndIf
            Return Localize("Hour")
        ElseIf $Minutes Then
            If $Minutes = 1 Then Return Localize("HoursMinute", "<HOURS>", $Hours)
            Return Localize("HoursMinutes", "<HOURS>", $Hours, "<MINUTES>", $Minutes)
        EndIf
        Return Localize("Hours", "<HOURS>", $Hours)
    ElseIf $Minutes = 1 Then
        Return Localize("Minute")
    EndIf
    Return Localize("Minutes", "<MINUTES>", $Minutes)
EndFunc

Func AdvancedAccountSettings($hWnd = 0)
    Local $s = ""
    $s &= "|" & "SkipVIPAccountReward,VIPAccountRewardTitle,VIPAccountRewardDescription,ReverseBoolean"
    $s &= "|" & "VIPAccountRewardCharacter,VIPAccountRewardCharacterTitle,VIPAccountRewardCharacterDescription,Number"
    $s &= "|" & "DefaultStartAtLoop,DefaultStartAtLoopTitle,DefaultStartAtLoopDescription,Number"
    $s &= "|" & "DefaultEndAtLoop,DefaultEndAtLoopTitle,DefaultEndAtLoopDescription,Number"
    $s &= "|" & "DefaultStartAtCharacter,DefaultStartAtCharacterTitle,DefaultStartAtCharacterDescription,Number"
    $s &= "|" & "DefaultEndAtCharacter,DefaultEndAtCharacterTitle,DefaultEndAtCharacterDescription,Number"
    Local $a = StringSplit(StringRegExpReplace($s, "^\|+", ""), "|")
    Local $Total = $a[0]
    Local $c[$Total + 1]
    Local $hGui = GUICreate($Title, 600, 400, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    GUICtrlCreateLabel(Localize("AdvancedSettings"), 160, 20, 100, -1, $SS_RIGHT)
    For $i = 1 To $Total
        $a[$i] = StringSplit($a[$i], ",")
        GUICtrlCreateLabel(Localize(($a[$i])[2]), 0, 23 + $i * 36, 340, -1, $SS_RIGHT)
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
        Local $v = ($a[$i])[1], $gv = GetAccountValue($v), $t = ($a[$i])[4]
        If $t = "Boolean" Or $t = "ReverseBoolean" Then
            $c[$i] = GUICtrlCreateCheckbox(" ", 350, 20 + $i * 36)
            If $t = "Boolean" Then
                If $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            Else
                If Not $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            EndIf
        Else
            $c[$i] = GUICtrlCreateInput($gv, 350, 20 + $i * 36, 155)
        EndIf
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
    Next
    _GUIScrollbars_Generate($hGUI, 1, 100 + $Total * 36)
    Local $ButtonDefault = GUICtrlCreateButton(Localize("Default"), 40, 60 + $Total * 36, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 268, 60 + $Total * 36, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 350, 60 + $Total * 36, 75, 25)
    GUISetState(@SW_SHOW, $hGui)
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $ButtonDefault
                For $i = 1 To $Total
                    Local $v = ($a[$i])[1], $t = ($a[$i])[4]
                    If $t = "Boolean" Or $t = "ReverseBoolean" Then
                        GUICtrlSetState($c[$i], $GUI_UNCHECKED)
                        If $t = "Boolean" Then
                            If GetDefaultValue($v) Then GUICtrlSetState($c[$i], $GUI_CHECKED)
                        Else
                            If Not GetDefaultValue($v) Then GUICtrlSetState($c[$i], $GUI_CHECKED)
                        EndIf
                    Else
                        GUICtrlSetData($c[$i], GetDefaultValue($v))
                    EndIf
                Next
            Case $ButtonOK
                For $i = 1 To $Total
                    Local $value, $v = ($a[$i])[1], $t = ($a[$i])[4]
                    If $t = "Boolean" Or $t = "ReverseBoolean" Then
                        If GUICtrlRead($c[$i]) = $GUI_CHECKED Then $value = 1
                        If $t = "Boolean" Then
                            $value = 0
                            If GUICtrlRead($c[$i]) = $GUI_CHECKED Then $value = 1
                        Else
                            $value = 1
                            If GUICtrlRead($c[$i]) = $GUI_CHECKED Then $value = 0
                        EndIf
                    Else
                        $value = GUICtrlRead($c[$i])
                        If $t = "Number" Or String(Number($value)) = String($value) Then
                            $value = Number($value)
                        EndIf
                    EndIf
                    If $value == GetDefaultValue($v) Or $value == "" Or $value == 0 Then
                        DeleteAccountValue($v)
                        DeleteIniAccount($v)
                    Else
                        SetAccountValue($v, $value)
                        SaveIniAccount($v, $value)
                    EndIf
                Next
                ExitLoop
            Case $ButtonCancel
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($hGUI)
EndFunc

Func ChooseAccountOptions()
    If GetAllAccountsValue("DisableOpeningBags") Then
        DeleteAccountValue("DisableOpeningBags")
        DeleteIniAccount("DisableOpeningBags")
        DeleteAccountValue("OpenBagsOnEveryLoop")
        DeleteIniAccount("OpenBagsOnEveryLoop")
        Return
    EndIf
    Local $hGui = GUICreate($Title, 320, 150)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    Local $OpenInventoryBagsCheckbox = GUICtrlCreateCheckbox(" " & Localize("OpenInventoryBags"), 25, 45, 270)
    If Not GetAccountValue("DisableOpeningBags") Then GUICtrlSetState($OpenInventoryBagsCheckbox, $GUI_CHECKED)
    Local $OpenInventoryBagsOnEveryLoopCheckbox = GUICtrlCreateCheckbox(" " & Localize("OpenInventoryBagsOnEveryLoop"), 25, 75, 270)
    If GetAccountValue("DisableOpeningBags") Or GetAllAccountsValue("OpenBagsOnEveryLoop") Then GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_DISABLE)
    If (Not GetAccountValue("DisableOpeningBags") And GetAccountValue("OpenBagsOnEveryLoop")) Or GetAllAccountsValue("OpenBagsOnEveryLoop") Then GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_CHECKED)
    Local $ButtonAdvanced = GUICtrlCreateButton(Localize("Advanced"), 25, 110, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 127, 110, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 214, 110, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $OpenInventoryBagsCheckbox
                If GUICtrlRead($OpenInventoryBagsCheckbox) = $GUI_CHECKED And Not GetAllAccountsValue("OpenBagsOnEveryLoop") Then
                    GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_ENABLE)
                    If GetAccountValue("OpenBagsOnEveryLoop") Then GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_CHECKED)
                Else
                    If GetAllAccountsValue("OpenBagsOnEveryLoop") Then
                        GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_CHECKED)
                    Else
                        GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_UNCHECKED)
                    EndIf
                    GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_DISABLE)
                EndIf
            Case $ButtonAdvanced
                AdvancedAccountSettings($hGui)
            Case $ButtonOK
                Local $disabled = 1
                If GUICtrlRead($OpenInventoryBagsCheckbox) = $GUI_CHECKED Then $disabled = 0
                If GetAccountValue("DisableOpeningBags") <> $disabled Then
                    If $disabled == GetDefaultValue("DisableOpeningBags") Then
                        DeleteAccountValue("DisableOpeningBags")
                        DeleteIniAccount("DisableOpeningBags")
                    Else
                        SetAccountValue("DisableOpeningBags", $disabled)
                        SaveIniAccount("DisableOpeningBags", GetAccountValue("DisableOpeningBags"))
                    EndIf
                EndIf
                Local $enabled = 0
                If GUICtrlRead($OpenInventoryBagsOnEveryLoopCheckbox) = $GUI_CHECKED And Not GetAllAccountsValue("OpenBagsOnEveryLoop") Then $enabled = 1
                If GetAccountValue("OpenBagsOnEveryLoop") <> $enabled Then
                    If $enabled == GetDefaultValue("OpenBagsOnEveryLoop") Then
                        DeleteAccountValue("OpenBagsOnEveryLoop")
                        DeleteIniAccount("OpenBagsOnEveryLoop")
                    Else
                        SetAccountValue("OpenBagsOnEveryLoop", $enabled)
                        SaveIniAccount("OpenBagsOnEveryLoop", GetAccountValue("OpenBagsOnEveryLoop"))
                    EndIf
                EndIf
                GUIDelete()
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

Func ChooseAccountEnableClaimVIPCharacterRewardOptions()
    If $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots")
    Local $Checkbox[$Total + 1]
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    GUICtrlCreateLabel(Localize("ClaimVIPCharacterReward", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    $Checkbox[0] = GUICtrlCreateCheckbox(Localize("AllCharacters"), 40, 70, 100)
    If GetAccountValue("ClaimVIPCharacterReward") Then GUICtrlSetState($Checkbox[0], $GUI_CHECKED)
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        $Checkbox[$i] = GUICtrlCreateCheckbox(Localize("CharacterNumber", "<NUMBER>", $i), 40 + (($Row - 1) * 100), 100 + ($Column * 30), 100)
        If GetAccountValue("ClaimVIPCharacterReward") Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
            GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        ElseIf GetCharacterValue("ClaimVIPCharacterReward", $i) Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
        EndIf
        If Not ( GetAccountValue("ClaimVIPCharacterReward") == GetDefaultValue("ClaimVIPCharacterReward") ) Then GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
    Next
    Local $ButtonOK = GUICtrlCreateButton("&OK", _Max(163 + ((Ceiling($Total / 10) - 3) * 100), 163), 450, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Checkbox[0]
                GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then
                    For $i = 1 To $Total
                        GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
                        GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
                    Next
                Else
                    For $i = 1 To $Total
                        GUICtrlSetState($Checkbox[$i], $GUI_ENABLE)
                        GUICtrlSetState($Checkbox[$i], $GUI_UNCHECKED)
                    Next
                EndIf
                GUICtrlSetState($ButtonOK, $GUI_ENABLE)
            Case $ButtonOK
                Local $enabled = 0
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("ClaimVIPCharacterReward") <> $enabled Then
                    If $enabled == GetDefaultValue("ClaimVIPCharacterReward") Then
                        DeleteAccountValue("ClaimVIPCharacterReward")
                        DeleteIniAccount("ClaimVIPCharacterReward")
                    Else
                        SetAccountValue("ClaimVIPCharacterReward", $enabled)
                        SaveIniAccount("ClaimVIPCharacterReward", $enabled)
                    EndIf
                EndIf
                For $i = 1 To $Total
                    $enabled = 0
                    If GetAccountValue("ClaimVIPCharacterReward") Or GUICtrlRead($Checkbox[$i]) = $GUI_CHECKED Then $enabled = 1
                    If GetAccountValue("ClaimVIPCharacterReward") Or $enabled == GetDefaultValue("ClaimVIPCharacterReward") Then
                        DeleteCharacterValue("ClaimVIPCharacterReward", $i)
                        DeleteIniCharacter("ClaimVIPCharacterReward", $i)
                    Else
                        SetCharacterValue("ClaimVIPCharacterReward", $enabled, $i)
                        SaveIniCharacter("ClaimVIPCharacterReward", $enabled, $i)
                    EndIf
                Next
                GUIDelete($hGUI)
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

Func ConfigureAccount()
    If CompletedAccount() Or (MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SkipAccountOptions", "<ACCOUNT>", $CurrentAccount)) = $IDYES) Then Return
    ChooseAccountOptions()
    ChooseAccountEnableClaimVIPCharacterRewardOptions()
    ChooseProfessionsAccountEnableOptions()
    ChooseProfessionsAccountSetTasksOptions()
    ChooseProfessionsAccountEnableAssetsOptions()
    ChooseProfessionsAccountSetAssetsOptions()
    If Not GetAccountValue("InfiniteLoopsStarted") And GetValue("UnattendedMode") <> 3 Then
        While 1
            Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("StartingLoop", "<MAXLOOPS>", $MaxLoops), GetValue("CurrentLoop"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            Local $number = Floor(Number($strNumber))
            If $number >= 1 Then
                SetAccountValue("StartAtLoop", $number)
                SetAccountValue("CurrentLoop", GetValue("StartAtLoop"))
                ExitLoop
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
        WEnd
        While 1
            Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EndingLoop", "<STARTATLOOP>", GetValue("StartAtLoop")), GetValue("EndAtLoop"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            Local $number = Floor(Number($strNumber))
            If $number >= GetValue("StartAtLoop") Then
                SetAccountValue("EndAtLoop", $number)
                ExitLoop
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
        WEnd
    EndIf
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("StartAtEachLoop", "<TOTALSLOTS>", GetValue("TotalSlots")), GetValue("StartAtCharacter"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number >= 1 And $number <= GetValue("TotalSlots") Then
            SetAccountValue("StartAtCharacter", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EndAtEachLoop", "<STARTAT>", GetValue("StartAtCharacter"), "<TOTALSLOTS>", GetValue("TotalSlots")), GetValue("EndAtCharacter"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number >= GetValue("StartAtCharacter") And $number <= GetValue("TotalSlots") Then
            SetAccountValue("EndAtCharacter", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    If GetValue("CurrentCharacter") < GetValue("StartAtCharacter") Then
        SetAccountValue("CurrentCharacter", GetValue("StartAtCharacter"))
    ElseIf GetValue("CurrentCharacter") > GetValue("EndAtCharacter") Then
        SetAccountValue("CurrentCharacter", GetValue("EndAtCharacter"))
    EndIf
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("StartAtCurrentLoop", "<STARTAT>", GetValue("StartAtCharacter"), "<ENDAT>", GetValue("EndAtCharacter")), GetValue("CurrentCharacter"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number >= GetValue("StartAtCharacter") And $number <= GetValue("EndAtCharacter") Then
            SetAccountValue("CurrentCharacter", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
EndFunc

Func Start(); If $RestartLoop Then Return 0
    If Not $FirstRun And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SkipAllConfigurations", "<NUMBER>", GetValue("TotalAccounts"))) = $IDYES Then
        $SkipAllConfigurations = 1
    EndIf
    If Not $UnattendedMode And Not $SkipAllConfigurations Then
        If Not $FirstRun Then ChooseOptions()
        Local $old = $CurrentAccount
        For $i = 1 To GetValue("TotalAccounts")
            $CurrentAccount = $i
            ConfigureAccount()
            If GetValue("CurrentCharacter") < GetValue("StartAtCharacter") Then
                SetAccountValue("CurrentCharacter", GetValue("StartAtCharacter"))
            ElseIf GetValue("CurrentCharacter") > GetValue("EndAtCharacter") Then
                SetAccountValue("CurrentCharacter", GetValue("EndAtCharacter"))
            EndIf
        Next
        $CurrentAccount = $old
    EndIf
    Begin(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Global $MinutesToStartSaved, $MinutesToStartSavedTimer

Func Begin(); If $RestartLoop Then Return 0
    $SkipAllConfigurations = 0
    If Not $UnattendedMode Then
        If ( $FirstRun Or $MinutesToStart ) And GetValue("UnattendedMode") <> 2 And GetValue("UnattendedMode") <> 3 Then
            While 1
                If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("GetMinutesUntilServerReset")) = $IDYES Then
                    If $MinutesToStartSavedTimer Then
                        Local $m = $MinutesToStartSaved - TimerDiff($MinutesToStartSavedTimer) / 60000
                        If $m >= 0 Then
                            $MinutesToStart = Round($m)
                            ExitLoop
                        EndIf
                    EndIf
                    $MinutesToStartSavedTimer = 0
                    $MinutesToStartSaved = _GetUTCMinutes(10, Random(120, 900, 1) / 60, True, True, False, $Title)
                    If $MinutesToStartSaved >= 0 Then
                        $MinutesToStartSavedTimer = TimerInit()
                        $MinutesToStart = Round($MinutesToStartSaved)
                        ExitLoop
                    EndIf
                Else
                    ExitLoop
                EndIf
                MsgBox($MB_ICONWARNING, $Title, Localize("FailedToGetMinutes"))
            WEnd
        EndIf
        While 1
            Local $strNumber = InputBox($Title, @CRLF & Localize("ToStartInvoking"), $MinutesToStart, "", GetValue("StartInputBoxWidth"), GetValue("StartInputBoxHeight"))
            If @error <> 0 Then Exit
            Local $number = Floor(Number($strNumber))
            If $number >= 0 Then
                $MinutesToStart = $number
                ExitLoop
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
        WEnd
    EndIf
    If GetValue("UnattendedMode") = 3 Then
        Local $old = $CurrentAccount
        For $i = 1 To GetValue("TotalAccounts")
            $CurrentAccount = $i
            SetAccountValue("CompletedAccountInvokes", 1)
            If GetValue("InfiniteLoops") And $EnableProfessions Then
                Local $oldc = GetValue("CurrentCharacter")
                For $c = GetValue("StartAtCharacter") To GetValue("EndAtCharacter")
                    SetAccountValue("CurrentCharacter", $c)
                    If GetValue("EnableProfessions") Then
                        SetAccountValue("InfiniteLoopsStarted", 1)
                        ExitLoop
                    EndIf
                Next
                SetAccountValue("CurrentCharacter", $oldc)
            EndIf
        Next
        $CurrentAccount = $old
        If Not CheckAccounts() Then Exit
    EndIf
    $FirstRun = 0
    Go(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Func Go(); If $RestartLoop Then Return 0
    $UnattendedMode = GetValue("UnattendedMode")
    $LogInTries = 0
    $LoggingIn = 1
    $DoLogInCommands = 1
    $DisableRelogCount = 1
    $DisableRestartCount = 1
    If $MinutesToStart Then
        Local $t = TimerInit(), $time = $MinutesToStart, $left = $time, $lastmin = 0, $leftover
        Position(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        If EndNowTime($left) Then
            SetAllAccountsValue("EndNow", 1)
            End(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
        EndIf
        While $left > 0
            $MinutesToStart = Ceiling($left)
            Splash("[ " & Localize("WaitingToStart", "<MINUTES>", HoursAndMinutes($left)) & " ]", 0)
            If $left > 1 then
                If $lastmin = Ceiling($left) Then
                    $leftover = Ceiling(($lastmin - $left) * 60000)
                    Sleep($leftover + 1)
                Else
                    $lastmin = Ceiling($left)
                    Sleep(60000)
                EndIf
            Else
                Sleep(Ceiling($left * 60000))
                ExitLoop
            EndIf
            $left = $time - TimerDiff($t) / 60000
        WEnd
        $MinutesToStart = 0
    EndIf
    If $UnattendedMode And Not $MinutesToEndSavedTimer Then
        While 1
            $MinutesToEndSaved = _GetUTCMinutes(10, 0, True, False, True, $Title)
            If $MinutesToEndSaved >= 0 Then
                $MinutesToEndSavedTimer = TimerInit()
                If EndNowTime() Then $MinutesToEndSaved += 1440
                ExitLoop
            EndIf
            If MsgBox($MB_RETRYCANCEL + $MB_ICONWARNING, $Title, Localize("FailedToGetMinutes"), 300) = $IDCANCEL Then Exit
        WEnd
    EndIf
    If $StartTimer Then
        Local $check = CheckAccounts()
        If $check > 0 Then
            $ETAText = ""
            Position(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Splash()
            If $check <> $CurrentAccount Then
                Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
                If ImageSearch("SelectionScreen") Then
                    MyMouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(1000)
                    $DisableRelogCount = 1
                EndIf
                $WaitingTimer = TimerInit()
                While Not ImageSearch("LogInScreen")
                    Sleep(500)
                    TimeOut(); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                    Position(); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                    If ImageSearch("SelectionScreen") Then
                        MyMouseMove($_ImageSearchX, $_ImageSearchY)
                        SingleClick()
                        Sleep(1000)
                        $DisableRelogCount = 1
                    EndIf
                WEnd
                $CurrentAccount = $check
            EndIf
        Else
            End(); If $RestartLoop Then Return 0
            If $RestartLoop Then Return 0
            Exit
        EndIf
    Else
        $LogStartDate = @YEAR & "-" & @MON & "-" & @MDAY
        $LogStartTime = @HOUR & ":" & @MIN & ":" & @SEC
        $StartTimer = TimerInit()
    EndIf
    $DisableRelogCount = 1
    $DisableRestartCount = 1
    StartLoop(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Func Initialize()
    Local $old = $CurrentAccount
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        SetAccountValue("StartAtLoop", GetValue("DefaultStartAtLoop"))
        SetAccountValue("EndAtLoop", GetValue("DefaultEndAtLoop"))
        SetAccountValue("StartAtCharacter", GetValue("DefaultStartAtCharacter"))
        SetAccountValue("EndAtCharacter", GetValue("DefaultEndAtCharacter"))
        SetAccountValue("CurrentCharacter", GetValue("StartAtCharacter"))
        SetAccountValue("CurrentLoop", GetValue("StartAtLoop"))
        If Not $UnattendedMode And Not $SkipAllConfigurations Then Load()
        If Not GetValue("EndAtCharacter") Or GetValue("EndAtCharacter") > GetValue("TotalSlots") Then SetAccountValue("EndAtCharacter", GetValue("TotalSlots"))
    Next
    $CurrentAccount = $old
EndFunc

Func Load()
    If ImageExists("LogInScreen") Then
        If Not GetValue("LogInUserName") Then
            SetAccountValue("LogInUserName", "")
        EndIf
        While 1
            Local $string = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EnterUsername"), GetValue("LogInUserName"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            If $string And $string <> "" Then
                SetAccountValue("LogInUserName", $string)
                ExitLoop
            EndIf
            If GetPrivateIniAccount("LogInUserName") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeleteUsername")) = $IDYES Then
                SetAccountValue("LogInUserName", "")
                SavePrivateIniAccount("LogInUserName")
            Else
                MsgBox($MB_ICONWARNING, $Title, Localize("ValidUsername"))
            EndIf
        WEnd
        If GetPrivateIniAccount("LogInUserName") <> GetValue("LogInUserName") Then
            If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SaveUsername")) = $IDYES Then
                SavePrivateIniAccount("LogInUserName", GetValue("LogInUserName"))
            Else
                SavePrivateIniAccount("LogInUserName")
            EndIf
        EndIf
        If Not GetValue("LogInPassword") Then SetAccountValue("LogInPassword", "")
        _Crypt_Startup()
        While 1
            Local $string = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EnterPassword"), GetValue("LogInPassword"), "*", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            If $string And $string <> "" Then
                If GetPrivateIniAccount("LogInPassword") == $string Then
                    SetAccountValue("LogInPassword", $string)
                    ExitLoop
                ElseIf GetValue("PasswordHash") Then
                    Local $Hash = Hex(_Crypt_HashData($string, $CALG_SHA1))
                    If $Hash = GetValue("PasswordHash") Then
                        SetAccountValue("LogInPassword", $string)
                        ExitLoop
                    EndIf
                    MsgBox($MB_ICONWARNING, $Title, Localize("PasswordIncorrect"))
                Else
                    Local $string2 = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EnterPasswordAgain"), "", "*", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
                    If @error <> 0 Then Exit
                    If $string == $string2 Then
                        SetAccountValue("LogInPassword", $string)
                        If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SavePassword")) = $IDYES Then
                            SavePrivateIniAccount("LogInPassword", GetValue("LogInPassword"))
                            If GetPrivateIniAccount("PasswordHash") <> "" Then
                                SavePrivateIniAccount("PasswordHash")
                            EndIf
                        Else
                            SavePrivateIniAccount("LogInPassword")
                            If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SavePasswordHash")) = $IDYES Then
                                SetAccountValue("PasswordHash", Hex(_Crypt_HashData(GetValue("LogInPassword"), $CALG_SHA1)))
                                SavePrivateIniAccount("PasswordHash", GetValue("PasswordHash"))
                            ElseIf GetPrivateIniAccount("PasswordHash") <> "" Then
                                SavePrivateIniAccount("PasswordHash")
                            EndIf
                        EndIf
                        ExitLoop
                    EndIf
                    MsgBox($MB_ICONWARNING, $Title, Localize("PasswordNotMatch"))
                EndIf
            Else
                If GetPrivateIniAccount("LogInPassword") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeletePassword")) = $IDYES Then
                    SetAccountValue("LogInPassword", "")
                    SavePrivateIniAccount("LogInPassword")
                ElseIf GetPrivateIniAccount("PasswordHash") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeletePasswordHash")) = $IDYES Then
                    DeleteAccountValue("PasswordHash")
                    SavePrivateIniAccount("PasswordHash")
                Else
                    MsgBox($MB_ICONWARNING, $Title, Localize("ValidPassword"))
                EndIf
            EndIf
        WEnd
        _Crypt_Shutdown()
    EndIf
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("TotalCharacters"), GetValue("TotalSlots"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number > 0 Then
            SetAccountValue("TotalSlots", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    If GetIniAccount("TotalSlots") <> GetValue("TotalSlots") Then SaveIniAccount("TotalSlots", GetValue("TotalSlots"))
EndFunc

Func SetCharacterInfo($name, $value = 0, $character = GetValue("CurrentCharacter"), $account = $CurrentAccount)
    If IsDeclared("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name) Then Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, $value)
    Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, $value, 2)
EndFunc

Func GetCharacterInfo($name, $character = GetValue("CurrentCharacter"), $account = $CurrentAccount)
    If IsDeclared("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name) Then Return Eval("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name)
    Return 0
EndFunc

Func AddCharacterCountInfo($name, $value = 1, $character = GetValue("CurrentCharacter"), $account = $CurrentAccount)
    If IsDeclared("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name) Then Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, GetCharacterInfo($name, $character, $account) + $value)
    Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, GetCharacterInfo($name, $character, $account) + $value, 2)
EndFunc

Func AdvancedAllAccountsSettings($hWnd = 0)
    Local $s = ""
    $s &= "|" & "DisableSimpleCharacterSelection,SimpleCharacterSelectionTitle,SimpleCharacterSelectionDescription,ReverseBoolean"
    $s &= "|" & "DisableCloseClient,CloseClientTitle,CloseClientDescription,ReverseBoolean"
    $s &= "|" & "NoInputBlocking,InputBlockingTitle,InputBlockingDescription,ReverseBoolean"
    $s &= "|" & "SkipVerifyFiles,SkipVerifyFilesTitle,SkipVerifyFilesDescription,Boolean"
    $s &= "|" & "DisableDonationPrompts,DisableDonationPromptsTitle,DisableDonationPromptsDescription,Boolean"
    $s &= "|" & "ProfessionsDelay,ProfessionsDelayTitle,ProfessionsDelayDescription,Number"
    $s &= "|" & "OptionalAssetsDelay,OptionalAssetsDelayTitle,OptionalAssetsDelayDescription,Number"
    $s &= "|" & "ClaimCofferDelay,ClaimCofferDelayTitle,ClaimCofferDelayDescription,Number"
    $s &= "|" & "ClaimVIPCharacterRewardDelay,ClaimVIPCharacterRewardDelayTitle,ClaimVIPCharacterRewardDelayDescription,Number"
    $s &= "|" & "ClaimVIPAccountRewardDelay,ClaimVIPAccountRewardDelayTitle,ClaimVIPAccountRewardDelayDescription,Number"
    $s &= "|" & "OpenInventoryBagDelay,OpenInventoryBagDelayTitle,OpenInventoryBagDelayDescription,Number"
    $s &= "|" & "OpenAnotherInventoryBagDelay,OpenAnotherInventoryBagDelayTitle,OpenAnotherInventoryBagDelayDescription,Number"
    $s &= "|" & "LogInDelaySeconds,LogInDelaySecondsTitle,LogInDelaySecondsDescription,Number"
    $s &= "|" & "KeyDelaySeconds,KeyDelaySecondsTitle,KeyDelaySecondsDescription,Number"
    $s &= "|" & "CharacterSelectionScrollAwayKeyDelaySeconds,CharacterSelectionScrollAwayKeyDelaySecondsTitle,CharacterSelectionScrollAwayKeyDelaySecondsDescription,Number"
    $s &= "|" & "CharacterSelectionScrollTowardKeyDelaySeconds,CharacterSelectionScrollTowardKeyDelaySecondsTitle,CharacterSelectionScrollTowardKeyDelaySecondsDescription,Number"
    $s &= "|" & "TimeOutMinutes,TimeOutMinutesTitle,TimeOutMinutesDescription,Number"
    $s &= "|" & "TimeOutRetries,TimeOutRetriesTitle,TimeOutRetriesDescription,Number"
    $s &= "|" & "MaxLogInAttempts,MaxLogInAttemptsTitle,MaxLogInAttemptsDescription,Number"
    $s &= "|" & "LogFilesToKeep,LogFilesToKeepTitle,LogFilesToKeepDescription,Number"
    $s &= "|" & "InvokeKey,InvokeKeyTitle,InvokeKeyDescription,Text"
    $s &= "|" & "GameMenuKey,GameMenuKeyTitle,GameMenuKeyDescription,Text"
    $s &= "|" & "CursorModeKey,CursorModeKeyTitle,CursorModeKeyDescription,Text"
    $s &= "|" & "InventoryKey,InventoryKeyTitle,InventoryKeyDescription,Text"
    $s &= "|" & "ProfessionsKey,ProfessionsKeyTitle,ProfessionsKeyDescription,Text"
    $s &= "|" & "CheckServerAddress,CheckServerAddressTitle,CheckServerAddressDescription,Text"
    Local $a = StringSplit(StringRegExpReplace($s, "^\|+", ""), "|")
    Local $Total = $a[0]
    Local $c[$Total + 1]
    Local $hGui = GUICreate($Title, 600, 400, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
    GUICtrlCreateLabel(Localize("AdvancedSettings"), 160, 20, 100, -1, $SS_RIGHT)
    For $i = 1 To $Total
        $a[$i] = StringSplit($a[$i], ",")
        GUICtrlCreateLabel(Localize(($a[$i])[2]), 0, 23 + $i * 36, 340, -1, $SS_RIGHT)
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
        Local $v = ($a[$i])[1], $gv = GetAllAccountsValue($v), $t = ($a[$i])[4]
        If $t = "Boolean" Or $t = "ReverseBoolean" Then
            $c[$i] = GUICtrlCreateCheckbox(" ", 350, 20 + $i * 36)
            If $t = "Boolean" Then
                If $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            Else
                If Not $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            EndIf
        Else
            $c[$i] = GUICtrlCreateInput($gv, 350, 20 + $i * 36, 155)
        EndIf
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
    Next
    _GUIScrollbars_Generate($hGUI, 1, 100 + $Total * 36)
    Local $ButtonDefault = GUICtrlCreateButton(Localize("Default"), 40, 60 + $Total * 36, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 268, 60 + $Total * 36, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 350, 60 + $Total * 36, 75, 25)
    GUISetState(@SW_SHOW, $hGui)
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $ButtonDefault
                For $i = 1 To $Total
                    Local $v = ($a[$i])[1], $t = ($a[$i])[4]
                    If $t = "Boolean" Or $t = "ReverseBoolean" Then
                        GUICtrlSetState($c[$i], $GUI_UNCHECKED)
                        If $t = "Boolean" Then
                            If GetDefaultValue($v) Then GUICtrlSetState($c[$i], $GUI_CHECKED)
                        Else
                            If Not GetDefaultValue($v) Then GUICtrlSetState($c[$i], $GUI_CHECKED)
                        EndIf
                    Else
                        GUICtrlSetData($c[$i], GetDefaultValue($v))
                    EndIf
                Next
            Case $ButtonOK
                For $i = 1 To $Total
                    Local $value, $v = ($a[$i])[1], $t = ($a[$i])[4]
                    If $t = "Boolean" Or $t = "ReverseBoolean" Then
                        If GUICtrlRead($c[$i]) = $GUI_CHECKED Then $value = 1
                        If $t = "Boolean" Then
                            $value = 0
                            If GUICtrlRead($c[$i]) = $GUI_CHECKED Then $value = 1
                        Else
                            $value = 1
                            If GUICtrlRead($c[$i]) = $GUI_CHECKED Then $value = 0
                        EndIf
                    Else
                        $value = GUICtrlRead($c[$i])
                        If $t = "Number" Or String(Number($value)) = String($value) Then
                            $value = Number($value)
                        EndIf
                    EndIf
                    If $value == GetDefaultValue($v) Or $value == "" Or $value == 0 Then
                        DeleteAllAccountsValue($v)
                        DeleteIniAllAccounts($v)
                    Else
                        SetAllAccountsValue($v, $value)
                        SaveIniAllAccounts($v, $value)
                    EndIf
                Next
                ExitLoop
            Case $ButtonCancel
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($hGUI)
EndFunc

Func ChooseOptions()
    Local $overflowxpdefault = GetValue("DisableOverflowXPRewardCollection"), $openbagsdefault = GetAllAccountsValue("DisableOpeningBags"), $openbagsoneveryloopdefault = GetAllAccountsValue("OpenBagsOnEveryLoop"), $cofferdefault = GetValue("Coffer"), $list = Localize($cofferdefault), $coffers = Array("CofferOfCelestialEnchantments, CofferOfCelestialArtifacts, CofferOfCelestialArtifactEquipment, BlessedProfessionsElementalPack, ElixirOfFate")
    For $i = 1 To $coffers[0]
        If Not ($coffers[$i] == $cofferdefault) Then $list &= "|" & Localize($coffers[$i])
    Next
    Local $hGui = GUICreate($Title, 320, 230)
    GUICtrlCreateLabel(Localize("ChooseCoffer"), 25, 20, 270)
    Local $hCombo = GUICtrlCreateCombo("", 25, 50, 270)
    GUICtrlSetData(-1, $list, Localize($cofferdefault))
    Local $CollectOverflowXPRewardsCheckbox = GUICtrlCreateCheckbox(" " & Localize("CollectOverflowXPRewards"), 25, 95, 270)
    If Not GetValue("DisableOverflowXPRewardCollection") Then GUICtrlSetState($CollectOverflowXPRewardsCheckbox, $GUI_CHECKED)
    Local $OpenInventoryBagsCheckbox = GUICtrlCreateCheckbox(" " & Localize("OpenInventoryBags"), 25, 125, 270)
    If Not GetAllAccountsValue("DisableOpeningBags") Then GUICtrlSetState($OpenInventoryBagsCheckbox, $GUI_CHECKED)
    Local $OpenInventoryBagsOnEveryLoopCheckbox = GUICtrlCreateCheckbox(" " & Localize("OpenInventoryBagsOnEveryLoop"), 25, 155, 270)
    If GetAllAccountsValue("DisableOpeningBags") Then
        GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_DISABLE)
    ElseIf GetAllAccountsValue("OpenBagsOnEveryLoop") Then
        GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_CHECKED)
    EndIf
    Local $ButtonAdvanced = GUICtrlCreateButton(Localize("Advanced"), 25, 195, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 127, 195, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 214, 195, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $OpenInventoryBagsCheckbox
                If GUICtrlRead($OpenInventoryBagsCheckbox) = $GUI_CHECKED Then
                    GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_ENABLE)
                    If GetAllAccountsValue("OpenBagsOnEveryLoop") Then GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_CHECKED)
                Else
                    GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_UNCHECKED)
                    GUICtrlSetState($OpenInventoryBagsOnEveryLoopCheckbox, $GUI_DISABLE)
                EndIf
            Case $ButtonAdvanced
                AdvancedAllAccountsSettings($hGui)
            Case $ButtonOK
                Local $CurrCombo = GUICtrlRead($hCombo), $overflowxpdisabled = 1, $openbagsdisabled = 1, $openbagsoneveryloopenabled = 0
                If GUICtrlRead($CollectOverflowXPRewardsCheckbox) = $GUI_CHECKED Then $overflowxpdisabled = 0
                If GUICtrlRead($OpenInventoryBagsCheckbox) = $GUI_CHECKED Then $openbagsdisabled = 0
                If GUICtrlRead($OpenInventoryBagsOnEveryLoopCheckbox) = $GUI_CHECKED Then $openbagsoneveryloopenabled = 1
                For $i = 1 To $coffers[0]
                    If Localize($coffers[$i]) == $CurrCombo Then
                        If Not ($cofferdefault == $coffers[$i]) Then
                            If $coffers[$i] == GetDefaultValue("Coffer") Then
                                DeleteAllAccountsValue("Coffer")
                                DeleteIniAllAccounts("Coffer")
                            Else
                                SetAllAccountsValue("Coffer", $coffers[$i])
                                SaveIniAllAccounts("Coffer", GetValue("Coffer"))
                            EndIf
                        EndIf
                        If $overflowxpdefault <> $overflowxpdisabled Then
                            If $overflowxpdisabled == GetDefaultValue("DisableOverflowXPRewardCollection") Then
                                DeleteAllAccountsValue("DisableOverflowXPRewardCollection")
                                DeleteIniAllAccounts("DisableOverflowXPRewardCollection")
                            Else
                                SetAllAccountsValue("DisableOverflowXPRewardCollection", $overflowxpdisabled)
                                SaveIniAllAccounts("DisableOverflowXPRewardCollection", GetValue("DisableOverflowXPRewardCollection"))
                            EndIf
                        EndIf
                        If $openbagsdefault <> $openbagsdisabled Then
                            If $openbagsdisabled == GetDefaultValue("DisableOpeningBags") Then
                                DeleteAllAccountsValue("DisableOpeningBags")
                                DeleteIniAllAccounts("DisableOpeningBags")
                            Else
                                SetAllAccountsValue("DisableOpeningBags", $openbagsdisabled)
                                SaveIniAllAccounts("DisableOpeningBags", GetAllAccountsValue("DisableOpeningBags"))
                            EndIf
                        EndIf
                        If $openbagsoneveryloopdefault <> $openbagsoneveryloopenabled Then
                            If $openbagsoneveryloopenabled == GetDefaultValue("OpenBagsOnEveryLoop") Then
                                DeleteAllAccountsValue("OpenBagsOnEveryLoop")
                                DeleteIniAllAccounts("OpenBagsOnEveryLoop")
                            Else
                                SetAllAccountsValue("OpenBagsOnEveryLoop", $openbagsoneveryloopenabled)
                                SaveIniAllAccounts("OpenBagsOnEveryLoop", GetAllAccountsValue("OpenBagsOnEveryLoop"))
                            EndIf
                        EndIf
                        GUIDelete()
                        Return
                    EndIf
                Next
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

Func RunScript(); If $RestartLoop Then Return 0
    If $CmdLine[0] Then
        SetAllAccountsValue("UnattendedMode", Number($CmdLine[1]))
        If GetValue("UnattendedMode") = 0 Then $UnattendedModeCheckSettings = 1
    EndIf
    Local $old = $CurrentAccount
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        If Not GetValue("LogInUserName") Or Not GetValue("LogInPassword") Or Not GetValue("TotalSlots") Then
            $AllLoginInfoFound = 0
            ExitLoop
        EndIf
    Next
    $CurrentAccount = $old
    If $AllLoginInfoFound And GetValue("UnattendedMode") <> 2 And GetValue("UnattendedMode") <> 3 Then $UnattendedMode = GetValue("UnattendedMode")
    If Not $UnattendedModeCheckSettings And Not GetValue("DisableDonationPrompts") And ( GetAllAccountsValue("TotalInvoked") - GetAllAccountsValue("DonationPrompts") * 2000 ) >= 2000 Then
        Statistics_SaveIniAllAccounts("DonationPrompts", Floor(GetAllAccountsValue("TotalInvoked") / 2000))
        CloseClient("DonationPrompt.exe"); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        If $UnattendedMode Then
            If @Compiled Then
                ShellExecute(@ScriptDir & "\DonationPrompt.exe", "", @ScriptDir)
            Else
                ShellExecute(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\DonationPrompt.au3"', @ScriptDir)
            EndIf
        ElseIf @Compiled Then
            ShellExecuteWait(@ScriptDir & "\DonationPrompt.exe", "", @ScriptDir)
        Else
            ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\DonationPrompt.au3"', @ScriptDir)
        EndIf
    EndIf
    If Not $UnattendedMode And @Compiled Then
        Local $tmpverfile = _DownloadFile("https://github.com/BigRedBot/NeverwinterInvokeBot/raw/master/version.ini", $Title, Localize("RetrievingVersion"))
        If $tmpverfile Then
            Local $CurrentVersion = IniRead($tmpverfile, "version", "version", "")
            FileDelete($tmpverfile)
            If $CurrentVersion <> "" Then
                If $CurrentVersion <> $Version And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("NewerVersionFound", "<VERSION>", $CurrentVersion), 60) = $IDYES Then
                    Local $tmpinstallfile = _DownloadFile("https://github.com/BigRedBot/NeverwinterInvokeBot/raw/master/NeverwinterInvokeBot.exe", $Title, Localize("DownloadingInstaller"))
                    If $tmpinstallfile Then
                        If FileCopy($tmpinstallfile, @ScriptDir & "\Install.exe", $FC_OVERWRITE) Then
                            FileDelete($tmpinstallfile)
                            Exit ShellExecute(@ScriptDir & "\Install.exe")
                        EndIf
                        FileDelete($tmpinstallfile)
                    EndIf
                    MsgBox($MB_ICONWARNING, $Title, Localize("CouldNotDownloadLatestVersion"))
                EndIf
            ElseIf Not $UnattendedModeCheckSettings Then
                MsgBox($MB_ICONWARNING, $Title, Localize("CouldNotReadCurrentVersionInfo"))
            EndIf
        ElseIf Not $UnattendedModeCheckSettings Then
            MsgBox($MB_ICONWARNING, $Title, Localize("CouldNotDownloadCurrentVersionInfo"))
        EndIf
    EndIf
    If $AllLoginInfoFound And $UnattendedModeCheckSettings Then Exit
    CheckProfessionsUnlockCode()
    If Not $UnattendedModeCheckSettings And Not $UnattendedMode And $AllLoginInfoFound And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SkipAllConfigurations", "<NUMBER>", GetValue("TotalAccounts"))) = $IDYES Then $SkipAllConfigurations = 1
    If Not $UnattendedMode And Not $SkipAllConfigurations Then
        ChooseOptions()
        While 1
            Local $strNumber = InputBox($Title, @CRLF & Localize("TotalAccounts"), GetValue("TotalAccounts"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            Local $number = Floor(Number($strNumber))
            If $number > 0 Then
                SetAllAccountsValue("TotalAccounts", $number)
                ExitLoop
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
        WEnd
        If GetIniAllAccounts("TotalAccounts") <> GetValue("TotalAccounts") Then SaveIniAllAccounts("TotalAccounts", GetValue("TotalAccounts"))
    EndIf
    Initialize()
    If $UnattendedModeCheckSettings Then Exit
    Start(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    Exit
EndFunc

RunScript()
