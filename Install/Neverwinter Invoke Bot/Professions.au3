
Local $MaxProfessionLevel = 25

Func RunProfessions(); If $RestartLoop Then Return 0
    If Not $EnableProfessions Or Not GetValue("EnableProfessions") Then Return
    Local $ProfessionLevel = -2, $ProfessionLoops = 0, $ProfessionTakeRewardsFailed = 0, $OverviewX, $OverviewY, $task = 1, $make_workers = 0, $lasttask = 0, $tasklist, $require_ingredients, $no_optional_assets, $leadership_found
    While 1
        If $ProfessionLoops >= 10 Then Return
        ClearWindows(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        $lasttask = 0
        MySend(GetValue("ProfessionsKey"))
        ProfessionsSleep(); If $RestartLoop Then Return 0
        If $RestartLoop Then Return 0
        While 1
        While 1
            If $ProfessionLoops >= 10 Then Return
            $ProfessionLoops += 1
            If ImageSearch("Professions_Overview") Then
                $OverviewX = $_ImageSearchX
                $OverviewY = $_ImageSearchY
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
                            $ProfessionLevel = -2
                            ProfessionsClickImage(); If $RestartLoop Then Return 0
                            If $RestartLoop Then Return 0
                        Else
                            $ProfessionLoops -= 1
                            $ProfessionTakeRewardsFailed = 1
                            ExitLoop 3
                        EndIf
                        MouseMove($ClientWidthCenter + Random(-50, 50, 1), $ClientBottom)
                    WEnd
                EndIf
                If Not ImageSearch("Professions_EmptySlot") Then
                    If Not DeclinePromptImageSearch("Later") And Not DeclinePromptImageSearch("Decline") Then Return
                    If Not ImageSearch("Professions_EmptySlot") Then Return
                EndIf
                If $ProfessionLevel = -2 Then
                    ProfessionsSleep(); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                    If Not ImageSearch("Professions_Leadership") Then
                        If $leadership_found Then ExitLoop 2
                        Return
                    EndIf
                    $leadership_found = 1
                    Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop - 44, $right = $_ImageSearchLeft + 100, $bottom = $_ImageSearchTop - 31, $tens, $ones, $image1, $image2, $tolerance = GetValue("ProfessionLevelImageTolerance")
                    $ProfessionLevel = $MaxProfessionLevel
                    While $ProfessionLevel > -1
                        If $ProfessionLevel < 10 Then
                            $tens = ""
                            $ones = $ProfessionLevel
                            $image1 = "Professions_Level" & $ones
                            $image2 = "Professions_LevelBlank"
                        Else
                            $tens = Floor($ProfessionLevel / 10)
                            $ones = $ProfessionLevel - $tens * 10
                            $image1 = "Professions_Level" & $tens
                            $image2 = "Professions_Level" & $ones
                        EndIf
                        If ImageSearch($image1, $left, $top, $right, $bottom, $tolerance) And ImageSearch("Professions_LevelBlank", $_ImageSearchLeft - 5, $_ImageSearchTop, $_ImageSearchLeft - 1, $_ImageSearchBottom, $tolerance) And ImageSearch($image2, $_ImageSearchRight + 11, $_ImageSearchTop, $_ImageSearchRight + 22, $_ImageSearchBottom, $tolerance) Then ExitLoop
                        $ProfessionLevel -= 1
                    WEnd
                    If $ProfessionLevel > -1 And GetValue("LeadershipProfessionTasks_Level_" & $ProfessionLevel) Then
                        $tasklist = StringSplit(GetValue("LeadershipProfessionTasks_Level_" & $ProfessionLevel), "|")
                        Splash("[ " & Localize("LeadershipLevel", "<LEVEL>", $ProfessionLevel) & " ]")
                    Else
                        $tasklist = StringSplit(GetValue("LeadershipProfessionTasks_Level_Unknown"), "|")
                        Splash("[ " & Localize("LeadershipLevel", "<LEVEL>", Localize("Unknown")) & " ]")
                    EndIf
                    $require_ingredients = StringSplit(GetValue("LeadershipProfessionTasks_RequireIngredients"), "|")
                    $no_optional_assets = StringSplit(GetValue("LeadershipProfessionTasks_NoOptionalAssets"), "|")
                EndIf
                If $task > $tasklist[0] Then Return
                If ImageSearch("Professions_Leadership") Then
                    ProfessionsClickImage(); If $RestartLoop Then Return 0
                    If $RestartLoop Then Return 0
                    While 1
                        If ImageSearch("Professions_Search") Then
                            If $task <> $lasttask Then
                                $lasttask = $task
                                $_ImageSearchX = $_ImageSearchLeft - 100 + Random(-50, 50, 1)
                                $_ImageSearchY = $_ImageSearchTop + Floor(($_ImageSearchHeight-1)/2) + Random(-5, 5, 1)
                                ProfessionsClickImage(); If $RestartLoop Then Return 0
                                If $RestartLoop Then Return 0
                                AutoItSetOption("SendKeyDownDelay", 5)
                                Send("{END}{BS 50}")
                                Sleep(100)
                                AutoItSetOption("SendKeyDownDelay", 15)
                                Send(StringLeft($tasklist[$task], 50), $SEND_RAW)
                                Sleep(100)
                                AutoItSetOption("SendKeyDownDelay", GetValue("KeyDelaySeconds") * 1000)
                                Send("{ENTER}")
                                ProfessionsSleep(); If $RestartLoop Then Return 0
                                If $RestartLoop Then Return 0
                            EndIf
                            If ImageSearch("Professions_Continue") Then
                                ProfessionsClickImage(); If $RestartLoop Then Return 0
                                If $RestartLoop Then Return 0
                                If _ArraySearch($no_optional_assets, $tasklist[$task], 1) = -1 And ProfessionsChooseAssets() Then; If $RestartLoop Then Return 0
                                    $make_workers = 1
                                    $task = 1
                                    $lasttask = 0
                                    $tasklist = StringSplit(GetValue("LeadershipProfessionTasks_Workers"), "|")
                                    $ProfessionLoops -= 1
                                    ExitLoop 3
                                EndIf
                                If $RestartLoop Then Return 0
                                If ImageSearch("Professions_StartTask") Then
                                    ProfessionsClickImage(); If $RestartLoop Then Return 0
                                    If $RestartLoop Then Return 0
                                    ExitLoop 2
                                Else
                                    ExitLoop 3
                                EndIf
                            ElseIf Not $make_workers And $ProfessionLevel > -1 And _ArraySearch($require_ingredients, $tasklist[$task], 1) = -1 And ImageSearch("Professions_Details") Then
                                $make_workers = 1
                                $task = 1
                                $lasttask = 0
                                $tasklist = StringSplit(GetValue("LeadershipProfessionTasks_Workers"), "|")
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

Func ProfessionsChooseAssets(); If $RestartLoop Then Return 0
    If Not $EnableOptionalAssets Or Not GetValue("EnableOptionalAssets") Then Return 0
    Local $retry = 0
    While 1
        If ImageSearch("Professions_Asset") And ImageSearch("Professions_Asset", $_ImageSearchLeft, $_ImageSearchBottom + 100, $_ImageSearchRight, $_ImageSearchBottom + 150) Then ExitLoop
        If $retry >= 10 Then Return 0
        If Not DeclinePromptImageSearch("Later") And Not DeclinePromptImageSearch("Decline") Then Sleep(1000)
        $retry += 1
    WEnd
    Local $left = $_ImageSearchX, $top = $_ImageSearchTop, $right = $_ImageSearchRight + 200, $select = 0, $workers = StringSplit(GetValue("LeadershipOptionalAssets"), "|")
    ProfessionsClickImage(); If $RestartLoop Then Return 0
    If $RestartLoop Then Return 0
    If ImageSearch("Professions_Asset_" & $workers[1], $left, $top, $left + 50) Then
        ProfessionsClickImage()
        Return 0
    EndIf
    If Not ImageSearch("Professions_AssetBorder", $left + 180, $top, $right, $top + 100) Then Return 0
    Local $borderleft = $_ImageSearchLeft, $borderright = $_ImageSearchRight
    MouseMove(Random($left + 20, $borderright - 10, 1), Random($_ImageSearchTop + 5, $_ImageSearchBottom - 5, 1))
    MouseWheel($MOUSE_WHEEL_UP)
    Sleep(GetValue("OptionalAssetsDelay") * 1000)
    Local $page = 1
    While Not ImageSearch("Professions_AssetBorder", $_ImageSearchLeft, $_ImageSearchTop, $_ImageSearchRight, $_ImageSearchBottom)
        If $page >= 60 Then Return 0
        MouseWheel($MOUSE_WHEEL_UP, 17)
        Sleep(GetValue("OptionalAssetsDelay") * 1000)
        If ImageSearch("Professions_Asset_" & $workers[1], $left, $top, $left + 50) Then
            ProfessionsClickImage()
            Return 0
        EndIf
        ImageSearch("Professions_AssetBorder", $borderleft, $top, $borderright, $top + 100)
        MouseWheel($MOUSE_WHEEL_UP)
        Sleep(GetValue("OptionalAssetsDelay") * 1000)
        $page += 1
    WEnd
    For $i = 2 To $workers[0]
        If ( Not $select Or $select > $i ) And ImageSearch("Professions_Asset_" & $workers[$i], $left, $top, $left + 50) Then $select = $i
    Next
    ImageSearch("Professions_AssetBorder", $borderleft, $top, $borderright, $top + 100)
    MouseWheel($MOUSE_WHEEL_DOWN)
    Sleep(GetValue("OptionalAssetsDelay") * 1000)
    $page = 1
    While Not ImageSearch("Professions_AssetBorder", $_ImageSearchLeft, $_ImageSearchTop, $_ImageSearchRight, $_ImageSearchBottom)
        If $page >= 60 Then Return 0
        MouseWheel($MOUSE_WHEEL_DOWN, 17)
        Sleep(GetValue("OptionalAssetsDelay") * 1000)
        If ImageSearch("Professions_Asset_" & $workers[1], $left, $top, $left + 50) Then
            ProfessionsClickImage()
            Return 0
        EndIf
        For $i = 2 To $workers[0]
            If ( Not $select Or $select > $i ) And ImageSearch("Professions_Asset_" & $workers[$i], $left, $top, $left + 50) Then $select = $i
        Next
        ImageSearch("Professions_AssetBorder", $borderleft, $top, $borderright, $top + 100)
        MouseWheel($MOUSE_WHEEL_DOWN)
        Sleep(GetValue("OptionalAssetsDelay") * 1000)
        $page += 1
    WEnd
    If Not $select Then Return 1
    If ImageSearch("Professions_Asset_" & $workers[$select], $left, $top, $left + 50) Then
        ProfessionsClickImage()
        Return 0
    EndIf
    ImageSearch("Professions_AssetBorder", $borderleft, $top, $borderright, $top + 100)
    MouseWheel($MOUSE_WHEEL_UP)
    Sleep(GetValue("OptionalAssetsDelay") * 1000)
    $page = 1
    While Not ImageSearch("Professions_AssetBorder", $_ImageSearchLeft, $_ImageSearchTop, $_ImageSearchRight, $_ImageSearchBottom)
        If $page >= 60 Then Return 0
        MouseWheel($MOUSE_WHEEL_UP, 17)
        Sleep(GetValue("OptionalAssetsDelay") * 1000)
        If ImageSearch("Professions_Asset_" & $workers[$select], $left, $top, $left + 50) Then
            ProfessionsClickImage()
            Return 0
        EndIf
        ImageSearch("Professions_AssetBorder", $borderleft, $top, $borderright, $top + 100)
        MouseWheel($MOUSE_WHEEL_UP)
        Sleep(GetValue("OptionalAssetsDelay") * 1000)
        $page += 1
    WEnd
    Return 0
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
    If ( $EnableProfessions And $EnableOptionalAssets ) Or $UnattendedModeCheckSettings Then Return
    _Crypt_Startup()
    If Not $EnableProfessions Then $EnableProfessions = CheckProfessionsUnlockCodeData("225BA7083CE6B485BE95CBDAF18CF6D025C4D7F3", "ProfessionsUnlockCode", "UnlockProfessions", "EnterProfessionsUnlockCode", "BuyProfessionsUnlockCode", "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=HBA5U7LQQ33BA")
    If $EnableProfessions And Not $EnableOptionalAssets Then $EnableOptionalAssets = CheckProfessionsUnlockCodeData("07016EDD9A3CB06164336D062698BFF2566696CF", "OptionalAssetsUnlockCode", "UnlockOptionalAssets", "EnterOptionalAssetsUnlockCode", "BuyOptionalAssetsUnlockCode", "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LWTPB6AEB4V86")
    _Crypt_Shutdown()
EndFunc

Func CheckProfessionsUnlockCodeData($hash, $code, $local1, $local2, $local3, $url)
    If Hex(_Crypt_HashData(StringUpper(StringStripWS(GetValue($code), $STR_STRIPALL)), $CALG_SHA1)) = $hash Then
        Return 1
    ElseIf Not $UnattendedMode And MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2, $Title, Localize($local1)) = $IDYES Then
        While 1
            Local $input = InputBox($Title, @CRLF & @CRLF & @CRLF & @CRLF & Localize($local2))
            If @error <> 0 Then
                If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize($local3)) = $IDYES Then
                    _Crypt_Shutdown()
                    Exit ShellExecute($url)
                EndIf
                Return 0
            EndIf
            $input = StringUpper(StringStripWS($input, $STR_STRIPALL))
            If Hex(_Crypt_HashData($input, $CALG_SHA1)) = $hash Then
                SetAllAccountsValue($code, $input)
                SavePrivateIniAllAccounts($code, $input)
                Return 1
            EndIf
        WEnd
    EndIf
    Return 0
EndFunc

Func ChooseProfessionsAccountEnableOptions()
    If Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots")
    Local $Checkbox[$Total + 1]
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
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
    Local $ButtonOK = GUICtrlCreateButton("&OK", _Max(163 + ((Ceiling($Total / 10) - 3) * 100), 163), 450, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Checkbox[0]
                GUICtrlSetState($ButtonOK, $GUI_DISABLE)
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
                GUICtrlSetState($ButtonOK, $GUI_ENABLE)
            Case $InfiniteLoopCheckbox
                If GUICtrlRead($InfiniteLoopCheckbox) = $GUI_CHECKED Then
                    GUICtrlSetState($InfiniteLoopMinutesButton, $GUI_ENABLE)
                Else
                    GUICtrlSetState($InfiniteLoopMinutesButton, $GUI_DISABLE)
                EndIf
            Case $InfiniteLoopMinutesButton
                Local $input = InputBox($Title, @CRLF & @CRLF & @CRLF & @CRLF & Localize("InfiniteLoopMinutes", "<MINUTES>", "( 80+ )"), GetAccountValue("InfiniteLoopDelayMinutes"), "", -1, -1, Default, Default, 0, $hGUI)
                If @error = 0 Then
                    GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                    $input = Number($input)
                    If $input <= 0 Then
                        $input = GetDefaultValue("InfiniteLoopDelayMinutes")
                    ElseIf $input <= 80 Then
                        $input = 80
                    EndIf
                    If $input == GetDefaultValue("InfiniteLoopDelayMinutes") Then
                        DeleteAccountValue("InfiniteLoopDelayMinutes")
                        DeleteIniAccount("InfiniteLoopDelayMinutes")
                    Else
                        SetAccountValue("InfiniteLoopDelayMinutes", $input)
                        SaveIniAccount("InfiniteLoopDelayMinutes", $input)
                    EndIf
                    GUICtrlSetData($InfiniteLoopMinutesButton, Localize("InfiniteLoopMinutes", "<MINUTES>", GetAccountValue("InfiniteLoopDelayMinutes")))
                    GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                EndIf
            Case $ButtonOK
                Local $enabled = 0
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("EnableProfessions") <> $enabled Then
                    If $enabled == GetDefaultValue("EnableProfessions") Then
                        DeleteAccountValue("EnableProfessions")
                        DeleteIniAccount("EnableProfessions")
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
                        DeleteIniAccount("InfiniteLoops")
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
                        DeleteIniCharacter("EnableProfessions", $i)
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

Func ChooseProfessionsAccountSetTasksOptions()
    If Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots"), $nMsg, $EnabledCharacterFound
    Local $Button[$Total + 1]
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    GUICtrlCreateLabel(Localize("EditProfessionTasks"), 150, 40, 270)
    Local $default = 1
    For $l = 0 To $MaxProfessionLevel + 1
        Local $level = $l
        If $l = $MaxProfessionLevel + 1 Then $level = "Unknown"
        If Not ( GetAccountValue("LeadershipProfessionTasks_Level_" & $level) == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) ) Then
            $default = 0
            ExitLoop
        EndIf
    Next
    If $default Then
        $Button[0] = GUICtrlCreateButton(Localize("AllCharacters"), 30, 70, 95)
    Else
        $Button[0] = GUICtrlCreateButton("* " & Localize("AllCharacters") & " *", 30, 70, 95)
    EndIf
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        Local $default = 1, $disabled = 0
        For $l = 0 To $MaxProfessionLevel + 1
            Local $level = $l
            If $l = $MaxProfessionLevel + 1 Then $level = "Unknown"
            If Not ( GetCharacterValue("LeadershipProfessionTasks_Level_" & $level, $i) == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) ) Then $default = 0
            If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then
                $EnabledCharacterFound = 1
                If Not ( GetAccountValue("LeadershipProfessionTasks_Level_" & $level) == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) ) Then $disabled = 1
            Else
                 $disabled = 1
            EndIf
        Next
        If $default Then
            $Button[$i] = GUICtrlCreateButton(Localize("CharacterNumber", "<NUMBER>", $i), 30 + (($Row - 1) * 100), 100 + ($Column * 30), 95)
        Else
            $Button[$i] = GUICtrlCreateButton("* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *", 30 + (($Row - 1) * 100), 100 + ($Column * 30), 95)
        EndIf
        If $disabled Then GUICtrlSetState($Button[$i], $GUI_DISABLE)
    Next
    If Not $EnabledCharacterFound Then
        GUIDelete($hGUI)
        Return
    EndIf
    Local $ButtonOK = GUICtrlCreateButton("&OK", _Max(163 + ((Ceiling($Total / 10) - 3) * 100), 163), 450, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
    GUISetState()
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Button[0]
                Local $results = ChooseProfessionsAccountSetTasksOptionsLevels($hGUI, Localize("EditProfessionTasksForAllCharacters"))
                If @error = 0 And MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2, $Title, Localize("OverwriteProfessionTasksForAllOtherCharacters", "<ACCOUNT>", $CurrentAccount), 0, $hGUI) = $IDYES Then
                    GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                    For $i = 0 To $Total
                        GUICtrlSetData($Button[0], Localize("Working"))
                        GUICtrlSetState($Button[$i], $GUI_DISABLE)
                    Next
                    Local $default = 1
                    For $l = 0 To $MaxProfessionLevel + 1
                        Local $level = $l
                        If $l = $MaxProfessionLevel + 1 Then $level = "Unknown"
                        $results[$l] = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($results[$l], "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "|"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                        If $results[$l] = "" Then $results[$l] = GetDefaultValue("LeadershipProfessionTasks_Level_" & $level)
                        If $results[$l] == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) Then
                            DeleteAccountValue("LeadershipProfessionTasks_Level_" & $level)
                            DeleteIniAccount("LeadershipProfessionTasks_Level_" & $level)
                        Else
                            $default = 0
                            SetAccountValue("LeadershipProfessionTasks_Level_" & $level, $results[$l])
                            SaveIniAccount("LeadershipProfessionTasks_Level_" & $level, $results[$l])
                        EndIf
                    Next
                    For $i = 1 To $Total
                        GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                        Local $disabled = 0
                        For $l = 0 To $MaxProfessionLevel + 1
                            Local $level = $l
                            If $l = $MaxProfessionLevel + 1 Then $level = "Unknown"
                            DeleteIniCharacter("LeadershipProfessionTasks_Level_" & $level, $i)
                            DeleteCharacterValue("LeadershipProfessionTasks_Level_" & $level, $i)
                            If Not ( GetAccountValue("LeadershipProfessionTasks_Level_" & $level) == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) ) Then $disabled = 1
                        Next
                        If $disabled Then
                            GUICtrlSetState($Button[$i], $GUI_DISABLE)
                        ElseIf GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then
                            GUICtrlSetState($Button[$i], $GUI_ENABLE)
                        EndIf
                    Next
                    GUICtrlSetState($Button[0], $GUI_ENABLE)
                    If $default Then
                        GUICtrlSetData($Button[0], Localize("AllCharacters"))
                    Else
                        GUICtrlSetData($Button[0], "* " & Localize("AllCharacters") & " *")
                    EndIf
                    GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                EndIf
            Case $Button[1] To $Button[$Total]
                For $i = 1 To $Total
                    If $Button[$i] = $nMsg Then
                        Local $results = ChooseProfessionsAccountSetTasksOptionsLevels($hGUI, Localize("EditProfessionTasksForCharacter", "<NUMBER>", $i), $i)
                        If @error = 0 Then
                            GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                            Local $default = 1
                            For $l = 0 To $MaxProfessionLevel + 1
                                Local $level = $l
                                If $l = $MaxProfessionLevel + 1 Then $level = "Unknown"
                                $results[$l] = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($results[$l], "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "|"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                                If $results[$l] = "" Then $results[$l] = GetDefaultValue("LeadershipProfessionTasks_Level_" & $level)
                                If $results[$l] == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) Then
                                    DeleteCharacterValue("LeadershipProfessionTasks_Level_" & $level, $i)
                                    DeleteIniCharacter("LeadershipProfessionTasks_Level_" & $level, $i)
                                Else
                                    $default = 0
                                    SetCharacterValue("LeadershipProfessionTasks_Level_" & $level, $results[$l], $i)
                                    SaveIniCharacter("LeadershipProfessionTasks_Level_" & $level, $results[$l], $i)
                                EndIf
                            Next
                            If $default Then
                                GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                            Else
                                GUICtrlSetData($Button[$i], "* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *")
                            EndIf
                            GUICtrlSetState($ButtonOK, $GUI_ENABLE)
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

Func ChooseProfessionsAccountSetTasksOptionsLevels($hWnd = 0, $label = 0, $character = 0)
    If Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = $MaxProfessionLevel + 1, $nMsg
    Local $Button[$Total + 1]
    Local $results[$Total + 1]
    Local $hGUI = GUICreate($Title, 360, 440, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    GUICtrlCreateLabel($label, 100, 40, 270)
    For $l = 0 To $Total
        Local $Row = Ceiling(($l + 1) / 10), $Column = ($l + 1) - (($Row - 1) * 10), $level = $l
        If $l = $Total Then $level = "Unknown"
        If $character Then
            $results[$l] = GetCharacterValue("LeadershipProfessionTasks_Level_" & $level, $character)
        Else
            $results[$l] = GetAccountValue("LeadershipProfessionTasks_Level_" & $level)
        EndIf
        If $results[$l] == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) Then
            $Button[$l] = GUICtrlCreateButton(Localize("LevelNumber", "<LEVEL>", Localize($level)), 30 + (($Row - 1) * 100), 50 + ($Column * 30), 95)
        Else
            $Button[$l] = GUICtrlCreateButton("* " & Localize("LevelNumber", "<LEVEL>", Localize($level)) & " *", 30 + (($Row - 1) * 100), 50 + ($Column * 30), 95)
        EndIf
    Next
    Local $ButtonOK = GUICtrlCreateButton("&OK", 163, 400, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 250, 400, 75, 25)
    GUISetState()
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $Button[0] To $Button[$Total]
                For $l = 0 To $Total
                    If $Button[$l] = $nMsg Then
                        Local $level = $l
                        If $l = $Total Then $level = "Unknown"
                        Local $txt = Localize("EditProfessionLevelTasksForAllCharacters", "<LEVEL>", Localize($level))
                        If $character Then $txt = Localize("EditProfessionLevelTasksForCharacter", "<LEVEL>", Localize($level), "<NUMBER>", $character)
                        Local $input = _MultilineInputBox($Title, Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount) & @CRLF & @CRLF & @CRLF & $txt, StringReplace($results[$l], "|", @CRLF), 0, 0, Default, Default, 0, $hGUI)
                        If @error = 0 Then
                            GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                            $input = StringStripWS(StringRegExpReplace(StringRegExpReplace(StringRegExpReplace($input, "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", ""), "\s*" & @CRLF & "\s*", "|"), $STR_STRIPLEADING + $STR_STRIPTRAILING)
                            If $input = "" Then $input = GetDefaultValue("LeadershipProfessionTasks_Level_" & $level)
                            $results[$l] = $input
                            If $results[$l] == GetDefaultValue("LeadershipProfessionTasks_Level_" & $level) Then
                                GUICtrlSetData($Button[$l], Localize("LevelNumber", "<LEVEL>", Localize($level)))
                            Else
                                GUICtrlSetData($Button[$l], "* " & Localize("LevelNumber", "<LEVEL>", Localize($level)) & " *")
                            EndIf
                            GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                        EndIf
                        ExitLoop
                    EndIf
                Next
            Case $ButtonOK
                GUIDelete($hGUI)
                Return SetError(0, 0, $results)
            Case $ButtonCancel
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($hGUI)
    Return SetError(1, 0, 0)
EndFunc

Func ChooseProfessionsAccountEnableAssetsOptions()
    If Not $EnableOptionalAssets Or Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots"), $EnabledCharacterFound
    Local $Checkbox[$Total + 1]
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    GUICtrlCreateLabel(Localize("EnableOptionalAssets", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    $Checkbox[0] = GUICtrlCreateCheckbox(Localize("AllCharacters"), 40, 70, 100)
    If GetAccountValue("EnableOptionalAssets") Then GUICtrlSetState($Checkbox[0], $GUI_CHECKED)
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        $Checkbox[$i] = GUICtrlCreateCheckbox(Localize("CharacterNumber", "<NUMBER>", $i), 40 + (($Row - 1) * 100), 100 + ($Column * 30), 100)
        If GetAccountValue("EnableOptionalAssets") Then
            If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
            GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        ElseIf GetCharacterValue("EnableOptionalAssets", $i) Then
            If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
        EndIf
        If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then
            $EnabledCharacterFound = 1
            If Not ( GetAccountValue("EnableOptionalAssets") == GetDefaultValue("EnableOptionalAssets") ) Then GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        Else
            GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
        EndIf
    Next
    If Not $EnabledCharacterFound Then
        GUIDelete($hGUI)
        Return
    EndIf
    Local $ButtonOK = GUICtrlCreateButton("&OK", _Max(163 + ((Ceiling($Total / 10) - 3) * 100), 163), 450, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Checkbox[0]
                GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then
                    For $i = 1 To $Total
                        If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then GUICtrlSetState($Checkbox[$i], $GUI_CHECKED)
                        GUICtrlSetState($Checkbox[$i], $GUI_DISABLE)
                    Next
                Else
                    For $i = 1 To $Total
                        If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then GUICtrlSetState($Checkbox[$i], $GUI_ENABLE)
                        GUICtrlSetState($Checkbox[$i], $GUI_UNCHECKED)
                    Next
                EndIf
                GUICtrlSetState($ButtonOK, $GUI_ENABLE)
            Case $ButtonOK
                Local $enabled = 0
                If GUICtrlRead($Checkbox[0]) = $GUI_CHECKED Then $enabled = 1
                If GetAccountValue("EnableOptionalAssets") <> $enabled Then
                    If $enabled == GetDefaultValue("EnableOptionalAssets") Then
                        DeleteAccountValue("EnableOptionalAssets")
                        DeleteIniAccount("EnableOptionalAssets")
                    Else
                        SetAccountValue("EnableOptionalAssets", $enabled)
                        SaveIniAccount("EnableOptionalAssets", $enabled)
                    EndIf
                EndIf
                For $i = 1 To $Total
                    $enabled = 0
                    If GetAccountValue("EnableOptionalAssets") Or GUICtrlRead($Checkbox[$i]) = $GUI_CHECKED Then $enabled = 1
                    If GetAccountValue("EnableOptionalAssets") Or $enabled == GetDefaultValue("EnableOptionalAssets") Then
                        DeleteCharacterValue("EnableOptionalAssets", $i)
                        DeleteIniCharacter("EnableOptionalAssets", $i)
                    Else
                        SetCharacterValue("EnableOptionalAssets", $enabled, $i)
                        SaveIniCharacter("EnableOptionalAssets", $enabled, $i)
                    EndIf
                Next
                GUIDelete($hGUI)
                Return
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

Func ChooseProfessionsAccountSetAssetsOptions()
    If Not $EnableOptionalAssets Or Not $EnableProfessions Or $UnattendedMode Or $UnattendedModeCheckSettings Then Return
    Local $Total = GetValue("TotalSlots"), $nMsg, $EnabledCharacterFound
    Local $Button[$Total + 1]
    Local $hGUI = GUICreate($Title, _Max(60 + (Ceiling($Total / 10) * 100), 360), 490)
    GUICtrlCreateLabel(Localize("AccountNumber", "<ACCOUNT>", $CurrentAccount), 25, 20, 150)
    GUICtrlCreateLabel(Localize("EditOptionalAssets", "<ACCOUNT>", $CurrentAccount), 150, 40, 270)
    If GetAccountValue("LeadershipOptionalAssets") == GetDefaultValue("LeadershipOptionalAssets") Then
        $Button[0] = GUICtrlCreateButton(Localize("AllCharacters"), 30, 70, 95)
    Else
        $Button[0] = GUICtrlCreateButton("* " & Localize("AllCharacters") & " *", 30, 70, 95)
    EndIf
    For $i = 1 To $Total
        Local $Row = Ceiling($i / 10), $Column = $i - (($Row - 1) * 10)
        If GetCharacterValue("LeadershipOptionalAssets", $i) == GetDefaultValue("LeadershipOptionalAssets") Then
            $Button[$i] = GUICtrlCreateButton(Localize("CharacterNumber", "<NUMBER>", $i), 30 + (($Row - 1) * 100), 100 + ($Column * 30), 95)
        Else
            $Button[$i] = GUICtrlCreateButton("* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *", 30 + (($Row - 1) * 100), 100 + ($Column * 30), 95)
        EndIf
        If ( GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) ) And ( GetAccountValue("EnableOptionalAssets") Or GetCharacterValue("EnableOptionalAssets", $i) ) Then
            $EnabledCharacterFound = 1
            If Not ( GetAccountValue("LeadershipOptionalAssets") == GetDefaultValue("LeadershipOptionalAssets") ) Then GUICtrlSetState($Button[$i], $GUI_DISABLE)
        Else
            GUICtrlSetState($Button[$i], $GUI_DISABLE)
        EndIf
    Next
    If Not $EnabledCharacterFound Then
        GUIDelete($hGUI)
        Return
    EndIf
    Local $ButtonOK = GUICtrlCreateButton("&OK", _Max(163 + ((Ceiling($Total / 10) - 3) * 100), 163), 450, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", _Max(250 + ((Ceiling($Total / 10) - 3) * 100), 250), 450, 75, 25)
    GUISetState()
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $Button[0]
                Local $input = SetProfessionsAccountAssets(Localize("EditOptionalAssetsForAllCharacters"), GetAccountValue("LeadershipOptionalAssets"), $hGUI)
                If @error = 0 And ( Not ( GetAccountValue("LeadershipOptionalAssets") == GetDefaultValue("LeadershipOptionalAssets") ) Or MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2, $Title, Localize("OverwriteOptionalAssetsForAllOtherCharacters", "<ACCOUNT>", $CurrentAccount), 0, $hGUI) = $IDYES ) Then
                    GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                    If $input == GetDefaultValue("LeadershipOptionalAssets") Then
                        DeleteAccountValue("LeadershipOptionalAssets")
                        GUICtrlSetData($Button[0], Localize("AllCharacters"))
                        DeleteIniAccount("LeadershipOptionalAssets")
                    Else
                        SetAccountValue("LeadershipOptionalAssets", $input)
                        GUICtrlSetData($Button[0], "* " & Localize("AllCharacters") & " *")
                        SaveIniAccount("LeadershipOptionalAssets", $input)
                    EndIf
                    For $i = 1 To $Total
                        GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                        DeleteIniCharacter("LeadershipOptionalAssets", $i)
                        DeleteCharacterValue("LeadershipOptionalAssets", $i)
                        If $input == GetDefaultValue("LeadershipOptionalAssets") Then
                            If GetAccountValue("EnableProfessions") Or GetCharacterValue("EnableProfessions", $i) Then GUICtrlSetState($Button[$i], $GUI_ENABLE)
                        Else
                            GUICtrlSetState($Button[$i], $GUI_DISABLE)
                        EndIf
                    Next
                    GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                EndIf
            Case $Button[1] To $Button[$Total]
                For $i = 1 To $Total
                    If $Button[$i] = $nMsg Then
                        Local $input = SetProfessionsAccountAssets(Localize("EditOptionalAssetsForCharacter", "<NUMBER>", $i), GetCharacterValue("LeadershipOptionalAssets", $i), $hGUI)
                        If @error = 0 Then
                            GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                            If $input == GetDefaultValue("LeadershipOptionalAssets") Then
                                DeleteCharacterValue("LeadershipOptionalAssets", $i)
                                GUICtrlSetData($Button[$i], Localize("CharacterNumber", "<NUMBER>", $i))
                                DeleteIniCharacter("LeadershipOptionalAssets", $i)
                            Else
                                SetCharacterValue("LeadershipOptionalAssets", $input, $i)
                                GUICtrlSetData($Button[$i], "* " & Localize("CharacterNumber", "<NUMBER>", $i) & " *")
                                SaveIniCharacter("LeadershipOptionalAssets", $input, $i)
                            EndIf
                            GUICtrlSetState($ButtonOK, $GUI_ENABLE)
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

Func SetProfessionsAccountAssets($msg, $setting, $hWnd = 0)
    Local $hGui = GUICreate($Title, 350, 440, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd)
    GUICtrlCreateLabel($msg, 25, 20, 325)
    Local $DefaultWorkers = StringSplit(GetDefaultValue("LeadershipOptionalAssets"), "|"), $TestWorkers = StringSplit($setting & "|" & GetDefaultValue("LeadershipOptionalAssets"), "|")
    Local $Total = $DefaultWorkers[0], $ButtonUp[$Total + 1], $ButtonDown[$Total + 1], $Label[$Total + 1], $Border[$Total + 1], $Image[$Total + 1], $Colors[$Total + 1], $DeleteWorkers = "0", $nMsg
    For $i = 1 To $Total
        $Colors[$i] = $COLOR_WHITE
    Next
    $Colors[1] = $COLOR_PURPLE
    $Colors[2] = $COLOR_BLUE
    $Colors[3] = $COLOR_GREEN
    For $i = 1 To $TestWorkers[0]
        Local $found = 0
        For $i2 = 1 To $Total
            If $TestWorkers[$i] == $DefaultWorkers[$i2] Then $found = 1
        Next
        If Not $found Then $DeleteWorkers &= ";" & $i
    Next
    _ArrayDelete($TestWorkers, $DeleteWorkers)
    Local $Workers = _ArrayUnique($TestWorkers)
    For $i = 1 To $Total
        $Label[$i] = GUICtrlCreateLabel(Localize($Workers[$i]), 0, 55 * $i + 14, 150, -1, $SS_RIGHT)
        $Border[$i] = GUICtrlCreateGraphic(158, 55 * $i + 4, 34, 34)
        Local $color = $COLOR_WHITE, $c = _ArraySearch($DefaultWorkers, $Workers[$i], 1)
        If $c > 0 Then $color = $Colors[$c]
        GUICtrlSetBkColor($Border[$i], $color)
        $Image[$i] = GUICtrlCreatePic("", 160, 55 * $i + 6, 30, 30)
        _SetImage($Image[$i], @ScriptDir & "\images\" & $Language & "\Professions_Asset_" & $Workers[$i] & ".png")
    Next
    For $i = 1 To $Total
        $ButtonUp[$i] = GUICtrlCreateButton(ChrW(9650), 200, 55 * $i, 20, 20)
    Next
    For $i = 1 To $Total
        $ButtonDown[$i] = GUICtrlCreateButton(ChrW(9660), 200, 55 * $i + 22, 20, 20)
    Next
    Local $ButtonDefault = GUICtrlCreateButton(Localize("Default"), 40, 400, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 168, 400, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 250, 400, 75, 25)
    GUISetState(@SW_SHOW, $hGui)
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $ButtonUp[1] To $ButtonUp[$Total]
                For $i = 1 To $Total
                    If $ButtonUp[$i] = $nMsg Then
                        GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                        Local $i2 = $i - 1
                        If $i = 1 Then $i2 = $Total
                        Local $first = $Workers[$i], $second = $Workers[$i2]
                        $Workers[$i2] = $first
                        $Workers[$i] = $second
                        For $i = 1 To $Total
                            GUICtrlSetData($Label[$i], Localize($Workers[$i]))
                            Local $color = $COLOR_WHITE, $c = _ArraySearch($DefaultWorkers, $Workers[$i], 1)
                            If $c > 0 Then $color = $Colors[$c]
                            GUICtrlSetBkColor($Border[$i], $color)
                            _SetImage($Image[$i], @ScriptDir & "\images\" & $Language & "\Professions_Asset_" & $Workers[$i] & ".png")
                        Next
                        GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                        ExitLoop
                    EndIf
                Next
            Case $ButtonDown[1] To $ButtonDown[$Total]
                For $i = 1 To $Total
                    If $ButtonDown[$i] = $nMsg Then
                        GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                        Local $i2 = $i + 1
                        If $i = $Total Then $i2 = 1
                        Local $first = $Workers[$i], $second = $Workers[$i2]
                        $Workers[$i2] = $first
                        $Workers[$i] = $second
                        For $i = 1 To $Total
                            GUICtrlSetData($Label[$i], Localize($Workers[$i]))
                            Local $color = $COLOR_WHITE, $c = _ArraySearch($DefaultWorkers, $Workers[$i], 1)
                            If $c > 0 Then $color = $Colors[$c]
                            GUICtrlSetBkColor($Border[$i], $color)
                            _SetImage($Image[$i], @ScriptDir & "\images\" & $Language & "\Professions_Asset_" & $Workers[$i] & ".png")
                        Next
                        GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                        ExitLoop
                    EndIf
                Next
            Case $ButtonDefault
                GUICtrlSetState($ButtonOK, $GUI_DISABLE)
                For $i = 1 To $Total
                    $Workers[$i] = $DefaultWorkers[$i]
                    GUICtrlSetData($Label[$i], Localize($Workers[$i]))
                    Local $color = $COLOR_WHITE, $c = _ArraySearch($DefaultWorkers, $Workers[$i], 1)
                    If $c > 0 Then $color = $Colors[$c]
                    GUICtrlSetBkColor($Border[$i], $color)
                    _SetImage($Image[$i], @ScriptDir & "\images\" & $Language & "\Professions_Asset_" & $Workers[$i] & ".png")
                Next
                GUICtrlSetState($ButtonOK, $GUI_ENABLE)
            Case $ButtonOK
                GUIDelete($hGUI)
                Return SetError(0, 0, _ArrayToString($Workers , "|", 1))
            Case $ButtonCancel
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($hGUI)
    Return SetError(1, 0, 0)
EndFunc
