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
    If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight Then
        MsgBox($MB_ICONWARNING, $Title, Localize("UnMaximize"))
        Exit
    ElseIf $DeskTopWidth < GetValue("GameWidth") Or $DeskTopHeight < GetValue("GameHeight") Then
        MsgBox($MB_ICONWARNING, $Title, Localize("ResolutionOrHigher", "<RESOLUTION>", GetValue("GameWidth") & "x" & GetValue("GameHeight")))
        Exit
    ElseIf $ClientWidth <> GetValue("GameWidth") Or $ClientHeight <> GetValue("GameHeight") Then
        WinMove($WinHandle, "", $WinLeft, $WinTop, GetValue("GameWidth") + $PaddingWidth, GetValue("GameHeight") + $PaddingHeight)
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
        If (GetValue("GameWidth") + $PaddingLeft) <= $DeskTopWidth And (GetValue("GameHeight") + $PaddingTop) <= $DeskTopHeight Then
            WinMove($WinHandle, "", 0, 0)
        ElseIf GetValue("GameWidth") + $PaddingLeft > $DeskTopWidth And GetValue("GameHeight") + $PaddingTop > $DeskTopHeight Then
            WinMove($WinHandle, "", 0 - $PaddingLeft, 0 - $PaddingTop)
        ElseIf GetValue("GameWidth") + $PaddingLeft > $DeskTopWidth Then
            WinMove($WinHandle, "", 0 - $PaddingLeft, 0)
        ElseIf GetValue("GameHeight") + $PaddingTop > $DeskTopHeight Then
            WinMove($WinHandle, "", 0, 0 - $PaddingTop)
        EndIf
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Capture()
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("UnableToMove"))
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterMoved"))
        Capture()
    EndIf
EndFunc

Func Capture()
    If MsgBox($MB_OKCANCEL, $Title, Localize("ClickOKToCapture")) <> $IDOK Then Exit
    Position()
    WinSetOnTop($WinHandle, "", 1)
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
