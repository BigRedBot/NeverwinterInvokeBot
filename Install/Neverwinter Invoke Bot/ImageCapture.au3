#NoTrayIcon
#RequireAdmin
AutoItSetOption("TrayAutoPause", 0)
Global $Name = "Neverwinter Client Image Capture"
Global $Title = $Name
#include "Shared.au3"
TraySetIcon(@ScriptDir & "\images\purple.ico")
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ImageCaptureAlreadyRunning"))
#include <ScreenCapture.au3>
#include <Clipboard.au3>

Func Position()
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
        Capture()
    EndIf
    If Not GetValue("GameWidth") Or Not GetValue("GameHeight") Then Return
    If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight And ( GetValue("GameWidth") <> $DeskTopWidth Or GetValue("GameHeight") <> $DeskTopHeight ) Then
        MsgBox($MB_ICONWARNING, $Title, Localize("UnMaximize"))
        Exit
    ElseIf $DeskTopWidth < GetValue("GameWidth") Or $DeskTopHeight < GetValue("GameHeight") Then
        MsgBox($MB_ICONWARNING, $Title, Localize("ResolutionOrHigher", "<RESOLUTION>", GetValue("GameWidth") & "x" & GetValue("GameHeight")))
        Exit
    ElseIf $ClientWidth <> GetValue("GameWidth") Or $ClientHeight <> GetValue("GameHeight") Then
        If $DeskTopWidth < GetValue("GameWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Capture()
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0, GetValue("GameWidth") + $PaddingWidth, GetValue("GameHeight") + $PaddingHeight)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Capture()
        EndIf
        If $ClientWidth <> GetValue("GameWidth") Or $ClientHeight <> GetValue("GameHeight") Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToResize"))
            Exit
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterResized"))
        Capture()
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        If $DeskTopWidth < GetValue("GameWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Capture()
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Capture()
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("UnableToMove"))
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterMoved"))
        Capture()
    EndIf
    WinSetOnTop($WinHandle, "", 1)
EndFunc

Func Capture()
    If MsgBox($MB_OKCANCEL, $Title, Localize("ClickOKToCapture")) <> $IDOK Then Exit
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
    If $err Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("ErrorOccuredWith", "<ERROR>", $err_txt), 10)
    MsgBox($MB_OK, $Title, Localize("NeverwinterCaptured"))
    Exit
EndFunc

Capture()
