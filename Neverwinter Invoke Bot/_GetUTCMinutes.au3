#include-once
#include <String.au3>

Local $TimeServer = "time.nist.gov"

Func _GetUTCMinutes($UTCHour = 0, $UTCMinute = 0, $Until = False)
    Local $r = -1
    TCPStartup()
    Local $s = TCPConnect(TCPNameToIP($TimeServer), 37)
    If $s > 0 Then 
        Local $d = TCPRecv($s, 512)
        If $d <> "" Then 
            $d = Asc(StringMid($d,1,1))*256^3+Asc(StringMid($d,2,1))*256^2+Asc(StringMid($d,3,1))*256+Asc(StringMid($d,4,1))
            $r = Floor(((($d/24/60/60)-Floor($d/24/60/60))*24)*60)
            If $UTCHour Or $UTCMinute Then
                Local $t = $UTCHour * 60 + $UTCMinute
                If $r > $t Then
                    $t += 24 * 60
                EndIf
                $r = 24 * 60 - ($t - $r)
            EndIf
            If $Until Then
                $r = 24 * 60 - $r
            EndIf
        EndIf
    EndIf
    TCPCloseSocket($s)
    TCPShutdown()
    Return $r
EndFunc
