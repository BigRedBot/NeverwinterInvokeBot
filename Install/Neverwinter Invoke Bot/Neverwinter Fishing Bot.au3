#NoTrayIcon
#RequireAdmin
Global $Name = "Neverwinter Fishing Bot"
#include "Shared.au3"
AutoItSetOption("TrayIconHide", 1)
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("FishingBotAlreadyRunning"))
#include "_ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))

Func Position()
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
        Fish()
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
                Fish()
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Fish()
        EndIf
        If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToResize"))
            End()
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterResized"))
        Fish()
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Fish()
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Fish()
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToMove"))
            End()
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterMoved"))
        Fish()
    EndIf
    WinSetOnTop($WinHandle, "", 1)
EndFunc

Local $SplashWindow, $LastSplashText = "", $SplashLeft = @DesktopWidth - GetValue("FishingSplashWidth") - 70 - 1, $SplashTop = @DesktopHeight - GetValue("FishingSplashHeight") - 50 - 1

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", Localize("ToStopPressEsc") & @CRLF & @CRLF & $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, Localize("ToStopPressEsc") & @CRLF & @CRLF & $s, GetValue("FishingSplashWidth"), GetValue("FishingSplashHeight"), $SplashLeft, $SplashTop - 50, $DLG_MOVEABLE + $DLG_NOTONTOP)
        $LastSplashText = $s
        WinSetOnTop($SplashWindow, "", 0)
    EndIf
EndFunc

Local $ImageSearchImage

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("FishingImageTolerance"), $resultPosition = -2)
    $ImageSearchImage = $image
    If Not FileExists("images\" & $Language & "\" & $image & ".png") Then Return 0
    If _ImageSearchArea("images\" & $Language & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists(@ScriptDir & "\images\" & $Language & "\" & $image & "-" & $i & ".png")
        If _ImageSearchArea("images\" & $Language & "\" & $image & "-" & $i & ".png", $resultPosition, $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Local $Catch[4], $Left[4], $Back[4], $Right[4], $Cast[4], $Hook[4], $LeftPressed, $BackPressed, $RightPressed, $MouseLeftPressed, $MouseRightPressed, $Caught, $EndTimer, $EndTime

Func End()
    If $LeftPressed Then Send(GetValue("FishingLeftKeyUp"))
    If $BackPressed Then Send(GetValue("FishingBackKeyUp"))
    If $RightPressed Then Send(GetValue("FishingRightKeyUp"))
    If $MouseLeftPressed Then MouseUp("left")
    If $MouseRightPressed Then MouseUp("right")
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    Exit
EndFunc

Func Fish()
While 1
While 1
    HotKeySet("{Esc}")
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    SplashOff()
    $SplashWindow = 0
    If $LeftPressed Then Send(GetValue("FishingLeftKeyUp"))
    $LeftPressed = 0
    If $BackPressed Then Send(GetValue("FishingBackKeyUp"))
    $BackPressed = 0
    If $RightPressed Then Send(GetValue("FishingRightKeyUp"))
    $RightPressed = 0
    If $MouseLeftPressed Then MouseUp("left")
    $MouseLeftPressed = 0
    If $MouseRightPressed Then MouseUp("right")
    $MouseRightPressed = 0
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
        HotKeySet("{Esc}", "Fish")
        Position()
        Sleep(2000)
        If ImageSearch("Fishing_Catch") Then
            Send(GetValue("CursorModeKey"))
            Sleep(2000)
        EndIf
        If Not ImageSearch("Fishing_Catch_Dimmed") Then ExitLoop 3
        $Catch[0] = $_ImageSearchLeft
        $Catch[1] = $_ImageSearchTop
        $Catch[2] = $_ImageSearchRight
        $Catch[3] = $_ImageSearchBottom
        If ImageSearch("Fishing_Bait") Then
            Send(GetValue("FishingBaitKey"))
            Sleep(2000)
            If ImageSearch("Fishing_Bait") Then ExitLoop 3
        EndIf
        If Not ImageSearch("Fishing_Left_Dimmed") Then ExitLoop 3
        $Left[0] = $_ImageSearchLeft
        $Left[1] = $_ImageSearchTop
        $Left[2] = $_ImageSearchRight
        $Left[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Back_Dimmed") Then ExitLoop 3
        $Back[0] = $_ImageSearchLeft
        $Back[1] = $_ImageSearchTop
        $Back[2] = $_ImageSearchRight
        $Back[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Right_Dimmed") Then ExitLoop 3
        $Right[0] = $_ImageSearchLeft
        $Right[1] = $_ImageSearchTop
        $Right[2] = $_ImageSearchRight
        $Right[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Cast") Then ExitLoop 3
        $Cast[0] = $_ImageSearchLeft
        $Cast[1] = $_ImageSearchTop
        $Cast[2] = $_ImageSearchRight
        $Cast[3] = $_ImageSearchBottom
        If Not ImageSearch("Fishing_Hook_Dimmed") Then ExitLoop 3
        $Hook[0] = $_ImageSearchLeft
        $Hook[1] = $_ImageSearchTop
        $Hook[2] = $_ImageSearchRight
        $Hook[3] = $_ImageSearchBottom
        If Not $EndTimer Then $EndTimer = TimerInit()
        While 1
        While 1
            If $EndTime - TimerDiff($EndTimer) <= 0 Then End()
            Splash(Localize("Waiting"))
            While Not ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3])
                Sleep(Random(100, 500, 1))
            WEnd
            Splash(Localize("Casting"))
            MouseDown("left")
            $MouseLeftPressed = 1
            Sleep(Random(500, 1000, 1))
            While ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3])
                If ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3]) Then ExitLoop 4
                Sleep(Random(500, 1000, 1))
            WEnd
            MouseUp("left")
            $MouseLeftPressed = 0
            Splash(Localize("Fishing"))
            While Not ImageSearch("Fishing_Hook", $Hook[0], $Hook[1], $Hook[2], $Hook[3])
                Sleep(Random(100, 500, 1))
                If ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3]) Then ExitLoop 2
            WEnd
            While ImageSearch("Fishing_Hook", $Hook[0], $Hook[1], $Hook[2], $Hook[3])
                Splash(Localize("Hooking"))
                MouseDown("right")
                $MouseRightPressed = 1
                Sleep(Random(500, 1000, 1))
                If ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3]) Then
                    MouseUp("right")
                    $MouseRightPressed = 0
                    ExitLoop 2
                EndIf
            WEnd
            MouseUp("right")
            $MouseRightPressed = 0
            $Caught = 0
            While Not ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3])
                While ImageSearch("Fishing_Catch", $Catch[0], $Catch[1], $Catch[2], $Catch[3])
                    Send(GetValue("FishingCatchKey"))
                    Splash(Localize("Catching"))
                    $Caught = 1
                    Sleep(Random(500, 1000, 1))
                    If ImageSearch("Fishing_Cast", $Cast[0], $Cast[1], $Cast[2], $Cast[3]) Then ExitLoop 2
                WEnd
                If ImageSearch("Fishing_Left", $Left[0], $Left[1], $Left[2], $Left[3]) Then
                    If $BackPressed Then Send(GetValue("FishingBackKeyUp"))
                    $BackPressed = 0
                    If $RightPressed Then Send(GetValue("FishingRightKeyUp"))
                    $RightPressed = 0
                    If Not $LeftPressed Then Send(GetValue("FishingLeftKeyDown"))
                    $LeftPressed = 1
                    Splash(Localize("ReelingLeft"))
                ElseIf ImageSearch("Fishing_Back", $Back[0], $Back[1], $Back[2], $Back[3]) Then
                    If $LeftPressed Then Send(GetValue("FishingLeftKeyUp"))
                    $LeftPressed = 0
                    If $RightPressed Then Send(GetValue("FishingRightKeyUp"))
                    $RightPressed = 0
                    If Not $BackPressed Then Send(GetValue("FishingBackKeyDown"))
                    $BackPressed = 1
                    Splash(Localize("ReelingBack"))
                ElseIf ImageSearch("Fishing_Right", $Right[0], $Right[1], $Right[2], $Right[3]) Then
                    If $LeftPressed Then Send(GetValue("FishingLeftKeyUp"))
                    $LeftPressed = 0
                    If $BackPressed Then Send(GetValue("FishingBackKeyUp"))
                    $BackPressed = 0
                    If Not $RightPressed Then Send(GetValue("FishingRightKeyDown"))
                    $RightPressed = 1
                    Splash(Localize("ReelingRight"))
                ElseIf $Caught And ImageSearch("Fishing_Left_Dimmed", $Left[0], $Left[1], $Left[2], $Left[3]) And ImageSearch("Fishing_Back_Dimmed", $Back[0], $Back[1], $Back[2], $Back[3]) And ImageSearch("Fishing_Right_Dimmed", $Right[0], $Right[1], $Right[2], $Right[3]) Then
                    Splash(Localize("Waiting"))
                EndIf
                Sleep(Random(100, 500, 1))
            WEnd
            If $LeftPressed Then Send(GetValue("FishingLeftKeyUp"))
            $LeftPressed = 0
            If $BackPressed Then Send(GetValue("FishingBackKeyUp"))
            $BackPressed = 0
            If $RightPressed Then Send(GetValue("FishingRightKeyUp"))
            $RightPressed = 0
        WEnd
        WEnd
    WEnd
    WEnd
WEnd
WEnd
EndFunc

Func AdvancedAllAccountsSettings($hWnd = 0)
    Local $s = ""
    $s &= "|" & "FishingBaitKey,FishingBaitKeyTitle,FishingBaitKeyDescription,Text"
    $s &= "|" & "FishingCatchKey,FishingCatchKeyTitle,FishingCatchKeyDescription,Text"
    $s &= "|" & "FishingLeftKeyDown,FishingLeftKeyDownTitle,FishingLeftKeyDownDescription,Text"
    $s &= "|" & "FishingLeftKeyUp,FishingLeftKeyUpTitle,FishingLeftKeyUpDescription,Text"
    $s &= "|" & "FishingBackKeyDown,FishingBackKeyDownTitle,FishingBackKeyDownDescription,Text"
    $s &= "|" & "FishingBackKeyUp,FishingBackKeyUpTitle,FishingBackKeyUpDescription,Text"
    $s &= "|" & "FishingRightKeyDown,FishingRightKeyDownTitle,FishingRightKeyDownDescription,Text"
    $s &= "|" & "FishingRightKeyUp,FishingRightKeyUpTitle,FishingRightKeyUpDescription,Text"
    Local $a = StringSplit(StringRegExpReplace($s, "^\|+", ""), "|")
    Local $Total = $a[0]
    Local $c[$Total + 1]
    Local $hGui = GUICreate($Title, 600, 420, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
    GUICtrlCreateLabel(Localize("AdvancedSettings"), 160, 20, 100, -1, $SS_RIGHT)
    For $i = 1 To $Total
        $a[$i] = StringSplit($a[$i], ",")
        GUICtrlCreateLabel(Localize(($a[$i])[2]), 0, 23 + $i * 40, 340, -1, $SS_RIGHT)
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
        Local $v = ($a[$i])[1], $gv = GetAllAccountsValue($v), $t = ($a[$i])[4]
        If $t = "Boolean" Or $t = "ReverseBoolean" Then
            $c[$i] = GUICtrlCreateCheckbox(" ", 350, 20 + $i * 40)
            If $t = "Boolean" Then
                If $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            Else
                If Not $gv Then GUICtrlSetState($c[$i], $GUI_CHECKED)
            EndIf
        Else
            $c[$i] = GUICtrlCreateInput($gv, 350, 20 + $i * 40, 155)
        EndIf
        GUICtrlSetTip(-1, Localize(($a[$i])[3], "<DIRECTORY>", $SettingsDir & "\Logs"))
    Next
    Local $ButtonDefaults = GUICtrlCreateButton("Defaults", 40, 60 + $Total * 40, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("OK", 268, 60 + $Total * 40, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", 350, 60 + $Total * 40, 75, 25)
    GUISetState(@SW_SHOW, $hGui)
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $ButtonDefaults
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

AdvancedAllAccountsSettings()
Fish()
