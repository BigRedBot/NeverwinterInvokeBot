#NoTrayIcon
#include "Shared.au3"
_Singleton("Neverwinter Invoke Bot: Utility Code Prompt" & "Jp4g9QRntjYP")
Local $timeout = 0
If $CmdLine[0] Then $timeout = Number($CmdLine[1])
RunCheckUtilityUnlockCode($timeout)