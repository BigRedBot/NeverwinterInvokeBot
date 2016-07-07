#RequireAdmin
#include <Misc.au3>
#include <MsgBoxConstants.au3>
If _Singleton("Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, "Unattended Launcher", "Already running!")
    Exit
EndIf
#include "_GetUTCMinutes.au3"
While 1
    Local $min = 0
    While 1
        $min = _GetUTCMinutes(10, 1, True)
        If $min >= 0 Then
            ExitLoop
        EndIf
        Sleep(600000)
    WEnd
    Sleep($min * 60000)
    If @Compiled Then
        ShellexecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", 1, @ScriptDir)
    Else
        ShellexecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" 1', @ScriptDir)
    EndIf
WEnd