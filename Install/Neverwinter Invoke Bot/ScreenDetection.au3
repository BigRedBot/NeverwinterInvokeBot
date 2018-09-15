#NoTrayIcon
Global $Name = "Neverwinter Invoke Bot: Screen Detection"
Global $Title = $Name
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\black.ico")
AutoItSetOption("TrayIconHide", 0)
TraySetToolTip($Title)
#include "_ImageSearch.au3"

Local $text, $timer, $time = 0, $count = 0

Func Position()
    FindWindow()
    If Not $WinHandle Or Not GetPosition() Then
        $text = Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = "Width=" & $ClientWidth & " Height=" & $ClientHeight
    Return 1
EndFunc

Local $SplashWindow, $LastSplashText = "", $SplashLeft = @DesktopWidth - GetValue("ScreenDetectionSplashWidth") - 6, $SplashTop = @DesktopHeight - GetValue("ScreenDetectionSplashHeight") - 25

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", Localize("ToStopPressEsc") & @CRLF & @CRLF & $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, Localize("ToStopPressEsc") & @CRLF & @CRLF & $s, GetValue("ScreenDetectionSplashWidth"), GetValue("ScreenDetectionSplashHeight"), $SplashLeft - 70, $SplashTop - 50, 16)
        $LastSplashText = $s
    EndIf
EndFunc

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"))
    If Not FileExists($ImagePath & $image & ".png") Then Return 0
    If _ImageSearch($ImagePath & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists($FullImagePath & $image & "-" & $i & ".png")
        If _ImageSearch($ImagePath & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Func End()
    Exit
EndFunc

Func CheckImage($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $intro = @CRLF & @CRLF, $ext = "")
    Local $i = ImageSearch($image, $left, $top, $right, $bottom), $n = ""
    If Not $i Then Return 0
    If $i > 1 Then $n = "-" & $i
    $text &= $intro & $image & $n & ".png" & $ext & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
    Return $i
EndFunc

HotKeySet("{Esc}", "End")
Splash()
While 1
    If Position() And $ClientWidth And $ClientHeight Then
        $timer = TimerInit()
        $count += 1
        CheckImage("SelectionScreen")
        CheckImage("SelectedCharacter")
        CheckImage("Invoked")
        CheckImage("CongratulationsWindow")
        CheckImage("OverflowXPReward")
        CheckImage("VaultOfPietyButton")
        CheckImage("CelestialSynergyTab")
        CheckImage("ElixirOfFate")
        CheckImage("BlessedProfessionsElementalPack")
        CheckImage("CofferOfCelestialEnchantments")
        CheckImage("CofferOfCelestialArtifacts")
        CheckImage("ChangeCharacterButton")
        CheckImage("LogInScreen")
        CheckImage("IAccept")
        CheckImage("Idle")
        CheckImage("OK")
        CheckImage("Decline")
        CheckImage("Later")
        CheckImage("InvalidUsernameOrPassword")
        CheckImage("Mismatch")
        CheckImage("OpenAnother")
        CheckImage("OpenAnotherOK")
        CheckImage("CelestialBagOfRefining")
        CheckImage("InventoryTab")
        CheckImage("VIPInventoryTab")
        CheckImage("Inventory")
        CheckImage("VIPInventory")
        If CheckImage("VIPCharacterRewards") Then CheckImage("VIPRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $ClientRight, $_ImageSearchBottom + 20, @CRLF)
        If CheckImage("VIPAccountRewards") Then CheckImage("VIPRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $ClientRight, $_ImageSearchBottom + 20, @CRLF)
        $time = Round(TimerDiff($timer) / 1000, 2)
    EndIf
    Splash($count & "x " & $time & "s" & @CRLF & $text)
WEnd
