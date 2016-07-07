#include-once
#include <AutoItConstants.au3>
#include <TrayConstants.au3>

Global $_GetUTCMinutes_LastTimeServer

Local $_GetUTCMinutes_TimeServers = "time.nist.gov, pool.ntp.org, 0.pool.ntp.org, 1.pool.ntp.org, 2.pool.ntp.org, 3.pool.ntp.org"

Local $_GetUTCMinutes_TimerDelaySet = TimerInit(), $_GetUTCMinutes_TimeServerArray = StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($_GetUTCMinutes_TimeServers, 8), "^,", ""), ",$", ""), ",")

Func _GetUTCMinutes($Hour = 0, $Minute = 0, $Until = False, $Splash = False, $FlashTrayIcon = False, $title = "")
    If $FlashTrayIcon Then
        TraySetState($TRAY_ICONSTATE_FLASH)
    EndIf
    Local $r = -1, $data = "", $wait = 5, $t = TimerDiff($_GetUTCMinutes_TimerDelaySet), $txt = Ceiling(5-$t/1000) & "..." & @CRLF, $lasttxt = $txt, $win
    If $Splash Then
        $win = SplashTextOn($title, $txt, 200, 100, -1, -1, $DLG_MOVEABLE + $DLG_TEXTVCENTER)
    EndIf
    If $title <> "" Then
        TraySetToolTip($title & @CRLF & $txt)
    EndIf
    While $t < $wait * 1000
        $txt = Ceiling($wait-$t/1000) & "..." & @CRLF
        If Not ($txt == $lasttxt) Then
            If $Splash Then
                ControlSetText($win, "", "Static1", $txt)
            EndIf
            If $title <> "" Then
                TraySetToolTip($title & @CRLF & $txt)
            EndIf
            $lasttxt = $txt
        EndIf
        Sleep(1000)
        $t = TimerDiff($_GetUTCMinutes_TimerDelaySet)
    WEnd
    Local $r = -1, $data = ""
	TCPStartup()
    If @error = 0 Then
        UDPStartup()
        If @error = 0 Then
            $wait = 10
            For $i = 1 to $_GetUTCMinutes_TimeServerArray[0]
                $txt = $_GetUTCMinutes_TimeServerArray[$i] & @CRLF
                If Not ($txt == $lasttxt) Then
                    If $Splash Then
                        ControlSetText($win, "", "Static1", $txt)
                    EndIf
                    If $title <> "" Then
                        TraySetToolTip($title & @CRLF & $txt)
                    EndIf
                    $lasttxt = $txt
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
                            Local $time = TimerInit()
                            While $data = ""
                                $t = TimerDiff($time)
                                If $t >= $wait * 1000 Then
                                    ExitLoop
                                EndIf
                                $txt = $_GetUTCMinutes_TimeServerArray[$i] & @CRLF
                                If $t >= 1000 Then
                                    $txt &= Ceiling($wait-$t/1000) & "..."
                                EndIf
                                If Not ($txt == $lasttxt) Then
                                    If $Splash Then
                                        ControlSetText($win, "", "Static1", $txt)
                                    EndIf
                                    If $title <> "" Then
                                        TraySetToolTip($title & @CRLF & $txt)
                                    EndIf
                                    $lasttxt = $txt
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
    If $title <> "" Then
        TraySetToolTip($title)
    EndIf
    If $FlashTrayIcon Then
        TraySetState($TRAY_ICONSTATE_STOPFLASH)
    EndIf
    $_GetUTCMinutes_TimerDelaySet = TimerInit()
    Return $r
EndFunc
