#NoTrayIcon
#RequireAdmin
AutoItSetOption("TrayAutoPause", 0)
Global $LoadPrivateSettings = 1
#include "..\variables.au3"
#include "Shared.au3"
TraySetIcon(@ScriptDir & "\images\red.ico")
Global $Title = $Name & " v" & $Version
TraySetToolTip($Title)
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    If Not $CmdLine[0] Or Number($CmdLine[1]) <> 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("AlreadyRunning"))
    Exit
EndIf
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
#include "_DownloadFile.au3"
#include "_GetUTCMinutes.au3"
#include "_ImageSearch.au3"
#include "_SendUnicode.au3"
#include <Crypt.au3>
Global $KeyDelay = GetValue("KeyDelaySeconds") * 1000
Global $TimeOut = GetValue("TimeOutMinutes") * 60000
AutoItSetOption("SendKeyDownDelay", $KeyDelay)
Global $MouseOffset = 5

Func Array($x)
    Return StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($x, 8), "^,", ""), ",$", ""), ",")
EndFunc

Global $GameClientInstallLocation = RegRead("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "InstallLocation")
If @error <> 0 Then $GameClientInstallLocation = 0

Global $ArcLauncherLocation = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Perfect World Entertainment\Arc", "launcher")
If @error <> 0 Then $ArcLauncherLocation = 0

Func GetLogInServerAddressString()
    Local $r = "", $a = Array(GetValue("LogInServerAddress"))
    If $a[1] And IsString($a[1]) And $a[1] <> "" Then
        TCPStartup()
        For $i = 1 to $a[0]
            Local $ip = TCPNameToIP($a[$i])
            If $ip And $ip <> "" Then
                $r &= " -server " & $ip
            EndIf
        Next
        TCPShutdown()
    EndIf
    Return $r
EndFunc

; add after: If $RestartLoop Then Return 0
Func CloseClient($r = 0, $p = "GameClient.exe")
    $WaitingTimer = TimerInit()
    Local $list = ProcessList($p)
    If @error <> 0 Then Return
    For $i = 1 To $list[0][0]
        Local $PID = $list[$i][1]
        While ProcessExists($PID)
            TimeOut($r)
            If $RestartLoop Then Return 0
            ProcessClose($PID)
            Sleep(100)
        WEnd
    Next
EndFunc

; add after: If $RestartLoop Then Return 0
Func Position($r = 0)
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        If GetValue("RestartGameClient") And $GameClientInstallLocation And $GameClientInstallLocation <> "" And GetValue("LogInServerAddress") And GetValue("LogInServerAddress") <> "" And GetValue("LogInUserName") And GetValue("LogInPassword") And ImageExists("LogInScreen") And FileExists($GameClientInstallLocation & "\Neverwinter\Live\GameClient.exe") Then
            $LogInTries = 0
            $LastLoginTry = 0
            $DisableRelogCount = 1
            Splash("[ " & Localize("NeverwinterNotFound") & " ]")
            CloseClient($r)
            If $RestartLoop Then Return 0
            Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
            FileChangeDir($GameClientInstallLocation & "\Neverwinter\Live")
            Run("GameClient.exe" & GetLogInServerAddressString(), $GameClientInstallLocation & "\Neverwinter\Live")
            FileChangeDir(@ScriptDir)
            Sleep(1000)
            Focus()
            While Not $WinHandle
                TimeOut($r)
                If $RestartLoop Then Return 0
                Focus()
                Sleep(1000)
            WEnd
            If Not $r And $StartTimer Then $Restarted += 1
            Position($r)
            If $RestartLoop Then Return 0
            $WaitingTimer = TimerInit()
            While Not ImageSearch("LogInScreen")
                Sleep(500)
                TimeOut($r)
                If $RestartLoop Then Return 0
                Position($r)
                If $RestartLoop Then Return 0
            WEnd
            Return
        EndIf
        Error(Localize("NeverwinterNotFound"))
        If $RestartLoop Then Return 0
    EndIf
    If GetValue("GameWidth") And GetValue("GameHeight") Then
        If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight Then
            Error(Localize("UnMaximize"))
            If $RestartLoop Then Return 0
            Return
        ElseIf $DeskTopWidth < ( GetValue("GameWidth") + $PaddingLeft ) Or $DeskTopHeight < ( GetValue("GameHeight") + $PaddingTop ) Then
            Error(Localize("ResolutionHigherThan", "<RESOLUTION>", (GetValue("GameWidth") + $PaddingLeft) & "x" & (GetValue("GameHeight") + $PaddingTop)))
            If $RestartLoop Then Return 0
            Return
        EndIf
        If $ClientWidth <> GetValue("GameWidth") Or $ClientHeight <> GetValue("GameHeight") Then
            WinMove($WinHandle, "", $WinLeft, $WinTop, GetValue("GameWidth") + $PaddingWidth, GetValue("GameHeight") + $PaddingHeight)
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                Position($r)
                If $RestartLoop Then Return 0
                Return
            EndIf
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            WinMove($WinHandle, "", 0, 0)
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                Position($r)
                If $RestartLoop Then Return 0
                Return
            EndIf
        EndIf
        If $ClientWidth <> GetValue("GameWidth") Or $ClientHeight <> GetValue("GameHeight") Then
            Error(Localize("UnableToResize"))
            If $RestartLoop Then Return 0
        ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            Error(Localize("UnableToMove"))
            If $RestartLoop Then Return 0
        EndIf
    EndIf
EndFunc

Global $MinutesToStart = 0, $ReLogged = 0, $LogInTries = 0, $LastLoginTry = 0, $DoRelogCount = 0, $DisableRelogCount = 1, $GamePatched = 0, $CofferTries = 0, $LoopStarted = 0, $RestartLoop = 0, $Restarted = 0, $LogTime = 0, $LogDate = 0, $LogSessionStart = 1, $LoopDelayMinutes[7] = [6, 0, 15, 30, 45, 60, 90], $MaxLoops = $LoopDelayMinutes[0], $FailedInvoke, $StartTimer, $WaitingTimer, $LoggingIn

Func SyncValues()
    If GetValue("FinishedLoop") Then
        AddAccountCountValue("CurrentLoop", GetValue("FinishedLoop"))
        SetAccountValue("FinishedLoop")
        SetAccountValue("Current", GetValue("StartAt"))
        SetAccountValue("FinishedInvoke")
        $ETAText = ""
    EndIf
    AddAccountCountValue("Current", GetValue("FinishedInvoke"))
    SetAccountValue("FinishedInvoke")
EndFunc

Func Loop()
    While 1
        While 1
            $LoopStarted = 1
            $RestartLoop = 0
            If CompletedAccount() Then
                End()
                If $RestartLoop Then ExitLoop 1
                Exit
            EndIf
            Position()
            If $RestartLoop Then Return 0
            Splash()
            $WaitingTimer = TimerInit()
            FindLogInScreen()
            If $RestartLoop Then ExitLoop 1
            If $DoRelogCount And Not $DisableRelogCount Then $ReLogged += 1
            $DoRelogCount = 0
            $DisableRelogCount = 0
            Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
            If ImageExists("SelectionScreen") Then
                $WaitingTimer = TimerInit()
                WaitForScreen("SelectionScreen")
                If $RestartLoop Then ExitLoop 1
            EndIf
            Position()
            If $RestartLoop Then ExitLoop 1
            Local $Start = GetValue("Current")
            For $i = $Start To GetValue("EndAt")
                SetAccountValue("Current", $i)
                SetAccountValue("FinishedInvoke")
                WaitToInvoke()
                If $RestartLoop Then ExitLoop 2
                Splash()
                Local $LoopTimer = TimerInit()
                Focus()
                MouseMove(GetValue("SelectCharacterMenuX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("SelectCharacterMenuY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
                DoubleRightClick()
                MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientHeightCenter + Random(-$MouseOffset, $MouseOffset, 1))
                If GetValue("Current") <= Ceiling(GetValue("TotalSlots") / 2) Then
                    If GetValue("TopScrollBarX") And GetValue("TopSelectedCharacterX") Then
                        For $n = 1 To 2
                            Send("{DOWN}")
                        Next
                        For $n = 1 To GetValue("TotalSlots")
                            Send("{UP}")
                            Position()
                            If $RestartLoop Then ExitLoop 3
                            If FindPixels(GetValue("TopScrollBarX"), GetValue("TopScrollBarY"), GetValue("TopScrollBarC")) And FindPixels(GetValue("TopSelectedCharacterX"), GetValue("TopSelectedCharacterY"), GetValue("TopSelectedCharacterC")) Then
                                ExitLoop
                            EndIf
                        Next
                    Else
                        For $n = 1 To GetValue("TotalSlots")
                            Send("{UP}")
                        Next
                    EndIf
                    Sleep($KeyDelay)
                    For $n = 2 To GetValue("Current")
                        Send("{DOWN}")
                        Sleep(50)
                    Next
                Else
                    If GetValue("BottomScrollBarX") And GetValue("BottomSelectedCharacterX") Then
                        For $n = 1 To 2
                            Send("{UP}")
                        Next
                        For $n = 1 To GetValue("TotalSlots")
                            Send("{DOWN}")
                            Position()
                            If $RestartLoop Then ExitLoop 3
                            If FindPixels(GetValue("BottomScrollBarX"), GetValue("BottomScrollBarY"), GetValue("BottomScrollBarC")) And FindPixels(GetValue("BottomSelectedCharacterX"), GetValue("BottomSelectedCharacterY"), GetValue("BottomSelectedCharacterC")) Then
                                ExitLoop
                            EndIf
                        Next
                    Else
                        For $n = 1 To GetValue("TotalSlots")
                            Send("{DOWN}")
                        Next
                    EndIf
                    Sleep($KeyDelay)
                    For $n = 1 To (GetValue("TotalSlots") - GetValue("Current"))
                        Send("{UP}")
                        Sleep(50)
                    Next
                EndIf
                Sleep(1000)
                Send("{ENTER}")
                If GetValue("SafeLogInX") Then
                    MouseMove(GetValue("SafeLogInX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("SafeLogInY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
                    DoubleClick()
                EndIf
                Splash("[ " & Localize("WaitingForInGameScreen") & " ]")
                If ImageExists("ChangeCharacterButton") Then
                    $WaitingTimer = TimerInit()
                    WaitForScreen("ChangeCharacterButton")
                    If $RestartLoop Then ExitLoop 2
                    Splash()
                    Sleep(GetValue("LogInDelaySeconds") * 1000)
                Else
                    Sleep(GetValue("LogInSeconds") * 1000)
                    Splash()
                EndIf
                If Not GetValue("DisableOverflowXPRewardCollection") And ImageSearch("OverflowXPReward") Then
                    Send(GetValue("CursorModeKey"))
                    Sleep(500)
                    MouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    SaveItemCount("TotalOverflowXPRewards", 1)
                    Sleep(1000)
                    ClearWindows()
                    If $RestartLoop Then Return 0
                    Sleep(500)
                EndIf
                GetVIPAccountReward()
                $WaitingTimer = TimerInit()
                $FailedInvoke = 1
                $CofferTries = 0
                Invoke()
                If $RestartLoop Then ExitLoop 2
                SetCharacterInfo("InvokeTime", TimerInit())
                SetCharacterInfo("InvokeLoop", GetValue("CurrentLoop"))
                SetAccountValue("FinishedInvoke", 1)
                If $FailedInvoke Then
                    AddAccountCountValue("FailedInvoke")
                    AddCharacterCountInfo("FailedInvoke")
                EndIf
                If GetValue("Current") >= GetValue("EndAt") Then
                    SetAccountValue("FinishedLoop", 1)
                    If GetValue("CurrentLoop") >= GetValue("EndAtLoop") Then SetAccountValue("CompletedAccount", 1)
                EndIf
                ChangeCharacter()
                If $RestartLoop Then ExitLoop 2
                Local $LogOutTimer = TimerInit()
                Local $RemainingCharacters = GetValue("EndAt") - GetValue("Current")
                Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                If ImageExists("SelectionScreen") Then
                    $WaitingTimer = TimerInit()
                    WaitForScreen("SelectionScreen")
                    If $RestartLoop Then ExitLoop 2
                    Splash()
                Else
                    Sleep(GetValue("LogOutSeconds") * 1000)
                    Splash()
                EndIf
                If GetValue("FinishedLoop") Or CompletedAccount() Then
                    ExitLoop
                Else
                    Local $AdditionalKeyPressTime = 0, $AddKeyPressTime = 0, $RemoveKeyPressTime = 0
                    If GetValue("TopScrollBarX") And GetValue("TopSelectedCharacterX") Then
                        $AddKeyPressTime = $KeyDelay
                    EndIf
                    If GetValue("BottomScrollBarX") And GetValue("BottomSelectedCharacterX") Then
                        $RemoveKeyPressTime = $KeyDelay
                    EndIf
                    For $n = 1 To $RemainingCharacters
                        If GetValue("Current") + $n <= Ceiling(GetValue("TotalSlots") / 2) Then
                            $AdditionalKeyPressTime += $n * ($KeyDelay + 50) + $AddKeyPressTime
                        ElseIf GetValue("Current") <= Floor(GetValue("TotalSlots") / 2) + 1 Then
                            $AdditionalKeyPressTime -= (GetValue("Current") + $n - Floor(GetValue("TotalSlots") / 2) + 1) * ($KeyDelay + 50)
                        Else
                            $AdditionalKeyPressTime -= $n * ($KeyDelay + 50) + $RemoveKeyPressTime
                        EndIf
                    Next
                    Local $LastTime = TimerDiff($LoopTimer)
                    Local $RemainingSeconds = ( $RemainingCharacters * $LastTime + $AdditionalKeyPressTime - TimerDiff($LogOutTimer) ) / 1000
                    $ETAText = Localize("LastInvokeTook", "<SECONDS>", Round($LastTime / 1000, 2)) & @CRLF & Localize("ETAForCurrentLoop", "<MINUTES>", HoursAndMinutes($RemainingSeconds / 60))
                EndIf
            Next
            End()
            If $RestartLoop Then ExitLoop 1
            Exit
        WEnd
    WEnd
EndFunc

; add after: If $RestartLoop Then Return 0
Func StartLoop()
    If $LoopStarted Then
        $RestartLoop = 1
        Return 0
    Else
        Loop()
        Exit
    EndIf
EndFunc

Func CompletedAccount()
    SyncValues()
    If GetValue("CompletedAccount") Or ( GetValue("CurrentLoop") > $MaxLoops And GetValue("Invoked") = (GetValue("TotalSlots") * $MaxLoops) ) Then
        SetAccountValue("CompletedAccount", 1)
        Return 1
    EndIf
    Return 0
EndFunc

Func CheckAccounts()
    Local $CurrentComplete = CompletedAccount(), $old = $CurrentAccount, $oldtime = GetTimeToInvoke(), $oldloop = GetValue("CurrentLoop"), $new = $old, $newtime = $oldtime, $newloop = $oldloop, $allcomplete = 1
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
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
    Local $LastLoop = GetCharacterInfo("InvokeLoop")
    If ( $LastLoop And GetValue("CurrentLoop") > $LastLoop ) Or ( Not $LastLoop And GetValue("CurrentLoop") > GetValue("StartAtLoop") ) Then
        Local $Time = GetCharacterInfo("InvokeTime")
        If Not $Time Then $Time = $StartTimer
        Local $i = GetValue("CurrentLoop")
        If $i > $MaxLoops Then $i = $MaxLoops
        Local $Minutes = $LoopDelayMinutes[$i] - TimerDiff($Time) / 60000
        If $Minutes > 0 Then Return $Minutes
    EndIf
    Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func WaitToInvoke()
    Local $Minutes = GetTimeToInvoke()
    If $Minutes > 1 And ImageExists("SelectionScreen") And ImageExists("LogInScreen") Then
        Local $check = CheckAccounts()
        If $check > 0 Then
            If $check <> $CurrentAccount Then
                $ETAText = ""
                Position()
                If $RestartLoop Then Return 0
                Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                $WaitingTimer = TimerInit()
                WaitForScreen("SelectionScreen")
                If $RestartLoop Then Return 0
                Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
                If ImageSearch("SelectionScreen") Then
                    MouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(1000)
                    $DisableRelogCount = 1
                EndIf
                $CurrentAccount = $check
                $WaitingTimer = TimerInit()
                While Not ImageSearch("LogInScreen")
                    Sleep(500)
                    TimeOut(1)
                    If $RestartLoop Then Return 0
                    Position(1)
                    If $RestartLoop Then Return 0
                WEnd
                StartLoop()
                If $RestartLoop Then Return 0
            EndIf
        Else
            End()
            If $RestartLoop Then Return 0
            Exit
        EndIf
    EndIf
    If $Minutes > 0 Then
        $ETAText = ""
        Position()
        If $RestartLoop Then Return 0
        WaitMinutes($Minutes, "WaitingForInvokeDelay")
        StartLoop()
        If $RestartLoop Then Return 0
    EndIf
EndFunc

; add after: If $RestartLoop Then Return 0
Func Invoke()
    If $CofferTries >= 5 Then Return
    If ImageExists("CongratulationsWindow") Then
        For $n = 1 To 5
            FindLogInScreen()
            If $RestartLoop Then Return 0
            Send(GetValue("InvokeKey"))
            Sleep(500)
            If ImageSearch("Invoked") Then
                If GetValue("CurrentLoop") > $MaxLoops Then
                    $FailedInvoke = 0
                EndIf
                Return
            EndIf
            For $k = 1 To 10
                If ImageSearch("VaultOfPietyButton") Then
                    MouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    GetCoffer()
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
                FindLogInScreen()
                If $RestartLoop Then Return 0
                Sleep(500)
            Next
        Next
    Else
        For $n = 1 To 3
            Send(GetValue("InvokeKey"))
            Sleep(5000)
        Next
        If ImageSearch("VaultOfPietyButton") Then
            MouseMove($_ImageSearchX, $_ImageSearchY)
            SingleClick()
            GetCoffer()
            If $RestartLoop Then Return 0
        EndIf
    EndIf
EndFunc

Func GetVIPAccountReward()
    If Not GetValue("SkipVIPAccountReward") And GetValue("VIPAccountRewardTries") >= 0 And GetValue("VIPAccountRewardTries") < 3 And ( GetValue("VIPAccountRewardCharacter") < GetValue("StartAt") Or GetValue("VIPAccountRewardCharacter") > GetValue("EndAt") Or GetValue("VIPAccountRewardCharacter") = GetValue("Current") ) And ImageExists("VIPAccountReward") Then
        AddAccountCountValue("VIPAccountRewardTries")
        Send(GetValue("InventoryKey"))
        Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
        MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientBottom)
        If ImageSearch("VIPAccountReward", -1) Then
            Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop, $right = $_ImageSearchRight, $bottom = $_ImageSearchBottom
            If ImageSearch("VIPAccountRewardBorder", -1, $_ImageSearchX, $_ImageSearchY-10) Then
                $_ImageSearchX = Random($_ImageSearchRight + GetValue("VIPAccountRewardButtonLeftOffset"), $_ImageSearchRight + GetValue("VIPAccountRewardButtonRightOffset"), 1)
                $_ImageSearchY = Random($_ImageSearchTop + GetValue("VIPAccountRewardButtonTopOffset"), $_ImageSearchTop + GetValue("VIPAccountRewardButtonBottomOffset"), 1)
                MouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
                MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientBottom)
                If Not ImageSearch("VIPAccountReward", -1, $left, $top, $right, $bottom) Then
                    SaveItemCount("TotalVIPAccountRewards", 1)
                ElseIf ImageSearch("VIPAccountRewardBorder", -1, $_ImageSearchX, $_ImageSearchY-10) Then
                    $_ImageSearchX = Random($_ImageSearchRight + GetValue("VIPAccountRewardButtonLeftOffset"), $_ImageSearchRight + GetValue("VIPAccountRewardButtonRightOffset"), 1)
                    $_ImageSearchY = Random($_ImageSearchTop + GetValue("VIPAccountRewardButtonTopOffset"), $_ImageSearchTop + GetValue("VIPAccountRewardButtonBottomOffset"), 1)
                    MouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(GetValue("ClaimVIPAccountRewardDelay") * 1000)
                    If Not ImageSearch("VIPAccountReward", -1, $left, $top, $right, $bottom) Then
                        SaveItemCount("TotalVIPAccountRewards", 1)
                    EndIf
                EndIf
            EndIf
        Else
            GetVIPAccountReward()
        EndIf
        If GetValue("VIPAccountRewardTries") >= 0 Then
            SetAccountValue("VIPAccountRewardTries", -1)
            ClearWindows()
            If $RestartLoop Then Return 0
            Sleep(500)
        EndIf
    EndIf
EndFunc

; add after: If $RestartLoop Then Return 0
Func GetCoffer()
    If $CofferTries >= 5 Then Return
    Sleep(GetValue("ClaimCofferDelay") * 1000)
    If ImageSearch("CelestialSynergyTab") Then
        MouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("ClaimCofferDelay") * 1000)
    EndIf
    If ImageSearch(GetValue("Coffer")) Then
        MouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(GetValue("ClaimCofferDelay") * 1000)
        If GetValue("Coffer") = "ElixirOfFate" Then
            If ImageSearch("OK") Then
                Send("{BS 2}4")
                Sleep(500)
                If ImageSearch("OK") Then
                    MouseMove($_ImageSearchX, $_ImageSearchY)
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
                MouseMove($_ImageSearchX, $_ImageSearchY)
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
    ClearWindows()
    If $RestartLoop Then Return 0
    Sleep(500)
    $CofferTries += 1
    Invoke()
    If $RestartLoop Then Return 0
EndFunc


Global $AlternateLogInCommands = 1

Func SearchForChangeCharacterButton()
    If $AlternateLogInCommands = 2 Or GetValue("GameMenuKey") = "{ESC}" Then
        Send("{ESC}")
    Else
        Send(GetValue("GameMenuKey"))
    EndIf
    Sleep(1500)
    If ImageSearch("ChangeCharacterButton") Then Return 1
    MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
    If ImageSearch("ChangeCharacterButton") Then Return 1
    If $AlternateLogInCommands = 1 Then
        $AlternateLogInCommands = 2
    Else
        $AlternateLogInCommands = 1
    EndIf
    Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func WaitForChangeCharacterButton()
    If Not ImageExists("ChangeCharacterButton") Then Return
    $AlternateLogInCommands = 1
    While Not SearchForChangeCharacterButton()
        TimeOut()
        If $RestartLoop Then Return 0
        FindLogInScreen()
        If $RestartLoop Then Return 0
    WEnd
EndFunc

; add after: If $RestartLoop Then Return 0
Func ClearWindows()
    While 1
        WaitForChangeCharacterButton()
        If $RestartLoop Then Return 0
        Send("{ESC}")
        If Not ImageSearch("ChangeCharacterButton") Then Return 1
    WEnd
EndFunc

; add after: If $RestartLoop Then Return 0
Func ChangeCharacter()
    $WaitingTimer = TimerInit()
    While 1
        While 1
            WaitForChangeCharacterButton()
            If $RestartLoop Then Return 0
            If ImageExists("ChangeCharacterButton") Then
                MouseMove($_ImageSearchX, $_ImageSearchY)
                DoubleClick()
            Else
                For $n = 1 To 3
                    Send("{DOWN}")
                    Sleep($KeyDelay)
                Next
                Sleep(500)
                Send("{ENTER}")
            EndIf
            Sleep(500)
            If ImageExists("ChangeCharacterConfirmation") And Not ImageSearch("ChangeCharacterConfirmation") Then
                Send("{ESC}")
                Sleep(500)
                Send("{ESC}")
                Sleep(1500)
                MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
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
            If ImageSearch("ChangeCharacterConfirmation") Then
                Send("{ESC}")
                Sleep(500)
                Send("{ESC}")
                Sleep(1500)
                MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
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
    Sleep($KeyDelay)
    MouseDown("primary")
    Sleep($KeyDelay)
    MouseUp("primary")
EndFunc

Func DoubleRightClick()
    SingleRightClick()
    SingleRightClick()
EndFunc

Func SingleRightClick()
    Sleep($KeyDelay)
    MouseDown("right")
    Sleep($KeyDelay)
    MouseUp("right")
EndFunc

Global $SplashWindow, $SplashWindowOnTop = 1, $LastSplashText = "", $SplashStartText = "", $ETAText = "", $SplashLeft = @DesktopWidth - GetValue("SplashWidth") - 70 - 1, $SplashTop = @DesktopHeight - GetValue("SplashHeight") - 50 - 1

Func Splash($s = "", $ontop = 1)
    If $s == 0 Then
        HotKeySet("{F4}")
        FindWindow()
        If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
        BlockInput(0)
        SplashOff()
        $SplashWindow = 0
        Return
    EndIf
    Local $Message = Localize("Invoking", "<CURRENT>", GetValue("Current"), "<ENDAT>", GetValue("EndAt"), "<CURRENTLOOP>", GetValue("CurrentLoop"), "<ENDATLOOP>", GetValue("EndAtLoop")) & @CRLF & $s & @CRLF & $ETAText
    If $SplashWindow And $ontop = $SplashWindowOnTop Then
        $Message = Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & $SplashStartText & $Message
        If Not ($LastSplashText == $Message) Then
            ControlSetText($SplashWindow, "", "Static1", $Message)
            $LastSplashText = $Message
        EndIf
    Else
        HotKeySet("{F4}", "Pause")
        Local $setontop = $DLG_NOTITLE, $leftlocation = $SplashLeft, $toplocation = $SplashTop
        If $ontop Then
            If Not GetValue("NoInputBlocking") Then BlockInput(1)
            $SplashWindowOnTop = 1
            $SplashStartText = Localize("ToStopPressCtrlAltDel") & @CRLF & @CRLF
        Else
            BlockInput(0)
            $SplashWindowOnTop = 0
            $setontop = $DLG_MOVEABLE
            $SplashStartText = Localize("ToStopPressF4") & @CRLF & @CRLF & @CRLF
            $toplocation = 50
        EndIf
        $Message = Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & $SplashStartText & $Message
        $SplashWindow = SplashTextOn("", $Message, GetValue("SplashWidth"), GetValue("SplashHeight"), $leftlocation, $toplocation, $setontop)
        $LastSplashText = $Message
        WinSetOnTop($SplashWindow, "", $ontop)
        If $ontop Then
            Focus()
        Else
            FindWindow()
        EndIf
        If $WinHandle Then WinSetOnTop($WinHandle, "", $ontop)
    EndIf
EndFunc

; add after: If $RestartLoop Then Return 0
Func WaitForScreen($image, $resultPosition = -2, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom)
    While 1
        Position()
        If $RestartLoop Then Return 0
        If ImageSearch($image, $resultPosition, $left, $top, $right, $bottom) Then Return
        FindLogInScreen()
        If $RestartLoop Then Return 0
        Sleep(500)
        TimeOut()
        If $RestartLoop Then Return 0
    WEnd
EndFunc

Func FindPixels($x, $y, $c)
    If $x And Hex(PixelGetColor($x + $OffsetX, $y + $OffsetY), 6) = String($c) Then Return 1
    Return 0
EndFunc

Global $DoLogInCommands = 1

Func ImageSearch($image, $resultPosition = -2, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom)
    If Not FileExists(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & ".png") Then Return 0
    If $DoLogInCommands And $image = "ChangeCharacterButton" Then
        If $DoLogInCommands = 2 Or GetValue("GameMenuKey") = "{ESC}" Then
            Send("{ESC}")
        Else
            Send(GetValue("GameMenuKey"))
        EndIf
        Sleep(1500)
        MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
        If $DoLogInCommands = 1 Then
            $DoLogInCommands = 2
        Else
            $DoLogInCommands = 1
        EndIf
    EndIf
    If _ImageSearchArea(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, GetValue("ImageSearchTolerance")) Then
        If $image <> "LogInScreen" And $image <> "Unavailable" And $image <> "Mismatch" Then
            $LoggingIn = 0
            $LogInTries = 0
            $LastLoginTry = 0
            If $image = "SelectionScreen" Then
                $DoLogInCommands = 1
            ElseIf $DoLogInCommands And $image = "ChangeCharacterButton" Then
                Send("{ESC}")
                If _ImageSearchArea(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, GetValue("ImageSearchTolerance")) Then Return 0
                $DoLogInCommands = 0
            EndIf
        EndIf
        Return 1
    EndIf
    Local $i = 2
    While FileExists(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & $i & ".png")
        If _ImageSearchArea(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & $i & ".png", $resultPosition, $left, $top, $right, $bottom, GetValue("ImageSearchTolerance")) Then
            If $image <> "LogInScreen" And $image <> "Unavailable" And $image <> "Mismatch" Then
                $LoggingIn = 0
                $LogInTries = 0
                $LastLoginTry = 0
                If $image = "SelectionScreen" Then
                    $DoLogInCommands = 1
                ElseIf $DoLogInCommands And $image = "ChangeCharacterButton" Then
                    Send("{ESC}")
                    If _ImageSearchArea(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, GetValue("ImageSearchTolerance")) Then Return 0
                    $DoLogInCommands = 0
                EndIf
            EndIf
            Return 1
        EndIf
        $i += 1
    WEnd
    Return 0
EndFunc

Func ImageExists($image)
    Return FileExists(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & ".png")
EndFunc

Func WaitMinutes($time, $msg)
    Local $t = TimerInit(), $left = $time, $lastmin = 0, $leftover
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

; add after: If $RestartLoop Then Return 0
Func FindLogInScreen()
    If ImageSearch("Idle") And ImageSearch("OK") Then
        AddAccountCountValue("IdleLogout")
        AddCharacterCountInfo("IdleLogout")
        SetAccountValue("FinishedInvoke", 1)
        $FailedInvoke = 0
        Splash()
        MouseMove($_ImageSearchX, $_ImageSearchY)
        DoubleClick()
        Sleep(1000)
    EndIf
    If ImageSearch("LogInScreen") Then
        While 1
            While 1
                $DoRelogCount = 1
                $LoggingIn = 1
                $DoLogInCommands = 1
                If $LastLoginTry And TimerDiff($LastLoginTry) / 1000 >= 60 Then
                    $LogInTries = 0
                    $LastLoginTry = 0
                    Position()
                    If $RestartLoop Then Return 0
                    WaitMinutes(15, "WaitingToRetryLogin")
                Else
                    Splash()
                    Sleep(1000)
                    LogIn()
                    If $RestartLoop Then Return 0
                    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                    Sleep(1000)
                    If ImageExists("SelectionScreen") Then
                        While Not ImageSearch("SelectionScreen")
                            If ImageSearch("ChangeCharacterButton") Then
                                Splash()
                                Sleep(1000)
                                ChangeCharacter()
                                If $RestartLoop Then Return 0
                                Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                                While Not ImageSearch("SelectionScreen")
                                    TimeOut()
                                    If $RestartLoop Then Return 0
                                    If ImageSearch("LogInScreen") Then ExitLoop 3
                                    Sleep(500)
                                WEnd
                                ExitLoop
                            ElseIf ImageSearch("Unavailable") Then
                                $LogInTries = 0
                                Position()
                                If $RestartLoop Then Return 0
                                WaitMinutes(15, "WaitingToRetryLogin")
                                ExitLoop
                            ElseIf ImageSearch("Mismatch") And PatchClient() Then
                                If $RestartLoop Then Return 0
                                ExitLoop
                            EndIf
                            If $RestartLoop Then Return 0
                            TimeOut()
                            If $RestartLoop Then Return 0
                            If ImageSearch("LogInScreen") Then ExitLoop 2
                            Sleep(500)
                        WEnd
                    EndIf
                EndIf
                StartLoop()
                If $RestartLoop Then Return 0
            WEnd
        WEnd
    EndIf
    Return
EndFunc

Func CheckServer()
    Local $ip = Array(GetValue("LogInServerAddress")), $first = 1
    If $ip[1] And IsString($ip[1]) And $ip[1] <> "" Then
        While 1
            For $i = 1 to $ip[0]
                Ping($ip[$i])
                If @error = 0 Then Return
            Next
            If $first Then
                $first = 0
                Splash("[ " & Localize("WaitingForGameServer") & " ]", 0)
            EndIf
            Sleep(10000)
        WEnd
    EndIf
EndFunc

; add after: If $RestartLoop Then Return 0
Func PatchClient()
    If $GameClientInstallLocation And $ArcLauncherLocation And FileExists($GameClientInstallLocation & "\Neverwinter\Live\GameClient.exe") And FileExists($ArcLauncherLocation) Then
        $DisableRelogCount = 1
        $LogInTries = 0
        CheckServer()
        $LogInTries = 0
        Splash("[ " & Localize("PatchingGame") & " ]", 0)
        Local $arc = ProcessExists("Arc.exe"), $auto = RegRead("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "AutoLaunch")
        CloseClient()
        If $RestartLoop Then Return 0
        CloseClient(0, "Neverwinter.exe")
        If $RestartLoop Then Return 0
        If Not Number($auto) Then RegWrite("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "AutoLaunch", "REG_DWORD", 1)
        ShellExecute($ArcLauncherLocation, "gamecustom nw")
        While Not ProcessExists("Neverwinter.exe")
            Sleep(1000)
        WEnd
        If Not $arc Then
            Sleep(1000)
            CloseClient(0, "Arc.exe")
            If $RestartLoop Then Return 0
        EndIf
        While Not ProcessExists("GameClient.exe")
            Sleep(1000)
        WEnd
        Sleep(1000)
        If Not Number($auto) Then RegWrite("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "AutoLaunch", "REG_DWORD", 0)
        CloseClient()
        If $RestartLoop Then Return 0
        Splash("", 0)
        Sleep(1000)
        $GamePatched = 1
        Return 1
    EndIf
    Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func LogIn()
    If GetValue("LogInUserName") And GetValue("LogInPassword") Then
        If $LogInTries >= GetValue("MaxLogInAttempts") Then
            Error(Localize("MaxLoginAttempts"))
            If $RestartLoop Then Return 0
        EndIf
        CheckServer()
        Position()
        If $RestartLoop Then Return 0
        Splash()
        If GetValue("UsernameBoxY") Then
            MouseMove(GetValue("UsernameBoxX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("UsernameBoxY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
        Else
            MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientHeightCenter + Random(-$MouseOffset, $MouseOffset, 1))
        EndIf
        DoubleClick()
        AutoItSetOption("SendKeyDownDelay", 5)
        Send("{RIGHT 254}{BS 254}")
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", 15)
        Send(_SendUnicodeReturn(BinaryToString(GetValue("LogInUserName"), 4)))
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", $KeyDelay)
        Send("{TAB}")
        AutoItSetOption("SendKeyDownDelay", 15)
        Send(_SendUnicodeReturn(BinaryToString(GetValue("LogInPassword"), 4)))
        Sleep(500)
        AutoItSetOption("SendKeyDownDelay", $KeyDelay)
        Send("{ENTER}")
        $LogInTries += 1
        $LastLoginTry = TimerInit()
    Else
        Error(Localize("UsernameAndPasswordNotDefined"))
        If $RestartLoop Then Return 0
    EndIf
EndFunc

; add after: If $RestartLoop Then Return 0
Func TimeOut($r = 0)
    If TimerDiff($WaitingTimer) < $TimeOut Then Return
    AddAccountCountValue("TimedOut")
    If Not $LoggingIn Then AddCharacterCountInfo("TimedOut")
    If Not $r And GetValue("RestartGameClient") And $GameClientInstallLocation And $GameClientInstallLocation <> "" And GetValue("LogInServerAddress") And GetValue("LogInServerAddress") <> "" And GetValue("LogInUserName") And GetValue("LogInPassword") And ImageExists("LogInScreen") And FileExists($GameClientInstallLocation & "\Neverwinter\Live\GameClient.exe") Then
        Splash("[ " & Localize("RestartingNeverwinter") & " ]")
        $DisableRelogCount = 1
        CloseClient(1)
        If $RestartLoop Then Return 0
        Position(1)
        If $RestartLoop Then Return 0
    Else
        Error(Localize("OperationTimedOut"))
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

; add after: If $RestartLoop Then Return 0
Func End()
    If ImageExists("SelectionScreen") And ImageExists("LogInScreen") Then
        Local $check = CheckAccounts()
        If $check > 0 Then
            If $check <> $CurrentAccount Then
                $ETAText = ""
                Position()
                If $RestartLoop Then Return 0
                Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
                If ImageSearch("SelectionScreen") Then
                    MouseMove($_ImageSearchX, $_ImageSearchY)
                    SingleClick()
                    Sleep(1000)
                    $DisableRelogCount = 1
                EndIf
                $CurrentAccount = $check
                $WaitingTimer = TimerInit()
                While Not ImageSearch("LogInScreen")
                    Sleep(500)
                    TimeOut(1)
                    If $RestartLoop Then Return 0
                    Position(1)
                    If $RestartLoop Then Return 0
                WEnd
            EndIf
            StartLoop()
            If $RestartLoop Then Return 0
        EndIf
    EndIf
    Position()
    If $RestartLoop Then Return 0
    Splash()
    If ImageSearch("SelectionScreen") Then
        MouseMove($_ImageSearchX, $_ImageSearchY)
        SingleClick()
        Sleep(1000)
        $DisableRelogCount = 1
    EndIf
    Local $EndTime = HoursAndMinutes(TimerDiff($StartTimer) / 60000)
    $DisableRelogCount = 1
    CloseClient()
    If $RestartLoop Then Return 0
    Splash(0)
    Local $old = $CurrentAccount
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        If CompletedAccount() And GetValue("CurrentLoop") <= GetValue("EndAtLoop") Then
            If GetValue("Current") = GetValue("StartAt") Then
                SetAccountValue("EndAtLoop", GetValue("CurrentLoop") - 1)
            Else
                SetAccountValue("EndAtLoop", GetValue("CurrentLoop"))
            EndIf
        EndIf
        SendMessage(Localize("CompletedInvoking", "<STARTAT>", GetValue("StartAt"), "<ENDAT>", GetValue("EndAt"), "<STARTATLOOP>", GetValue("StartAtLoop"), "<ENDATLOOP>", GetValue("EndAtLoop")) & @CRLF & @CRLF & Localize("InvokingTook", "<MINUTES>", $EndTime))
    Next
    $CurrentAccount = $old
    $LogTime = 0
    Exit
EndFunc

; only call from hot key
Func Pause()
    $LoopStarted = 0
    $RestartLoop = 0
    Message(Localize("Paused"))
    If $RestartLoop Then Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func Error($s)
    Message($s, $MB_ICONWARNING, 1)
    If $RestartLoop Then Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func Message($s, $n = $MB_OK, $ontop = 0)
    If Not $FirstRun And Not CheckAccounts() Then
        End()
        If $RestartLoop Then Return 0
        Exit
    EndIf
    $UnattendedMode = 0
    Splash(0)
    Local $old = $CurrentAccount
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        SendMessage($s, $n, $ontop)
    Next
    $CurrentAccount = $old
    $LogTime = 0
    Start()
    If $RestartLoop Then Return 0
    Exit
EndFunc

Func SendMessage($s, $n = $MB_OK, $ontop = 0)
    $ETAText = ""
    Local $text = "    " & Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & $s
    Local $CofferCount = 0, $ProfessionPackCount = 0, $ElixirOfFateCount = 0, $OverflowXPRewardCount = 0, $VIPAccountRewardCount = 0, $IdleLogoutText = "", $TimedOutText = "", $FailedInvokeText = ""
    For $i = 1 To GetValue("TotalSlots")
        $CofferCount += GetCharacterInfo("TotalCelestialCoffers", $i)
        $ProfessionPackCount += GetCharacterInfo("TotalProfessionPacks", $i)
        $ElixirOfFateCount += GetCharacterInfo("TotalElixirsOfFate", $i)
        $OverflowXPRewardCount += GetCharacterInfo("TotalOverflowXPRewards", $i)
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
    Next
    If $IdleLogoutText <> "" Then $IdleLogoutText = " ( " & $IdleLogoutText & " )"
    If $TimedOutText <> "" Then $TimedOutText = " ( " & $TimedOutText & " )"
    If $FailedInvokeText <> "" Then $FailedInvokeText = " ( " & $FailedInvokeText & " )"
    If GetValue("Invoked") Then
        $text &= @CRLF & @CRLF & Localize("InvokedTimes", "<INVOKED>", GetValue("Invoked"), "<INVOKETOTAL>", GetValue("TotalSlots") * $MaxLoops, "<PERCENT>", Floor((GetValue("Invoked") / (GetValue("TotalSlots") * $MaxLoops)) * 100))
    EndIf
    If $CofferCount Then
        $text &= @CRLF & @CRLF & Localize("CofferCount", "<COUNT>", $CofferCount)
    EndIf
    If $ProfessionPackCount Then
        $text &= @CRLF & @CRLF & Localize("ProfessionPackCount", "<COUNT>", $ProfessionPackCount)
    EndIf
    If $ElixirOfFateCount Then
        $text &= @CRLF & @CRLF & Localize("ElixirOfFateCount", "<COUNT>", $ElixirOfFateCount)
    EndIf
    If $OverflowXPRewardCount Then
        $text &= @CRLF & @CRLF & Localize("OverflowXPRewardCount", "<COUNT>", $OverflowXPRewardCount)
    EndIf
    If $VIPAccountRewardCount Then
        $text &= @CRLF & @CRLF & Localize("VIPAccountRewardCount")
    ElseIf Not GetValue("SkipVIPAccountReward") And GetValue("VIPAccountRewardTries") <> 0 Then
        $text &= @CRLF & @CRLF & Localize("FailedVIPAccountReward")
    EndIf
    If GetValue("IdleLogout") Then
        $text &= @CRLF & @CRLF & Localize("IdleLogoutCount", "<COUNT>", GetValue("IdleLogout")) & $IdleLogoutText
    EndIf
    If GetValue("TimedOut") Then
        $text &= @CRLF & @CRLF & Localize("TimedOutCount", "<COUNT>", GetValue("TimedOut")) & $TimedOutText
    EndIf
    If GetValue("FailedInvoke") Then
        $text &= @CRLF & @CRLF & Localize("FailedInvokeCount", "<COUNT>", GetValue("FailedInvoke")) & $FailedInvokeText
    EndIf
    If $ReLogged Then
        $text &= @CRLF & @CRLF & Localize("ReLoggedCount", "<COUNT>", $ReLogged)
    EndIf
    If $Restarted Then
        $text &= @CRLF & @CRLF & Localize("RestartedCount", "<COUNT>", $Restarted)
    EndIf
    If $GamePatched Then
        $text &= @CRLF & @CRLF & Localize("GamePatched")
    EndIf
    If Not CompletedAccount() Then
        $text &= @CRLF & @CRLF & Localize("Invoking", "<CURRENT>", GetValue("Current"), "<ENDAT>", GetValue("EndAt"), "<CURRENTLOOP>", GetValue("CurrentLoop"), "<ENDATLOOP>", GetValue("EndAtLoop"))
    EndIf
    If $LogDate Then
        If Not FileExists($SettingsDir & "\Logs") Then DirCreate($SettingsDir & "\Logs")
        Local $LogStart = "", $LogEnd = @CRLF
        If $LogSessionStart Then
            $LogStart = @CRLF & Localize("SessionStart") & @CRLF & @CRLF
            $LogSessionStart = 0
        EndIf
        If Not $LogTime Then
            $LogTime = @HOUR & ":" & @MIN & ":" & @SEC
            $LogStart &= @YEAR & "-" & @MON & "-" & @MDAY & " " & $LogTime & @CRLF
        EndIf
        If $CurrentAccount = GetValue("TotalAccounts") Then $LogEnd = @CRLF & @CRLF
        FileWrite($SettingsDir & "\Logs\Log_" & $LogDate & ".txt", $LogStart & StringReplace($text, @CRLF & @CRLF, @CRLF) & $LogEnd)
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

Func ConfigureAccount()
    If CompletedAccount() Then
        Return
    ElseIf MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SkipAccountOptions", "<ACCOUNT>", $CurrentAccount)) = $IDYES Then
        Return
    EndIf
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
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("StartAtEachLoop", "<TOTALSLOTS>", GetValue("TotalSlots")), GetValue("StartAt"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number >= 1 And $number <= GetValue("TotalSlots") Then
            SetAccountValue("StartAt", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EndAtEachLoop", "<STARTAT>", GetValue("StartAt"), "<TOTALSLOTS>", GetValue("TotalSlots")), GetValue("EndAt"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number >= GetValue("StartAt") And $number <= GetValue("TotalSlots") Then
            SetAccountValue("EndAt", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    If GetValue("Current") < GetValue("StartAt") Then
        SetAccountValue("Current", GetValue("StartAt"))
    ElseIf GetValue("Current") > GetValue("EndAt") Then
        SetAccountValue("Current", GetValue("EndAt"))
    EndIf
    While 1
        Local $strNumber = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("StartAtCurrentLoop", "<STARTAT>", GetValue("StartAt"), "<ENDAT>", GetValue("EndAt")), GetValue("Current"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
        If @error <> 0 Then Exit
        Local $number = Floor(Number($strNumber))
        If $number >= GetValue("StartAt") And $number <= GetValue("EndAt") Then
            SetAccountValue("Current", $number)
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
EndFunc

; add after: If $RestartLoop Then Return 0
Func Start()
    If Not $FirstRun And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SkipAllConfigurations", "<NUMBER>", GetValue("TotalAccounts"))) = $IDYES Then
        $SkipAllConfigurations = 1
    EndIf
    If Not $UnattendedMode And Not $SkipAllConfigurations Then
        If Not $FirstRun Then ChooseOptions()
        Local $old = $CurrentAccount
        For $i = 1 To GetValue("TotalAccounts")
            $CurrentAccount = $i
            ConfigureAccount()
            If GetValue("Current") < GetValue("StartAt") Then
                SetAccountValue("Current", GetValue("StartAt"))
            ElseIf GetValue("Current") > GetValue("EndAt") Then
                SetAccountValue("Current", GetValue("EndAt"))
            EndIf
        Next
        $CurrentAccount = $old
    EndIf
    Begin()
    If $RestartLoop Then Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func Begin()
    $SkipAllConfigurations = 0
    If Not $UnattendedMode Then
        If ( $FirstRun Or $MinutesToStart ) And GetValue("UnattendedMode") <> 2 Then
            While 1
                If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("GetMinutesUntilServerReset")) = $IDYES Then
                    Local $m = _GetUTCMinutes(10, 1, True, True, False, $Title)
                    If $m >= 0 Then
                        $MinutesToStart = $m
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
    $FirstRun = 0
    Go()
    If $RestartLoop Then Return 0
EndFunc

; add after: If $RestartLoop Then Return 0
Func Go()
    $UnattendedMode = GetValue("UnattendedMode")
    $LogInTries = 0
    $LoggingIn = 1
    $DoLogInCommands = 1
    $DisableRelogCount = 1
    If $MinutesToStart Then
        Local $t = TimerInit(), $time = $MinutesToStart, $left = $time, $lastmin = 0, $leftover
        Position()
        If $RestartLoop Then Return 0
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
    If Not $LogDate Then $LogDate = @YEAR & "-" & @MON & "-" & @MDAY
    Local $check = CheckAccounts()
    If $check > 0 Then
        $ETAText = ""
        Position()
        If $RestartLoop Then Return 0
        Splash()
        If $check <> $CurrentAccount Then
            Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
            If ImageSearch("SelectionScreen") Then
                MouseMove($_ImageSearchX, $_ImageSearchY)
                SingleClick()
                Sleep(1000)
                $DisableRelogCount = 1
            EndIf
            $CurrentAccount = $check
            $WaitingTimer = TimerInit()
            While Not ImageSearch("LogInScreen")
                Sleep(500)
                TimeOut(1)
                If $RestartLoop Then Return 0
                Position(1)
                If $RestartLoop Then Return 0
            WEnd
        EndIf
    Else
        End()
        If $RestartLoop Then Return 0
        Exit
    EndIf
    If Not $StartTimer Then $StartTimer = TimerInit()
    $DisableRelogCount = 1
    StartLoop()
    If $RestartLoop Then Return 0
EndFunc

Func Initialize()
    Local $old = $CurrentAccount
    For $i = 1 To GetValue("TotalAccounts")
        $CurrentAccount = $i
        SetAccountValue("Current", GetValue("StartAt"))
        SetAccountValue("CurrentLoop", GetValue("StartAtLoop"))
        If Not $UnattendedMode And Not $SkipAllConfigurations Then Load()
        If Not GetValue("EndAt") Then SetAccountValue("EndAt", GetValue("TotalSlots"))
    Next
    $CurrentAccount = $old
EndFunc

Func Load()
    If ImageExists("LogInScreen") Then
        If Not GetValue("LogInUserName") Then
            SetAccountValue("LogInUserName", "")
        EndIf
        While 1
            Local $string = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EnterUsername"), BinaryToString(GetValue("LogInUserName"), 4), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            $string = String(StringToBinary($string, 4))
            If $string And $string <> "" Then
                SetAccountValue("LogInUserName", $string)
                ExitLoop
            EndIf
            If GetIniPrivate("LogInUserName") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeleteUsername")) = $IDYES Then
                SetAccountValue("LogInUserName", "")
                SaveIniPrivate("LogInUserName")
            Else
                MsgBox($MB_ICONWARNING, $Title, Localize("ValidUsername"))
            EndIf
        WEnd
        If BinaryToString(GetIniPrivate("LogInUserName"), 4) <> BinaryToString(GetValue("LogInUserName"), 4) Then
            If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SaveUsername")) = $IDYES Then
                SaveIniPrivate("LogInUserName", GetValue("LogInUserName"))
            Else
                SaveIniPrivate("LogInUserName")
            EndIf
        EndIf
        If Not GetValue("LogInPassword") Then SetAccountValue("LogInPassword", "")
        _Crypt_Startup()
        While 1
            Local $string = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EnterPassword"), BinaryToString(GetValue("LogInPassword"), 4), "*", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            $string = String(StringToBinary($string, 4))
            If $string And $string <> "" Then
                If BinaryToString(GetIniPrivate("LogInPassword"), 4) == BinaryToString($string, 4) Then
                    SetAccountValue("LogInPassword", $string)
                    ExitLoop
                ElseIf GetValue("PasswordHash") Then
                    Local $Hash = Hex(_Crypt_HashData(BinaryToString($string, 4), $CALG_SHA1))
                    If $Hash = GetValue("PasswordHash") Then
                        SetAccountValue("LogInPassword", $string)
                        ExitLoop
                    EndIf
                    MsgBox($MB_ICONWARNING, $Title, Localize("PasswordIncorrect"))
                Else
                    Local $string2 = InputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & Localize("EnterPasswordAgain"), "", "*", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
                    If @error <> 0 Then Exit
                    If $string == String(StringToBinary($string2, 4)) Then
                        SetAccountValue("LogInPassword", $string)
                        If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SavePassword")) = $IDYES Then
                            SaveIniPrivate("LogInPassword", GetValue("LogInPassword"))
                            If GetIniPrivate("PasswordHash") <> "" Then
                                SaveIniPrivate("PasswordHash")
                            EndIf
                        Else
                            SaveIniPrivate("LogInPassword")
                            If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SavePasswordHash")) = $IDYES Then
                                SetAccountValue("PasswordHash", Hex(_Crypt_HashData(BinaryToString(GetValue("LogInPassword"), 4), $CALG_SHA1)))
                                SaveIniPrivate("PasswordHash", GetValue("PasswordHash"))
                            ElseIf GetIniPrivate("PasswordHash") <> "" Then
                                SaveIniPrivate("PasswordHash")
                            EndIf
                        EndIf
                        ExitLoop
                    EndIf
                    MsgBox($MB_ICONWARNING, $Title, Localize("PasswordNotMatch"))
                EndIf
            Else
                If GetIniPrivate("LogInPassword") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeletePassword")) = $IDYES Then
                    SetAccountValue("LogInPassword", "")
                    SaveIniPrivate("LogInPassword")
                ElseIf GetIniPrivate("PasswordHash") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeletePasswordHash")) = $IDYES Then
                    SetAccountValue("PasswordHash")
                    SaveIniPrivate("PasswordHash")
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

Func SetCharacterInfo($name, $value = 0, $character = GetValue("Current"), $account = $CurrentAccount)
    If IsDeclared("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name) Then Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, $value)
    Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, $value, 2)
EndFunc

Func GetCharacterInfo($name, $character = GetValue("Current"), $account = $CurrentAccount)
    If IsDeclared("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name) Then Return Eval("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name)
    Return 0
EndFunc

Func AddCharacterCountInfo($name, $value = 1, $character = GetValue("Current"), $account = $CurrentAccount)
    If IsDeclared("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name) Then Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, GetCharacterInfo($name, $character, $account) + $value)
    Return Assign("ACCOUNT" & $account & "CHARACTER" & $character & "NAME" & $name, GetCharacterInfo($name, $character, $account) + $value, 2)
EndFunc

Func ChooseOptions()
    Local $overflowxpdefault = GetValue("DisableOverflowXPRewardCollection"), $cofferdefault = GetValue("Coffer"), $list = Localize($cofferdefault), $coffers = Array("CofferOfCelestialEnchantments, CofferOfCelestialArtifacts, CofferOfCelestialArtifactEquipment, BlessedProfessionsElementalPack, ElixirOfFate")
    For $i = 1 To $coffers[0]
        If Not ($coffers[$i] == $cofferdefault) Then $list &= "|" & Localize($coffers[$i])
    Next
    Local $hGUI = GUICreate($Title, 320, 170)
    GUICtrlCreateLabel(Localize("ChooseCoffer"), 25, 20, 270)
    Local $hCombo = GUICtrlCreateCombo("", 25, 50, 270)
    GUICtrlSetData(-1, $list, Localize($cofferdefault))
    Local $Checkbox = GUICtrlCreateCheckbox(" " & Localize("CollectOverflowXPRewards"), 25, 95, 270)
    If Not GetValue("DisableOverflowXPRewardCollection") Then GUICtrlSetState(-1, $GUI_CHECKED)
    Local $hButton = GUICtrlCreateButton("OK", 118, 135, 84, -1, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", 214, 135, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $hButton
                Local $CurrCombo = GUICtrlRead($hCombo), $overflowxpdisabled = 1
                If GUICtrlRead($Checkbox) = $GUI_CHECKED Then $overflowxpdisabled = 0
                For $i = 1 To $coffers[0]
                    If Localize($coffers[$i]) == $CurrCombo Then
                        GUIDelete()
                        If Not ($cofferdefault == $coffers[$i]) Then
                            SetValue("Coffer", $coffers[$i])
                            If GetValue("Coffer") == GetDefaultValue("Coffer") Then
                                SaveIniAllAccounts("Coffer")
                            Else
                                SaveIniAllAccounts("Coffer", GetValue("Coffer"))
                            EndIf
                        EndIf
                        If $overflowxpdefault <> $overflowxpdisabled Then
                            SetValue("DisableOverflowXPRewardCollection", $overflowxpdisabled)
                            If GetValue("DisableOverflowXPRewardCollection") == GetDefaultValue("DisableOverflowXPRewardCollection") Then
                                SaveIniAllAccounts("DisableOverflowXPRewardCollection")
                            Else
                                SaveIniAllAccounts("DisableOverflowXPRewardCollection", GetValue("DisableOverflowXPRewardCollection"))
                            EndIf
                        EndIf
                        Return
                    EndIf
                Next
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

Global $AllLoginInfoFound = 1, $SkipAllConfigurations = 0, $FirstRun = 1, $UnattendedMode = 0, $UnattendedModeCheckSettings = 0

Func RunScript()
    If $CmdLine[0] Then
        SetValue("UnattendedMode", Number($CmdLine[1]))
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
    If $AllLoginInfoFound And GetValue("UnattendedMode") <> 2 Then $UnattendedMode = GetValue("UnattendedMode")
    If Not $UnattendedModeCheckSettings And Not GetValue("DisableDonationPrompts") And ( GetAllAccountsValue("TotalInvoked") - GetAllAccountsValue("DonationPrompts") * 2000 ) >= 2000 Then
        Statistics_SaveIniAllAccounts("DonationPrompts", Floor(GetAllAccountsValue("TotalInvoked") / 2000))
        CloseClient(0, "DonationPrompt.exe")
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
                            ShellExecute(@ScriptDir & "\Install.exe")
                            Exit
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
    If Not $UnattendedModeCheckSettings And Not $UnattendedMode And $AllLoginInfoFound And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SkipAllConfigurations", "<NUMBER>", GetValue("TotalAccounts"))) = $IDYES Then $SkipAllConfigurations = 1
    If Not $UnattendedMode And Not $SkipAllConfigurations Then
        ChooseOptions()
        While 1
            Local $strNumber = InputBox($Title, @CRLF & Localize("TotalAccounts"), GetValue("TotalAccounts"), "", GetValue("InputBoxWidth"), GetValue("InputBoxHeight"))
            If @error <> 0 Then Exit
            Local $number = Floor(Number($strNumber))
            If $number > 0 Then
                SetValue("TotalAccounts", $number)
                ExitLoop
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
        WEnd
        If GetIniAllAccounts("TotalAccounts") <> GetValue("TotalAccounts") Then SaveIniAllAccounts("TotalAccounts", GetValue("TotalAccounts"))
    EndIf
    Initialize()
    If $UnattendedModeCheckSettings Then Exit
    Start()
EndFunc

RunScript()
