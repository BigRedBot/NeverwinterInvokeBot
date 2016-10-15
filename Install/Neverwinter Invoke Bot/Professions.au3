
Func RunProfessions(); If $RestartLoop Then Return 0
    If Not $EnableProfessions Or Not GetValue("EnableProfessions") Then Return
    If $StartingKeyboardLayout And Not (Hex($StartingKeyboardLayout, 4) == "0409") And $WinHandle And $ProcessName = "GameClient.exe" And WinExists($WinHandle) Then
        Local $k = _WinAPI_GetKeyboardLayout($WinHandle)
        If $k And Not (Hex($k, 4) == "0409") Then _WinAPI_SetKeyboardLayout($WinHandle, 0x0409)
    EndIf
    Local $ProfessionLoops = 0, $ProfessionTakeRewardsFailed = 0, $OverviewX, $OverviewY, $task = 1, $lasttask = 0, $tasklist = StringSplit(GetValue("LeadershipProfessionTasks"), "|")
    While 1
        If $ProfessionLoops >= 10 Then Return
        ClearWindows(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        $lasttask = 0
        Send(GetValue("ProfessionsKey"))
        ProfessionsSleep(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        While 1
            While 1
                $ProfessionLoops += 1
                If $ProfessionLoops > 10 Then Return
                If ImageSearch("Professions_Overview") Then
                    $OverviewX = $_ImageSearchX
                    $OverviewY = $_ImageSearchY
                    If Not ImageSearch("Professions_Leadership") Then Return
                    If ImageSearch("Professions_Search") Then
                        $_ImageSearchX = $OverviewX
                        $_ImageSearchY = $OverviewY
                        ProfessionsClickImage(); If $RestartLoop Then Return 0
                        If $RestartLoop Then Return 0
                    EndIf
                    MouseMove($ClientWidthCenter + Random(-50, 50, 1), $ClientBottom)
                    If Not $ProfessionTakeRewardsFailed Then
                        While ImageSearch("Professions_CollectResult")
                            ProfessionsClickImage(); If $RestartLoop Then Return 0
                            If $RestartLoop Then Return 0
                            MouseMove($ClientWidthCenter + Random(-50, 50, 1), $ClientBottom)
                            If ImageSearch("Professions_TakeRewards") Then
                                $lasttask = 0
                                $task = 1
                                ProfessionsClickImage(); If $RestartLoop Then Return 0
                                If $RestartLoop Then Return 0
                            Else
                                $ProfessionTakeRewardsFailed = 1
                                ExitLoop 3
                            EndIf
                            MouseMove($ClientWidthCenter + Random(-50, 50, 1), $ClientBottom)
                        WEnd
                    EndIf
                    If $task > $tasklist[0] Then Return
                    If Not ImageSearch("Professions_EmptySlot") Then Return
                    If ImageSearch("Professions_Leadership") Then
                        ProfessionsClickImage(); If $RestartLoop Then Return 0
                        If $RestartLoop Then Return 0
                        While 1
                            If ImageSearch("Professions_Search") Then
                                If $task <> $lasttask Then
                                    $lasttask = $task
                                    $_ImageSearchX = $_ImageSearchLeft - 100 + Random(-50, 50, 1)
                                    $_ImageSearchY = $_ImageSearchTop + Int(($_ImageSearchHeight-1)/2) + Random(-5, 5, 1)
                                    ProfessionsClickImage(); If $RestartLoop Then Return 0
                                    If $RestartLoop Then Return 0
                                    ClipPut($tasklist[$task])
                                    Send("{CTRLDOWN}a{CTRLUP}{CTRLDOWN}v{CTRLUP}{ENTER}")
                                    ProfessionsSleep(); If $RestartLoop Then Return 0
                                    If $RestartLoop Then Return 0
                                EndIf
                                If ImageSearch("Professions_Continue") Then
                                    ProfessionsClickImage(); If $RestartLoop Then Return 0
                                    If $RestartLoop Then Return 0
                                    If ImageSearch("Professions_StartTask") Then
                                        ProfessionsClickImage(); If $RestartLoop Then Return 0
                                        If $RestartLoop Then Return 0
                                        ExitLoop 2
                                    Else
                                        ExitLoop 3
                                    EndIf
                                Else
                                    $task += 1
                                    If $task > $tasklist[0] Then ExitLoop 2
                                EndIf
                            Else
                                ExitLoop 3
                            EndIf
                        WEnd
                    Else
                        ExitLoop 2
                    EndIf
                Else
                    ExitLoop 2
                EndIf
            WEnd
        WEnd
    WEnd
EndFunc

Func ProfessionsClickImage($sleeptime = GetValue("ProfessionsDelay") * 1000); If $RestartLoop Then Return 0
    MouseMove($_ImageSearchX, $_ImageSearchY)
    SingleClick()
    ProfessionsSleep($sleeptime); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
EndFunc

Func ProfessionsSleep($sleeptime = GetValue("ProfessionsDelay") * 1000); If $RestartLoop Then Return 0
    Sleep($sleeptime)
    FindLogInScreen(); If $RestartLoop Then Return 0
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
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 270)
    GUICtrlCreateLabel(Localize("EnableProfessions", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    $Checkbox[0] = GUICtrlCreateCheckbox(Localize("AllCharacters"), 40, 70, 100)
    If GetAccountValue("EnableProfessions") Then GUICtrlSetState($Checkbox[0], $GUI_CHECKED)
    Local $InfiniteLoopCheckbox = GUICtrlCreateCheckbox(Localize("EnableInfiniteLoops"), 140, 70, 200)
    If GetAccountValue("InfiniteLoops") Then GUICtrlSetState($InfiniteLoopCheckbox, $GUI_CHECKED)
    Local $InfiniteLoopMinutesButton = GUICtrlCreateButton(Localize("InfiniteLoopMinutes", "<MINUTES>", GetAccountValue("InfiniteLoopDelayMinutes")), 140, 95, 170)
    If Not GetAccountValue("InfiniteLoops") Then GUICtrlSetState($InfiniteLoopMinutesButton, $GUI_DISABLE)
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        $Checkbox[$i] = GUICtrlCreateCheckbox(Localize("CharacterNumber", "<NUMBER>", $i), 40 + (($Row - 1) * 100), 100 + ($Column * 30), 100)
        If GetAccountValue("EnableProfessions") Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
            GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        ElseIf GetCharacterValue("EnableProfessions", $i) Then
            GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
        EndIf
    Next
    Local $ButtonOK = GUICtrlCreateButton("OK", _Max(154 + ((Ceiling($Total / 10) - 3) * 100), 154), 450, 84, -1, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
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
            Case $InfiniteLoopCheckbox
                If GUICtrlRead($InfiniteLoopCheckbox) = $GUI_CHECKED Then
                    GUICtrlSetState($InfiniteLoopMinutesButton, $GUI_ENABLE)
                Else
                    GUICtrlSetState($InfiniteLoopMinutesButton, $GUI_DISABLE)
                EndIf
            Case $InfiniteLoopMinutesButton
                Local $input = InputBox($Title, @CRLF & @CRLF & @CRLF & @CRLF & Localize("InfiniteLoopMinutes", "<MINUTES>", "( 80+ )"), GetAccountValue("InfiniteLoopDelayMinutes"), "", -1, -1, Default, Default, 0, $hGUI)
                If @error = 0 Then
                    $input = Number($input)
                    If $input <= 0 Then
                        $input = GetDefaultValue("InfiniteLoopDelayMinutes")
                    ElseIf $input <= 80 Then
                        $input = 80
                    EndIf
                    If $input == GetDefaultValue("InfiniteLoopDelayMinutes") Then
                        DeleteAccountValue("InfiniteLoopDelayMinutes")
                        SaveIniAccount("InfiniteLoopDelayMinutes")
                    Else
                        SetAccountValue("InfiniteLoopDelayMinutes", $input)
                        SaveIniAccount("InfiniteLoopDelayMinutes", $input)
                    EndIf
                    GUICtrlSetData($InfiniteLoopMinutesButton, Localize("InfiniteLoopMinutes", "<MINUTES>", GetAccountValue("InfiniteLoopDelayMinutes")))
                EndIf
            Case $ButtonOK
                Local $enabled = 0
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("EnableProfessions") <> $enabled Then
                    If $enabled == GetDefaultValue("EnableProfessions") Then
                        DeleteAccountValue("EnableProfessions")
                        SaveIniAccount("EnableProfessions")
                    Else
                        SetAccountValue("EnableProfessions", $enabled)
                        SaveIniAccount("EnableProfessions", $enabled)
                    EndIf
                EndIf
                $enabled = 0
                If GUICtrlRead($InfiniteLoopCheckbox) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("InfiniteLoops") <> $enabled Then
                    If $enabled == GetDefaultValue("InfiniteLoops") Then
                        DeleteAccountValue("InfiniteLoops")
                        SaveIniAccount("InfiniteLoops")
                    Else
                        SetAccountValue("InfiniteLoops", $enabled)
                        SaveIniAccount("InfiniteLoops", $enabled)
                    EndIf
                EndIf
                For $i = 1 To $Total
                    $enabled = 0
                    If GetAccountValue("EnableProfessions") Or GUICtrlRead($Checkbox[$i]) = $GUI_CHECKED Then $enabled = 1
                    If GetAccountValue("EnableProfessions") Or $enabled == GetDefaultValue("EnableProfessions") Then
                        DeleteCharacterValue("EnableProfessions", $i)
                        SaveIniCharacter("EnableProfessions", "", $i)
                    Else
                        SetCharacterValue("EnableProfessions", $enabled, $i)
                        SaveIniCharacter("EnableProfessions", $enabled, $i)
                    EndIf
                Next
                GUIDelete($hGUI)
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
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 270)
    GUICtrlCreateLabel(Localize("EditProfessionTasks", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    If GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") Then
        $Button[0] = GUICtrlCreateButton(Localize("AllCharacters"), 30, 70, 95)
    Else
        $Button[0] = GUICtrlCreateButton("* " & Localize("AllCharacters") & " *", 30, 70, 95)
    EndIf
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        If GetValue("LeadershipProfessionTasks", $CurrentAccount, $i) == GetDefaultValue("LeadershipProfessionTasks") Then
            $Button[$i] = GUICtrlCreateButton(Localize("CharacterNumber", "<NUMBER>", $i), 30 + (($Row - 1) * 100), 100 + ($Column * 30), 95)
        Else
            $Button[$i] = GUICtrlCreateButton("* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *", 30 + (($Row - 1) * 100), 100 + ($Column * 30), 95)
        EndIf
        If GetAccountValue("EnableProfessions") Or GetValue("EnableProfessions", $CurrentAccount, $i) Then
            $EnabledCharacterFound = 1
            If Not ( GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") ) Then GUICtrlSetState($Button[$i], $GUI_DISABLE)
        Else
            GUICtrlSetState($Button[$i], $GUI_DISABLE)
        EndIf
    Next
    If Not $EnabledCharacterFound Then Return
    Local $ButtonOK = GUICtrlCreateButton("OK", _Max(154 + ((Ceiling($Total / 10) - 3) * 100), 154), 450, 84, -1, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
    GUISetState()
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Button[0]
                Local $input = _MultilineInputBox($Title, @CRLF & @CRLF & @CRLF & Localize("EditProfessionTasksForAllCharacters"), StringReplace(GetAccountValue("LeadershipProfessionTasks"), "|", @CRLF), 0, 0, Default, Default, 0, $hGUI)
                If @error = 0 And ( Not ( GetAccountValue("LeadershipProfessionTasks") == GetDefaultValue("LeadershipProfessionTasks") ) Or MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2, $Title, Localize("OverwriteProfessionTasksForAllOtherCharacters", "<ACCOUNT>", $CurrentAccount), 0, $hGUI) = $IDYES ) Then
                    $input = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($input, "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "|"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                    If $input = "" Then $input = GetDefaultValue("LeadershipProfessionTasks")
                    If $input == GetDefaultValue("LeadershipProfessionTasks") Then
                        DeleteAccountValue("LeadershipProfessionTasks")
                        GUICtrlSetData($Button[0], Localize("AllCharacters"))
                        SaveIniAccount("LeadershipProfessionTasks")
                    Else
                        SetAccountValue("LeadershipProfessionTasks", $input)
                        GUICtrlSetData($Button[0], "* " & Localize("AllCharacters") & " *")
                        SaveIniAccount("LeadershipProfessionTasks", $input)
                    EndIf
                    For $i = 1 To $Total
                        GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                        SaveIniCharacter("LeadershipProfessionTasks", "", $i)
                        DeleteCharacterValue("LeadershipProfessionTasks", $i)
                        If $input == GetDefaultValue("LeadershipProfessionTasks") Then
                            If GetAccountValue("EnableProfessions") Or GetValue("EnableProfessions", $CurrentAccount, $i) Then GUICtrlSetState($Button[$i], $GUI_ENABLE)
                        Else
                            GUICtrlSetState($Button[$i], $GUI_DISABLE)
                        EndIf
                    Next
                EndIf
            Case $Button[1] To $Button[$Total]
                For $i = 1 To $Total
                    If $Button[$i] = $nMsg Then
                        Local $input = _MultilineInputBox($Title, @CRLF & @CRLF & @CRLF & Localize("EditProfessionTasksForCharacter", "<NUMBER>", $i), StringReplace(GetCharacterValue("LeadershipProfessionTasks", $i), "|", @CRLF), 0, 0, Default, Default, 0, $hGUI)
                        If @error = 0 Then
                            $input = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($input, "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "|"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                            If $input = "" Then $input = GetDefaultValue("LeadershipProfessionTasks")
                            If $input == GetDefaultValue("LeadershipProfessionTasks") Then
                                DeleteCharacterValue("LeadershipProfessionTasks", $i)
                                GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                                SaveIniCharacter("LeadershipProfessionTasks", "", $i)
                            Else
                                SetCharacterValue("LeadershipProfessionTasks", $input, $i)
                                GUICtrlSetData($Button[$i], "* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *")
                                SaveIniCharacter("LeadershipProfessionTasks", $input, $i)
                            EndIf
                        EndIf
                        ExitLoop
                    EndIf
                Next
            Case $ButtonOK
                GUIDelete($hGUI)
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc
