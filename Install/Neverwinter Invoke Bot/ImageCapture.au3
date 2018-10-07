#NoTrayIcon
#RequireAdmin
Global $Name = "Neverwinter Client Image Capture"
Global $Title = $Name
#include "Shared.au3"
If _Singleton("Neverwinter Client Image Capture" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ImageCaptureAlreadyRunning"))
TraySetIcon(@ScriptDir & "\images\purple.ico")
TrayItemSetOnEvent(TrayCreateItem(Localize("Exit")), "ExitScript")
TraySetState($TRAY_ICONSTATE_SHOW)
TraySetToolTip($Title)
#include <ScreenCapture.au3>
#include <Clipboard.au3>

Func ExitScript()
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    Exit
EndFunc

Func Position()
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
        Capture()
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
                Capture()
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
            Capture()
        EndIf
        If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UnableToResize"))
            ExitScript()
        EndIf
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterResized"))
        Capture()
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
                Capture()
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterNotFound"))
            Capture()
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UnableToMove"))
            ExitScript()
        EndIf
        MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("NeverwinterMoved"))
        Capture()
    EndIf
    WinSetOnTop($WinHandle, "", 1)
EndFunc

Func Capture()
    While 1
        If MsgBox($MB_OKCANCEL + $MB_TOPMOST, $Title, Localize("ClickOKToCapture")) <> $IDOK Then ExitScript()
        Position()
        Sleep(500)
        Local $err = False, $err_txt
        Local $hHBITMAP = _ScreenCapture_Capture("", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, False)
        WinSetOnTop($WinHandle, "", 0)
        If Not _ClipBoard_Open(0) Then
            $err = @error
            $err_txt = "_ClipBoard_Open"
        EndIf
        If Not _ClipBoard_Empty() Then
            $err = @error
            $err_txt = "_ClipBoard_Empty"
        EndIf
        If Not _ClipBoard_SetDataEx($hHBITMAP, $CF_BITMAP) Then
            $err = @error
            $err_txt = "_ClipBoard_SetDataEx"
        EndIf
        _ClipBoard_Close()
        _WinAPI_DeleteObject($hHBITMAP)
        If $err Then
            MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ErrorOccuredWith", "<ERROR>", $err_txt), 10)
            ExitScript()
        EndIf
        MsgBox($MB_OK + $MB_TOPMOST, $Title, Localize("NeverwinterCaptured"))
    WEnd
EndFunc

Capture()
