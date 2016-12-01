#NoTrayIcon
Global $Name = "Neverwinter Invoke Bot: Screen Detection Fishing"
Global $Title = $Name
#include "Shared.au3"
If _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\black.ico")
AutoItSetOption("TrayIconHide", 0)
TraySetToolTip($Title)
#include "_ImageSearch.au3"

Local $text, $timer, $time = 0, $count = 0

Func Position()
    FindWindow()
    If Not $WinHandle Or Not GetPosition() Then
        $text = Localize("NeverwinterNotFound")
        Return 0
    EndIf
    $text = "Width=" & $ClientWidth & " Height=" & $ClientHeight
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

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("FishingImageTolerance"))
    $ImageSearchImage = $image
    If Not FileExists("images\" & $Language & "\" & $image & ".png") Then Return 0
    If _ImageSearch("images\" & $Language & "\" & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists(@ScriptDir & "\images\" & $Language & "\" & $image & "-" & $i & ".png")
        If _ImageSearch("images\" & $Language & "\" & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then Return $i
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
        If ImageSearch("Fishing_Bait") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Bait_Lugworm") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Bait_Lugworm_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Bait_Krill") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Bait_Krill_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Catch") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Catch_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Left") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Left_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Right") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Right_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Back") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Back_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Cast") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Cast_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Hook") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ImageSearch("Fishing_Hook_Dimmed") Then $text &= @CRLF & @CRLF & $ImageSearchImage & ".png" & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        $time = Round(TimerDiff($timer) / 1000, 2)
    EndIf
    Splash($count & "x " & $time & "s" & @CRLF & $text)
WEnd
