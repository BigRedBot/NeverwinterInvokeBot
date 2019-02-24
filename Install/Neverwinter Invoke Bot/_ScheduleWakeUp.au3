#include-once
#include <Date.au3>
#include <WinAPIFiles.au3>

Func _ScheduleWakeUp($wake, $buffer = 0, $tn = "Neverwinter Invoke Bot Wake Up")
    Local $epoch = _DateDiff("s", "1970/01/01 00:00:00", _NowCalc())
    Local $w = $wake, $b = $buffer, $minimum = 10
    If $w < $minimum Then $w = $minimum
    If $b > $w - $minimum Then $b = $w - $minimum
    Local $StartTime = _ScheduleWakeUp_EpochToDate($epoch + $w - $b)
    Local $EndTime = _ScheduleWakeUp_EpochToDate($epoch + $w)
    If $b < 1 Then $b = 1

    If Not RunWait('schtasks /query /tn "' & $tn & '"', "", @SW_HIDE) And RunWait('schtasks /delete /tn "' & $tn & '" /f', "", @SW_HIDE) Then Return 0
    Local $XMLFile = @ScriptDir & "\ScheduledWakeUp.xml"
    If FileExists($XMLFile) And Not FileDelete($XMLFile) Then Return 0

    Local $XMLText = _
    '<?xml version="1.0" encoding="UTF-16"?>' & @CRLF & _
    '<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">' & @CRLF & _
    '  <RegistrationInfo>' & @CRLF & _
    '    <Author>SYSTEM</Author>' & @CRLF & _
    '  </RegistrationInfo>' & @CRLF & _
    '  <Triggers>' & @CRLF & _
    '    <TimeTrigger>' & @CRLF & _
    '      <StartBoundary>' & $StartTime & '</StartBoundary>' & @CRLF & _
    '      <EndBoundary>' & $EndTime & '</EndBoundary>' & @CRLF & _
    '      <Enabled>true</Enabled>' & @CRLF & _
    '    </TimeTrigger>' & @CRLF & _
    '  </Triggers>' & @CRLF & _
    '  <Principals>' & @CRLF & _
    '    <Principal id="Author">' & @CRLF & _
    '      <UserId>S-1-5-18</UserId>' & @CRLF & _
    '      <RunLevel>HighestAvailable</RunLevel>' & @CRLF & _
    '    </Principal>' & @CRLF & _
    '  </Principals>' & @CRLF & _
    '  <Settings>' & @CRLF & _
    '    <MultipleInstancesPolicy>StopExisting</MultipleInstancesPolicy>' & @CRLF & _
    '    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>' & @CRLF & _
    '    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>' & @CRLF & _
    '    <AllowHardTerminate>true</AllowHardTerminate>' & @CRLF & _
    '    <StartWhenAvailable>true</StartWhenAvailable>' & @CRLF & _
    '    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>' & @CRLF & _
    '    <IdleSettings>' & @CRLF & _
    '      <StopOnIdleEnd>true</StopOnIdleEnd>' & @CRLF & _
    '      <RestartOnIdle>false</RestartOnIdle>' & @CRLF & _
    '    </IdleSettings>' & @CRLF & _
    '    <AllowStartOnDemand>true</AllowStartOnDemand>' & @CRLF & _
    '    <Enabled>true</Enabled>' & @CRLF & _
    '    <Hidden>false</Hidden>' & @CRLF & _
    '    <RunOnlyIfIdle>false</RunOnlyIfIdle>' & @CRLF & _
    '    <WakeToRun>true</WakeToRun>' & @CRLF & _
    '    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>' & @CRLF & _
    '    <DeleteExpiredTaskAfter>PT0S</DeleteExpiredTaskAfter>' & @CRLF & _
    '    <Priority>7</Priority>' & @CRLF & _
    '  </Settings>' & @CRLF & _
    '  <Actions Context="Author">' & @CRLF & _
    '    <Exec>' & @CRLF & _
    '      <Command>cmd.exe</Command>' & @CRLF & _
    '      <Arguments>/c ping 192.0.2.1 -n 1 -w ' & Int($b * 1000) & ' &gt;nul</Arguments>' & @CRLF & _
    '    </Exec>' & @CRLF & _
    '  </Actions>' & @CRLF & _
    '</Task>'

    If Not FileWrite($XMLFile, $XMLText) Then Return 0
    If RunWait('schtasks /create /xml "' & $XMLFile & '" /tn "' & $tn & '"', "", @SW_HIDE) Then
        FileDelete($XMLFile)
        Return 0
    Else
        FileDelete($XMLFile)
    EndIf
    Return 1
EndFunc

Func _ScheduleWakeUp_Delete($tn = "Neverwinter Invoke Bot Wake Up")
    If Not RunWait('schtasks /query /tn "' & $tn & '"', "", @SW_HIDE) And RunWait('schtasks /delete /tn "' & $tn & '" /f', "", @SW_HIDE) Then Return 0
    Return 1
EndFunc

Func _ScheduleWakeUp_Delete_ExitScript()
    Return _ScheduleWakeUp_Delete("Neverwinter Invoke Bot Wake Up")
EndFunc

;MsgBox(0, "", _ScheduleWakeUp_EpochToDate(_DateDiff("s", "1970/01/01 00:00:00", _NowCalc()), 1, "$1/$2/$3 $4:$5:$6"))
Func _ScheduleWakeUp_EpochToDate($epoch, $local = 0, $format = '$1-$2-$3T$4:$5:$6Z')
    Local $timeAdj = 0
    If Not $local Then
        Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
        $timeAdj = $aSysTimeInfo[1] * 60
        If $aSysTimeInfo[0] = 2 Then $timeAdj += $aSysTimeInfo[7] * 60
    EndIf
    Return StringRegExpReplace(_DateAdd('s', Int($epoch + $timeAdj), '1970/01/01 00:00:00'), '(\d\d\d\d).(\d\d).(\d\d).(\d\d).(\d\d).(\d\d)', $format)
EndFunc
