#AutoIt3Wrapper_UseX64=n
#RequireAdmin
Global $LoadPrivateSettings = 1
#include "..\variables.au3"
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Name, Localize("AlreadyRunning"))
    Exit
EndIf
#include "_DownloadFile.au3"
#include "_GetUTCMinutes.au3"
#include "_AddCommaToNumber.au3"
#include "ImageSearch.au3"
#include "_SendUnicode.au3"
#include <Crypt.au3>
Global $KeyDelay = $KeyDelaySeconds * 1000
Global $TimeOut = $TimeOutMinutes * 60000
AutoItSetOption("SendKeyDownDelay", $KeyDelay)
Global $Title = $Name & " v" & $Version
Global $MouseOffset = 5

If @AutoItX64 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
    Exit
EndIf

Func Array($x)
    Return StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($x, 8), "^,", ""), ",$", ""), ",")
EndFunc

Global $GameClientInstallLocation = RegRead("HKEY_CURRENT_USER\SOFTWARE\Cryptic\Neverwinter", "InstallLocation")
If @error <> 0 Then
    $GameClientInstallLocation = 0
EndIf

Func GetLogInServerAddressString()
    Local $r = "", $a = Array($LogInServerAddress)
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

Func Position($r = 0)
    Focus()
    If Not $WinFound Or Not GetPosition() Then
        If $RestartGameClient And $GameClientInstallLocation And $GameClientInstallLocation <> "" And $LogInServerAddress And $LogInServerAddress <> "" And $LogInUserName And $LogInPassword And Exists("LogInScreen") And FileExists($GameClientInstallLocation & "\Neverwinter\Live\GameClient.exe") Then
            Splash("[ " & Localize("NeverwinterNotFound") & " ]")
            $WaitingTimer = TimerInit()
            While ProcessExists("GameClient.exe")
                TimeOut($r)
                ProcessWaitClose("GameClient.exe", 60)
                Sleep(500)
            WEnd
            BlockInput(1)
            Splash("[ " & Localize("WaitingForLogInScreen") & " ]")
            FileChangeDir($GameClientInstallLocation & "\Neverwinter\Live")
            
            Run("GameClient.exe" & GetLogInServerAddressString(), $GameClientInstallLocation & "\Neverwinter\Live")
            FileChangeDir(@ScriptDir)
            Sleep(1000)
            Focus()
            While Not $WinFound
                TimeOut($r)
                Focus()
                Sleep(1000)
            WEnd
            If Not $r And $StartTimer Then
                $Restarted += 1
            EndIf
            Position($r)
            WinSetOnTop($WinHandle, "", 1)
            $WaitingTimer = TimerInit()
            While Not ImageSearch("LogInScreen")
                Sleep(500)
                TimeOut($r)
                Position($r)
            WEnd
            Return
        EndIf
        Error(Localize("NeverwinterNotFound"))
    EndIf
    If $GameWidth And $GameHeight Then
        If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight Then
            BlockInput(0)
            WinSetOnTop($WinHandle, "", 0)
            HotKeySet("{F4}")
            SplashOff()
            $SplashWindow = 0
            Error(Localize("UnMaximize"))
            Return
        ElseIf $DeskTopWidth <= ($GameWidth + $PaddingLeft) Or $DeskTopHeight <= ($GameHeight + $PaddingTop) Or ( $DeskTopWidth <= ($GameWidth + $PaddingLeft + $SplashWidth) And $DeskTopHeight <= ($GameHeight + $PaddingTop + $SplashHeight) ) Then
            BlockInput(0)
            WinSetOnTop($WinHandle, "", 0)
            HotKeySet("{F4}")
            SplashOff()
            $SplashWindow = 0
            Error(Localize("ResolutionHigherThan", "<RESOLUTION>", ($GameWidth + $PaddingLeft) & "x" & ($GameHeight + $PaddingTop + $SplashHeight)))
            Return
        EndIf
        If $ClientWidth <> $GameWidth Or $ClientHeight <> $GameHeight Then
            WinMove($WinHandle, "", $WinLeft, $WinTop, $GameWidth + $PaddingWidth, $GameHeight + $PaddingHeight)
            Focus()
            If Not $WinFound Or Not GetPosition() Then
                Position($r)
                Return
            EndIf
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or ( $ClientRight >= $SplashLeft And $ClientBottom >= $SplashTop ) Then
            WinMove($WinHandle, "", 0, 0)
            Focus()
            If Not $WinFound Or Not GetPosition() Then
                Position($r)
                Return
            EndIf
        EndIf
        If $ClientWidth <> $GameWidth Or $ClientHeight <> $GameHeight Then
            Error(Localize("UnableToResize"))
        ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or ( $ClientRight >= $SplashLeft And $ClientBottom >= $SplashTop ) Then
            Error(Localize("UnableToMove"))
        EndIf
    EndIf
EndFunc

Global $Current = $StartAt, $MinutesToStart = 0, $FinishedInvoke = 0, $FinishedLoop = 0, $Invoked = 0, $ReLogged = 0, $LogInTries = 0, $Restarted = 0, $IdleLogout = 0, $TimedOut = 0, $LoopDelayMinutes[7] = [6, 0, 15, 30, 45, 60, 90], $CurrentLoop = $StartAtLoop, $StartTimer, $WaitingTimer, $LoggingIn

Func Loop()
    If $FinishedLoop Then
        $CurrentLoop += $FinishedLoop
        $FinishedLoop = 0
        $Current = $StartAt
        $FinishedInvoke = 0
        $ETAText = ""
    EndIf
    $Current += $FinishedInvoke
    $FinishedInvoke = 0
    If $CurrentLoop > $EndAtLoop Or ( $CurrentLoop > $LoopDelayMinutes[0] And $Invoked = ($TotalSlots * $LoopDelayMinutes[0]) ) Then
        End()
    EndIf
    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
    If Exists("SelectionScreen") Then
        $WaitingTimer = TimerInit()
        WaitForScreen("SelectionScreen")
        $LoggingIn = 0
        $LogInTries = 0
    EndIf
    Position()
    Local $Start = $Current
    For $i = $Start To $EndAt
        $Current = $i
        $FinishedInvoke = 0
        WaitToInvoke()
        Splash()
        Local $LoopTimer = TimerInit()
        Focus()
        MouseMove($SelectCharacterMenuX + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), $SelectCharacterMenuY + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
        DoubleRightClick()
        MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientHeightCenter + Random(-$MouseOffset, $MouseOffset, 1))
        If $Current <= Ceiling($TotalSlots / 2) Then
            If $TopScrollBarX And $TopSelectedCharacterX Then
                For $n = 1 To 2
                    Send("{DOWN}")
                Next
                For $n = 1 To $TotalSlots
                    Send("{UP}")
                    If FindPixels($TopScrollBarX, $TopScrollBarY, $TopScrollBarC) And FindPixels($TopSelectedCharacterX, $TopSelectedCharacterY, $TopSelectedCharacterC) Then
                        ExitLoop
                    EndIf
                Next
            Else
                For $n = 1 To $TotalSlots
                    Send("{UP}")
                Next
            EndIf
            Sleep($KeyDelay)
            For $n = 2 To $Current
                Send("{DOWN}")
                Sleep(50)
            Next
        Else
            If $BottomScrollBarX And $BottomSelectedCharacterX Then
                For $n = 1 To 2
                    Send("{UP}")
                Next
                For $n = 1 To $TotalSlots
                    Send("{DOWN}")
                    If FindPixels($BottomScrollBarX, $BottomScrollBarY, $BottomScrollBarC) And FindPixels($BottomSelectedCharacterX, $BottomSelectedCharacterY, $BottomSelectedCharacterC) Then
                        ExitLoop
                    EndIf
                Next
            Else
                For $n = 1 To $TotalSlots
                    Send("{DOWN}")
                Next
            EndIf
            Sleep($KeyDelay)
            For $n = 1 To ($TotalSlots - $Current)
                Send("{UP}")
                Sleep(50)
            Next
        EndIf
        Sleep(1000)
        Send("{ENTER}")
        If $SafeLogInX Then
            MouseMove($SafeLogInX + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), $SafeLogInY + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
            DoubleClick()
        EndIf
        Splash("[ " & Localize("WaitingForInGameScreen") & " ]")
        If Exists("InGameScreen") Then
            $WaitingTimer = TimerInit()
            WaitForScreen("InGameScreen")
            Splash()
            Sleep($LogInDelaySeconds * 1000)
        Else
            Sleep($LogInSeconds * 1000)
            Splash()
        EndIf
        Sleep(500)
        If ImageSearch("OverflowXPReward") Then
            Send($CursorModeKey)
            Sleep(500)
            MouseMove($X, $Y)
            SingleClick()
            $CollectedOverflowXPRewards[$Current] = 1
            Sleep(1000)
            Send($JumpKey)
            Sleep(500)
        EndIf
        $WaitingTimer = TimerInit()
        Invoke()
        $InvokeTime[$Current] = TimerInit()
        $InvokeLoop[$Current] = $CurrentLoop
        $FinishedInvoke = 1
        If $EndAt = $Current Then
            $FinishedLoop = 1
        EndIf
        $WaitingTimer = TimerInit()
        ChangeCharacter()
        If $EndAt = $Current And $EndAtLoop = $CurrentLoop Then
            ExitLoop
        EndIf
        Local $LogOutTimer = TimerInit()
        Local $RemainingCharacters = $EndAt - $Current
        Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
        If Exists("SelectionScreen") Then
            $WaitingTimer = TimerInit()
            WaitForScreen("SelectionScreen")
            Splash()
        Else
            Sleep($LogOutSeconds * 1000)
            Splash()
        EndIf
        If $FinishedLoop Then
            Loop()
        Else
            Local $AdditionalKeyPressTime = 0, $AddKeyPressTime = 0, $RemoveKeyPressTime = 0
            If $TopScrollBarX And $TopSelectedCharacterX Then
                $AddKeyPressTime = $KeyDelay
            EndIf
            If $BottomScrollBarX And $BottomSelectedCharacterX Then
                $RemoveKeyPressTime = $KeyDelay
            EndIf
            For $n = 1 To $RemainingCharacters
                If $Current + $n <= Ceiling($TotalSlots / 2) Then
                    $AdditionalKeyPressTime += $n * ($KeyDelay + 50) + $AddKeyPressTime
                ElseIf $Current <= Floor($TotalSlots / 2) + 1 Then
                    $AdditionalKeyPressTime -= ($Current + $n - Floor($TotalSlots / 2) + 1) * ($KeyDelay + 50)
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
EndFunc

Func WaitToInvoke()
    Local $LastLoop = $InvokeLoop[$Current]
    If ( $LastLoop And $CurrentLoop > $LastLoop ) Or ( Not $LastLoop And $CurrentLoop > $StartAtLoop ) Then
        Local $Time = $InvokeTime[$Current]
        If Not $Time Then
            $Time = $StartTimer
        EndIf
        Local $i = $CurrentLoop
        If $CurrentLoop > $LoopDelayMinutes[0] Then
            $i = $LoopDelayMinutes[0]
        EndIf
        Local $Minutes = $LoopDelayMinutes[$i] - TimerDiff($Time) / 60000
        If $Minutes > 0 Then
            $ETAText = ""
            Position()
            BlockInput(0)
            WinSetOnTop($WinHandle, "", 0)
            While $Minutes > 0
                Splash("[ " & Localize("WaitingForInvokeDelay", "<MINUTES>", HoursAndMinutes($Minutes)) & " ]", 0)
                Sleep(1000)
                $Minutes = $LoopDelayMinutes[$i] - TimerDiff($Time) / 60000
            WEnd
            Position()
            BlockInput(1)
            WinSetOnTop($WinHandle, "", 1)
            Loop()
        EndIf
    EndIf
EndFunc

Func Invoke()
    If Exists("CongratulationsWindow") Then
        For $n = 1 To 10
            FindLogInScreen()
            Send($InvokeKey)
            Sleep(500)
            If ImageSearch("Invoked") Then
                Return
            EndIf
            For $k = 1 To 10
                If ImageSearch("VaultOfPietyButton") Then
                    GetCoffer()
                    Return
                ElseIf ImageSearch("CongratulationsWindow") Then
                    Sleep(500)
                    If ImageSearch("CongratulationsWindow") Then
                        $Invoked += 1
                        IniWrite($SettingsDir & "\Settings.ini", "Statistics", "TotalInvoked", Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalInvoked", "")) + 1)
                        Return
                    EndIf
                EndIf
                FindLogInScreen()
                Sleep(500)
            Next
        Next
    Else
        For $n = 1 To 3
            Send($InvokeKey)
            Sleep(5000)
        Next
        If ImageSearch("VaultOfPietyButton") Then
            GetCoffer()
        EndIf
    EndIf
EndFunc

Func GetCoffer()
    MouseMove($X, $Y)
    SingleClick()
    Sleep(1000)
    If ImageSearch("CelestialSynergyTab") Then
        MouseMove($X, $Y)
        DoubleClick()
        Sleep(1000)
    EndIf
    If ImageSearch($Coffer) Then
        MouseMove($X, $Y)
        DoubleClick()
        Sleep(1000)
        For $n = 1 To 2
            Send("{ENTER}")
            Sleep(500)
        Next
        $CollectedCoffers[$Current] = 1
    EndIf
    Sleep(1000)
    Send($JumpKey)
    Sleep(500)
    Invoke()
EndFunc

Func ChangeCharacter()
    TimeOut()
    FindLogInScreen()
    Send($JumpKey)
    Sleep(500)
    Send($GameMenuKey)
    Sleep(1500)
    If Exists("ChangeCharacterButton") And Not ImageSearch("ChangeCharacterButton") Then
        MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
        While Not ImageSearch("ChangeCharacterButton")
            TimeOut()
            FindLogInScreen()
            Send("{ESC}")
            Sleep(500)
            Send("{ESC}")
            Sleep(1500)
            MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
            If ImageSearch("ChangeCharacterButton") Then
                Send("{ESC}")
                Sleep(500)
            EndIf
            Send($JumpKey)
            Sleep(500)
            Send($GameMenuKey)
            Sleep(1500)
            MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
        WEnd
    EndIf
    If Exists("ChangeCharacterButton") Then
        MouseMove($X, $Y)
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
    If Exists("ChangeCharacterConfirmation") And Not ImageSearch("ChangeCharacterConfirmation") Then
        Send("{ESC}")
        Sleep(500)
        Send("{ESC}")
        Sleep(1500)
        MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientTop + Round($ClientHeight * 0.60) + Random(-$MouseOffset, $MouseOffset, 1))
        If ImageSearch("ChangeCharacterButton") Then
            Send("{ESC}")
            Sleep(500)
        EndIf
        ChangeCharacter()
        Return
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
        ChangeCharacter()
        Return
    EndIf
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

Global $SplashWindow, $SplashWindowOnTop = 1, $LastSplashText = "", $SplashStartText = "", $ETAText = "", $SplashWidth = 380, $SplashHeight = 165, $SplashLeft = @DesktopWidth - $SplashWidth - 1, $SplashTop = @DesktopHeight - $SplashHeight - 1

Func Splash($s = "", $ontop = 1)
    Local $Message = Localize("Invoking", "<CURRENT>", $Current, "<ENDAT>", $EndAt, "<CURRENTLOOP>", $CurrentLoop, "<ENDATLOOP>", $EndAtLoop) & @CRLF & $s & @CRLF & $ETAText
    If $SplashWindow And $ontop = $SplashWindowOnTop Then
        If Not ($LastSplashText == $Message) Then
            ControlSetText($SplashWindow, "", "Static1", $SplashStartText & $Message)
            $LastSplashText = $Message
        EndIf
    Else
        Local $setontop = $DLG_NOTITLE, $toplocation = $SplashTop, $leftlocation = $SplashLeft
        If $ontop Then
            $SplashWindowOnTop = 1
            $SplashStartText = Localize("ToStopPressCtrlAltDel") & @CRLF & @CRLF
        Else
            $SplashWindowOnTop = 0
            $setontop = $DLG_NOTONTOP + $DLG_MOVEABLE
            $SplashStartText = Localize("ToStopPressF4") & @CRLF & @CRLF & @CRLF
            $toplocation = 30
            $leftlocation = $SplashLeft - 30
        EndIf
        HotKeySet("{F4}", "Pause")
        $SplashWindow = SplashTextOn("", $SplashStartText & $Message, $SplashWidth, $SplashHeight, $leftlocation, $toplocation, $setontop, "", 0)
        $LastSplashText = $Message
    EndIf
EndFunc

Func WaitForScreen($f1 = 0, $f2 = 0)
    #forceref $f1, $f2
    Local $p = @NumParams
    While 1
        Position()
        For $i = 1 To $p
            If ImageSearch(Eval("f" & $i)) Then
                Return
            EndIf
        Next
        FindLogInScreen()
        Sleep(500)
        TimeOut()
    WEnd
EndFunc

Func FindPixels(ByRef $x, ByRef $y, ByRef $c)
    Position()
    If $x And Hex(PixelGetColor($x + $OffsetX, $y + $OffsetY), 6) = String($c) Then
        Return 1
    EndIf
    Return 0
EndFunc

Global $X = 0, $Y = 0, $LogIn = 1
Func ImageSearch($f1 = 0 , $f2 = 0)
    #forceref $f1, $f2
    For $i = 1 To @NumParams
        local $f = Eval("f" & $i)
        If $f And FileExists("images\" & $Language & "\" & $f & ".png") Then
            If _ImageSearchArea("images\" & $Language & "\" & $f & ".png", -2, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $X, $Y, $ImageSearchTolerance) Then
                If $LogIn And $f = "InGameScreen" Then
                    $LogIn = 0
                EndIf
                Return 1
            ElseIf $LogIn And $f = "InGameScreen" Then
                Send($JumpKey)
            EndIf
        EndIf
    Next
    Return 0
EndFunc

Func Exists($f1 = 0, $f2 = 0)
    #forceref $f1, $f2
    For $i = 1 To @NumParams
        local $f = Eval("f" & $i)
        If $f And FileExists("images\" & $Language & "\" & $f & ".png") Then
            Return 1
        EndIf
    Next
    Return 0
EndFunc

Func FindLogInScreen($r = 0)
    If ImageSearch("Idle") Then
        $IdleLogout += 1
        If $IdleLogoutCharacter[$Current] Then
            $IdleLogoutCharacter[$Current] += 1
        Else
            $IdleLogoutCharacter[$Current] = 1
        EndIf
        $FinishedInvoke = 1
        Splash()
        MouseMove($X, $Y)
        DoubleClick()
        Sleep(1000)
        While ImageSearch("Idle")
            TimeOut()
            MouseMove($X, $Y)
            DoubleClick()
            Sleep(1000)
        WEnd
    EndIf
    If ImageSearch("LogInScreen") Then
        $LoggingIn = 1
        $LogIn = 1
        Splash()
        Sleep(1000)
        LogIn()
        Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
        Sleep(1000)
        If Exists("SelectionScreen") Then
            While Not ImageSearch("SelectionScreen")
                If ImageSearch("InGameScreen") Then
                    $LoggingIn = 0
                    $LogInTries = 0
                    Splash()
                    Sleep(1000)
                    ChangeCharacter()
                    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
                    While Not ImageSearch("SelectionScreen")
                        TimeOut()
                        FindLogInScreen()
                        Sleep(500)
                    WEnd
                    ExitLoop
                EndIf
                TimeOut()
                FindLogInScreen()
                Sleep(500)
            WEnd
            $LoggingIn = 0
            $LogInTries = 0
        EndIf
        If Not $r Then
            $ReLogged += 1
            Loop()
        EndIf
    EndIf
EndFunc

Func LogIn()
    If $LogInUserName And $LogInPassword Then
        If $LogInTries >= $MaxLogInAttempts Then
            Error(Localize("MaxLoginAttempts"))
        Else
            Focus()
            If $UsernameBoxY Then
                MouseMove($UsernameBoxX + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), $UsernameBoxY + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
            Else
                MouseMove($ClientWidthCenter + Random(-$MouseOffset, $MouseOffset, 1), $ClientHeightCenter + Random(-$MouseOffset, $MouseOffset, 1))
            EndIf
            DoubleClick()
            AutoItSetOption("SendKeyDownDelay", 5)
            Send("{RIGHT 254}{BS 254}")
            Sleep(500)
            AutoItSetOption("SendKeyDownDelay", 15)
            Send(_SendUnicodeReturn(BinaryToString($LogInUserName, 4)))
            Sleep(500)
            AutoItSetOption("SendKeyDownDelay", $KeyDelay)
            Send("{TAB}")
            AutoItSetOption("SendKeyDownDelay", 15)
            Send(_SendUnicodeReturn(BinaryToString($LogInPassword, 4)))
            Sleep(500)
            AutoItSetOption("SendKeyDownDelay", $KeyDelay)
            Send("{ENTER}")
            $LogInTries += 1
        EndIf
    Else
        Error(Localize("UsernameAndPasswordNotDefined"))
    EndIf
EndFunc

Func TimeOut($r = 0)
    If TimerDiff($WaitingTimer) >= $TimeOut Then
        $TimedOut += 1
        If Not $LoggingIn Then
            If $TimedOutCharacter[$Current] Then
                $TimedOutCharacter[$Current] += 1
            Else
                $TimedOutCharacter[$Current] = 1
            EndIf
        EndIf
        If Not $r And $RestartGameClient And $GameClientInstallLocation And $GameClientInstallLocation <> "" And $LogInServerAddress And $LogInServerAddress <> "" And $LogInUserName And $LogInPassword And Exists("LogInScreen") And FileExists($GameClientInstallLocation & "\Neverwinter\Live\GameClient.exe") Then
            Splash("[ " & Localize("RestartingNeverwinter") & " ]")
            If ProcessExists("GameClient.exe") Then
                ProcessClose("GameClient.exe")
            EndIf
            $WaitingTimer = TimerInit()
            While ProcessExists("GameClient.exe")
                TimeOut(1)
                ProcessWaitClose("GameClient.exe", 60)
                Sleep(500)
            WEnd
            Position(1)
        Else
            Error(Localize("OperationTimedOut"))
        EndIf
    EndIf
EndFunc

Func End()
    Message(Localize("CompletedInvoking", "<STARTAT>", $StartAt, "<ENDAT>", $EndAt, "<STARTATLOOP>", $StartAtLoop, "<ENDATLOOP>", $EndAtLoop) & @CRLF & @CRLF & Localize("InvokingTook", "<MINUTES>", HoursAndMinutes(TimerDiff($StartTimer) / 60000)))
    Exit
EndFunc

Func Pause()
    Message(Localize("Paused"))
    Start()
EndFunc

Func Error($s)
    Message($s, $MB_ICONWARNING, 1)
    Start()
EndFunc

Func Message($s, $n = $MB_OK, $ontop = 0)
    If $FinishedLoop Then
        $CurrentLoop += $FinishedLoop
        $FinishedLoop = 0
        $Current = $StartAt
        $FinishedInvoke = 0
        $ETAText = ""
    EndIf
    $Current += $FinishedInvoke
    $FinishedInvoke = 0
    If $CurrentLoop > $EndAtLoop Or ( $CurrentLoop > $LoopDelayMinutes[0] And $Invoked = ($TotalSlots * $LoopDelayMinutes[0]) ) Then
        If $CurrentLoop <= $EndAtLoop Then
            If $Current = $StartAt Then
                $EndAtLoop = $CurrentLoop - 1
            Else
                $EndAtLoop = $CurrentLoop
            EndIf
        EndIf
        $CurrentLoop = 0
        End()
    EndIf
    BlockInput(0)
    WinSetOnTop($WinHandle, "", 0)
    HotKeySet("{F4}")
    AutoItSetOption("SendKeyDownDelay", $KeyDelay)
    SplashOff()
    $SplashWindow = 0
    $ETAText = ""
    Local $text = $s
    Local $CofferCount = 0, $OverflowXPRewardCount = 0, $TimedOutCharacterText = "", $IdleLogoutCharacterText = ""
    For $i = 1 To $TotalSlots
        If $CollectedCoffers[$i] Then
            $CofferCount += 1
            IniWrite($SettingsDir & "\Settings.ini", "Statistics", "TotalCelestialCoffers", Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalCelestialCoffers", "")) + 1)
        EndIf
        If $CollectedOverflowXPRewards[$i] Then
            $OverflowXPRewardCount += 1
            IniWrite($SettingsDir & "\Settings.ini", "Statistics", "TotalOverflowXPRewards", Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalOverflowXPRewards", "")) + 1)
        EndIf
        If $IdleLogoutCharacter[$i] Then
            Local $times = ""
            If $IdleLogoutCharacter[$i] > 1 Then
                $times = $IdleLogoutCharacter[$i] & "x"
            EndIf
            If $IdleLogoutCharacterText <> "" Then
                $IdleLogoutCharacterText &= ", " & $times & "#" & $i
            Else
                $IdleLogoutCharacterText = $times & "#" & $i
            EndIf
        EndIf
        If $TimedOutCharacter[$i] Then
            Local $times = ""
            If $TimedOutCharacter[$i] > 1 Then
                $times = $TimedOutCharacter[$i] & "x"
            EndIf
            If $TimedOutCharacterText <> "" Then
                $TimedOutCharacterText &= ", " & $times & "#" & $i
            Else
                $TimedOutCharacterText = $times & "#" & $i
            EndIf
        EndIf
    Next
    If $IdleLogoutCharacterText <> "" Then
        $IdleLogoutCharacterText = " ( " & $IdleLogoutCharacterText & " )"
    EndIf
    If $TimedOutCharacterText <> "" Then
        $TimedOutCharacterText = " ( " & $TimedOutCharacterText & " )"
    EndIf
    If $Invoked Then
        $text &= @CRLF & @CRLF & Localize("InvokedTimes", "<INVOKED>", $Invoked, "<INVOKETOTAL>", $TotalSlots * $LoopDelayMinutes[0], "<PERCENT>", Floor(($Invoked / ($TotalSlots * $LoopDelayMinutes[0])) * 100))
    EndIf
    If $CofferCount Then
        $text &= @CRLF & @CRLF & Localize("CofferCount", "<COUNT>", $CofferCount)
    EndIf
    If $OverflowXPRewardCount Then
        $text &= @CRLF & @CRLF & Localize("OverflowXPRewardCount", "<COUNT>", $OverflowXPRewardCount)
    EndIf
    If $ReLogged Then
        $text &= @CRLF & @CRLF & Localize("ReLoggedCount", "<COUNT>", $ReLogged)
    EndIf
    If $Restarted Then
        $text &= @CRLF & @CRLF & Localize("RestartedCount", "<COUNT>", $Restarted)
    EndIf
    If $IdleLogout Then
        $text &= @CRLF & @CRLF & Localize("IdleLogoutCount", "<COUNT>", $IdleLogout) & $IdleLogoutCharacterText
    EndIf
    If $TimedOut Then
        $text &= @CRLF & @CRLF & Localize("TimedOutCount", "<COUNT>", $TimedOut) & $TimedOutCharacterText
    EndIf
    If $ontop Then
        MsgBox($n, $Title, $text, "", WinGetHandle(AutoItWinGetTitle()) * WinSetOnTop(AutoItWinGetTitle(), "", 1))
    Else
        MsgBox($n, $Title, $text)
    EndIf
EndFunc

Func HoursAndMinutes($n)
    Local $All = Ceiling($n)
    Local $Hours = Floor($All / 60)
    Local $Minutes = $All - $Hours * 60
    If $Hours Then
        If $Minutes Then
            Return Localize("HoursMinutes", "<HOURS>", $Hours, "<MINUTES>", $Minutes)
        EndIf
        Return Localize("Hours", "<HOURS>", $Hours)
    EndIf
    Return Localize("Minutes", "<MINUTES>", $Minutes)
EndFunc

Local $FirstRun = 1
Func Start()
    While 1
        Local $strNumber = InputBox($Title, @CRLF & Localize("StartingLoop", "<MAXLOOPS>", $LoopDelayMinutes[0]), $CurrentLoop, "", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= 1 Then
            $StartAtLoop = $number
            $CurrentLoop = $StartAtLoop
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    While 1
        Local $strNumber = InputBox($Title, @CRLF & Localize("EndingLoop", "<STARTATLOOP>", $StartAtLoop), $EndAtLoop, "", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= $StartAtLoop Then
            $EndAtLoop = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    While 1
        Local $strNumber = InputBox($Title, @CRLF & Localize("StartAtEachLoop", "<TOTALSLOTS>", $TotalSlots), $StartAt, "", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= 1 And $number <= $TotalSlots Then
            $StartAt = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    While 1
        Local $strNumber = InputBox($Title, @CRLF & Localize("EndAtEachLoop", "<STARTAT>", $StartAt, "<TOTALSLOTS>", $TotalSlots), $EndAt, "", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= $StartAt And $number <= $TotalSlots Then
            $EndAt = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    If $Current < $StartAt Then
        $Current = $StartAt
    ElseIf $Current > $EndAt Then
        $Current = $EndAt
    EndIf
    While 1
        Local $strNumber = InputBox($Title, @CRLF & Localize("StartAtCurrentLoop", "<STARTAT>", $StartAt, "<ENDAT>", $EndAt), $Current, "", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= $StartAt And $number <= $EndAt Then
            $Current = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    If $FirstRun Or $MinutesToStart Then
        $FirstRun = 0
        Local $Time = 0
        While 1
            If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("GetMinutesUntilServerReset")) = $IDYES Then
                If $Time Then
                    $Time = TimerDiff($Time)
                    If $Time < 5000 Then
                        Sleep(5000 - $Time)
                    EndIf
                EndIf
                Local $m = _GetUTCMinutes(10, 1, True)
                If $m >= 0 Then
                    $MinutesToStart = $m
                    ExitLoop
                EndIf
            Else
                ExitLoop
            EndIf
            $Time = TimerInit()
            MsgBox($MB_ICONWARNING, $Title, Localize("FailedToGetMinutes"))
        WEnd
    EndIf
    While 1
        Local $strNumber = InputBox($Title, @CRLF & Localize("ToStartInvoking"), $MinutesToStart, "", 300, 180)
        If @error <> 0 Then
            Exit
        EndIf
        Local $number = Floor(Number($strNumber))
        If $number >= 0 Then
            $MinutesToStart = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    $StartTimer = 0
    $LogInTries = 0
    $LoggingIn = 1
    $LogIn = 1
    If $MinutesToStart Then
        Local $Time = TimerInit(), $Minutes = $MinutesToStart, $StartingMinutes = $MinutesToStart
        Position()
        BlockInput(0)
        WinSetOnTop($WinHandle, "", 0)
        While $Minutes > 0
            $MinutesToStart = Ceiling($Minutes)
            Splash("[ " & Localize("WaitingToStart", "<MINUTES>", HoursAndMinutes($Minutes)) & " ]", 0)
            Sleep(1000)
            $Minutes = $StartingMinutes - TimerDiff($Time) / 60000
        WEnd
        $MinutesToStart = 0
    EndIf
    BlockInput(1)
    Position()
    WinSetOnTop($WinHandle, "", 1)
    $WaitingTimer = TimerInit()
    FindLogInScreen(1)
    $StartTimer = TimerInit()
    Loop()
EndFunc

If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("CheckForUpdate")) = $IDYES Then
    Local $tmpverfile = _DownloadFile("https://github.com/BigRedBot/NeverwinterInvokeBot/raw/master/version.ini", $Title, "Retrieving current version information...")
    If $tmpverfile Then
        Local $CurrentVersion = IniRead($tmpverfile, "version", "version", "")
        FileDelete($tmpverfile)
        If $CurrentVersion <> "" Then
            If $CurrentVersion = $Version Then
                MsgBox($MB_OK, $Title, Localize("RunningLatestVersion"))
            ElseIf MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("NewerVersionFound", "<VERSION>", $CurrentVersion)) = $IDYES Then
                Local $tmpinstallfile = _DownloadFile("https://github.com/BigRedBot/NeverwinterInvokeBot/raw/master/NeverwinterInvokeBot.exe", $Title, Localize("DownloadingInstaller"))
                If $tmpinstallfile Then
                    FileCopy($tmpinstallfile, @ScriptDir & "\Install.exe", $FC_OVERWRITE)
                    FileDelete($tmpinstallfile)
                    ShellExecute(@ScriptDir & "\Install.exe")
                    Exit
                Else
                    MsgBox($MB_ICONWARNING, $Title, Localize("CouldNotDownloadLatestVersion"))
                EndIf
            EndIf
        Else
            MsgBox($MB_ICONWARNING, $Title, Localize("CouldNotReadCurrentVersionInfo"))
        EndIf
    Else
        MsgBox($MB_ICONWARNING, $Title, Localize("CouldNotDownloadCurrentVersionInfo"))
    EndIf
EndIf

If ( Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalInvoked", "")) - Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "DonationPrompts", "")) * 2352 ) >= 2352 Then
    IniWrite($SettingsDir & "\Settings.ini", "Statistics", "DonationPrompts", Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "DonationPrompts", "")) + 1)
    Local $text = Localize("InvokedTotalTimes", "<COUNT>", _AddCommaToNumber(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalInvoked", "")))
    If Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalCelestialCoffers", "")) Then
        $text &= @CRLF & @CRLF & Localize("TotalCelestialCoffersCollected", "<COUNT>", _AddCommaToNumber(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalCelestialCoffers", "")))
    EndIf
    If Number(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalOverflowXPRewards", "")) Then
        $text &= @CRLF & @CRLF & Localize("TotalOverflowXPRewardsCollected", "<COUNT>", _AddCommaToNumber(IniRead($SettingsDir & "\Settings.ini", "Statistics", "TotalOverflowXPRewards", "")))
    EndIf
    If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, $text & @CRLF & @CRLF & @CRLF & Localize("DonateNow")) = $IDYES Then
        ShellExecute(@ScriptDir & "\Donation.html")
        Exit
    EndIf
EndIf

If Exists("LogInScreen") Then
    If Not $LogInUserName Then
        $LogInUserName = ""
    EndIf
    While 1
        Local $string = InputBox($Title, @CRLF & Localize("EnterUsername"), BinaryToString($LogInUserName, 4), "", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        $string = String(StringToBinary($string, 4))
        If $string And $string <> "" Then
            $LogInUserName = $string
            ExitLoop
        EndIf
        If IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInUserName", "") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeleteUsername")) = $IDYES Then
            $LogInUserName = ""
            IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInUserName", "")
        Else
            MsgBox($MB_ICONWARNING, $Title, Localize("ValidUsername"))
        EndIf
    WEnd
    If BinaryToString(IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInUserName", ""), 4) <> BinaryToString($LogInUserName, 4) Then
        If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SaveUsername")) = $IDYES Then
            IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInUserName", $LogInUserName)
        Else
            IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInUserName", "")
        EndIf
    EndIf
    If Not $LogInPassword Then
        $LogInPassword = ""
    EndIf
    _Crypt_Startup()
    While 1
        Local $string = InputBox($Title, @CRLF & Localize("EnterPassword"), BinaryToString($LogInPassword, 4), "*", "", 140)
        If @error <> 0 Then
            Exit
        EndIf
        $string = String(StringToBinary($string, 4))
        If $string And $string <> "" Then
            If BinaryToString(IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInPassword", ""), 4) == BinaryToString($string, 4) Then
                $LogInPassword = $string
                ExitLoop
            ElseIf $PasswordHash Then
                Local $Hash = Hex(_Crypt_HashData(BinaryToString($string, 4), $CALG_SHA1))
                If $Hash = $PasswordHash Then
                    $LogInPassword = $string
                    ExitLoop
                EndIf
                MsgBox($MB_ICONWARNING, $Title, Localize("PasswordIncorrect"))
            Else
                Local $string2 = InputBox($Title, @CRLF & Localize("EnterPasswordAgain"), "", "*", "", 140)
                If @error <> 0 Then
                    Exit
                EndIf
                If $string == String(StringToBinary($string2, 4)) Then
                    $LogInPassword = $string
                    If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SavePassword")) = $IDYES Then
                        IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInPassword", $LogInPassword)
                        If IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", "") <> "" Then
                            IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", "")
                        EndIf
                    Else
                        IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInPassword", "")
                        If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("SavePasswordHash")) = $IDYES Then
                            $PasswordHash = Hex(_Crypt_HashData(BinaryToString($LogInPassword, 4), $CALG_SHA1))
                            IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", $PasswordHash)
                        ElseIf IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", "") <> "" Then
                            IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", "")
                        EndIf
                    EndIf
                    ExitLoop
                EndIf
                MsgBox($MB_ICONWARNING, $Title, Localize("PasswordNotMatch"))
            EndIf
        Else
            If IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInPassword", "") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeletePassword")) = $IDYES Then
                $LogInPassword = ""
                IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "LogInPassword", "")
            ElseIf IniRead($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", "") <> "" And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("DeletePasswordHash")) = $IDYES Then
                $PasswordHash = 0
                IniWrite($SettingsDir & "\PrivateSettings.ini", "PrivateSettings", "PasswordHash", "")
            Else
                MsgBox($MB_ICONWARNING, $Title, Localize("ValidPassword"))
            EndIf
        EndIf
    WEnd
    _Crypt_Shutdown()
EndIf

While 1
    Local $strNumber = InputBox($Title, @CRLF & Localize("TotalCharacters"), $TotalSlots, "", "", 140)
    If @error <> 0 Then
        Exit
    EndIf
    Local $number = Floor(Number($strNumber))
    If $number > 0 Then
        $TotalSlots = $number
        ExitLoop
    EndIf
    MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
WEnd
If IniRead($SettingsDir & "\Settings.ini", "Settings", "TotalSlots", "") <> $TotalSlots Then
    IniWrite($SettingsDir & "\Settings.ini", "Settings", "TotalSlots", $TotalSlots)
EndIf

If Not $EndAt Then
    $EndAt = $TotalSlots
EndIf

Global $InvokeTime[$TotalSlots + 2], $InvokeLoop[$TotalSlots + 2], $CollectedCoffers[$TotalSlots + 2], $CollectedOverflowXPRewards[$TotalSlots + 2], $TimedOutCharacter[$TotalSlots + 2], $IdleLogoutCharacter[$TotalSlots + 2]

Start()