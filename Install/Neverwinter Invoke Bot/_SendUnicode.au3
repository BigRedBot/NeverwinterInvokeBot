#include-once
#include <String.au3>
;======================================================
;
; Function Name:    _SendUnicode("string")
; Description:    Send a unicode or an ASCII string.
; Parameter(s):  $string is the string you want to send.
; Requirement(s):   String Input.
; Return Value(s):  String converted into ASC code.
; Author(s):        Robie Zhou (robiezhou@gmail.com)
;
;======================================================

Func _SendUnicode($string)
    Send(_SendUnicodeReturn($string))
    Sleep(500)
EndFunc

Func _SendUnicodeReturn($string)
    Local $char
    Local $code
    Local $send = ""
    For $i = 1 to StringLen($string)
        $char = StringMid($string, $i, 1)
        $code = Asc($char)
        If $code > 127 Then
            $code = $code * 256
            $i  = $i + 1
            $char = StringMid($string, $i, 1)
            $code = $code + Asc($char)
        EndIf
        $send &= "{ASC " & $code & "}"
    Next
    Return $send
EndFunc