#include-once

Func _AddCommaToNumber($v)
    Local $s = String(Ceiling(Number($v)))
    If StringLen($s) > 3 Then
        $s = StringLeft($s, StringLen($s) - 3) & "," & StringRight($s,3)
        Do
           If Not StringInStr(StringLeft($s, 4), ",") Then
              $s = StringLeft($s, StringInStr($s, ",") - 4) & "," & StringRight($s, StringLen($s) - StringInStr($s, ",") + 4)
           EndIf
        Until StringInStr(StringLeft($s, 4), ",")
    EndIf
    Return $s
EndFunc
