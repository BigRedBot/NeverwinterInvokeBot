#NoTrayIcon
Global $Name = "Neverwinter Invoke Bot: Screen Detection"
Global $Title = $Name
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\black.ico")
AutoItSetOption("TrayIconHide", 0)
#include "_ImageSearch.au3"

Local $text, $timer, $time = 0, $count = 0

Func Position()
    FindWindow()
    If Not $WinHandle Or Not GetPosition() Then
        $text = Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = "GameClientWidth=" & $ClientWidth & " GameClientHeight=" & $ClientHeight
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

Local $ImageSearchImage

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"), $resultPosition = -2)
    $ImageSearchImage = $image
    If Not FileExists("images\" & $Language & "\" & $image & ".png") Then Return 0
    If _ImageSearchArea("images\" & $Language & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists(@ScriptDir & "\images\" & $Language & "\" & $image & "-" & $i & ".png")
        If _ImageSearchArea("images\" & $Language & "\" & $image & "-" & $i & ".png", $resultPosition, $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Func End()
    Exit
EndFunc

HotKeySet("{Esc}", "End")
Splash()
While 1
    If Position() And $ClientWidth And $ClientHeight Then
        $timer = TimerInit()
        $count += 1
        If ImageSearch("SelectionScreen") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Invoked") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("CongratulationsWindow") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("OverflowXPReward") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("VaultOfPietyButton") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("CelestialSynergyTab") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("ElixirOfFate") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("BlessedProfessionsElementalPack") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("CofferOfCelestialEnchantments") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("CofferOfCelestialArtifacts") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("CofferOfCelestialArtifactEquipment") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("ChangeCharacterButton") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("LogInScreen") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Idle") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("OK") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Decline") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Later") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("InvalidUsernameOrPassword") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Mismatch") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("OpenAnother") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("CelestialBagOfRefining") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("VIPInventory") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("VIPAccountRewards") Then
            $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            If ImageSearch("VIPAccountRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $_ImageSearchRight + 200, $_ImageSearchBottom + 20) Then $text &= @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        $time = Round(TimerDiff($timer) / 1000, 2)
    EndIf
    Splash($count & " = " & $time & "s" & @CRLF & $text)
WEnd
