Global $Name = "Neverwinter Invoke Bot: Screen Detection"

#AutoIt3Wrapper_UseX64=n
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Name, $LOCALIZATION_ScreenDetectionAlreadyRunning)
    Exit
EndIf
#include "ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then
    MsgBox($MB_ICONWARNING, $Title, $LOCALIZATION_Use32bit)
    Exit
EndIf

Global $text

Func Position()
    FindWindow()
    If Not $WinFound Or Not GetPosition() Then
        $text = $LOCALIZATION_ToStopPressF4 & @CRLF & @CRLF & $LOCALIZATION_NeverwinterNotFound
        Return 0
    EndIf
    $text = $LOCALIZATION_ToStopPressF4 & @CRLF & @CRLF & "GameWidth=" & $ClientWidth & " GameHeight=" & $ClientHeight
    Return 1
EndFunc

Global $SplashWindow, $LastSplashText = "", $SplashWidth = 380, $SplashHeight = 210, $SplashLeft = @DesktopWidth - $SplashWidth - 6, $SplashTop = @DesktopHeight - $SplashHeight - 25

Func Splash($s = "")
    If $SplashWindow Then
        If Not ($LastSplashText == $s) Then
            ControlSetText($SplashWindow, "", "Static1", $s)
            $LastSplashText = $s
        EndIf
    Else
        $SplashWindow = SplashTextOn($Title, $s, $SplashWidth, $SplashHeight, $SplashLeft, $SplashTop, 16, "", 0)
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
        If $f And FileExists("images\" & $Language & "\" & $f & ".png") And _ImageSearchArea("images\" & $Language & "\" & $f & ".png", 1, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $X, $Y, $ImageSearchTolerance) Then
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
            $text &= @CRLF & @CRLF & $LOCALIZATION_CharacterSelectionScreenDetected
        EndIf
        If FindPixels($TopScrollBarX, $TopScrollBarY, $TopScrollBarC) Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_TopOfScrollBarDetected
        EndIf
        If FindPixels($TopSelectedCharacterX, $TopSelectedCharacterY, $TopSelectedCharacterC) Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_TopSelectedCharacterDetected
        EndIf
        If FindPixels($BottomScrollBarX, $BottomScrollBarY, $BottomScrollBarC) Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_BottomOfScrollBarDetected
        EndIf
        If FindPixels($BottomSelectedCharacterX, $BottomSelectedCharacterY, $BottomSelectedCharacterC) Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_BottomSelectedCharacterDetected
        EndIf
        If ImageSearch("InGameScreen") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_InGameScreenDetected
        EndIf
        If ImageSearch("Invoked") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_AlreadyInvokedDetected
        EndIf
        If ImageSearch("CongratulationsWindow") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_InvokeCongratulationsWindowDetected
        EndIf
        If ImageSearch("OverflowXPReward") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_OverflowExperiencePointRewardDetected
        EndIf
        If ImageSearch("VaultOfPietyButton") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_VaultOfPietyButtonDetected
        EndIf
        If ImageSearch("CelestialSynergyTab") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_VaultOfPietyCelestialSynergyTabDetected
        EndIf
        If ImageSearch("Enchantments") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_CofferOfCelestialEnchantmentsDetected
        EndIf
        If ImageSearch("Artifacts") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_CofferOfCelestialArtifactsDetected
        EndIf
        If ImageSearch("ArtifactEquipment") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_CofferOfCelestialArtifactEquipmentDetected
        EndIf
        If ImageSearch("ElixirOfFate") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_ElixirOfFateDetected
        EndIf
        If ImageSearch("ProfessionsPack") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_BlessedProfessionsElementalPackDetected
        EndIf
        If ImageSearch("ChangeCharacterButton") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_GameMenuDetected
        EndIf
        If ImageSearch("ChangeCharacterConfirmation") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_ChangeCharacterConfirmationDetected
        EndIf
        If ImageSearch("LogInScreen") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_LogInScreenDetected
        EndIf
        If ImageSearch("Idle") Then
            $text &= @CRLF & @CRLF & $LOCALIZATION_IdleLogOutMessageBoxDetected
        EndIf
    EndIf
    Splash($text)
    Sleep(500)
WEnd
