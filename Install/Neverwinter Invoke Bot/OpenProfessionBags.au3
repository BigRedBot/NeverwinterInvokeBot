#NoTrayIcon
#RequireAdmin

If @Compiled Then
    ShellExecuteWait(@ScriptDir & "\Invoke.exe", 7, @ScriptDir)
Else
    ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Invoke.au3" ' & 7, @ScriptDir)
EndIf
