#include "_GetUTCMinutes.au3"
#include <MsgBoxConstants.au3>
Local $t, $h, $m, $s, $TimeZone = -8
Local $Hour = 2
Local $Minute = 0
Local $Second = 0

$t = _GetUTCSeconds($TimeZone, $Hour * 3600 + $Minute * 60 + $Second, True, True, True, "_GetUTCMinutes Test")
$h = Floor($t / 3600)
$m = Floor($t / 60 - $h * 60)
$s = Floor(($t - $h * 3600 - $m * 60))
MsgBox($MB_OK + $MB_TOPMOST, "_GetUTCMinutes Test", "Time Zone: " & $TimeZone & @CRLF & "Until: " & $Hour & " : " & $Minute & " : " & $Second & @CRLF & @CRLF & "Hours: " & $h & @CRLF & "Minutes: " & $m & @CRLF & "Seconds: " & $s)

$t = _GetUTCSeconds($TimeZone, $Hour * 3600 + $Minute * 60 + $Second, False, True, True, "_GetUTCMinutes Test")
$h = Floor($t / 3600)
$m = Floor($t / 60 - $h * 60)
$s = Floor(($t - $h * 3600 - $m * 60))
MsgBox($MB_OK + $MB_TOPMOST, "_GetUTCMinutes Test", "Time Zone: " & $TimeZone & @CRLF & "Since: " & $Hour & " : " & $Minute & " : " & $Second & @CRLF & @CRLF & "Hours: " & $h & @CRLF & "Minutes: " & $m & @CRLF & "Seconds: " & $s)
