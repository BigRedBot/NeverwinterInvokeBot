AutoItSetOption("TrayAutoPause", 0)
TraySetIcon(@ScriptDir & "\images\black.ico")
Global $Name = "Neverwinter Invoke Bot: Screen Detection"
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
    Exit
EndIf
#include "_ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
    Exit
EndIf

Local $text

Func ScreenDetection_Position()
    FindWindow()
    If Not $WinFound Or Not GetPosition() Then
        $text = Localize("ToStopPressEsc") & @CRLF & @CRLF & Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = Localize("ToStopPressEsc") & @CRLF & @CRLF & "GameWidth=" & $ClientWidth & " GameHeight=" & $ClientHeight
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
        $ScreenDetection_SplashWindow = SplashTextOn($Title, $s, GetValue("ScreenDetectionSplashWidth"), GetValue("ScreenDetectionSplashHeight"), $ScreenDetection_SplashLeft, $ScreenDetection_SplashTop, 16)
        $ScreenDetection_LastSplashText = $s
    EndIf
EndFunc

Func ScreenDetection_FindPixels(ByRef $x, ByRef $y, ByRef $c)
    If $x And Hex(PixelGetColor($x + $OffsetX, $y + $OffsetY), 6) = String($c) Then
        Return 1
    EndIf
    Return 0
EndFunc

Local $X = 0, $Y = 0
Func ScreenDetection_ImageSearch($image, $resultPosition = -1, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom)
    If FileExists("images\" & GetValue("Language") & "\" & $image & ".png") And _ImageSearchArea("images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, $X, $Y, GetValue("ImageSearchTolerance")) Then
        Return 1
    EndIf
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
            $text &= @CRLF & @CRLF & Localize("CharacterSelectionScreenDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_FindPixels(GetValue("TopScrollBarX"), GetValue("TopScrollBarY"), GetValue("TopScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("TopOfScrollBarDetected") & " @ " & GetValue("TopScrollBarX") & ", " & GetValue("TopScrollBarY")
        EndIf
        If ScreenDetection_FindPixels(GetValue("TopSelectedCharacterX"), GetValue("TopSelectedCharacterY"), GetValue("TopSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("TopSelectedCharacterDetected") & " @ " & GetValue("TopSelectedCharacterX") & ", " & GetValue("TopSelectedCharacterY")
        EndIf
        If ScreenDetection_FindPixels(GetValue("BottomScrollBarX"), GetValue("BottomScrollBarY"), GetValue("BottomScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomOfScrollBarDetected") & " @ " & GetValue("BottomScrollBarX") & ", " & GetValue("BottomScrollBarY")
        EndIf
        If ScreenDetection_FindPixels(GetValue("BottomSelectedCharacterX"), GetValue("BottomSelectedCharacterY"), GetValue("BottomSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomSelectedCharacterDetected") & " @ " & GetValue("BottomSelectedCharacterX") & ", " & GetValue("BottomSelectedCharacterY")
        EndIf
        If ScreenDetection_ImageSearch("InGameScreen") Then
            $text &= @CRLF & @CRLF & Localize("InGameScreenDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Invoked") Then
            $text &= @CRLF & @CRLF & Localize("AlreadyInvokedDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CongratulationsWindow") Then
            $text &= @CRLF & @CRLF & Localize("InvokeCongratulationsWindowDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("OverflowXPReward") Then
            $text &= @CRLF & @CRLF & Localize("OverflowExperiencePointRewardDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("VaultOfPietyButton") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyButtonDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CelestialSynergyTab") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyCelestialSynergyTabDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CofferOfCelestialEnchantments") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialEnchantmentsDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifacts") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactsDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifactEquipment") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactEquipmentDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("ElixirOfFate") Then
            $text &= @CRLF & @CRLF & Localize("ElixirOfFateDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("BlessedProfessionsElementalPack") Then
            $text &= @CRLF & @CRLF & Localize("BlessedProfessionsElementalPackDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("ChangeCharacterButton") Then
            $text &= @CRLF & @CRLF & Localize("GameMenuDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("ChangeCharacterConfirmation") Then
            $text &= @CRLF & @CRLF & Localize("ChangeCharacterConfirmationDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("LogInScreen") Then
            $text &= @CRLF & @CRLF & Localize("LogInScreenDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Idle") Then
            $text &= @CRLF & @CRLF & Localize("IdleLogOutMessageBoxDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("OK") Then
            $text &= @CRLF & @CRLF & Localize("OKButtonDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("VIPAccountReward") Then
            $text &= @CRLF & @CRLF & Localize("VIPAccountRewardDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
            If ScreenDetection_ImageSearch("VIPAccountRewardBorder", -1, $X, $Y-10) Then
                $text &= @CRLF & @CRLF & Localize("VIPAccountRewardBorderDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
            EndIf
        EndIf
    EndIf
    ScreenDetection_Splash($text)
    Sleep(500)
WEnd
