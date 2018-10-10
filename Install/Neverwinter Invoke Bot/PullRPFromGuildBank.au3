#NoTrayIcon
#RequireAdmin
Global $Name = "Neverwinter Invoke Bot: Pull RP from Guild Bank"
Global $Title = $Name
#include "Shared.au3"
If _Singleton("Neverwinter Invoke Bot: Pull RP from Guild Bank" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Name, Localize("PullRPFromGuildBankAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\teal.ico")
TrayItemSetOnEvent(TrayCreateItem(Localize("Exit")), "ExitScript")
TraySetToolTip($Title)
#include "_ImageSearch.au3"

Func ExitScript()
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    Exit
EndFunc

Local $MouseOffset = 5, $KeyDelay = GetValue("KeyDelaySeconds") * 1000

Func Position()
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
        Return 0
    EndIf
    If Not GetValue("GameClientWidth") Or Not GetValue("GameClientHeight") Then Return
    If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight And ( GetValue("GameClientWidth") <> $DeskTopWidth Or GetValue("GameClientHeight") <> $DeskTopHeight ) Then
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UnMaximize"))
        ExitScript()
    ElseIf $DeskTopWidth < GetValue("GameClientWidth") Or $DeskTopHeight < GetValue("GameClientHeight") Then
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ResolutionOrHigher", "<RESOLUTION>", GetValue("GameClientWidth") & "x" & GetValue("GameClientHeight")))
        ExitScript()
    ElseIf $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
                Return 0
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
            Return 0
        EndIf
        If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UnableToResize"))
            ExitScript()
        EndIf
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterResized"))
        Return 0
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
                Return 0
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
            Return 0
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UnableToMove"))
            ExitScript()
        EndIf
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterMoved"))
        Return 0
    EndIf
    WinSetOnTop($WinHandle, "", 1)
    Return 1
EndFunc

Local $SplashWindow, $LastSplashText = "", $SplashLeft = @DesktopWidth - GetValue("SplashWidth") - 70 - 1, $SplashTop = @DesktopHeight - GetValue("SplashHeight") - 50 - 1

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", Localize("ToStopPressEsc") & @CRLF & @CRLF & $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, Localize("ToStopPressEsc") & @CRLF & @CRLF & $s, GetValue("SplashWidth"), GetValue("SplashHeight"), $SplashLeft, $SplashTop - 50, $DLG_MOVEABLE + $DLG_NOTONTOP)
        $LastSplashText = $s
        WinSetOnTop($SplashWindow, "", 0)
    EndIf
EndFunc

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"))
    If Not FileExists($ImagePath & $image & ".png") Then Return 0
    If _ImageSearch($ImagePath & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists($FullImagePath & $image & "-" & $i & ".png")
        If _ImageSearch($ImagePath & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Local $found, $reset, $rp = StringSplit("Black_Opal|Flawless_Sapphire|Emerald|Greater_Enchanting_Stone|Moderate_Mark_of_Potency|Black_Pearl|Peridot|Moderate_Enchanting_Stone|Lesser_Mark_of_Potency", "|")

Func Pull()
    While 1
    While 1
        HotKeySet("{Esc}")
        If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
        SplashOff()
        $SplashWindow = 0
        If MsgBox($MB_OKCANCEL + $MB_TOPMOST, $Title, Localize("ClickOKToPullRPFromGuildBank")) <> $IDOK Then ExitScript()
        If Not Position() Then ExitLoop
        HotKeySet("{Esc}", "Pull")
        Splash()
        $reset = 1
        For $n = 1 To 2
            For $i = 1 To $rp[0]
                If ImageSearch("SortButton") Then
                    Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop, $right = $_ImageSearchRight, $bottom = $_ImageSearchBottom, $NextRPLeft = $ClientLeft, $NextRPTop = $_ImageSearchBottom, $NextRPTopSecond = $_ImageSearchBottom, $NextRPBottom = $ClientBottom
                    If $reset Then
                        $reset = 0
                        MyMouseMove($left - 20 - Random(0, 100, 1), Random($top, $bottom, 1))
                    EndIf
                    While 1
                        $found = 0
                        If ImageSearch("Item_Half_" & $rp[$i], $NextRPLeft, $NextRPTop, $right + 10, $NextRPBottom) Or ImageSearch("Item_Half_" & $rp[$i], $ClientLeft, $NextRPTopSecond, $right + 10, $ClientBottom) Then $found = 1
                        If $found Then
                            $NextRPLeft = $_ImageSearchRight
                            $NextRPTop = $_ImageSearchTop
                            $NextRPBottom = $_ImageSearchBottom
                            $NextRPTopSecond = $_ImageSearchBottom
                            $reset = 1
                            MyMouseMove($_ImageSearchX, $_ImageSearchY)
                            DoubleClick()
                        Else
                            If $reset Then
                                $reset = 0
                                MyMouseMove($left - 20 - Random(0, 100, 1), Random($top, $bottom, 1))
                            EndIf
                            $found = 0
                            If ImageSearch("Item_Half_" & $rp[$i], $NextRPLeft, $NextRPTop, $right + 10, $NextRPBottom) Or ImageSearch("Item_Half_" & $rp[$i], $ClientLeft, $NextRPTopSecond, $right + 10) Then $found = 1
                            If $found Then
                                $NextRPLeft = $_ImageSearchRight
                                $NextRPTop = $_ImageSearchTop
                                $NextRPBottom = $_ImageSearchBottom
                                $NextRPTopSecond = $_ImageSearchBottom
                                $reset = 1
                                MyMouseMove($_ImageSearchX, $_ImageSearchY)
                                DoubleClick()
                            Else
                                ExitLoop
                            EndIf
                        EndIf
                        While ImageSearch("OpenAnotherOK")
                            Send("99")
                            $reset = 1
                            MyMouseMove($_ImageSearchX, $_ImageSearchY)
                            SingleClick()
                        WEnd
                    WEnd
                EndIf
            Next
        Next
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

If Not CheckUtilityUnlockCode() Then Exit
Pull()
