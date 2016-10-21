#NoTrayIcon
#RequireAdmin
AutoItSetOption("TrayAutoPause", 0)
#include "..\variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include "_GetUTCMinutes.au3"
#include "_UnicodeIni.au3"
#include "Localization.au3"
Global $Title = $Name & " " & $Version & ": Unattended Launcher"
TraySetToolTip($Title)
LoadLocalizations()
If _Singleton($Name & ": Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("UnattendedAlreadyRunning"))
Local $CanRun = 1, $Ran
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)
Local $RunNowItem = TrayCreateItem(Localize("RunNow"))
TrayItemSetOnEvent($RunNowItem, "RunNow")
TrayCreateItem("")
Local $DoProfessionsItem = TrayCreateItem(Localize("DoProfessions"))
TrayItemSetOnEvent($DoProfessionsItem, "DoProfessions")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("Exit")), "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "RunNow")
TraySetState($TRAY_ICONSTATE_SHOW)

Func ExitScript()
    Exit
EndFunc

Func RunInvokeBot($n = 1, $flash = 0)
    If Not $CanRun Then Return
    $CanRun = 0
    $Ran = 1
    TrayItemSetState($RunNowItem, $TRAY_DISABLE)
    TrayItemSetState($DoProfessionsItem, $TRAY_DISABLE)
    TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
    TraySetIcon(@ScriptDir & "\images\green.ico")
    If $flash Then
        TraySetState($TRAY_ICONSTATE_FLASH)
    Else
        TraySetState($TRAY_ICONSTATE_STOPFLASH)
    EndIf
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
RunInvokeBot(0, 1)
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

Func WaitMinutes($time, $msg)
    Local $t = TimerInit(), $left = $time, $txt = "", $last = ""
    While $left > 0
        $txt = $Title & @CRLF & Localize($msg) & @CRLF & HoursAndMinutes($left)
        If Not ($last == $txt) Then
            TraySetToolTip($txt)
            $last = $txt
        EndIf
        Sleep(1000)
        If $Ran Then ExitLoop
        $left = $time - TimerDiff($t) / 60000
    WEnd
EndFunc

While 1
    While 1
        $Ran = 0
        TraySetIcon(@ScriptDir & "\images\teal.ico")
        Local $min = 0
        While 1
            $min = _GetUTCMinutes(10, 2, True, False, True, $Title & @CRLF & Localize("GettingTimeUntilServerReset"))
            If $Ran Then ExitLoop 2
            If $min >= 0 Then ExitLoop
            WaitMinutes(10, "WaitingToRetryGettingTimeUntilServerReset")
            If $Ran Then ExitLoop 2
        WEnd
        TraySetIcon(@ScriptDir & "\images\blue.ico")
        WaitMinutes($min, "WaitingForServerReset")
        If $Ran Then ExitLoop
        TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
        TraySetIcon(@ScriptDir & "\images\green.ico")
        Local $process = "Neverwinter Invoke Bot.exe"
        If Not @Compiled Then $process = StringRegExpReplace(@AutoItExe, ".*\\", "")
        Local $list = ProcessList($process)
        If @error = 0 Then
            For $i = 1 To $list[0][0]
                If $list[$i][1] <> @AutoItPID Then ProcessClose($list[$i][1])
            Next
        EndIf
        RunInvokeBot()
    WEnd
WEnd