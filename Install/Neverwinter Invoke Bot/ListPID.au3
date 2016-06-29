#AutoIt3Wrapper_UseX64=n
#RequireAdmin
If @AutoItX64 Then
    Exit
EndIf
#include <WinAPIProc.au3>
#include <WinAPIFiles.au3>
Local $text = "", $list = ProcessList("GameClient.exe")
If @error = 0 Then
    For $i = 1 To $list[0][0]
        Local $Data = _WinAPI_EnumProcessWindows($list[$i][1], False)
        If @error = 0 Then
            $text &= "PID#" & $list[$i][1] & @CRLF
            For $i2 = 1 To $Data[0][0]
                If WinExists($Data[$i2][0]) Then
                    If $Data[$i2][1] == "CrypticWindowClass" Then
                        $text &= "GameWindowFound: WinHandle = " & $Data[$i2][0] & " WinClass = " & $Data[$i2][1] & @CRLF
                    Else
                        $text &= "WinHandle = " & $Data[$i2][0] & " WinClass = " & $Data[$i2][1] & @CRLF
                    EndIf
                Else
                    $text &= "NotWinExists: WinHandle = " & $Data[$i2][0] & " WinClass = " & $Data[$i2][1] & @CRLF
                EndIf
            Next
            $text &= @CRLF
        EndIf
    Next
    $text = StringRegExpReplace(StringRegExpReplace($text, @CRLF & "$", ""), @CRLF & "$", "")
    FileDelete(@ScriptDir & "\ListPID.txt")
    FileWrite(@ScriptDir & "\ListPID.txt", $text)
    MsgBox(0, "", "Saved to:" & @CRLF & @ScriptDir & "\ListPID.txt" & @CRLF & @CRLF & $text)
EndIf