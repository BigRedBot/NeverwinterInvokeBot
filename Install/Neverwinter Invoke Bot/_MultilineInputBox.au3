#include-once
;===============================================================================
;
; Function Name:   _MultilineInputBox
; Description::    Multiline Inputbox
; Parameter(s):    same as Inputbox, but without Psswordchar
; Requirement(s):
; Return Value(s): same as InputBox
; Author(s):       Oscar, Prog@ndy
;
;===============================================================================
Func _MultilineInputBox($title = "", $prompt = "", $Default = "", $width = 0, $height = 0, $left = Default, $top = Default, $timeOut = 0, $hWnd = 0)
    Local $OnEventMode = Opt('GUIOnEventMode', 0)
    Local $text = ""
    If $width < 400 Then $width = 400
    If $height < 330 Then $height = 330
    Local $widthAddition = $width-400
    Local $heightAddition = $height-330
    Local $error = 0
    Local $hGui = GUICreate($title, $width, $height, $left, $top, 0x00C00000+0x00080000,0,$hWnd)
    If @error Then
        $error = 3
    Else
        GUICtrlCreateLabel($prompt, 5, 5, 390, 90)
        If @error Then $error = 3
        Local $Edit = GUICtrlCreateEdit($Default, 5, 105, 390+$widthAddition, 190+$heightAddition)
        If @error Then $error = 3
        Local $hOK = GUICtrlCreateButton('&OK', 70, 300+$heightAddition, 80, 25)
        If @error Then $error = 3
        Local $htime = GUICtrlCreateLabel('', 170, 305+$heightAddition, 50, 20)
        If @error Then $error = 3
        Local $hCancel = GUICtrlCreateButton('&Cancel', 230, 300+$heightAddition, 80, 25)
        If @error Then $error = 3
        GUISetState(@SW_SHOW, $hGui)
        If @error Then $error = 3
        Local $timer = TimerInit(), $s1, $s2, $msg
        Do
            $msg = GUIGetMsg(1)
            If $msg[1] = $hGui Then
            Switch $msg[0]
                Case 0xFFFFFFFD, $hCancel ; 0xFFFFFFFD = $GUI_EVENT_CLOSE
                    $error = 1
                    ExitLoop
                Case $hOK
                    ExitLoop
            EndSwitch
            EndIf
            If $timeOut > 0 And TimerDiff($timer) >= $timeOut Then $error = 2
            $s1 = Round(($timeOut - TimerDiff($timer)) / 1000)
            If $timeOut And $s1 <> $s2 Then
                GUICtrlSetData($htime, $s1 & "s")
                $s2 = $s1
            EndIf
        Until $error
        If Not $error Then $text = GUICtrlRead($Edit)
        GUIDelete($hGui)
        Opt('GUIOnEventMode', $OnEventMode)
    EndIf
    SetError($error)
    Return $text
EndFunc