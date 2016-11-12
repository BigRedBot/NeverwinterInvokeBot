#NoTrayIcon
AutoItSetOption("TrayAutoPause", 0)
Global $Name = "Neverwinter Invoke Bot: Screen Detection"
#include "Shared.au3"
TraySetIcon(@ScriptDir & "\images\black.ico")
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
#include "_ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))

Local $text, $timer, $time = 0, $count = 0

Func ScreenDetection_Position()
    FindWindow()
    If Not $WinHandle Or Not GetPosition() Then
        $text = Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = "GameClientWidth=" & $ClientWidth & " GameClientHeight=" & $ClientHeight & @CRLF
    Return 1
EndFunc

Local $ScreenDetection_SplashWindow, $ScreenDetection_LastSplashText = "", $ScreenDetection_SplashLeft = @DesktopWidth - GetValue("ScreenDetectionSplashWidth") - 6, $ScreenDetection_SplashTop = @DesktopHeight - GetValue("ScreenDetectionSplashHeight") - 25

Func ScreenDetection_Splash($s = "")
    If $ScreenDetection_SplashWindow Then
        If Not ($ScreenDetection_LastSplashText == $s) Then
            ControlSetText($ScreenDetection_SplashWindow, "", "Static1", $s)
            $ScreenDetection_LastSplashText = $s
        EndIf
    Else
        $ScreenDetection_SplashWindow = SplashTextOn($Title, $s, GetValue("ScreenDetectionSplashWidth"), GetValue("ScreenDetectionSplashHeight"), $ScreenDetection_SplashLeft - 70, $ScreenDetection_SplashTop - 50, 16)
        $ScreenDetection_LastSplashText = $s
    EndIf
EndFunc

Local $ImageSearchImage

Func ScreenDetection_ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"), $resultPosition = -2)
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

Func ScreenDetection_End()
    Exit
EndFunc

HotKeySet("{Esc}", "ScreenDetection_End")
ScreenDetection_Splash()
While 1
    If ScreenDetection_Position() And $ClientWidth And $ClientHeight Then
        $timer = TimerInit()
        $count += 1
        If ScreenDetection_ImageSearch("SelectionScreen") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Invoked") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CongratulationsWindow") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("OverflowXPReward") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VaultOfPietyButton") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CelestialSynergyTab") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("ElixirOfFate") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("BlessedProfessionsElementalPack") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CofferOfCelestialEnchantments") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifacts") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifactEquipment") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("ChangeCharacterButton") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("LogInScreen") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Idle") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("OK") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Decline") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Later") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("InvalidUsernameOrPassword") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Mismatch") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("OpenAnother") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CelestialBagOfRefining") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VIPInventory") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VIPAccountRewards") Then
            $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            If ScreenDetection_ImageSearch("VIPAccountRewardBorder", $_ImageSearchRight + 100, $_ImageSearchTop - 20, $_ImageSearchRight + 200, $_ImageSearchBottom + 20) Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        $time = Round(TimerDiff($timer) / 1000, 2)
    EndIf
    ScreenDetection_Splash($count & " = " & $time & "s" & @CRLF & $text)
WEnd
