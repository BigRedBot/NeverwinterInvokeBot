Global $Name = "Neverwinter Invoke Bot: Screen Detection"

#AutoIt3Wrapper_UseX64=n
#include "Shared.au3"
#include "ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then
    MsgBox($MB_ICONWARNING, $Title, "Please run this script with the 32 bit version of AutoIt!")
    Exit
EndIf

Global $text

Func Position()
    FindWindow()
    If Not $WinFound Or Not GetPosition() Then
        $text = "To Stop: Press F4" & @CRLF & @CRLF & "Neverwinter window not found!"
        Return 0
    EndIf
    $text = "To Stop: Press F4" & @CRLF & @CRLF & "GameWidth=" & $ClientWidth & " GameHeight=" & $ClientHeight
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
        If $f And FileExists("images\" & $f & ".png") And _ImageSearchArea("images\" & $f & ".png", 1, $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, $X, $Y, $ImageSearchTolerance) Then
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
            $text &= @CRLF & @CRLF & "Character Selection Screen Detected"
        EndIf
        If FindPixels($TopScrollBarX, $TopScrollBarY, $TopScrollBarC) Then
            $text &= @CRLF & @CRLF & "Top of Scroll Bar Detected"
        EndIf
        If FindPixels($TopSelectedCharacterX, $TopSelectedCharacterY, $TopSelectedCharacterC) Then
            $text &= @CRLF & @CRLF & "Top Selected Character Detected"
        EndIf
        If FindPixels($BottomScrollBarX, $BottomScrollBarY, $BottomScrollBarC) Then
            $text &= @CRLF & @CRLF & "Bottom of Scroll Bar Detected"
        EndIf
        If FindPixels($BottomSelectedCharacterX, $BottomSelectedCharacterY, $BottomSelectedCharacterC) Then
            $text &= @CRLF & @CRLF & "Bottom Selected Character Detected"
        EndIf
        If ImageSearch("InGameScreen") Then
            $text &= @CRLF & @CRLF & "In Game Screen Detected"
        EndIf
        If ImageSearch("Invoked") Then
            $text &= @CRLF & @CRLF & "Already Invoked Detected"
        EndIf
        If ImageSearch("CongratulationsWindow") Then
            $text &= @CRLF & @CRLF & "Invoke Congratulations Window Detected"
        EndIf
        If ImageSearch("OverflowXPReward") Then
            $text &= @CRLF & @CRLF & "Overflow Experience Point Reward Detected"
        EndIf
        If ImageSearch("VaultOfPietyButton") Then
            $text &= @CRLF & @CRLF & "Vault of Piety Button Detected"
        EndIf
        If ImageSearch("CelestialSynergyTab") Then
            $text &= @CRLF & @CRLF & "Vault of Piety Celestial Synergy Tab Detected"
        EndIf
        If ImageSearch("Enchantments") Then
            $text &= @CRLF & @CRLF & "Coffer of Celestial Enchantments Detected"
        EndIf
        If ImageSearch("Artifacts") Then
            $text &= @CRLF & @CRLF & "Coffer of Celestial Artifacts Detected"
        EndIf
        If ImageSearch("ArtifactEquipment") Then
            $text &= @CRLF & @CRLF & "Coffer of Celestial Artifact Equipment Detected"
        EndIf
        If ImageSearch("ElixirOfFate") Then
            $text &= @CRLF & @CRLF & "Elixir of Fate Detected"
        EndIf
        If ImageSearch("ProfessionsPack") Then
            $text &= @CRLF & @CRLF & "Blessed Professions Elemental Pack Detected"
        EndIf
        If ImageSearch("ChangeCharacterButton") Then
            $text &= @CRLF & @CRLF & "Game Menu Detected"
        EndIf
        If ImageSearch("ChangeCharacterConfirmation") Then
            $text &= @CRLF & @CRLF & "Change Character Confirmation Detected"
        EndIf
        If ImageSearch("LogInScreen") Then
            $text &= @CRLF & @CRLF & "Log In Screen Detected"
        EndIf
        If ImageSearch("Idle") Then
            $text &= @CRLF & @CRLF & "Idle Log Out Message Box Detected"
        EndIf
    EndIf
    Splash($text)
    Sleep(500)
WEnd
