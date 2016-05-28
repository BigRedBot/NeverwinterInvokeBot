#RequireAdmin
Global $Name = "Neverwinter Client Image Capture"
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Name, Localize("ImageCaptureAlreadyRunning"))
    Exit
EndIf
#include <ScreenCapture.au3>
#include <Clipboard.au3>
Global $Title = $Name

Func Position()
    Focus()
    If Not $WinFound Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
        Capture()
    EndIf
    If $GameWidth And $GameHeight Then
        If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnMaximize"))
            Exit
        ElseIf $DeskTopWidth <= ($GameWidth + $PaddingLeft) Or $DeskTopHeight <= ($GameHeight + $PaddingTop) Then
            MsgBox($MB_ICONWARNING, $Title, Localize("ResolutionHigherThan", "<RESOLUTION>", ($GameWidth + $PaddingLeft) & "x" & ($GameHeight + $PaddingTop)))
            Exit
        ElseIf $ClientWidth <> $GameWidth Or $ClientHeight <> $GameHeight Then
            WinMove($WinHandle, "", $WinLeft, $WinTop, $GameWidth + $PaddingWidth, $GameHeight + $PaddingHeight)
            If $ClientWidth <> $GameWidth Or $ClientHeight <> $GameHeight Then
                MsgBox($MB_ICONWARNING, $Title, Localize("UnableToResize"))
                Exit
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterResized"))
            Capture()
        ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            WinMove($WinHandle, "", 0, 0)
            If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
                MsgBox($MB_ICONWARNING, $Title, Localize("UnableToMove"))
                Exit
            EndIf
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterMoved"))
            Capture()
        EndIf
    EndIf
EndFunc

Func Capture()
    If MsgBox($MB_OKCANCEL, $Title, Localize("ClickOKToCapture")) <> $IDOK Then
        Exit
    EndIf
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
    If $err Then
        MsgBox($MB_ICONWARNING, $Title, Localize("ErrorOccuredWith", "<ERROR>", $err_txt), 10)
        Exit
    EndIf
    MsgBox($MB_OK, $Title, Localize("NeverwinterCaptured"))
    Exit
EndFunc

Capture()
