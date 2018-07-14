#NoTrayIcon
#RequireAdmin
Global $Name = "Neverwinter Fishing Bot"
Global $Title = $Name
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("FishingBotAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\green.ico")
TrayItemSetOnEvent($TrayExitItem, "End")
AutoItSetOption("TrayIconHide", 0)
TraySetToolTip($Title)
#include "_ImageSearch.au3"

Local $Rank[4], $Bait[4], $Catch[4], $Left[4], $Back[4], $Right[4], $Cast[4], $Hook[4], $LeftPressed, $BackPressed, $RightPressed, $MovePressed, $CastPressed, $HookPressed, $Caught, $EndTimer, $EndTime, $FishingTimer, $LastReelingTime = 0, $MouseOffset = 5, $KeyDelay = GetValue("KeyDelaySeconds") * 1000

Func Position()
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
        Return 0
    EndIf
    If Not GetValue("GameClientWidth") Or Not GetValue("GameClientHeight") Then Return
    If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight And ( GetValue("GameClientWidth") <> $DeskTopWidth Or GetValue("GameClientHeight") <> $DeskTopHeight ) Then
        MsgBox($MB_ICONWARNING, $Title, Localize("UnMaximize"))
        End()
    ElseIf $DeskTopWidth < GetValue("GameClientWidth") Or $DeskTopHeight < GetValue("GameClientHeight") Then
        MsgBox($MB_ICONWARNING, $Title, Localize("ResolutionOrHigher", "<RESOLUTION>", GetValue("GameClientWidth") & "x" & GetValue("GameClientHeight")))
        End()
    ElseIf $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Return 0
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Return 0
        EndIf
        If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToResize"))
            End()
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterResized"))
        Return 0
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Return 0
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Return 0
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToMove"))
            End()
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterMoved"))
        Return 0
    EndIf
    WinSetOnTop($WinHandle, "", 1)
    Return 1
EndFunc

Local $SplashWindow, $LastSplashText = "", $SplashLeft = @DesktopWidth - GetValue("FishingSplashWidth") - 70 - 1, $SplashTop = @DesktopHeight - GetValue("FishingSplashHeight") - 50 - 1

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", Localize("ToStopPressF4") & @CRLF & @CRLF & $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, Localize("ToStopPressF4") & @CRLF & @CRLF & $s, GetValue("FishingSplashWidth"), GetValue("FishingSplashHeight"), $SplashLeft, $SplashTop - 50, $DLG_MOVEABLE + $DLG_NOTONTOP)
        $LastSplashText = $s
        WinSetOnTop($SplashWindow, "", 0)
    EndIf
EndFunc

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("FishingImageTolerance"))
    If Not FileExists("images\" & $Language & "\" & $image & ".png") Then Return 0
    If _ImageSearch("images\" & $Language & "\" & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists(@ScriptDir & "\images\" & $Language & "\" & $image & "-" & $i & ".png")
        If _ImageSearch("images\" & $Language & "\" & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Func ReleaseKeys()
    If $LeftPressed Then MySend(GetValue("FishingLeftKeyUp"))
    $LeftPressed = 0
    If $BackPressed Then MySend(GetValue("FishingBackKeyUp"))
    $BackPressed = 0
    If $RightPressed Then MySend(GetValue("FishingRightKeyUp"))
    $RightPressed = 0
    If $MovePressed Then MySend(GetValue("FishingMoveKeyUp"))
    $MovePressed = 0
    If $CastPressed Then MySend(GetValue("FishingCastKeyUp"))
    $CastPressed = 0
    If $HookPressed Then MySend(GetValue("FishingHookKeyUp"))
    $HookPressed = 0
EndFunc

Func ReelingKeyReady()
    If ImageSearch("Fishing_Back", $Back[0], $Back[1], $Back[2], $Back[3]) Or ImageSearch("Fishing_Left", $Left[0], $Left[1], $Left[2], $Left[3]) Or ImageSearch("Fishing_Right", $Right[0], $Right[1], $Right[2], $Right[3]) Then Return 1
    Return 0
EndFunc

Func ReleaseFish()
    Local $RankFound = 0
    For $i = 1 To 5
        If ImageSearch("Fishing_Rank_" & $i, $Rank[0], $Rank[1], $Rank[2], $Rank[3]) Then
            $RankFound = $i
            ExitLoop
        EndIf
    Next
    If Not GetValue("FishingReleaseRank" & $RankFound) Then Return 0
    If Not $MovePressed Then MySend(GetValue("FishingMoveKeyDown"))
    $MovePressed = 1
    Sleep(Random(400, 500, 1))
    If $MovePressed Then MySend(GetValue("FishingMoveKeyUp"))
    $MovePressed = 0
    Return 1
EndFunc

Func End()
    ReleaseKeys()
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    Exit
EndFunc

Func Fish()
While 1
While 1
    HotKeySet("{F4}")
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    SplashOff()
    $SplashWindow = 0
    ReleaseKeys()
    If $EndTimer Then
        $EndTime = $EndTime - TimerDiff($EndTimer)
        If $EndTime <= 0 Then $EndTime = 8 * 3600000
    ElseIf Not $EndTime Then
        $EndTime = 8 * 3600000
    EndIf
    While 1
        Local $strNumber = InputBox($Title, Localize("ToStartFishing"), Round($EndTime / 3600000, 5))
        If @error <> 0 Then End()
        Local $number = Ceiling(Number($strNumber) * 3600000)
        If $number > 0 And $number < 24 * 3600000 Then
            $EndTimer = 0
            $EndTime = $number
            ExitLoop
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"))
    WEnd
    While 1
    While 1
        HotKeySet("{F4}", "Fish")
        Splash()
        If Not Position() Then ExitLoop 3
        Sleep(GetValue("FishingDelaySeconds") * 1000)
        If Not ImageSearch("Fishing_Catch") And Not ImageSearch("Fishing_Catch_Dimmed") Then ExitLoop 3
        $Catch[0] = $_ImageSearchLeft
        $Catch[1] = $_ImageSearchTop
        $Catch[2] = $_ImageSearchRight
        $Catch[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Left") And Not ImageSearch("Fishing_Left_Dimmed") Then ExitLoop 3
        $Left[0] = $_ImageSearchLeft
        $Left[1] = $_ImageSearchTop
        $Left[2] = $_ImageSearchRight
        $Left[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Back") And Not ImageSearch("Fishing_Back_Dimmed") Then ExitLoop 3
        $Back[0] = $_ImageSearchLeft
        $Back[1] = $_ImageSearchTop
        $Back[2] = $_ImageSearchRight
        $Back[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Right") And Not ImageSearch("Fishing_Right_Dimmed") Then ExitLoop 3
        $Right[0] = $_ImageSearchLeft
        $Right[1] = $_ImageSearchTop
        $Right[2] = $_ImageSearchRight
        $Right[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Cast") And Not ImageSearch("Fishing_Cast_Dimmed") Then ExitLoop 3
        $Cast[0] = $_ImageSearchLeft
        $Cast[1] = $_ImageSearchTop
        $Cast[2] = $_ImageSearchRight
        $Cast[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Hook") And Not ImageSearch("Fishing_Hook_Dimmed") Then ExitLoop 3
        $Hook[0] = $_ImageSearchLeft
        $Hook[1] = $_ImageSearchTop
        $Hook[2] = $_ImageSearchRight
        $Hook[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Bait") And Not ImageSearch("Fishing_Bait_Common") And Not ImageSearch("Fishing_Bait_Common_Dimmed") And Not ImageSearch("Fishing_Bait_Uncommon") And Not ImageSearch("Fishing_Bait_Uncommon_Dimmed") Then ExitLoop 3
        $Bait[0] = $_ImageSearchLeft
        $Bait[1] = $_ImageSearchTop
        $Bait[2] = $_ImageSearchRight
        $Bait[3] = $_ImageSearchBottom
        Local $ReleaseFishEnabled = 0
        For $i = 0 To 5
            If GetValue("FishingReleaseRank" & $i) Then
                $ReleaseFishEnabled = 1
                ExitLoop
            EndIf
        Next
        If $ReleaseFishEnabled Then
            $ReleaseFishEnabled = 0
            For $i = 0 To 5
                If ImageSearch("Fishing_Rank_" & $i) Then
                    $ReleaseFishEnabled = 1
                    ExitLoop
                EndIf
            Next
            If Not $ReleaseFishEnabled Then ExitLoop 3
            $Rank[0] = $_ImageSearchLeft
            $Rank[1] = $_ImageSearchTop
            $Rank[2] = $_ImageSearchRight
            $Rank[3] = $_ImageSearchBottom
        EndIf
        If ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3]) And ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3]) Then
            MySend(GetValue("FishingCursorModeKey"))
            Sleep(GetValue("FishingDelaySeconds") * 1000)
            If ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3]) And ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3]) Then ExitLoop 3
        EndIf
        If ImageSearch("Fishing_Bait", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Then
            Splash(Localize("Baiting"))
            MySend(GetValue("FishingBaitKey"))
            Sleep(GetValue("FishingDelaySeconds") * 1000)
            If Not ImageSearch("Fishing_Bait_Common", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) And Not ImageSearch("Fishing_Bait_Common_Dimmed", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) And Not ImageSearch("Fishing_Bait_Uncommon", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) And Not ImageSearch("Fishing_Bait_Uncommon_Dimmed", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Then ExitLoop 3
        EndIf
        If Not $EndTimer Then $EndTimer = TimerInit()
        While 1
        While 1
            ReleaseKeys()
            If Not ReelingKeyReady() Then
                If $EndTime - TimerDiff($EndTimer) <= 0 Then End()
                If ImageSearch("Fishing_Bait_Blank", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Or ImageSearch("Fishing_Bait", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Then ExitLoop 3
                Splash(Localize("Waiting"))
                $FishingTimer = TimerInit()
                While Not ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3])
                    If ReelingKeyReady() Then ExitLoop 2
                    If 30000 - TimerDiff($FishingTimer) <= 0 Then
                        If Not ReLog() Then ExitLoop 6
                        ExitLoop 4
                    EndIf
                    Sleep(Random(100, 500, 1))
                WEnd
                If ImageSearch("Fishing_Bait_Common", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Then
                    Splash(Localize("BaitingUncommon"))
                    MySend(GetValue("FishingBaitKey"))
                    Sleep(GetValue("FishingDelaySeconds") * 1000)
                EndIf
                Splash(Localize("Casting"))
                If Not $CastPressed Then MySend(GetValue("FishingCastKeyDown"))
                $CastPressed = 1
                Sleep(Random(500, 750, 1))
                If $CastPressed Then MySend(GetValue("FishingCastKeyUp"))
                $CastPressed = 0
                $FishingTimer = TimerInit()
                While Not ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3])
                    If ReelingKeyReady() Then ExitLoop 2
                    If ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3]) Then ExitLoop 6
                    If 10000 - TimerDiff($FishingTimer) <= 0 Then ExitLoop 4
                    Sleep(Random(100, 500, 1))
                WEnd
                Splash(Localize("Fishing"))
                $FishingTimer = TimerInit()
                While Not ImageSearch("Fishing_Hook", $Hook[0], $Hook[1], $Hook[2], $Hook[3])
                    If ReelingKeyReady() Then ExitLoop 2
                    If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then ExitLoop 4
                    Sleep(Random(100, 500, 1))
                WEnd
                If $ReleaseFishEnabled And ReleaseFish() Then ExitLoop 1
                $FishingTimer = TimerInit()
                While ImageSearch("Fishing_Hook", $Hook[0], $Hook[1], $Hook[2], $Hook[3])
                    If ReelingKeyReady() Then ExitLoop 2
                    If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then ExitLoop 4
                    Splash(Localize("Hooking"))
                    If Not $HookPressed Then MySend(GetValue("FishingHookKeyDown"))
                    $HookPressed = 1
                    Sleep(Random(100, 500, 1))
                WEnd
                If $HookPressed Then MySend(GetValue("FishingHookKeyUp"))
                $HookPressed = 0
            EndIf
            $FishingTimer = TimerInit()
            $LastReelingTime = 0
            $Caught = 0
            While 1
                If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then ExitLoop 4
                While ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3])
                    $LastReelingTime = 0
                    If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then ExitLoop 5
                    Splash(Localize("Catching"))
                    MySend(GetValue("FishingCatchKey"))
                    $Caught = 1
                    If ImageSearch("Fishing_Back", $Back[0], $Back[1], $Back[2], $Back[3]) Then
                        If $LeftPressed Then MySend(GetValue("FishingLeftKeyUp"))
                        $LeftPressed = 0
                        If $RightPressed Then MySend(GetValue("FishingRightKeyUp"))
                        $RightPressed = 0
                        If Not $BackPressed Then MySend(GetValue("FishingBackKeyDown"))
                        $BackPressed = 1
                    ElseIf ImageSearch("Fishing_Left", $Left[0], $Left[1], $Left[2], $Left[3]) Then
                        If $BackPressed Then MySend(GetValue("FishingBackKeyUp"))
                        $BackPressed = 0
                        If $RightPressed Then MySend(GetValue("FishingRightKeyUp"))
                        $RightPressed = 0
                        If Not $LeftPressed Then MySend(GetValue("FishingLeftKeyDown"))
                        $LeftPressed = 1
                    ElseIf ImageSearch("Fishing_Right", $Right[0], $Right[1], $Right[2], $Right[3]) Then
                        If $LeftPressed Then MySend(GetValue("FishingLeftKeyUp"))
                        $LeftPressed = 0
                        If $BackPressed Then MySend(GetValue("FishingBackKeyUp"))
                        $BackPressed = 0
                        If Not $RightPressed Then MySend(GetValue("FishingRightKeyDown"))
                        $RightPressed = 1
                    EndIf
                    Sleep(Random(500, 1000, 1))
                WEnd
                If ImageSearch("Fishing_Back", $Back[0], $Back[1], $Back[2], $Back[3]) Then
                    $LastReelingTime = 0
                    Splash(Localize("ReelingBack"))
                    If $LeftPressed Then MySend(GetValue("FishingLeftKeyUp"))
                    $LeftPressed = 0
                    If $RightPressed Then MySend(GetValue("FishingRightKeyUp"))
                    $RightPressed = 0
                    If Not $BackPressed Then MySend(GetValue("FishingBackKeyDown"))
                    $BackPressed = 1
                ElseIf ImageSearch("Fishing_Left", $Left[0], $Left[1], $Left[2], $Left[3]) Then
                    $LastReelingTime = 0
                    Splash(Localize("ReelingLeft"))
                    If $BackPressed Then MySend(GetValue("FishingBackKeyUp"))
                    $BackPressed = 0
                    If $RightPressed Then MySend(GetValue("FishingRightKeyUp"))
                    $RightPressed = 0
                    If Not $LeftPressed Then MySend(GetValue("FishingLeftKeyDown"))
                    $LeftPressed = 1
                ElseIf ImageSearch("Fishing_Right", $Right[0], $Right[1], $Right[2], $Right[3]) Then
                    $LastReelingTime = 0
                    Splash(Localize("ReelingRight"))
                    If $LeftPressed Then MySend(GetValue("FishingLeftKeyUp"))
                    $LeftPressed = 0
                    If $BackPressed Then MySend(GetValue("FishingBackKeyUp"))
                    $BackPressed = 0
                    If Not $RightPressed Then MySend(GetValue("FishingRightKeyDown"))
                    $RightPressed = 1
                Else
                    If $Caught And ImageSearch("Fishing_Bait_Blank", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Or ImageSearch("Fishing_Bait", $Bait[0], $Bait[1], $Bait[2], $Bait[3]) Then ExitLoop 4
                    If ImageSearch("Fishing_Left_Dimmed", $Left[0], $Left[1], $Left[2], $Left[3]) And ImageSearch("Fishing_Back_Dimmed", $Back[0], $Back[1], $Back[2], $Back[3]) And ImageSearch("Fishing_Right_Dimmed", $Right[0], $Right[1], $Right[2], $Right[3]) Then
                        If Not $LastReelingTime Then
                            Splash(Localize("Waiting"))
                            $LastReelingTime = TimerInit()
                        EndIf
                        If $Caught Or 5000 - TimerDiff($LastReelingTime) <= 0 Then ExitLoop 1
                    EndIf
                EndIf
                Sleep(Random(100, 500, 1))
            WEnd
        WEnd
        WEnd
    WEnd
    WEnd
WEnd
WEnd
EndFunc

Func Settings($hWnd = 0)
    Local $s = ""
    $s &= "|" & "FishingReleaseRank1,FishingReleaseRank1Title,FishingReleaseRank1Description,Boolean"
    $s &= "|" & "FishingReleaseRank2,FishingReleaseRank2Title,FishingReleaseRank2Description,Boolean"
    $s &= "|" & "FishingReleaseRank3,FishingReleaseRank3Title,FishingReleaseRank3Description,Boolean"
    $s &= "|" & "FishingReleaseRank4,FishingReleaseRank4Title,FishingReleaseRank4Description,Boolean"
    $s &= "|" & "FishingReleaseRank5,FishingReleaseRank5Title,FishingReleaseRank5Description,Boolean"
    $s &= "|" & "FishingReleaseRank0,FishingReleaseRank0Title,FishingReleaseRank0Description,Boolean"
    Local $a = StringSplit(StringRegExpReplace($s, "^\|+", ""), "|")
    Local $Total = $a[0]
    Local $c[$Total + 1]
    Local $hGui = GUICreate($Title, 400, 100 + $Total * 36, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
    GUICtrlCreateLabel(Localize("Settings"), 20, 20, 100, -1, $SS_RIGHT)
    For $i = 1 To $Total
        $a[$i] = StringSplit($a[$i], ",")
        GUICtrlCreateLabel(Localize(($a[$i])[2]), 0, 23 + $i * 36, 200, -1, $SS_RIGHT)
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
        Local $v = ($a[$i])[1], $gv = GetAllAccountsValue($v), $t = ($a[$i])[4]
        If $t = "Boolean" Or $t = "ReverseBoolean" Then
            $c[$i] = GUICtrlCreateCheckbox(" ", 210, 20 + $i * 36)
            If $t = "Boolean" Then
                If $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            Else
                If Not $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            EndIf
        Else
            $c[$i] = GUICtrlCreateInput($gv, 210, 20 + $i * 36, 155)
        EndIf
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
    Next
    Local $ButtonDefault = GUICtrlCreateButton(Localize("Default"), 20, 64 + $Total * 36, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 128, 64 + $Total * 36, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 210, 64 + $Total * 36, 75, 25)
    Local $ButtonAdvanced = GUICtrlCreateButton(Localize("Advanced"), 310, 64 + $Total * 36, 75, 25)
    GUISetState(@SW_SHOW, $hGui)
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                End()
            Case $ButtonAdvanced
                AdvancedSettings($hGui)
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
                        If $t = "Number" Then
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
                End()
        EndSwitch
    WEnd
    GUIDelete($hGUI)
EndFunc

Func AdvancedSettings($hWnd = 0)
    Local $s = ""
    $s &= "|" & "FishingBaitKey,FishingBaitKeyTitle,FishingBaitKeyDescription,Text"
    $s &= "|" & "FishingCatchKey,FishingCatchKeyTitle,FishingCatchKeyDescription,Text"
    $s &= "|" & "FishingCastKeyDown,FishingCastKeyDownTitle,FishingCastKeyDownDescription,Text"
    $s &= "|" & "FishingCastKeyUp,FishingCastKeyUpTitle,FishingCastKeyUpDescription,Text"
    $s &= "|" & "FishingHookKeyDown,FishingHookKeyDownTitle,FishingHookKeyDownDescription,Text"
    $s &= "|" & "FishingHookKeyUp,FishingHookKeyUpTitle,FishingHookKeyUpDescription,Text"
    $s &= "|" & "FishingLeftKeyDown,FishingLeftKeyDownTitle,FishingLeftKeyDownDescription,Text"
    $s &= "|" & "FishingLeftKeyUp,FishingLeftKeyUpTitle,FishingLeftKeyUpDescription,Text"
    $s &= "|" & "FishingBackKeyDown,FishingBackKeyDownTitle,FishingBackKeyDownDescription,Text"
    $s &= "|" & "FishingBackKeyUp,FishingBackKeyUpTitle,FishingBackKeyUpDescription,Text"
    $s &= "|" & "FishingRightKeyDown,FishingRightKeyDownTitle,FishingRightKeyDownDescription,Text"
    $s &= "|" & "FishingRightKeyUp,FishingRightKeyUpTitle,FishingRightKeyUpDescription,Text"
    $s &= "|" & "FishingMoveKeyDown,FishingMoveKeyDownTitle,FishingMoveKeyDownDescription,Text"
    $s &= "|" & "FishingMoveKeyUp,FishingMoveKeyUpTitle,FishingMoveKeyUpDescription,Text"
    $s &= "|" & "FishingCursorModeKey,CursorModeKeyTitle,CursorModeKeyDescription,Text"
    $s &= "|" & "FishingTimeOutMinutes,TimeOutMinutesTitle,TimeOutMinutesDescription,Number"
    $s &= "|" & "FishingDelaySeconds,FishingDelaySecondsTitle,FishingDelaySecondsDescription,Number"
    Local $a = StringSplit(StringRegExpReplace($s, "^\|+", ""), "|")
    Local $Total = $a[0]
    Local $c[$Total + 1]
    Local $hGui = GUICreate($Title, 600, 100 + $Total * 36, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
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
    Local $ButtonDefault = GUICtrlCreateButton(Localize("Default"), 40, 64 + $Total * 36, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 268, 64 + $Total * 36, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 350, 64 + $Total * 36, 75, 25)
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
                        If $t = "Number" Then
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

Func ReLog()
    If Not ChangeCharacter() Then Return 0
    Splash("[ " & Localize("WaitingForCharacterSelectionScreen") & " ]")
    $FishingTimer = TimerInit()
    While 1
        If Not Position() Then Return 0
        If ImageSearch("SelectionScreen", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then ExitLoop
        ;FindLogInScreen()
        Sleep(500)
        If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then Return 0
    WEnd
    MyMouseMove(GetValue("CharacterSelectionMenuX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("CharacterSelectionMenuY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
    DoubleRightClick()
    Sleep(1000)
    Send("{ENTER}")
    Sleep(1000)
    If GetValue("SafeLoginX") Then
        MyMouseMove(GetValue("SafeLoginX") + $OffsetX + Random(-$MouseOffset, $MouseOffset, 1), GetValue("SafeLoginY") + $OffsetY + Random(-$MouseOffset, $MouseOffset, 1))
        DoubleClick()
    EndIf
    Splash("[ " & Localize("WaitingForInGameScreen") & " ]")
    $FishingTimer = TimerInit()
    While 1
        If Not Position() Then Return 0
        If ImageSearch("Fishing_Catch_Dimmed", $Catch[0], $Catch[1], $Catch[2], $Catch[3], GetValue("ImageTolerance")) Or ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3], GetValue("ImageTolerance")) Then ExitLoop
        ;FindLogInScreen()
        Sleep(500)
        If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then Return 0
    WEnd
    Sleep(GetValue("LogInDelaySeconds") * 1000)
    Return 1
EndFunc

Global $AlternateLogInCommands = 1

Func SearchForChangeCharacterButton()
    If ImageSearch("ChangeCharacterButton", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then Return 1
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
    If ImageSearch("ChangeCharacterButton", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then Return 1
    Return 0
EndFunc

Func WaitForChangeCharacterButton()
    $AlternateLogInCommands = 1
    While Not SearchForChangeCharacterButton()
        If GetValue("FishingTimeOutMinutes") * 60000 - TimerDiff($FishingTimer) <= 0 Then Return 0
        ;FindLogInScreen()
    WEnd
    Return 1
EndFunc

Func ChangeCharacter()
    $FishingTimer = TimerInit()
While 1
While 1
    If Not WaitForChangeCharacterButton() Then Return 0
    MyMouseMove($_ImageSearchX, $_ImageSearchY)
    DoubleClick()
    Sleep(500)
    If Not ImageSearch("OK", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then
        Send("{ESC}")
        Sleep(500)
        Send("{ESC}")
        Sleep(1500)
        If ImageSearch("ChangeCharacterButton", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then
            Send("{ESC}")
            Sleep(500)
        EndIf
        ExitLoop
    EndIf
    For $n = 1 To 4
        Send("{ENTER}")
        Sleep(500)
    Next
    If ImageSearch("OK", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then
        Send("{ESC}")
        Sleep(500)
        Send("{ESC}")
        Sleep(1500)
        If ImageSearch("ChangeCharacterButton", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, GetValue("ImageTolerance")) Then
            Send("{ESC}")
            Sleep(500)
        EndIf
        ExitLoop
    EndIf
Return 1
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

Settings()
Fish()
