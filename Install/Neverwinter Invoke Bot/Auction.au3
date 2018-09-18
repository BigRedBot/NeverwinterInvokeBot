#NoTrayIcon
#RequireAdmin
Global $Name = "Neverwinter Invoke Bot: Auction"
Global $Title = $Name
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("AuctionAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\teal.ico")
TrayItemSetOnEvent($TrayExitItem, "End")
AutoItSetOption("TrayIconHide", 0)
TraySetToolTip($Title)
#include "_ImageSearch.au3"
#include "_GUIScrollbars_Ex.au3"
#Include "_Icons.au3"

Local $MouseOffset = 5, $KeyDelay = GetValue("KeyDelaySeconds") * 1000

Func Position()
    Focus()
    If Not $WinHandle Or Not GetPosition() Then
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
        Return 0
    EndIf
    If Not GetValue("GameClientWidth") Or Not GetValue("GameClientHeight") Then Return
    If $WinLeft = 0 And $WinTop = 0 And $WinWidth = $DeskTopWidth And $WinHeight = $DeskTopHeight And $ClientWidth = $DeskTopWidth And $ClientHeight = $DeskTopHeight And ( GetValue("GameClientWidth") <> $DeskTopWidth Or GetValue("GameClientHeight") <> $DeskTopHeight ) Then
        MsgBox($MB_ICONWARNING, $Title, Localize("UnMaximize"))
        End()
    ElseIf $DeskTopWidth < GetValue("GameClientWidth") Or $DeskTopHeight < GetValue("GameClientHeight") Then
        MsgBox($MB_ICONWARNING, $Title, Localize("ResolutionOrHigher", "<RESOLUTION>", GetValue("GameClientWidth") & "x" & GetValue("GameClientHeight")))
        End()
    ElseIf $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Return 0
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0, GetValue("GameClientWidth") + $PaddingWidth, GetValue("GameClientHeight") + $PaddingHeight)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Return 0
        EndIf
        If $ClientWidth <> GetValue("GameClientWidth") Or $ClientHeight <> GetValue("GameClientHeight") Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToResize"))
            End()
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterResized"))
        Return 0
    ElseIf $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
        If $DeskTopWidth < GetValue("GameClientWidth") + $PaddingWidth Or $DeskTopHeight < GetValue("GameClientHeight") + $PaddingHeight Then
            Local $ostyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $WinHandle, "int", -16)
            DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $WinHandle, "int", -16, "long", BitAND($ostyle[0], BitNOT($WS_BORDER + $WS_DLGFRAME + $WS_THICKFRAME)))
            DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $WinHandle, "hwnd", $WinHandle, "int", 0, "int", 0, "int", 0, "int", 0, "long", BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))
            Focus()
            If Not $WinHandle Or Not GetPosition() Then
                MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
                Return 0
            EndIf
        EndIf
        WinMove($WinHandle, "", 0, 0)
        Focus()
        If Not $WinHandle Or Not GetPosition() Then
            MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterNotFound"))
            Return 0
        EndIf
        If $ClientLeft < 0 Or $ClientTop < 0 Or $ClientRight >= $DeskTopWidth Or $ClientBottom >= $DeskTopHeight Then
            MsgBox($MB_ICONWARNING, $Title, Localize("UnableToMove"))
            End()
        EndIf
        MsgBox($MB_ICONWARNING, $Title, Localize("NeverwinterMoved"))
        Return 0
    EndIf
    WinSetOnTop($WinHandle, "", 1)
    Return 1
EndFunc

Local $SplashWindow, $LastSplashText = "", $SplashLeft = @DesktopWidth - GetValue("SplashWidth") - 70 - 1, $SplashTop = @DesktopHeight - GetValue("SplashHeight") - 50 - 1

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", Localize("ToStopPressEsc") & @CRLF & @CRLF & $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, Localize("ToStopPressEsc") & @CRLF & @CRLF & $s, GetValue("SplashWidth"), GetValue("SplashHeight"), $SplashLeft, $SplashTop - 50, $DLG_MOVEABLE + $DLG_NOTONTOP)
        $LastSplashText = $s
        WinSetOnTop($SplashWindow, "", 0)
    EndIf
EndFunc

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"))
    If Not ImageExists($image) Then Return 0
    If _ImageSearch($ImagePath & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While ImageExists($image & "-" & $i)
        If _ImageSearch($ImagePath & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Func ImageExists($image)
    Return FileExists($FullImagePath & $image & ".png")
EndFunc

Func End()
    If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
    Exit
EndFunc

Local $speed = 2, $Item_Number = 0, $AD_Number = "", $itemQuantity = 1, $left, $top, $right, $bottom, $n, $loop, $itemArray = StringSplit(GetValue("AuctionItems"), "|")

Func Auction()
    While 1
    While 1
        $left = 0
        $loop = 0
        HotKeySet("{Esc}")
        If $WinHandle Then WinSetOnTop($WinHandle, "", 0)
        SplashOff()
        $SplashWindow = 0
        SetAuctionOptions()
        If Not Position() Then ExitLoop
        HotKeySet("{Esc}", "Auction")
        Splash(@CRLF & $itemQuantity & " x " & Localize($itemArray[$Item_Number]) & @CRLF & @CRLF & AddCommas($AD_Number) & " AD")
        While 1
            $loop += 1
            If Not $left Then
                If Not ImageSearch("Auction_Click_Here") Then ExitLoop
                $left = $_ImageSearchLeft
                $top = $_ImageSearchTop
                $right = $_ImageSearchRight
                $bottom = $_ImageSearchBottom
            EndIf
            MyMouseMove(Random($left, $right, 1), Random($top, $bottom, 1), $speed)
            SingleClick()
            Sleep(500)
            MyMouseMove($OffsetX + Random(490, 508, 1), $OffsetY + Random(251, 530, 1), $speed)
            $n = 0
            While 1
                If Not ImageSearch("Auction_Button_Select", $OffsetX + 357, $OffsetY + 601, $OffsetX + 504, $OffsetY + 624) Then ExitLoop 2
                If $itemQuantity == 1 Then
                    If ImageSearch("Item_Half_" & $itemArray[$Item_Number], $OffsetX + 215, $OffsetY + 242, $OffsetX + 488, $OffsetY + 533) Then ExitLoop
                Else
                    If ImageSearch("Item_99x_" & $itemArray[$Item_Number], $OffsetX + 215, $OffsetY + 242, $OffsetX + 488, $OffsetY + 533) Then ExitLoop
                EndIf
                If $n == 14 Then
                    HotKeySet("{Esc}")
                    Send("{ESC}")
                    ExitLoop 2
                EndIf
                $n += 1
                MouseWheel($MOUSE_WHEEL_DOWN, 7)
                Sleep(100)
            WEnd
            MyMouseMove($_ImageSearchX, $_ImageSearchY, $speed)
            DoubleClick()
            If ImageSearch("OpenAnotherOK") Then
                If $itemQuantity == 1 Then
                    Send("{BS 2}1")
                Else
                    Send("99")
                EndIf
                MyMouseMove($_ImageSearchX, $_ImageSearchY, $speed)
                SingleClick()
            EndIf
            Sleep(500)
            If $itemQuantity == 1 Then
                If Not ImageSearch("Item_1x_" & $itemArray[$Item_Number], $left, $top, $left + 45, $bottom) Then ExitLoop
            Else
                If Not ImageSearch("Item_Half_" & $itemArray[$Item_Number], $left, $top, $left + 45, $bottom) Then ExitLoop
            EndIf
            MyMouseMove($left + Random(93, 112, 1), $bottom + Random(36, 53, 1), $speed)
            SingleClick()
            Send("{BS}")
            MyMouseMove($left + Random(93, 112, 1), $bottom + Random(93, 110, 1), $speed)
            SingleClick()
            Send("{BS}" & $AD_Number)
            Sleep(500)
            If Not ImageSearch("Auction_Button_Post", $left, $bottom + 110, $right) Then ExitLoop
            MyMouseMove($_ImageSearchX, $_ImageSearchY, $speed)
            SingleClick()
            If $loop == 100 Then ExitLoop
            Sleep(500)
            $n = 0
            While ImageSearch("Item_Half_" & $itemArray[$Item_Number], $left, $top, $left + 45, $bottom)
                If $n == 50 Then ExitLoop
                $n += 1
                Sleep(200)
            WEnd
        WEnd
    WEnd
    WEnd
EndFunc

Func SetAuctionOptions($hWnd = 0)
    Local $hGUI = GUICreate($Title, 350, 210, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd), $nMsg
    Local $Label = GUICtrlCreateLabel(Localize("ClickOKToPostItemsToAuction"), 25, 20, 325)
    Local $ImageIcon = GUICtrlCreatePic("", 70, 55, 38, 38)
    Local $ImageLabel = GUICtrlCreateLabel("", 120, 66, 200, 20)
    Local $ButtonSelect = GUICtrlCreateButton("&Select", 130, 60, 75, 25)
    Local $Checkbox = GUICtrlCreateCheckbox("99x", 20, 65, 40, 20)
    Local $ADInput = GUICtrlCreateInput(AddCommas($AD_Number), 100, 130, 120, 20)
    Local $ADIcon = GUICtrlCreatePic("", 224, 130, 16, 16)
    Local $ButtonOK = GUICtrlCreateButton("&OK", 168, 170, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("&Cancel", 250, 170, 75, 25)
    If $Item_Number Then
        GUICtrlSetState($ButtonSelect, $GUI_HIDE)
        If Not ImageExists("Item_99x_" & $itemArray[$Item_Number]) Then
            $itemQuantity = 1
            GUICtrlSetState($Checkbox, $GUI_DISABLE)
        ElseIf Not ImageExists("Item_1x_" & $itemArray[$Item_Number]) Then
            $itemQuantity = 99
            GUICtrlSetState($Checkbox, $GUI_DISABLE)
        EndIf
        If $itemQuantity == 1 Then
            _SetImage($ImageIcon, $FullImagePath & "Item_1x_" & $itemArray[$Item_Number] & ".png")
        Else
            _SetImage($ImageIcon, $FullImagePath & "Item_99x_" & $itemArray[$Item_Number] & ".png")
            GUICtrlSetState($Checkbox, $GUI_CHECKED)
        EndIf
        GUICtrlSetData($ImageLabel, Localize($itemArray[$Item_Number]))
        GuiCtrlSetState($ADInput, $GUI_FOCUS)
        _SetImage($ADIcon, $FullImagePath & "AD.png")
    Else
        GUICtrlSetState($Label, $GUI_HIDE)
        GUICtrlSetState($ImageIcon, $GUI_HIDE)
        GUICtrlSetState($ImageLabel, $GUI_HIDE)
        GUICtrlSetState($Checkbox, $GUI_DISABLE)
        GUICtrlSetState($ButtonOK, $GUI_DISABLE)
        GUICtrlSetState($ADInput, $GUI_DISABLE)
        _SetImage($ADIcon, $FullImagePath & "AD_BW.png")
        GuiCtrlSetState($ButtonSelect, $GUI_FOCUS)
    EndIf
    GUISetState(@SW_SHOW, $hGUI)
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $Checkbox
                If GUICtrlRead($Checkbox) = $GUI_CHECKED Then
                    $itemQuantity = 99
                    _SetImage($ImageIcon, $FullImagePath & "Item_99x_" & $itemArray[$Item_Number] & ".png")
                Else
                    $itemQuantity = 1
                    _SetImage($ImageIcon, $FullImagePath & "Item_1x_" & $itemArray[$Item_Number] & ".png")
                EndIf
                $AD_Number = ""
                GUICtrlSetData($ADInput, $AD_Number)
                GuiCtrlSetState($ADInput, $GUI_FOCUS)
            Case $ImageIcon
                If SelectAuctionItem() Then
                    $itemQuantity = 1
                    If Not ImageExists("Item_99x_" & $itemArray[$Item_Number]) Then
                        $itemQuantity = 1
                        GUICtrlSetState($Checkbox, $GUI_DISABLE)
                    ElseIf Not ImageExists("Item_1x_" & $itemArray[$Item_Number]) Then
                        $itemQuantity = 99
                        GUICtrlSetState($Checkbox, $GUI_DISABLE)
                    Else
                        GUICtrlSetState($Checkbox, $GUI_ENABLE)
                    EndIf
                    If $itemQuantity == 1 Then
                        _SetImage($ImageIcon, $FullImagePath & "Item_1x_" & $itemArray[$Item_Number] & ".png")
                        GUICtrlSetState($Checkbox, $GUI_UNCHECKED)
                    Else
                        _SetImage($ImageIcon, $FullImagePath & "Item_99x_" & $itemArray[$Item_Number] & ".png")
                        GUICtrlSetState($Checkbox, $GUI_CHECKED)
                    EndIf
                    GUICtrlSetData($ImageLabel, Localize($itemArray[$Item_Number]))
                    $AD_Number = ""
                    GUICtrlSetData($ADInput, $AD_Number)
                    GUICtrlSetState($ADInput, $GUI_ENABLE)
                    _SetImage($ADIcon, $FullImagePath & "AD.png")
                    GUICtrlSetState($ButtonSelect, $GUI_HIDE)
                    GUICtrlSetState($ImageIcon, $GUI_SHOW)
                    GUICtrlSetState($ImageLabel, $GUI_SHOW)
                    GUICtrlSetState($Label, $GUI_SHOW)
                    GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                EndIf
                If $Item_Number Then GuiCtrlSetState($ADInput, $GUI_FOCUS)
            Case $ImageLabel
                If SelectAuctionItem() Then
                    $itemQuantity = 1
                    If Not ImageExists("Item_99x_" & $itemArray[$Item_Number]) Then
                        $itemQuantity = 1
                        GUICtrlSetState($Checkbox, $GUI_DISABLE)
                    ElseIf Not ImageExists("Item_1x_" & $itemArray[$Item_Number]) Then
                        $itemQuantity = 99
                        GUICtrlSetState($Checkbox, $GUI_DISABLE)
                    Else
                        GUICtrlSetState($Checkbox, $GUI_ENABLE)
                    EndIf
                    If $itemQuantity == 1 Then
                        _SetImage($ImageIcon, $FullImagePath & "Item_1x_" & $itemArray[$Item_Number] & ".png")
                        GUICtrlSetState($Checkbox, $GUI_UNCHECKED)
                    Else
                        _SetImage($ImageIcon, $FullImagePath & "Item_99x_" & $itemArray[$Item_Number] & ".png")
                        GUICtrlSetState($Checkbox, $GUI_CHECKED)
                    EndIf
                    GUICtrlSetData($ImageLabel, Localize($itemArray[$Item_Number]))
                    $AD_Number = ""
                    GUICtrlSetData($ADInput, $AD_Number)
                    GUICtrlSetState($ADInput, $GUI_ENABLE)
                    _SetImage($ADIcon, $FullImagePath & "AD.png")
                    GUICtrlSetState($ButtonSelect, $GUI_HIDE)
                    GUICtrlSetState($ImageIcon, $GUI_SHOW)
                    GUICtrlSetState($ImageLabel, $GUI_SHOW)
                    GUICtrlSetState($Label, $GUI_SHOW)
                    GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                EndIf
                If $Item_Number Then GuiCtrlSetState($ADInput, $GUI_FOCUS)
            Case $ButtonSelect
                If SelectAuctionItem() Then
                    $itemQuantity = 1
                    If Not ImageExists("Item_99x_" & $itemArray[$Item_Number]) Then
                        $itemQuantity = 1
                        GUICtrlSetState($Checkbox, $GUI_DISABLE)
                    ElseIf Not ImageExists("Item_1x_" & $itemArray[$Item_Number]) Then
                        $itemQuantity = 99
                        GUICtrlSetState($Checkbox, $GUI_DISABLE)
                    Else
                        GUICtrlSetState($Checkbox, $GUI_ENABLE)
                    EndIf
                    If $itemQuantity == 1 Then
                        _SetImage($ImageIcon, $FullImagePath & "Item_1x_" & $itemArray[$Item_Number] & ".png")
                        GUICtrlSetState($Checkbox, $GUI_UNCHECKED)
                    Else
                        _SetImage($ImageIcon, $FullImagePath & "Item_99x_" & $itemArray[$Item_Number] & ".png")
                        GUICtrlSetState($Checkbox, $GUI_CHECKED)
                    EndIf
                    GUICtrlSetData($ImageLabel, Localize($itemArray[$Item_Number]))
                    $AD_Number = ""
                    GUICtrlSetData($ADInput, $AD_Number)
                    GUICtrlSetState($ADInput, $GUI_ENABLE)
                    _SetImage($ADIcon, $FullImagePath & "AD.png")
                    GUICtrlSetState($ButtonSelect, $GUI_HIDE)
                    GUICtrlSetState($ImageIcon, $GUI_SHOW)
                    GUICtrlSetState($ImageLabel, $GUI_SHOW)
                    GUICtrlSetState($Label, $GUI_SHOW)
                    GUICtrlSetState($ButtonOK, $GUI_ENABLE)
                EndIf
                If $Item_Number Then GuiCtrlSetState($ADInput, $GUI_FOCUS)
            Case $ADInput
                Local $inputValue = GUICtrlRead($ADInput)
                Local $formattedValue = AddCommas(StringReplace($inputValue, ",", ""))
                If Not ($inputValue == $formattedValue) And StringRegExp($formattedValue, "(^[1-9]$)|(^[1-9].*\d$)") And StringRegExp($formattedValue, "^(\d+|\d{1,3}(,\d{3})*)(\.\d+)?$") And StringRegExp(StringReplace($formattedValue, ",", ""), "^\d+$") Then
                    If Number(StringReplace($formattedValue, ",", "")) > 100000000 Then
                        GUICtrlSetData($ADInput, "100,000,000")
                    Else
                        GUICtrlSetData($ADInput, $formattedValue)
                    EndIf
                EndIf
            Case $ButtonOK
                Local $inputValue = GUICtrlRead($ADInput)
                If StringRegExp($inputValue, "(^[1-9]$)|(^[1-9].*\d$)") And StringRegExp($inputValue, "^(\d+|\d{1,3}(,\d{3})*)(\.\d+)?$") And StringRegExp(StringReplace($inputValue, ",", ""), "^\d+$") Then
                    $AD_Number = Number(StringReplace($inputValue, ",", ""))
                    If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, $itemQuantity & " x " & Localize($itemArray[$Item_Number]) & @CRLF & @CRLF & AddCommas($AD_Number) & " AD", 0, $hGUI) = $IDYES Then
                        GUIDelete($hGUI)
                        Return $AD_Number
                    EndIf
                Else
                    MsgBox($MB_ICONWARNING, $Title, Localize("ValidNumber"), 0, $hGUI)
                EndIf
                GuiCtrlSetState($ADInput, $GUI_FOCUS)
            Case $ButtonCancel
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($hGUI)
    End()
EndFunc

Func SelectAuctionItem($hWnd = 0)
    Local $hGUI = GUICreate($Title, 350, 440, Default, Default, 0x00C00000 + 0x00080000, 0, $hWnd), $nMsg
    Local $Total = $itemArray[0], $idRadio[$Total + 1], $Image[$Total + 1], $idRadioValue = $Item_Number
    For $i = 1 To $Total
        $Image[$i] = GUICtrlCreatePic("", 50, 60 * $i - 30, 38, 38)
        If ImageExists("Item_99x_" & $itemArray[$i]) Then
            _SetImage($Image[$i], $FullImagePath & "Item_99x_" & $itemArray[$i] & ".png")
        Else
            _SetImage($Image[$i], $FullImagePath & "Item_1x_" & $itemArray[$i] & ".png")
        EndIf
    Next
    For $i = 1 To $Total
        $idRadio[$i] = GUICtrlCreateRadio(Localize($itemArray[$i]), 100, 60 * $i - 22, 200, 20)
    Next
    If $idRadioValue Then GUICtrlSetState($idRadio[$idRadioValue], $GUI_CHECKED)
    _GUIScrollbars_Generate($hGUI, 1, $Total * 60 + 30)
    GUISetState(@SW_SHOW, $hGUI)
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $idRadio[1] To $idRadio[$Total]
                $idRadioValue = $nMsg + 1 - $idRadio[1]
                GUICtrlSetState($idRadio[$idRadioValue], $GUI_CHECKED)
                $Item_Number = $idRadioValue
                GUIDelete($hGUI)
                Return 1
            Case $Image[1] To $Image[$Total]
                $idRadioValue = $nMsg + 1 - $Image[1]
                GUICtrlSetState($idRadio[$idRadioValue], $GUI_CHECKED)
                $Item_Number = $idRadioValue
                GUIDelete($hGUI)
                Return 1
        EndSwitch
    WEnd
    GUIDelete($hGUI)
    Return 0
EndFunc

Func AddCommas($number)
    Return StringRegExpReplace($number, "(?!\.)(\d)(?=(?:\d{3})+(?!\d))(?<!\.\d{1}|\.\d{2}|\.\d{3}|\.\d{4}|\.\d{5}|\.\d{6}|\.\d{7}|\.\d{8}|\.\d{9})", "\1,")
EndFunc

Func DoubleClick()
    SingleClick()
    SingleClick()
EndFunc

Func SingleClick()
    Sleep($KeyDelay)
    MouseDown("primary")
    Sleep($KeyDelay)
    MouseUp("primary")
EndFunc

Auction()
