#NoTrayIcon
#include "variables.au3"
Global $Title = $Name & " v" & $Version
#include "Shared.au3"
_Singleton("Neverwinter Invoke Bot: Donation Prompt" & "Jp4g9QRntjYP")
#include "_AddCommaToNumber.au3"

While 1
    Local $text = Localize("InvokedTotalTimes", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalInvoked")))
    If GetAllAccountsValue("TotalCelestialCoffers") Then $text &= @CRLF & @CRLF & Localize("TotalCelestialCoffersCollected", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalCelestialCoffers")))
    If GetAllAccountsValue("TotalProfessionPacks") Then $text &= @CRLF & @CRLF & Localize("TotalProfessionPacksCollected", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalProfessionPacks")))
    If GetAllAccountsValue("TotalElixirsOfFate") Then $text &= @CRLF & @CRLF & Localize("TotalElixirsOfFateCollected", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalElixirsOfFate")))
    If GetAllAccountsValue("TotalOverflowXPRewards") Then $text &= @CRLF & @CRLF & Localize("TotalOverflowXPRewardsCollected", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalOverflowXPRewards")))
    If GetAllAccountsValue("TotalVIPCharacterRewards") Then $text &= @CRLF & @CRLF & Localize("TotalVIPCharacterRewardsCollected", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalVIPCharacterRewards")))
    If GetAllAccountsValue("TotalVIPAccountRewards") Then $text &= @CRLF & @CRLF & Localize("TotalVIPAccountRewardsCollected", "<COUNT>", _AddCommaToNumber(GetAllAccountsValue("TotalVIPAccountRewards")))
    Local $msg = MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_TOPMOST, $Title, $text & @CRLF & @CRLF & @CRLF & Localize("DonateNow"), 900)
    If $msg = $IDYES Then Exit ShellExecute(@ScriptDir & "\Donation.html")
    If $msg <> $IDTIMEOUT Then Exit
    While _Singleton($Name & "Jp4g9QRntjYP", 1) = 0
        Sleep(1000)
    WEnd
Wend
