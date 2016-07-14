Local $a[5] = [4, "208.95.186.167", "208.95.186.168", "208.95.186.96", "patchserver.crypticstudios.com"], $txt = ""
For $i = 1 to $a[0]
    Local $ping = Ping($a[$i])
    If @error <> 0 Then
        $ping = "Failed"
    EndIf
    $txt &= $a[$i] & " = " & $ping & @CRLF
Next
MsgBox(0, "", $txt)