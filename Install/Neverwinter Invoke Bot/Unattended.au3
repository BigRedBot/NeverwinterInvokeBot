#NoTrayIcon
#RequireAdmin
#include "..\variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include <Timers.au3>
#include "_GetUTCMinutes.au3"
#include "_UnicodeIni.au3"
#include "Localization.au3"
Global $Title = $Name & " " & $Version & ": Unattended Launcher"
LoadLocalizations()
If _Singleton($Name & ": Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("UnattendedAlreadyRunning"))
Local $CanRun = 1, $Ran
AutoItSetOption("TrayAutoPause", 0)
AutoItSetOption("TrayMenuMode", 3)
AutoItSetOption("TrayOnEventMode", 1)
Local $RunNowItem = TrayCreateItem(Localize("RunNow"))
TrayItemSetOnEvent($RunNowItem, "RunNow")
TrayCreateItem("")
Local $DoProfessionsItem = TrayCreateItem(Localize("DoProfessions"))
TrayItemSetOnEvent($DoProfessionsItem, "DoProfessions")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem("&Exit"), "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "RunNow")
TraySetState($TRAY_ICONSTATE_SHOW)
TraySetToolTip($Title)

Func ExitScript()
    Exit
EndFunc

Func RunInvokeBot($n, $noflash = 1)
    If Not $CanRun Then Return
    $CanRun = 0
    $Ran = 1
    TrayItemSetState($RunNowItem, $TRAY_DISABLE)
    TrayItemSetState($DoProfessionsItem, $TRAY_DISABLE)
    TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
    TraySetIcon(@ScriptDir & "\images\green.ico")
    If $noflash Then TraySetState($TRAY_ICONSTATE_STOPFLASH)
    If @Compiled Then
        ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", $n, @ScriptDir)
    Else
        ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" ' & $n, @ScriptDir)
    EndIf
    TrayItemSetState($RunNowItem, $TRAY_ENABLE)
    TrayItemSetState($DoProfessionsItem, $TRAY_ENABLE)
    TraySetIcon(@ScriptDir & "\images\teal.ico")
    TraySetState($TRAY_ICONSTATE_FLASH)
    $CanRun = 1
EndFunc

Func RunNow()
    RunInvokeBot(2)
EndFunc

Func DoProfessions()
    RunInvokeBot(3)
EndFunc

Local $deleted = 1
If FileExists(@ScriptDir & "\Install.exe") Then $deleted = FileDelete(@ScriptDir & "\Install.exe")
TraySetState($TRAY_ICONSTATE_FLASH)
RunInvokeBot(0, 0)
If $deleted And FileExists(@ScriptDir & "\Install.exe") Then Exit

Func HoursAndMinutes($n)
    Local $All = Ceiling($n)
    Local $Hours = Floor($All / 60)
    Local $Minutes = $All - $Hours * 60
    If $Hours Then
        If $Hours = 1 Then
            If $Minutes Then
                If $Minutes = 1 Then Return Localize("HourMinute")
                Return Localize("HourMinutes", "<MINUTES>", $Minutes)
            EndIf
            Return Localize("Hour")
        ElseIf $Minutes Then
            If $Minutes = 1 Then Return Localize("HoursMinute", "<HOURS>", $Hours)
            Return Localize("HoursMinutes", "<HOURS>", $Hours, "<MINUTES>", $Minutes)
        EndIf
        Return Localize("Hours", "<HOURS>", $Hours)
    ElseIf $Minutes = 1 Then
        Return Localize("Minute")
    EndIf
    Return Localize("Minutes", "<MINUTES>", $Minutes)
EndFunc

Func WaitMinutes($time, $msg, $idle = 0)
    Local $t = TimerInit(), $left = $time, $txt = "", $last = "", $DoMsgBox = 1, $MsgBoxReturn
    If $idle Then
        $left = $time - _Timer_GetIdleTime() / 60000
        If $left > 0 Then
            $txt = $Title & @CRLF & Localize($msg) & @CRLF & HoursAndMinutes($time)
            TraySetToolTip($txt)
        EndIf
    EndIf
    While $left > 0
        If $idle Then
            If $DoMsgBox And $left * 60 > 15 Then
                $MsgBoxReturn = MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("RunInvokeBotNow"), Int($left * 60))
                If $MsgBoxReturn = $IDYES Then Return
                If $MsgBoxReturn = $IDNO Then $DoMsgBox = 0
            Else
                Sleep(1000)
            EndIf
            If $Ran Then ExitLoop
            $left = $time - _Timer_GetIdleTime() / 60000
        Else
            $txt = $Title & @CRLF & Localize($msg) & @CRLF & HoursAndMinutes($left)
            If Not ($last == $txt) Then
                TraySetToolTip($txt)
                $last = $txt
            EndIf
            Sleep(1000)
            If $Ran Then ExitLoop
            $left = $time - TimerDiff($t) / 60000
        EndIf
    WEnd
EndFunc

While 1
    While 1
        $Ran = 0
        TraySetIcon(@ScriptDir & "\images\teal.ico")
        Local $min = 0
        While 1
            $min = _GetUTCMinutes(10, Random(120, 900, 1) / 60, True, False, True, $Title & @CRLF & Localize("GettingTimeUntilServerReset"))
            If $Ran Then ExitLoop 2
            If $min >= 0 Then ExitLoop
            WaitMinutes(10, "WaitingToRetryGettingTimeUntilServerReset")
            If $Ran Then ExitLoop 2
        WEnd
        TraySetIcon(@ScriptDir & "\images\blue.ico")
        WaitMinutes($min, "WaitingForServerReset")
        If $Ran Then ExitLoop
        TraySetIcon(@ScriptDir & "\images\yellow.ico")
        WaitMinutes(10, "WaitingForSystemIdle", 1)
        If $Ran Then ExitLoop
        TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
        TraySetIcon(@ScriptDir & "\images\green.ico")
        If MsgBox($MB_OKCANCEL, $Title, Localize("AboutToStart"), 15) = $IDCANCEL Then ExitLoop
        If $Ran Then ExitLoop
        If Not @Compiled Then
            Local $list = ProcessList(StringRegExpReplace(@AutoItExe, ".*\\", ""))
            If @error = 0 Then
                For $i = 1 To $list[0][0]
                    If $list[$i][1] <> @AutoItPID Then ProcessClose($list[$i][1])
                Next
            EndIf
        EndIf
        ProcessClose("Neverwinter Invoke Bot.exe")
        ProcessClose("Neverwinter Fishing Bot.exe")
        RunInvokeBot(1)
    WEnd
WEnd