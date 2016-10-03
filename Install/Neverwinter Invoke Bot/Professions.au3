
Func RunProfessions(); If $RestartLoop Then Return 0
    If Not $EnableProfessions Then Return
    ClearWindows(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    
EndFunc

Func CheckProfessionsUnlockCode()
    If $EnableProfessions Or $UnattendedModeCheckSettings Then Return
    _Crypt_Startup()
    Local $hash = "225BA7083CE6B485BE95CBDAF18CF6D025C4D7F3"
    If Hex(_Crypt_HashData(StringUpper(StringStripWS(GetValue("ProfessionsUnlockCode"), $STR_STRIPALL)), $CALG_SHA1)) = $hash Then
        $EnableProfessions = 1
    ElseIf Not $UnattendedMode And MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2, $Title, Localize("UnlockProfessions")) = $IDYES Then
        While 1
            Local $input = InputBox($Title, @CRLF & @CRLF & @CRLF & @CRLF & Localize("EnterProfessionsUnlockCode"))
            If @error <> 0 Then
                If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("BuyProfessionsUnlockCode"), 900) = $IDYES Then Exit ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HBA5U7LQQ33BA")
                ExitLoop
            EndIf
            $input = StringUpper(StringStripWS($input, $STR_STRIPALL))
            If Hex(_Crypt_HashData($input, $CALG_SHA1)) = $hash Then
                $EnableProfessions = 1
                SetAllAccountsValue("ProfessionsUnlockCode", $input)
                SavePrivateIniAllAccounts("ProfessionsUnlockCode", $input)
                ExitLoop
            EndIf
        WEnd
    EndIf
    _Crypt_Shutdown()
EndFunc

Func ChooseProfessionsAccountOption()
    If Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots")
    Local $Checkbox[$Total + 1]
    GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 400)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 270)
    GUICtrlCreateLabel(Localize("EnableProfessions", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    $Checkbox[0] = GUICtrlCreateCheckbox(Localize("AllCharacters"), 40, 70)
    If GetAccountValue("EnableProfessions") Then GUICtrlSetState($Checkbox[0], $GUI_CHECKED)
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10)
        Local $Column = $i - (($Row - 1) * 10)
        $Checkbox[$i] = GUICtrlCreateCheckbox(Localize("CharacterNumber", "<NUMBER>", $i), 40 + (($Row - 1) * 100), 80 + ($Column * 24))
        If GetAccountValue("EnableProfessions") Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
            GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        ElseIf GetCharacterValue("EnableProfessions", $i) Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
        EndIf
    Next
    Local $hButton = GUICtrlCreateButton("OK", _Max(154 + ((Ceiling($Total / 10) - 3) * 100), 154), 360, 84, -1, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 360, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Checkbox[0]
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then
                    For $i = 1 To $Total
                        GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
                        GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
                    Next
                Else
                    For $i = 1 To $Total
                        GUICtrlSetState($Checkbox[$i], $GUI_ENABLE)
                        GUICtrlSetState($Checkbox[$i], $GUI_UNCHECKED)
                    Next
                EndIf
            Case $hButton
                Local $enabled = 0
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("EnableProfessions") <> $enabled Then
                    SetAccountValue("EnableProfessions", $enabled)
                    If GetAccountValue("EnableProfessions") == GetDefaultValue("EnableProfessions") Then
                        SaveIniAccount("EnableProfessions")
                    Else
                        SaveIniAccount("EnableProfessions", GetAccountValue("EnableProfessions"))
                    EndIf
                EndIf
                For $i = 1 To $Total
                    $enabled = 0
                    If GUICtrlRead($Checkbox[$i]) = $GUI_CHECKED And Not GetAccountValue("EnableProfessions") Then $enabled = 1
                    If GetCharacterValue("EnableProfessions", $i) <> $enabled Then
                        SetCharacterValue("EnableProfessions", $enabled, $i)
                        If GetCharacterValue("EnableProfessions", $i) == GetDefaultValue("EnableProfessions") Then
                            SaveIniCharacter("EnableProfessions", "", $i)
                        Else
                            SaveIniCharacter("EnableProfessions", GetCharacterValue("EnableProfessions", $i), $i)
                        EndIf
                    EndIf
                Next
                GUIDelete()
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc
