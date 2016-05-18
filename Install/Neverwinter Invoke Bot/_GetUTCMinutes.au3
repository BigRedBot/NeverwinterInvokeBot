#include-once
#include <String.au3>
Func _GetUTCMinutes($Hour = 0, $Minute = 0, $Until = False)
    Local $r = -1
    TCPStartup()
    Local $s = TCPConnect(TCPNameToIP("time.nist.gov"), 37)
    If $s > 0 Then 
        Local $d = TCPRecv($s, 512)
        If $d <> "" Then 
            $d = Asc(StringMid($d,1,1))*256^3+Asc(StringMid($d,2,1))*256^2+Asc(StringMid($d,3,1))*256+Asc(StringMid($d,4,1))
            $r = Floor(((($d/24/60/60)-Floor($d/24/60/60))*24)*60)
            If $Hour Or $Minute Then
                Local $t = $Hour * 60 + $Minute
                If $r > $t Then
                    $t += 24 * 60
                EndIf
                $r = 24 * 60 - ($t - $r)
            EndIf
            If $Until Then
                $r = 24 * 60 - $r
            EndIf
        EndIf
        TCPCloseSocket($s)
    EndIf
    TCPShutdown()
    Return $r
EndFunc