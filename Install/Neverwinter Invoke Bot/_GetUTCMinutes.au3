#include-once
#include <AutoItConstants.au3>

Global $_GetUTCMinutes_LastTimeServer

Local $_GetUTCMinutes_TimeServers = "time.nist.gov, pool.ntp.org, 0.pool.ntp.org, 1.pool.ntp.org, 2.pool.ntp.org, 3.pool.ntp.org"

Local $_GetUTCMinutes_TimerDelaySet = TimerInit(), $_GetUTCMinutes_TimeServerArray = StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($_GetUTCMinutes_TimeServers, 8), "^,", ""), ",$", ""), ",")

Func _GetUTCMinutes($Hour = 0, $Minute = 0, $Until = False, $Splash = False)
    Local $r = -1, $data = "", $t = TimerDiff($_GetUTCMinutes_TimerDelaySet), $txt, $lasttxt, $w
    If $Splash Then
        $w = SplashTextOn("", Ceiling(5-$t/1000) & "..." & @CRLF, 200, 100, -1, -1, $DLG_MOVEABLE + $DLG_TEXTVCENTER, "", 0)
    EndIf
    While $t < 5000
        If $Splash Then
            $txt = Ceiling(5-$t/1000) & "..." & @CRLF
            If Not ($txt == $lasttxt) Then
                ControlSetText($w, "", "Static1", $txt)
                $lasttxt = $txt
            EndIf
        EndIf
        Sleep(1000)
        $t = TimerDiff($_GetUTCMinutes_TimerDelaySet)
    WEnd
    Local $r = -1, $data = ""
	TCPStartup()
    If @error = 0 Then
        UDPStartup()
        If @error = 0 Then
            For $i = 1 to $_GetUTCMinutes_TimeServerArray[0]
                If $Splash Then
                    $txt = $_GetUTCMinutes_TimeServerArray[$i] & @CRLF
                    If Not ($txt == $lasttxt) Then
                        ControlSetText($w, "", "Static1", $txt)
                        $lasttxt = $txt
                    EndIf
                EndIf
                Local $ip = TCPNameToIP($_GetUTCMinutes_TimeServerArray[$i])
                If $ip <> "" Then
                    Sleep(250)
                    Local $socket = UDPOpen($ip, 123)
                    If @error = 0 Then
                        Local $p = "", $d = "1b0e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                        While $d
                            $p &= Chr(Dec(StringLeft($d, 2)))
                            $d = StringTrimLeft($d, 2)
                        WEnd
                        UDPSend($socket, $p)
                        If @error = 0 Then
                            Local $Time = TimerInit()
                            While $data = ""
                                $t = TimerDiff($Time)
                                If $t >= 5000 Then
                                    ExitLoop
                                EndIf
                                If $Splash Then
                                    $txt = $_GetUTCMinutes_TimeServerArray[$i] & @CRLF & Ceiling(5-$t/1000) & "..."
                                    If Not ($txt == $lasttxt) Then
                                        ControlSetText($w, "", "Static1", $txt)
                                        $lasttxt = $txt
                                    EndIf
                                EndIf
                                Sleep(100)
                                $data = UDPRecv($socket, 100)
                            WEnd
                        EndIf
                    EndIf
                    UDPCloseSocket($socket)
                    If $data <> "" Then
                        $_GetUTCMinutes_LastTimeServer = $_GetUTCMinutes_TimeServerArray[$i]
                        ExitLoop
                    EndIf
                EndIf
                Sleep(250)
            Next
            If $data <> "" Then
                Local $h = StringMid($data, 83, 8)
                $data = Dec(StringTrimRight($h, 1)) * 16 + Dec(StringRight($h, 1))
                $r = Floor(((($data/24/60/60)-Floor($data/24/60/60))*24)*60)
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
        EndIf
        UDPShutdown()
    EndIf
	TCPShutdown()
    If $Splash Then
        SplashOff()
    EndIf
    $_GetUTCMinutes_TimerDelaySet = TimerInit()
    Return $r
EndFunc
