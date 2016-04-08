Global $Name = "Neverwinter Client Image Capture"

#include "Shared.au3"
#include <ScreenCapture.au3>
#include <Clipboard.au3>
Global $Title = $Name

Func Position()
    Focus()
    If Not $WinFound Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING, $Title, "Neverwinter window not found!")
        Capture()
    EndIf
    If $GameWidth And $GameHeight Then
        If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight Then
            MsgBox($MB_ICONWARNING, $Title, "Please un-maximize the Neverwinter window!")
            Exit
        ElseIf $DeskTopWidth <= ($GameWidth + $PaddingLeft) Or $DeskTopHeight <= ($GameHeight + $PaddingTop) Then
            MsgBox($MB_ICONWARNING, $Title, "Your screen resolution must be higher than " & ($GameWidth + $PaddingLeft) & "x" & ($GameHeight + $PaddingTop) & "!")
            Exit
        ElseIf $ClientWidth <> $GameWidth Or $ClientHeight <> $GameHeight Then
            WinMove($WinHandle, "", $WinLeft, $WinTop, $GameWidth + $PaddingWidth, $GameHeight + $PaddingHeight)
            MsgBox($MB_ICONWARNING, $Title, "Neverwinter window resized!")
            Capture()
        ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            WinMove($WinHandle, "", 0, 0)
            MsgBox($MB_ICONWARNING, $Title, "Neverwinter window moved!")
            Capture()
        EndIf
    EndIf
EndFunc

Func Capture()
    If MsgBox($MB_OKCANCEL, $Title, "Click OK to capture Neverwinter client screen now.") <> $IDOK Then
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
        $err_txt = "_ClipBoard_Open failed!"
    EndIf
    If Not _ClipBoard_Empty() Then
        $err = @error
        $err_txt = "_ClipBoard_Empty failed!"
    EndIf
    If Not _ClipBoard_SetDataEx($hHBITMAP, $CF_BITMAP) Then
        $err = @error
        $err_txt = "_ClipBoard_SetDataEx failed!"
    EndIf
    _ClipBoard_Close()
    _WinAPI_DeleteObject($hHBITMAP)
    If $err Then
        MsgBox($MB_ICONWARNING, "Error", "An error has occured: " & $err_txt, 10)
        Exit
    EndIf
    MsgBox($MB_OK, $Title, "Neverwinter client screen captured." & @CRLF & @CRLF & "You may now paste the image into an image editor.")
    Exit
EndFunc

Capture()
