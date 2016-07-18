#NoTrayIcon
AutoItSetOption("TrayAutoPause", 0)
Global $Name = "Neverwinter Invoke Bot: Screen Detection"
#include "Shared.au3"
TraySetIcon(@ScriptDir & "\images\black.ico")
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
#include "_ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))

Local $text

Func ScreenDetection_Position()
    FindWindow()
    If Not $WinFound Or Not GetPosition() Then
        $text = Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = "GameWidth=" & $ClientWidth & " GameHeight=" & $ClientHeight
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

Func ScreenDetection_FindPixels($x, $y, $c)
    If $x And Hex(PixelGetColor($x + $OffsetX, $y + $OffsetY), 6) = String($c) Then Return 1
    Return 0
EndFunc

Func ScreenDetection_ImageSearch($image, $resultPosition = -1, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom)
    If FileExists("images\" & GetValue("Language") & "\" & $image & ".png") And _ImageSearchArea("images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, GetValue("ImageSearchTolerance")) Then Return 1
    Return 0
EndFunc

Func ScreenDetection_End()
    Exit
EndFunc

HotKeySet("{Esc}", "ScreenDetection_End")
ScreenDetection_Splash()
While 1
    If ScreenDetection_Position() Then
        If ScreenDetection_ImageSearch("SelectionScreen") Then
            $text &= @CRLF & @CRLF & Localize("CharacterSelectionScreenDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_FindPixels(GetValue("TopScrollBarX"), GetValue("TopScrollBarY"), GetValue("TopScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("TopOfScrollBarDetected") & @CRLF & GetValue("TopScrollBarX") & ", " & GetValue("TopScrollBarY")
        EndIf
        If ScreenDetection_FindPixels(GetValue("TopSelectedCharacterX"), GetValue("TopSelectedCharacterY"), GetValue("TopSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("TopSelectedCharacterDetected") & @CRLF & GetValue("TopSelectedCharacterX") & ", " & GetValue("TopSelectedCharacterY")
        EndIf
        If ScreenDetection_FindPixels(GetValue("BottomScrollBarX"), GetValue("BottomScrollBarY"), GetValue("BottomScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomOfScrollBarDetected") & @CRLF & GetValue("BottomScrollBarX") & ", " & GetValue("BottomScrollBarY")
        EndIf
        If ScreenDetection_FindPixels(GetValue("BottomSelectedCharacterX"), GetValue("BottomSelectedCharacterY"), GetValue("BottomSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomSelectedCharacterDetected") & @CRLF & GetValue("BottomSelectedCharacterX") & ", " & GetValue("BottomSelectedCharacterY")
        EndIf
        If ScreenDetection_ImageSearch("InGameScreen") Then
            $text &= @CRLF & @CRLF & Localize("InGameScreenDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Invoked") Then
            $text &= @CRLF & @CRLF & Localize("AlreadyInvokedDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CongratulationsWindow") Then
            $text &= @CRLF & @CRLF & Localize("InvokeCongratulationsWindowDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("OverflowXPReward") Then
            $text &= @CRLF & @CRLF & Localize("OverflowExperiencePointRewardDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("VaultOfPietyButton") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyButtonDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CelestialSynergyTab") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyCelestialSynergyTabDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("ElixirOfFate") Then
            $text &= @CRLF & @CRLF & Localize("ElixirOfFateDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("BlessedProfessionsElementalPack") Then
            $text &= @CRLF & @CRLF & Localize("BlessedProfessionsElementalPackDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CofferOfCelestialEnchantments") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialEnchantmentsDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifacts") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactsDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifactEquipment") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactEquipmentDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("ChangeCharacterButton") Then
            $text &= @CRLF & @CRLF & Localize("GameMenuDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("ChangeCharacterConfirmation") Then
            $text &= @CRLF & @CRLF & Localize("ChangeCharacterConfirmationDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("LogInScreen") Then
            $text &= @CRLF & @CRLF & Localize("LogInScreenDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Idle") Then
            $text &= @CRLF & @CRLF & Localize("IdleLogOutMessageBoxDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("OK") Then
            $text &= @CRLF & @CRLF & Localize("OKButtonDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("VIPAccountReward") Then
            $text &= @CRLF & @CRLF & Localize("VIPAccountRewardDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            If ScreenDetection_ImageSearch("VIPAccountRewardBorder", -1, $_ImageSearchX, $_ImageSearchY-10) Then
                $text &= @CRLF & @CRLF & Localize("VIPAccountRewardBorderDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            ElseIf ScreenDetection_ImageSearch("VIPAccountRewardBorder2", -1, $_ImageSearchX, $_ImageSearchY-10) Then
                $text &= @CRLF & @CRLF & Localize("VIPAccountRewardBorder2Detected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            EndIf
        EndIf
        If ScreenDetection_ImageSearch("Unavailable") Then
            $text &= @CRLF & @CRLF & Localize("ServerUnavailableDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Mismatch") Then
            $text &= @CRLF & @CRLF & Localize("VersionMismatchDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
    EndIf
    ScreenDetection_Splash($text)
    Sleep(500)
WEnd
