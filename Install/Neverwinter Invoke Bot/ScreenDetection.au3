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
Func ImageSearch($f1 = 0 , $f2 = 0)
    #forceref $f1, $f2
    For $i = 1 To @NumParams
        local $f = Eval("f" & $i)
        If $f And FileExists("images\" & GetValue("Language") & "\" & $f & ".png") And _ImageSearchArea("images\" & GetValue("Language") & "\" & $f & ".png", 1, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $X, $Y, GetValue("ImageSearchTolerance")) Then
            Return 1
        EndIf
    Next
    Return 0
EndFunc

Func End()
    Exit
EndFunc

HotKeySet("{F4}", "End")
Splash()
While 1
    If Position() Then
        If ImageSearch("SelectionScreen") Then
            $text &= @CRLF & @CRLF & Localize("CharacterSelectionScreenDetected")
        EndIf
        If FindPixels(GetValue("TopScrollBarX"), GetValue("TopScrollBarY"), GetValue("TopScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("TopOfScrollBarDetected")
        EndIf
        If FindPixels(GetValue("TopSelectedCharacterX"), GetValue("TopSelectedCharacterY"), GetValue("TopSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("TopSelectedCharacterDetected")
        EndIf
        If FindPixels(GetValue("BottomScrollBarX"), GetValue("BottomScrollBarY"), GetValue("BottomScrollBarC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomOfScrollBarDetected")
        EndIf
        If FindPixels(GetValue("BottomSelectedCharacterX"), GetValue("BottomSelectedCharacterY"), GetValue("BottomSelectedCharacterC")) Then
            $text &= @CRLF & @CRLF & Localize("BottomSelectedCharacterDetected")
        EndIf
        If ImageSearch("InGameScreen") Then
            $text &= @CRLF & @CRLF & Localize("InGameScreenDetected")
        EndIf
        If ImageSearch("Invoked") Then
            $text &= @CRLF & @CRLF & Localize("AlreadyInvokedDetected")
        EndIf
        If ImageSearch("CongratulationsWindow") Then
            $text &= @CRLF & @CRLF & Localize("InvokeCongratulationsWindowDetected")
        EndIf
        If ImageSearch("OverflowXPReward") Then
            $text &= @CRLF & @CRLF & Localize("OverflowExperiencePointRewardDetected")
        EndIf
        If ImageSearch("VaultOfPietyButton") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyButtonDetected")
        EndIf
        If ImageSearch("CelestialSynergyTab") Then
            $text &= @CRLF & @CRLF & Localize("VaultOfPietyCelestialSynergyTabDetected")
        EndIf
        If ImageSearch("Enchantments") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialEnchantmentsDetected")
        EndIf
        If ImageSearch("Artifacts") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactsDetected")
        EndIf
        If ImageSearch("ArtifactEquipment") Then
            $text &= @CRLF & @CRLF & Localize("CofferOfCelestialArtifactEquipmentDetected")
        EndIf
        If ImageSearch("ElixirOfFate") Then
            $text &= @CRLF & @CRLF & Localize("ElixirOfFateDetected")
        EndIf
        If ImageSearch("ProfessionsPack") Then
            $text &= @CRLF & @CRLF & Localize("BlessedProfessionsElementalPackDetected")
        EndIf
        If ImageSearch("ChangeCharacterButton") Then
            $text &= @CRLF & @CRLF & Localize("GameMenuDetected")
        EndIf
        If ImageSearch("ChangeCharacterConfirmation") Then
            $text &= @CRLF & @CRLF & Localize("ChangeCharacterConfirmationDetected")
        EndIf
        If ImageSearch("LogInScreen") Then
            $text &= @CRLF & @CRLF & Localize("LogInScreenDetected")
        EndIf
        If ImageSearch("Idle") Then
            $text &= @CRLF & @CRLF & Localize("IdleLogOutMessageBoxDetected")
        EndIf
    EndIf
    Splash($text)
    Sleep(500)
WEnd
