#include-once

;Variables
Local $NTP_IP[4], $NTPIP[4], $NTP_Server[4] = ['time.nist.gov','pool.ntp.org','ntp.amnic.net','ntp.stairweb.de']

;main program
Func _GetUTCMinutes($Hour = 0, $Minute = 0, $Until = False)
    Local $r = -1, $d = ""
    $NTP_IP = call('_GetUTCMinutes_check_internet_connectivity')
    If 	$NTP_IP[0] <> '' Then
        $d = call('_GetUTCMinutes_NTP_Connect', $NTP_Server[0])
    ElseIf $NTP_IP[1] <> '' Then
        $d = call('_GetUTCMinutes_NTP_Connect', $NTP_Server[1])
    ElseIf $NTP_IP[2] <> '' Then
        $d = call('_GetUTCMinutes_NTP_Connect', $NTP_Server[2])
    ElseIf $NTP_IP[3] <> '' Then
        $d = call('_GetUTCMinutes_NTP_Connect', $NTP_Server[3])
    Else
        Return $r
    EndIf
    If $d <> "" Then
        $d = _GetUTCMinutes_UnsignedHexToDec(StringMid($d, 83, 8))
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
    Return $r
EndFunc

;Function to check wich/if servers if you are available to avoid UDP blockage.
Func _GetUTCMinutes_check_internet_connectivity()
	TCPStartup()
		For $i = 0 to 3
			$NTPIP[$i] = TCPNameToIP($NTP_Server[$i])
			Sleep(250)
		Next
	TCPShutdown ()
	Return $NTPIP
EndFunc

;Function to read time from ntp server.
Func _GetUTCMinutes_NTP_Connect($NTP_Server)
	UDPStartup()
	Local $socket = UDPOpen(TCPNameToIP($NTP_Server), 123)
	Local $status = UDPSend($socket, _GetUTCMinutes_MakePacket("1b0e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"))
	Local $data = ""
    Local $Time = TimerInit()
	While $data = ""
		$data = UDPRecv($socket, 100)
        If TimerDiff($Time) >= 15000 Then
            ExitLoop
        EndIf
		Sleep(100)
	WEnd
	UDPCloseSocket($socket)
	UDPShutdown()
	Return $data
EndFunc

;Function to send packet to ntp server
Func _GetUTCMinutes_MakePacket($d)
    Local $p = ""
    While $d
        $p &= Chr(Dec(StringLeft($d, 2)))
        $d = StringTrimLeft($d, 2)
    WEnd
    Return $p
EndFunc

;Function to decript UnsignedHexToDec
Func _GetUTCMinutes_UnsignedHexToDec($n)
    $ones = StringRight($n, 1)
    $n = StringTrimRight($n, 1)
    Return Dec($n) * 16 + Dec($ones)
EndFunc
