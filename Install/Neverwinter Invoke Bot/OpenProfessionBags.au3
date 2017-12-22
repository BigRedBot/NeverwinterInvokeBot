#NoTrayIcon
#RequireAdmin

If @Compiled Then
    ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", 7, @ScriptDir)
Else
    ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" ' & 7, @ScriptDir)
EndIf
