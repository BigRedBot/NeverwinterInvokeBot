
Func RunProfessions(); If $RestartLoop Then Return 0
    If Not $EnableProfessions Or Not GetValue("EnableProfessions") Then Return
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
                If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("BuyProfessionsUnlockCode")) = $IDYES Then
                    _Crypt_Shutdown()
                    Exit ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HBA5U7LQQ33BA")
                EndIf
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
    GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 460)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 270)
    GUICtrlCreateLabel(Localize("EnableProfessions", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    $Checkbox[0] = GUICtrlCreateCheckbox(Localize("AllCharacters"), 40, 70, 100)
    If GetAccountValue("EnableProfessions") Then GUICtrlSetState($Checkbox[0], $GUI_CHECKED)
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        $Checkbox[$i] = GUICtrlCreateCheckbox(Localize("CharacterNumber", "<NUMBER>", $i), 40 + (($Row - 1) * 100), 80 + ($Column * 30), 100)
        If GetAccountValue("EnableProfessions") Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
            GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        ElseIf GetCharacterValue("EnableProfessions", $i) Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
        EndIf
    Next
    Local $ButtonOK = GUICtrlCreateButton("OK", _Max(154 + ((Ceiling($Total / 10) - 3) * 100), 154), 420, 84, -1, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 420, 75, 25)
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
            Case $ButtonOK
                Local $enabled = 0
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("EnableProfessions") <> $enabled Then
                    SetAccountValue("EnableProfessions", $enabled)
                    If GetAccountValue("EnableProfessions") == GetDefaultValue("EnableProfessions") Then
                        SaveIniAccount("EnableProfessions")
                    Else
                        SaveIniAccount("EnableProfessions", $enabled)
                    EndIf
                EndIf
                For $i = 1 To $Total
                    $enabled = 0
                    If GetAccountValue("EnableProfessions") Or GUICtrlRead($Checkbox[$i]) = $GUI_CHECKED Then $enabled = 1
                    SetCharacterValue("EnableProfessions", $enabled, $i)
                    If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) == GetDefaultValue("EnableProfessions") Then
                        SaveIniCharacter("EnableProfessions", "", $i)
                    Else
                        SaveIniCharacter("EnableProfessions", $enabled, $i)
                    EndIf
                Next
                GUIDelete()
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

Func ChooseProfessionsAccountTaskOption()
    If Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots"), $nMsg, $EnabledCharacterFound
    Local $Button[$Total + 1]
    GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 460)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 270)
    GUICtrlCreateLabel(Localize("EditProfessionTasks", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    If GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") Then
        $Button[0] = GUICtrlCreateButton(Localize("AllCharacters"), 30, 70, 95)
    Else
        $Button[0] = GUICtrlCreateButton("* " & Localize("AllCharacters") & " *", 30, 70, 95)
    EndIf
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10), $NotDefault = " * "
        If GetValue("LeadershipProfessionTasks", $CurrentAccount, $i) == GetDefaultValue("LeadershipProfessionTasks") Then
            $Button[$i] = GUICtrlCreateButton(Localize("CharacterNumber", "<NUMBER>", $i), 30 + (($Row - 1) * 100), 80 + ($Column * 30), 95)
        Else
            $Button[$i] = GUICtrlCreateButton("* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *", 30 + (($Row - 1) * 100), 80 + ($Column * 30), 95)
        EndIf
        If GetAccountValue("EnableProfessions") Or GetValue("EnableProfessions", $CurrentAccount, $i) Then
            $EnabledCharacterFound = 1
            If Not ( GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") ) Then GUICtrlSetState($Button[$i], $GUI_DISABLE)
        Else
            GUICtrlSetState($Button[$i], $GUI_DISABLE)
        EndIf
    Next
    If Not $EnabledCharacterFound Then Return
    Local $ButtonOK = GUICtrlCreateButton("OK", _Max(154 + ((Ceiling($Total / 10) - 3) * 100), 154), 420, 84, -1, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 420, 75, 25)
    GUISetState()
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Button[0]
                Local $input = _MultilineInputBox($Title, @CRLF & @CRLF & @CRLF & Localize("EditProfessionTasksForAllCharacters"), StringReplace(GetAccountValue("LeadershipProfessionTasks"), "<BR>", @CRLF))
                If @error = 0 And ( Not ( GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") ) Or MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2, $Title, Localize("OverwriteProfessionTasksForAllOtherCharacters", "<ACCOUNT>", $CurrentAccount)) = $IDYES ) Then
                    $input = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($input, "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "<BR>"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                    If $input = "" Then $input = GetDefaultValue("LeadershipProfessionTasks")
                    SetAccountValue("LeadershipProfessionTasks", $input)
                    If GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") Then
                        GUICtrlSetData($Button[0], Localize("AllCharacters"))
                        SaveIniAccount("LeadershipProfessionTasks")
                    Else
                        GUICtrlSetData($Button[0], "* " & Localize("AllCharacters") & " *")
                        SaveIniAccount("LeadershipProfessionTasks", $input)
                    EndIf
                    For $i = 1 To $Total
                        SetCharacterValue("LeadershipProfessionTasks", GetAccountValue("LeadershipProfessionTasks"), $i)
                        GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                        SaveIniCharacter("LeadershipProfessionTasks", "", $i)
                        If GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") Then
                            If GetAccountValue("EnableProfessions") Or GetValue("EnableProfessions", $CurrentAccount, $i) Then GUICtrlSetState($Button[$i], $GUI_ENABLE)
                        Else
                            GUICtrlSetState($Button[$i], $GUI_DISABLE)
                        EndIf
                    Next
                EndIf
            Case $Button[1] To $Button[$Total]
                For $i = 1 To $Total
                    If $Button[$i] = $nMsg Then
                        Local $input = _MultilineInputBox($Title, @CRLF & @CRLF & @CRLF & Localize("EditProfessionTasksForCharacter", "<NUMBER>", $i), StringReplace(GetCharacterValue("LeadershipProfessionTasks", $i), "<BR>", @CRLF))
                        If @error = 0 Then
                            $input = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($input, "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "<BR>"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                            If $input = "" Then $input = GetDefaultValue("LeadershipProfessionTasks")
                            SetCharacterValue("LeadershipProfessionTasks", $input, $i)
                            If GetCharacterValue("LeadershipProfessionTasks", $i) == GetDefaultValue("LeadershipProfessionTasks") Then
                                GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                                SaveIniCharacter("LeadershipProfessionTasks", "", $i)
                            Else
                                GUICtrlSetData($Button[$i], "* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *")
                                SaveIniCharacter("LeadershipProfessionTasks", $input, $i)
                            EndIf
                        EndIf
                        ExitLoop
                    EndIf
                Next
            Case $ButtonOK
                GUIDelete()
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc
