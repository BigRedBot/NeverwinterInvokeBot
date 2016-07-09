Local $a[4] = [3, "208.95.186.167", "208.95.186.168", "208.95.186.96"], $txt = ""
For $i = 1 to $a[0]
    Local $ping = Ping($a[$i])
    If @error <> 0 Then
        $ping = "Failed"
    EndIf
    $txt &= $a[$i] & " = " & $ping & @CRLF
Next
MsgBox(0, "", $txt)