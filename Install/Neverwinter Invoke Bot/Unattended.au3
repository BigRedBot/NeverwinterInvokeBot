#NoTrayIcon
#RequireAdmin
AutoItSetOption("TrayAutoPause", 0)
#include "..\variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include "_GetUTCMinutes.au3"
#include "Localization.au3"
Global $Title = $Name & " " & $Version & ": Unattended Launcher"
TraySetToolTip($Title)
LoadLocalizations()
If _Singleton($Name & ": Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("UnattendedAlreadyRunning"))
Local $CanRun, $Ran
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)
Local $RunItem = TrayCreateItem(" ")
TrayItemSetOnEvent(-1, "RunNow")
TrayCreateItem("")
TrayCreateItem(Localize("Exit"))
TrayItemSetOnEvent(-1, "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "RunNow")
TraySetState($TRAY_ICONSTATE_SHOW)

Func ExitScript()
    Exit
EndFunc

Func RunNow()
    If Not $CanRun Then Return
    $CanRun = 0
    $Ran = 1
    TrayItemSetText($RunItem, " ")
    TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
    TraySetIcon(@ScriptDir & "\images\green.ico")
    If @Compiled Then
        ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", 2, @ScriptDir)
    Else
        ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" 2', @ScriptDir)
    EndIf
EndFunc

TraySetIcon(@ScriptDir & "\images\green.ico")
TraySetState($TRAY_ICONSTATE_FLASH)
If @Compiled Then
    Local $deleted = 1
    If FileExists(@ScriptDir & "\Install.exe") Then $deleted = FileDelete(@ScriptDir & "\Install.exe")
    ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", 0, @ScriptDir)
    If $deleted And FileExists(@ScriptDir & "\Install.exe") Then Exit
Else
    ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" 0', @ScriptDir)
EndIf
TraySetState($TRAY_ICONSTATE_STOPFLASH)

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
    $CanRun = 1
    TrayItemSetText($RunItem, Localize("RunNow"))
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
    $CanRun = 0
    TrayItemSetText($RunItem, " ")
EndFunc

While 1
    While 1
        $Ran = 0
        TraySetIcon(@ScriptDir & "\images\teal.ico")
        Local $min = 0
        While 1
            $min = _GetUTCMinutes(10, 1, True, False, True, $Title & @CRLF & Localize("GettingTimeUntilServerReset"))
            If $min >= 0 Then ExitLoop
            WaitMinutes(10, "WaitingToRetryGettingTimeUntilServerReset")
            If $Ran Then ExitLoop 2
        WEnd
        TraySetIcon(@ScriptDir & "\images\blue.ico")
        WaitMinutes($min, "WaitingForServerReset")
        If $Ran Then ExitLoop
        TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
        TraySetIcon(@ScriptDir & "\images\green.ico")
        While ProcessExists("Neverwinter Invoke Bot.exe")
            ProcessClose("Neverwinter Invoke Bot.exe")
            Sleep(500)
        WEnd
        While ProcessExists("GameClient.exe")
            ProcessClose("GameClient.exe")
            Sleep(500)
        WEnd
        If @Compiled Then
            ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", 1, @ScriptDir)
        Else
            ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" 1', @ScriptDir)
        EndIf
    WEnd
WEnd