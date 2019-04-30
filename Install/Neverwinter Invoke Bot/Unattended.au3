#NoTrayIcon
#RequireAdmin
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include <Timers.au3>
#include "_ScheduleWakeUp.au3"
#include "_GetUTCMinutes.au3"
#include "_UnicodeIni.au3"
#include "Shared.au3"
Global $Title = $Name & " " & $Version & ": Unattended Launcher"
LoadLocalizations()
If _Singleton("Neverwinter Invoke Bot: Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("UnattendedAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("Use32bit"))
OnAutoItExitRegister("_ScheduleWakeUp_Delete_ExitScript")
Local $CanRun = 1, $Ran, $Disabled
Local $RunNowItem = TrayCreateItem(Localize("RunNow"))
TrayItemSetOnEvent($RunNowItem, "RunNow")
TrayCreateItem("")
Local $DoProfessionsItem
If Not $RemoveProfessions Then
    $DoProfessionsItem = TrayCreateItem(Localize("DoProfessions"))
    TrayItemSetOnEvent($DoProfessionsItem, "DoProfessions")
    TrayCreateItem("")
EndIf
Local $DoOpenProfessionBagsItem = TrayCreateItem(Localize("DoOpenProfessionBags"))
TrayItemSetOnEvent($DoOpenProfessionBagsItem, "DoOpenProfessionBags")
TrayCreateItem("")
TrayItemSetState(TrayCreateItem(" "), $TRAY_DISABLE)
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("RunFishingBot")), "Fish")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("PullGuildBankRP")), "GuildBankRP")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("PostItemsToAuction")), "Auction")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("PullItemsFromMail")), "Mail")
TrayCreateItem("")
TrayItemSetState(TrayCreateItem(" "), $TRAY_DISABLE)
TrayCreateItem("")
Local $DisableItem = TrayCreateItem(Localize("Disable"))
TrayItemSetOnEvent($DisableItem, "Disable")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("Logs")), "Logs")
TrayCreateItem("")
TrayItemSetOnEvent(TrayCreateItem(Localize("Exit")), "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "RunNow")
TraySetToolTip($Title)

Func ExitScript()
    Exit
EndFunc

Func Disable()
    If $Disabled Then
        $Disabled = 0
        DeleteAllAccountsValue("UnattendedDisabled")
        DeleteIniAllAccounts("UnattendedDisabled")
        TrayItemSetText($DisableItem, Localize("Disable"))
    Else
        $Disabled = 1
        $Ran = 1
        SetAllAccountsValue("UnattendedDisabled", 1)
        SaveIniAllAccounts("UnattendedDisabled", 1)
        TrayItemSetText($DisableItem, Localize("Enable"))
        If $CanRun Then
            TraySetToolTip($Title)
            TraySetIcon(@ScriptDir & "\images\black.ico")
            TraySetState($TRAY_ICONSTATE_STOPFLASH)
        EndIf
    EndIf
EndFunc

Func Logs()
    If WinExists("Logs") Then
        WinActivate("Logs")
    Else
        Run("explorer.exe " & $LogsDir)
    EndIf
EndFunc

Func RunInvokeBot($n, $noflash = 1)
    If Not $CanRun Then Return
    $CanRun = 0
    $Ran = 1
    TrayItemSetState($RunNowItem, $TRAY_DISABLE)
    If Not $RemoveProfessions Then TrayItemSetState($DoProfessionsItem, $TRAY_DISABLE)
    TrayItemSetState($DoOpenProfessionBagsItem, $TRAY_DISABLE)
    TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
    TraySetIcon(@ScriptDir & "\images\green.ico")
    If $noflash Then TraySetState($TRAY_ICONSTATE_STOPFLASH)
    If @Compiled Then
        ShellExecuteWait(@ScriptDir & "\Invoke.exe", $n, @ScriptDir)
    Else
        ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Invoke.au3" ' & $n, @ScriptDir)
    EndIf
    TrayItemSetState($RunNowItem, $TRAY_ENABLE)
    If Not $RemoveProfessions Then TrayItemSetState($DoProfessionsItem, $TRAY_ENABLE)
    TrayItemSetState($DoOpenProfessionBagsItem, $TRAY_ENABLE)
    If $Disabled Then
        TraySetToolTip($Title)
        TraySetIcon(@ScriptDir & "\images\black.ico")
        TraySetState($TRAY_ICONSTATE_STOPFLASH)
    Else
        TraySetIcon(@ScriptDir & "\images\teal.ico")
        TraySetState($TRAY_ICONSTATE_FLASH)
    EndIf
    $CanRun = 1
EndFunc

Func RunNow()
    RunInvokeBot(2)
EndFunc

Func DoProfessions()
    RunInvokeBot(3)
EndFunc

Func DoOpenProfessionBags()
    RunInvokeBot(7)
EndFunc

Func Fish()
    If @Compiled Then
        ShellExecute(@ScriptDir & "\Fish.exe", "", @ScriptDir)
    Else
        ShellExecute(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Fish.au3"', @ScriptDir)
    EndIf
EndFunc

Func GuildBankRP()
    If @Compiled Then
        ShellExecute(@ScriptDir & "\GuildBankRP.exe", "", @ScriptDir)
    Else
        ShellExecute(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\GuildBankRP.au3"', @ScriptDir)
    EndIf
EndFunc

Func Auction()
    If @Compiled Then
        ShellExecute(@ScriptDir & "\Auction.exe", "", @ScriptDir)
    Else
        ShellExecute(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Auction.au3"', @ScriptDir)
    EndIf
EndFunc

Func Mail()
    If @Compiled Then
        ShellExecute(@ScriptDir & "\Mail.exe", "", @ScriptDir)
    Else
        ShellExecute(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Mail.au3"', @ScriptDir)
    EndIf
EndFunc

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
    ElseIf $time >= 6 Then
        _ScheduleWakeUp(($time - 5) * 60)
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

Func Unattended()
    While 1
    While 1
        If $Disabled Then
            TrayItemSetText($DisableItem, Localize("Enable"))
            If $CanRun Then
                TraySetToolTip($Title)
                TraySetIcon(@ScriptDir & "\images\black.ico")
                TraySetState($TRAY_ICONSTATE_STOPFLASH)
            EndIf
            While $Disabled
                Sleep(1000)
            WEnd
        EndIf
        While Not $CanRun
            Sleep(1000)
            If $Disabled Then ExitLoop 2
        WEnd
        $Ran = 0
        TraySetIcon(@ScriptDir & "\images\teal.ico")
        Local $min = 0
        While 1
            $min = _GetUTCMinutes(GetValue("ServerResetTimeZone"), GetValue("ServerResetTimeHour") * 3600 + Random(2 * 60, 30 * 60, 1), True, False, True, $Title & @CRLF & Localize("GettingTimeUntilServerReset"))
            If $Ran Then ExitLoop 2
            If $min >= 0 Then ExitLoop
            WaitMinutes(10, "WaitingToRetryGettingTimeUntilServerReset")
            If $Ran Then ExitLoop 2
        WEnd
        TraySetIcon(@ScriptDir & "\images\blue.ico")
        WaitMinutes($min, "WaitingForServerReset")
        If $Ran Then ExitLoop
        TraySetIcon(@ScriptDir & "\images\yellow.ico")
        WaitMinutes(5, "WaitingForSystemIdle", 1)
        If $Ran Then ExitLoop
        TraySetToolTip($Title & @CRLF & Localize("UnattendedRunning"))
        TraySetIcon(@ScriptDir & "\images\green.ico")
        If MsgBox($MB_OKCANCEL + $MB_TOPMOST, $Title, Localize("AboutToStart"), 15) = $IDCANCEL Then ExitLoop
        If $Ran Then ExitLoop
        If Not @Compiled Then
            Local $list = ProcessList(StringRegExpReplace(@AutoItExe, ".*\\", ""))
            If @error = 0 Then
                For $i = 1 To $list[0][0]
                    If $list[$i][1] <> @AutoItPID Then ProcessClose($list[$i][1])
                Next
            EndIf
        EndIf
        ProcessClose("Invoke.exe")
        ProcessClose("Fish.exe")
        RunInvokeBot(1)
    WEnd
    WEnd
EndFunc

If GetAllAccountsValue("UnattendedDisabled") Then $Disabled = 1
If $Disabled Then TrayItemSetText($DisableItem, Localize("Enable"))
Local $deleted = 1
If FileExists(@ScriptDir & "\Install.exe") Then $deleted = FileDelete(@ScriptDir & "\Install.exe")
TraySetState($TRAY_ICONSTATE_FLASH)
RunInvokeBot(0, 0)
If $deleted And FileExists(@ScriptDir & "\Install.exe") Then Exit

CheckUtilityUnlockCode(15)
Unattended()
