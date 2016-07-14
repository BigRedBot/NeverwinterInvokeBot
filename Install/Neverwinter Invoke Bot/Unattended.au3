#RequireAdmin
AutoItSetOption("TrayAutoPause", 0)
#include "..\variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include "_GetUTCMinutes.au3"
#include "Localization.au3"
Global $Title = $Name & ": Unattended Launcher"
TraySetToolTip($Title)
LoadLocalizations()
If _Singleton($Title & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("UnattendedAlreadyRunning"))
    Exit
EndIf
TraySetIcon(@ScriptDir & "\images\green.ico")
TraySetState($TRAY_ICONSTATE_FLASH)
If @Compiled Then
    Local $deleted = 1
    If FileExists(@ScriptDir & "\Install.exe") Then $deleted = FileDelete(@ScriptDir & "\Install.exe")
    ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", -1, @ScriptDir)
    If $deleted And FileExists(@ScriptDir & "\Install.exe") Then Exit
Else
    ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" -1', @ScriptDir)
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
    Local $t = TimerInit(), $left = $time, $txt = "", $last = "", $lastmin = 0, $leftover
    While $left > 0
        $txt = $Title & @CRLF & Localize($msg) & @CRLF & HoursAndMinutes($left)
        If Not ($last == $txt) Then
            TraySetToolTip($txt)
            $last = $txt
        EndIf
        If $left > 1 then
            If $lastmin = Ceiling($left) Then
                $leftover = Ceiling(($lastmin - $left) * 60000)
                Sleep($leftover + 1)
            Else
                $lastmin = Ceiling($left)
                Sleep(60000)
            EndIf
        Else
            Sleep(Ceiling($left * 60000))
            ExitLoop
        EndIf
        $left = $time - TimerDiff($t) / 60000
    WEnd
EndFunc

While 1
    TraySetIcon(@ScriptDir & "\images\teal.ico")
    Local $min = 0
    While 1
        $min = _GetUTCMinutes(10, 1, True, False, True, $Title & @CRLF & Localize("GettingTimeUntilServerReset"))
        If $min >= 0 Then ExitLoop
        WaitMinutes(10, "WaitingToRetryGettingTimeUntilServerReset")
    WEnd
    TraySetIcon(@ScriptDir & "\images\blue.ico")
    WaitMinutes($min, "WaitingForServerReset")
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