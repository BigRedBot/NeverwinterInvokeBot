#NoTrayIcon
AutoItSetOption("TrayAutoPause", 0)
Global $Name = "Neverwinter Invoke Bot: Screen Detection Professions"
#include "Shared.au3"
TraySetIcon(@ScriptDir & "\images\black.ico")
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
#include "_ImageSearch.au3"
Global $Title = $Name

If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))

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
        If ImageSearch("Professions_Leadership") Then
            $text &= @CRLF & @CRLF & $ImageSearchImage & ".png"
            Local $text2 = @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop - 44, $right = $_ImageSearchLeft + 100, $bottom = $_ImageSearchTop - 31, $tens, $ones, $image1, $image2, $tolerance = 100,$ProfessionLevel = 25
            While $ProfessionLevel >= 0
                If $ProfessionLevel < 10 Then
                    $tens = ""
                    $ones = $ProfessionLevel
                    $image1 = "Professions_Level" & $ones
                    $image2 = "Professions_LevelBlank"
                Else
                    $tens = Floor($ProfessionLevel / 10)
                    $ones = $ProfessionLevel - $tens * 10
                    $image1 = "Professions_Level" & $tens
                    $image2 = "Professions_Level" & $ones
                EndIf
                If ImageSearch($image1, $left, $top, $right, $bottom, $tolerance) And ImageSearch("Professions_LevelBlank", $_ImageSearchLeft - 5, $_ImageSearchTop, $_ImageSearchLeft - 1, $_ImageSearchBottom, $tolerance) And ImageSearch($image2, $_ImageSearchRight + 11, $_ImageSearchTop, $_ImageSearchRight + 22, $_ImageSearchBottom, $tolerance) Then
                    $text &= @CRLF & "Level " & $tens & $ones
                    ExitLoop
                EndIf
                $ProfessionLevel -= 1
            WEnd
            $text &= $text2
        EndIf
        If ImageSearch("Professions_Overview") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_CollectResult") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_TakeRewards") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_EmptySlot") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Search") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Continue") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_StartTask") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset") Then
            $text &= @CRLF & @CRLF & $ImageSearchImage & ".png 1" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            If ImageSearch("Professions_Asset", $_ImageSearchLeft, $_ImageSearchBottom + 100, $_ImageSearchRight, $_ImageSearchBottom + 150) Then $text &= @CRLF & $ImageSearchImage & ".png 2" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ImageSearch("Professions_AssetBorder", $_ImageSearchLeft, $_ImageSearchTop, $_ImageSearchRight + 200) Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset_Hero") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset_Adventurer") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset_ManatArms") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset_Footman") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset_Guard") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Professions_Asset_Mercenary") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        $time = Round(TimerDiff($timer) / 1000, 2)
    EndIf
    Splash($count & " = " & $time & "s" & @CRLF & $text)
WEnd
