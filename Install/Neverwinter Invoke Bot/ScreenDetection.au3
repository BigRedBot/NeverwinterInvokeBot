Global $Name = "Neverwinter Invoke Bot: Screen Detection"

#AutoIt3Wrapper_UseX64=n
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

Global $text

Func Position()
    FindWindow()
    If Not $WinFound Or Not GetPosition() Then
        $text = Localize("ToStopPressF4") & @CRLF & @CRLF & Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = Localize("ToStopPressF4") & @CRLF & @CRLF & "GameWidth=" & $ClientWidth & " GameHeight=" & $ClientHeight
    Return 1
EndFunc

Global $SplashWindow, $LastSplashText = "", $SplashLeft = @DesktopWidth - GetValue("ScreenDetectionSplashWidth") - 6, $SplashTop = @DesktopHeight - GetValue("ScreenDetectionSplashHeight") - 25

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, $s, GetValue("ScreenDetectionSplashWidth"), GetValue("ScreenDetectionSplashHeight"), $SplashLeft, $SplashTop, 16, "", 0)
        $LastSplashText = $s
    EndIf
EndFunc

Func FindPixels(ByRef $x, ByRef $y, ByRef $c)
    If $x And Hex(PixelGetColor($x + $OffsetX, $y + $OffsetY), 6) = String($c) Then
        Return 1
    EndIf
    Return 0
EndFunc

Global $X = 0, $Y = 0
Func ImageSearch($image, $resultPosition = -1, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom)
    If ImageExists($image) And _ImageSearchArea("images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, $X, $Y, GetValue("ImageSearchTolerance")) Then
        Return 1
    EndIf
    Return 0
EndFunc

Func ImageExists($image)
    Return FileExists("images\" & GetValue("Language") & "\" & $image & ".png")
EndFunc

Func End()
    Exit
EndFunc

HotKeySet("{F4}", "End")
Splash()
While 1
    If Position() Then
        If ImageSearch("SelectionScreen") Then
            $text &= @CRLF & @CRLF & Localize("CharacterSelectionScreenDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If FindPixels(GetValue("TopScrollBarX"), GetValue("TopScrollBarY"), GetValue("TopScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("TopOfScrollBarDetected") & " @ " & GetValue("TopScrollBarX") & ", " & GetValue("TopScrollBarY")
        EndIf
        If FindPixels(GetValue("TopSelectedCharacterX"), GetValue("TopSelectedCharacterY"), GetValue("TopSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("TopSelectedCharacterDetected") & " @ " & GetValue("TopSelectedCharacterX") & ", " & GetValue("TopSelectedCharacterY")
        EndIf
        If FindPixels(GetValue("BottomScrollBarX"), GetValue("BottomScrollBarY"), GetValue("BottomScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomOfScrollBarDetected") & " @ " & GetValue("BottomScrollBarX") & ", " & GetValue("BottomScrollBarY")
        EndIf
        If FindPixels(GetValue("BottomSelectedCharacterX"), GetValue("BottomSelectedCharacterY"), GetValue("BottomSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomSelectedCharacterDetected") & " @ " & GetValue("BottomSelectedCharacterX") & ", " & GetValue("BottomSelectedCharacterY")
        EndIf
        If ImageSearch("InGameScreen") Then
            $text &= @CRLF & @CRLF & Localize("InGameScreenDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("Invoked") Then
            $text &= @CRLF & @CRLF & Localize("AlreadyInvokedDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("CongratulationsWindow") Then
            $text &= @CRLF & @CRLF & Localize("InvokeCongratulationsWindowDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("OverflowXPReward") Then
            $text &= @CRLF & @CRLF & Localize("OverflowExperiencePointRewardDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("VaultOfPietyButton") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyButtonDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("CelestialSynergyTab") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyCelestialSynergyTabDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("CofferOfCelestialEnchantments") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialEnchantmentsDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("CofferOfCelestialArtifacts") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactsDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("CofferOfCelestialArtifactEquipment") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactEquipmentDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("ElixirOfFate") Then
            $text &= @CRLF & @CRLF & Localize("ElixirOfFateDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("BlessedProfessionsElementalPack") Then
            $text &= @CRLF & @CRLF & Localize("BlessedProfessionsElementalPackDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("ChangeCharacterButton") Then
            $text &= @CRLF & @CRLF & Localize("GameMenuDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("ChangeCharacterConfirmation") Then
            $text &= @CRLF & @CRLF & Localize("ChangeCharacterConfirmationDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("LogInScreen") Then
            $text &= @CRLF & @CRLF & Localize("LogInScreenDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("Idle") Then
            $text &= @CRLF & @CRLF & Localize("IdleLogOutMessageBoxDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("OK") Then
            $text &= @CRLF & @CRLF & Localize("OKButtonDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
        EndIf
        If ImageSearch("VIPAccountReward") Then
            $text &= @CRLF & @CRLF & Localize("VIPAccountRewardDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
            If ImageSearch("VIPAccountRewardBorder", -1, $X, $Y-10) Then
                $text &= @CRLF & @CRLF & Localize("VIPAccountRewardBorderDetected") & " @ " & $X-$OffsetX & ", " & $Y-$OffsetY
            EndIf
        EndIf
    EndIf
    Splash($text)
    Sleep(500)
WEnd
