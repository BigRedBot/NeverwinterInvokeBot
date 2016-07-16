AutoItSetOption("TrayAutoPause", 0)
#include "_GetUTCMinutes.au3"
#include <MsgBoxConstants.au3>
Local $Title = "_GetUTCMinutes_Test"
TraySetToolTip($Title)
Local $min = 0
While 1
    While 1
        If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, "Get minutes until server reset?") = $IDYES Then
            $min = _GetUTCMinutes(10, 1, True, True, True, $Title)
            If $min >= 0 Then ExitLoop
        Else
            Exit
        EndIf
        MsgBox($MB_ICONWARNING, $Title, "Failed to get minutes until server reset!")
    WEnd
    MsgBox($MB_OK, $Title, $_GetUTCMinutes_LastTimeServer & @CRLF & $min & " minutes left until server reset.")
WEnd