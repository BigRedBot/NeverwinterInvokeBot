#NoTrayIcon
#RequireAdmin
Global $Name = "Neverwinter Invoke Bot: Mail"
Global $Title = $Name
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Name, Localize("MailAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\teal.ico")
TrayItemSetOnEvent(TrayCreateItem("&Exit"), "ExitScript")
TraySetState($TRAY_ICONSTATE_SHOW)
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

Local $n, $delay, $TakeAndDelete, $mouseX, $mouseY, $leftTake, $topTake, $rightTake, $bottomTake, $leftDelete, $topDelete, $rightDelete, $bottomDelete, $leftOK, $topOK, $rightOK, $bottomOK, $loop

Func Mail()
    While 1
    While 1
        HotKeySet("{Esc}")
        If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
        SplashOff()
        $SplashWindow = 0
        If $loop Then MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TOPMOST, $Title, "	" & $loop)
        If MsgBox($MB_OKCANCEL + $MB_TOPMOST, $Title, Localize("ClickOKToPullItemsFromMail")) <> $IDOK Then ExitScript()
        If Not Position() Then ExitLoop
        HotKeySet("{Esc}", "Mail")
        Splash()
        $leftTake = 0
        $leftDelete = 0
        $leftOK = 0
        $loop = 0
        $delay = 1000
        $TakeAndDelete = 0
        While 1
            $n = 0
            If $leftTake Then
                While Not ImageSearch("Mail_Button_Take_Items", $leftTake, $topTake, $rightTake, $bottomTake)
                    If $n == 15 Then ExitLoop 2
                    Sleep(200)
                    $n += 1
                WEnd
                If ImageSearch("Mail_Button_Delete", $leftDelete, $topDelete, $rightDelete, $bottomDelete) Then
                    $TakeAndDelete = 1
                Else
                    $TakeAndDelete = 0
                EndIf
            Else
                Sleep(500)
                While Not ImageSearch("Mail_Button_Take_Items")
                    If $n == 6 Then ExitLoop 2
                    Sleep(500)
                    $n += 1
                WEnd
                $leftTake = $_ImageSearchLeft
                $topTake = $_ImageSearchTop
                $rightTake = $_ImageSearchRight
                $bottomTake = $_ImageSearchBottom
                $mouseX = $_ImageSearchX
                $mouseY = $_ImageSearchY
                If ImageSearch("Mail_Button_Delete") Then
                    $leftDelete = $_ImageSearchLeft
                    $topDelete = $_ImageSearchTop
                    $rightDelete = $_ImageSearchRight
                    $bottomDelete = $_ImageSearchBottom
                    $TakeAndDelete = 1
                EndIf
            EndIf
            MyMouseMove($mouseX, $mouseY)
            SingleClick()
            While 1
            While 1
                $n = 0
                While ImageSearch("Mail_Button_Take_Items", $leftTake, $topTake, $rightTake, $bottomTake)
                    If $n == 15 Then ExitLoop 4
                    Sleep(200)
                    $n += 1
                WEnd
                $n = 0
                If $leftDelete Then
                    While Not ImageSearch("Mail_Button_Delete", $leftDelete, $topDelete, $rightDelete, $bottomDelete)
                        If $n == 15 Then ExitLoop 4
                        Sleep(200)
                        $n += 1
                    WEnd
                    If Not $Loop Then
                        If $TakeAndDelete Then Sleep(2000)
                        $n = 0
                        While ImageSearch("Mail_Button_Take_Items")
                            If $n == 6 Then ExitLoop 4
                            Sleep(500)
                            $n += 1
                        WEnd
                    ElseIf $TakeAndDelete Then
                        Sleep($delay)
                    EndIf
                Else
                    While Not ImageSearch("Mail_Button_Delete")
                        If $n == 6 Then ExitLoop 4
                        Sleep(500)
                        $n += 1
                    WEnd
                    $leftDelete = $_ImageSearchLeft
                    $topDelete = $_ImageSearchTop
                    $rightDelete = $_ImageSearchRight
                    $bottomDelete = $_ImageSearchBottom
                    If $TakeAndDelete Then Sleep(2000)
                    $n = 0
                    While ImageSearch("Mail_Button_Take_Items")
                        If $n == 6 Then ExitLoop 4
                        Sleep(500)
                        $n += 1
                    WEnd
                EndIf
                Send("{DEL}")
                $n = 0
                If $leftOK Then
                    While Not ImageSearch("OK", $leftOK, $topOK, $rightOK, $bottomOK)
                        If $n == 15 Then
                            If ImageSearch("OK") Then
                                HotKeySet("{Esc}")
                                Send("{ESC}")
                                HotKeySet("{Esc}", "Mail")
                                $n = 0
                                While ImageSearch("OK")
                                    If $n == 6 Then ExitLoop 5
                                    Sleep(500)
                                    $n += 1
                                WEnd
                                $n = 0
                                While ImageSearch("Mail_Button_Take_Items")
                                    If $n == 6 Then ExitLoop 5
                                    Sleep(500)
                                    $n += 1
                                WEnd
                                $delay += 250
                                ExitLoop 2
                            EndIf
                            ExitLoop 4
                        EndIf
                        Sleep(200)
                        $n += 1
                    WEnd
                Else
                    Sleep(500)
                    While Not ImageSearch("OK")
                        If $n == 6 Then
                            If Not ImageSearch("OK") Then ExitLoop 4
                        EndIf
                        Sleep(500)
                        $n += 1
                    WEnd
                    $leftOK = $_ImageSearchLeft
                    $topOK = $_ImageSearchTop
                    $rightOK = $_ImageSearchRight
                    $bottomOK = $_ImageSearchBottom
                EndIf
                $loop += 1
                Splash(@CRLF & $loop)
                Send("{ENTER}")
                Sleep(100)
                Send("{ENTER}")
                ExitLoop 2
            WEnd
            WEnd
        WEnd
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

Mail()
