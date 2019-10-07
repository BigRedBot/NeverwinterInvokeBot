#include-once
#include <AutoItConstants.au3>
#include <TrayConstants.au3>

Global $_GetUTCMinutes_LastTimeServer

Local $_GetUTCMinutes_TimeServers = "time.google.com, pool.ntp.org, time.nist.gov, 0.pool.ntp.org, 1.pool.ntp.org, 2.pool.ntp.org, 3.pool.ntp.org"

Local $_GetUTCMinutes_TimerDelaySet = TimerInit(), $_GetUTCMinutes_TimeServerArray = StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($_GetUTCMinutes_TimeServers, 8), "^,", ""), ",$", ""), ",")

Func _GetUTCMinutes($TimeZone = 0, $Seconds = 0, $Until = False, $Splash = False, $FlashTrayIcon = False, $title = "")
    Local $r = _GetUTCSeconds($TimeZone, $Seconds, $Until, $Splash, $FlashTrayIcon, $title)
    If $r > 0 Then Return ($r / 60)
    Return $r
EndFunc

Func _GetUTCSeconds($TimeZone = 0, $Seconds = 0, $Until = False, $Splash = False, $FlashTrayIcon = False, $title = "")
    If $FlashTrayIcon Then
        TraySetState($TRAY_ICONSTATE_FLASH)
    EndIf
    Local $r = -1, $data = "", $wait = 5, $t = TimerDiff($_GetUTCMinutes_TimerDelaySet), $txt = Ceiling($wait - $t / 1000) & "...", $lasttxt = $txt, $win
    If $Splash Then
        $win = SplashTextOn($title, $txt & @CRLF, 200, 100, -1, -1, $DLG_MOVEABLE + $DLG_TEXTVCENTER)
    EndIf
    If $title <> "" Then
        TraySetToolTip($title & @CRLF & $txt)
    EndIf
    While $t < $wait * 1000
        $txt = Ceiling($wait - $t / 1000) & "..."
        If Not ($txt == $lasttxt) Then
            If $Splash Then
                ControlSetText($win, "", "Static1", $txt & @CRLF)
            EndIf
            If $title <> "" Then
                TraySetToolTip($title & @CRLF & $txt)
            EndIf
            $lasttxt = $txt
        EndIf
        Sleep(1000)
        $t = TimerDiff($_GetUTCMinutes_TimerDelaySet)
    WEnd
	TCPStartup()
    If @error = 0 Then
        UDPStartup()
        If @error = 0 Then
            $wait = 10
            For $i = 1 To $_GetUTCMinutes_TimeServerArray[0]
                $txt = $_GetUTCMinutes_TimeServerArray[$i]
                If Not ($txt == $lasttxt) Then
                    If $Splash Then
                        ControlSetText($win, "", "Static1", $txt & @CRLF)
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
                                $txt = $_GetUTCMinutes_TimeServerArray[$i]
                                Local $n = ""
                                If $t >= 1000 Then
                                    $n = Ceiling($wait - $t / 1000) & "..."
                                EndIf
                                If Not (($txt & $n) == $lasttxt) Then
                                    If $Splash Then
                                        ControlSetText($win, "", "Static1", $txt & @CRLF & $n)
                                    EndIf
                                    If $title <> "" Then
                                        TraySetToolTip($title & @CRLF & $txt & "   " & $n)
                                    EndIf
                                    $lasttxt = $txt & $n
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
                $data = StringMid($data, 83, 8)
                $data = ( Dec(StringTrimRight($data, 1)) * 16 + Dec(StringRight($data, 1)) + $TimeZone * 3600 - $Seconds ) / 86400
                $r = ( $data - Floor($data) ) * 86400
                If $Until And $r Then $r = 86400 - $r
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
