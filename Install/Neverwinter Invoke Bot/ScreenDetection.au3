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
    If Not $WinHandle Or Not GetPosition() Then
        $text = Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = "GameClientWidth=" & $ClientWidth & " GameClientHeight=" & $ClientHeight
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

Func ScreenDetection_FindPixels($x, $y, $c, $t = 5)
    Local $a = StringSplit(StringRegExpReplace(Hex(PixelGetColor($x + $OffsetX, $y + $OffsetY), 6), "(..)(..)(..)", "$1|$2|$3"), "|")
    Local $b = StringSplit(StringRegExpReplace($c, "(..)(..)(..)", "$1|$2|$3"), "|")
    For $i = 1 To 3
        Local $d = Dec($a[$i]) - Dec($b[$i])
        If $d > $t Or $d < -$t Then Return 0
    Next
    Return 1
EndFunc

Func ScreenDetection_ImageSearch($image, $resultPosition = -1, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"))
    If Not FileExists("images\" & GetValue("Language") & "\" & $image & ".png") Then Return 0
    If _ImageSearchArea("images\" & GetValue("Language") & "\" & $image & ".png", $resultPosition, $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists(@ScriptDir & "\images\" & GetValue("Language") & "\" & $image & $i & ".png")
        If _ImageSearchArea("images\" & GetValue("Language") & "\" & $image & $i & ".png", $resultPosition, $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Func ScreenDetection_End()
    Exit
EndFunc

Func Array($x)
    Return StringSplit(StringRegExpReplace(StringRegExpReplace(StringStripWS($x, $STR_STRIPALL), "^,", ""), ",$", ""), ",")
EndFunc

If GetValue("TopSelectedCharacterX") And GetValue("TopScrollBarX") Then
    Global $TopSelectedCharacterX = Array(GetValue("TopSelectedCharacterX")), $TopSelectedCharacterY = Array(GetValue("TopSelectedCharacterY")), $TopSelectedCharacterC = Array(GetValue("TopSelectedCharacterC")), $TopScrollBarX = Array(GetValue("TopScrollBarX")), $TopScrollBarY = Array(GetValue("TopScrollBarY")), $TopScrollBarC = Array(GetValue("TopScrollBarC"))
EndIf

If GetValue("BottomSelectedCharacterX") And GetValue("BottomScrollBarX") Then
    Global $BottomSelectedCharacterX = Array(GetValue("BottomSelectedCharacterX")), $BottomSelectedCharacterY = Array(GetValue("BottomSelectedCharacterY")), $BottomSelectedCharacterC = Array(GetValue("BottomSelectedCharacterC")), $BottomScrollBarX = Array(GetValue("BottomScrollBarX")), $BottomScrollBarY = Array(GetValue("BottomScrollBarY")), $BottomScrollBarC = Array(GetValue("BottomScrollBarC"))
EndIf

HotKeySet("{Esc}", "ScreenDetection_End")
ScreenDetection_Splash()
Local $n = ""
While 1
    If ScreenDetection_Position() Then
        If ScreenDetection_ImageSearch("SelectionScreen") Then $text &= @CRLF & @CRLF & _
            Localize("CharacterSelectionScreenDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        For $n2 = 1 To $TopSelectedCharacterX[0]
            If ScreenDetection_FindPixels($TopSelectedCharacterX[$n2], $TopSelectedCharacterY[$n2], $TopSelectedCharacterC[$n2]) Then
                $n = ""
                If $TopSelectedCharacterX[0] > 1 Then $n = " #" & $n2
                $text &= @CRLF & @CRLF & Localize("TopSelectedCharacterDetected") & @CRLF & $TopSelectedCharacterX[$n2] & ", " & $TopSelectedCharacterY[$n2] & $n
            EndIf
        Next
        For $n2 = 1 To $TopScrollBarX[0]
            If ScreenDetection_FindPixels($TopScrollBarX[$n2], $TopScrollBarY[$n2], $TopScrollBarC[$n2]) Then
                $n = ""
                If $TopScrollBarX[0] > 1 Then $n = " #" & $n2
                $text &= @CRLF & @CRLF & Localize("TopOfScrollBarDetected") & @CRLF & $TopScrollBarX[$n2] & ", " & $TopScrollBarY[$n2] & $n
            EndIf
        Next
        For $n2 = 1 To $BottomSelectedCharacterX[0]
            If ScreenDetection_FindPixels($BottomSelectedCharacterX[$n2], $BottomSelectedCharacterY[$n2], $BottomSelectedCharacterC[$n2]) Then
                $n = ""
                If $BottomSelectedCharacterX[0] > 1 Then $n = " #" & $n2
                $text &= @CRLF & @CRLF & Localize("BottomSelectedCharacterDetected") & @CRLF & $BottomSelectedCharacterX[$n2] & ", " & $BottomSelectedCharacterY[$n2] & $n
            EndIf
        Next
        For $n2 = 1 To $BottomScrollBarX[0]
            If ScreenDetection_FindPixels($BottomScrollBarX[$n2], $BottomScrollBarY[$n2], $BottomScrollBarC[$n2]) Then
                $n = ""
                If $BottomScrollBarX[0] > 1 Then $n = " #" & $n2
                $text &= @CRLF & @CRLF & Localize("BottomOfScrollBarDetected") & @CRLF & $BottomScrollBarX[$n2] & ", " & $BottomScrollBarY[$n2] & $n
            EndIf
        Next
        If ScreenDetection_ImageSearch("Invoked") Then $text &= @CRLF & @CRLF & _
            Localize("AlreadyInvokedDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CongratulationsWindow") Then $text &= @CRLF & @CRLF & _
            Localize("InvokeCongratulationsWindowDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("OverflowXPReward") Then $text &= @CRLF & @CRLF & _
            Localize("OverflowExperiencePointRewardDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VaultOfPietyButton") Then $text &= @CRLF & @CRLF & _
            Localize("VaultOfPietyButtonDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CelestialSynergyTab") Then $text &= @CRLF & @CRLF & _
            Localize("VaultOfPietyCelestialSynergyTabDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("ElixirOfFate") Then $text &= @CRLF & @CRLF & _
            Localize("ElixirOfFateDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("BlessedProfessionsElementalPack") Then $text &= @CRLF & @CRLF & _
            Localize("BlessedProfessionsElementalPackDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CofferOfCelestialEnchantments") Then $text &= @CRLF & @CRLF & _
            Localize("CofferOfCelestialEnchantmentsDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifacts") Then $text &= @CRLF & @CRLF & _
            Localize("CofferOfCelestialArtifactsDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CofferOfCelestialArtifactEquipment") Then $text &= @CRLF & @CRLF & _
            Localize("CofferOfCelestialArtifactEquipmentDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("ChangeCharacterButton") Then $text &= @CRLF & @CRLF & _
            Localize("GameMenuDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("LogInScreen") Then $text &= @CRLF & @CRLF & _
            Localize("LogInScreenDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Idle") Then $text &= @CRLF & @CRLF & _
            Localize("IdleLogOutMessageBoxDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("OK") Then $text &= @CRLF & @CRLF & _
            Localize("OKButtonDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VIPAccountReward") Then
            $text &= @CRLF & @CRLF & Localize("VIPAccountRewardDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            If ScreenDetection_ImageSearch("VIPAccountRewardBorder", -1, $_ImageSearchX, $_ImageSearchY-50) Then $text &= @CRLF & @CRLF & _
                Localize("VIPAccountRewardBorderDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Unavailable") Then $text &= @CRLF & @CRLF & _
            Localize("ServerUnavailableDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("TryAgainLater") Then $text &= @CRLF & @CRLF & _
            Localize("TryAgainLaterDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Mismatch") Then $text &= @CRLF & @CRLF & _
            Localize("VersionMismatchDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VIPInventory") Then $text &= @CRLF & @CRLF & _
            Localize("VIPInventoryDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("OpenAnother") Then $text &= @CRLF & @CRLF & _
            Localize("OpenAnotherButtonDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("CelestialBagOfRefining") Then $text &= @CRLF & @CRLF & _
            Localize("CelestialBagOfRefiningDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("VIPAccountRewards") Then $text &= @CRLF & @CRLF & _
            Localize("VIPAccountRewardsDetected") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
    EndIf
    ScreenDetection_Splash($text)
    Sleep(500)
WEnd
