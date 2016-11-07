#NoTrayIcon
AutoItSetOption("TrayAutoPause", 0)
Global $Name = "Neverwinter Invoke Bot: Screen Detection Professions"
#include "Shared.au3"
TraySetIcon(@ScriptDir & "\images\black.ico")
If _Singleton("Neverwinter Invoke Bot: Screen Detection" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING, $Name, Localize("ScreenDetectionAlreadyRunning"))
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

Func ScreenDetection_ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $resultPosition = -2, $tolerance = GetValue("ImageTolerance"))
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

HotKeySet("{Esc}", "ScreenDetection_End")
ScreenDetection_Splash()
While 1
    If ScreenDetection_Position() Then
        If ScreenDetection_ImageSearch("Professions_Overview") Then $text &= @CRLF & @CRLF & Localize("Professions_Overview") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Leadership") Then $text &= @CRLF & @CRLF & Localize("Professions_Leadership") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_CollectResult") Then $text &= @CRLF & @CRLF & Localize("Professions_CollectResult") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_TakeRewards") Then $text &= @CRLF & @CRLF & Localize("Professions_TakeRewards") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_EmptySlot") Then $text &= @CRLF & @CRLF & Localize("Professions_EmptySlot") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Search") Then $text &= @CRLF & @CRLF & Localize("Professions_Search") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Continue") Then $text &= @CRLF & @CRLF & Localize("Professions_Continue") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_StartTask") Then $text &= @CRLF & @CRLF & Localize("Professions_StartTask") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset") Then
            $text &= @CRLF & @CRLF & Localize("Professions_Asset1") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            If ScreenDetection_ImageSearch("Professions_Asset", $_ImageSearchLeft, $_ImageSearchBottom + 100, $_ImageSearchRight, $_ImageSearchBottom + 150) Then $text &= @CRLF & @CRLF & Localize("Professions_Asset2") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        EndIf
        If ScreenDetection_ImageSearch("Professions_AssetBorder", $_ImageSearchLeft, $_ImageSearchTop, $_ImageSearchRight + 200) Then $text &= @CRLF & @CRLF & Localize("Professions_AssetBorder") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset_Hero") Then $text &= @CRLF & @CRLF & Localize("Professions_Asset_Hero") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset_Adventurer") Then $text &= @CRLF & @CRLF & Localize("Professions_Asset_Adventurer") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset_ManatArms") Then $text &= @CRLF & @CRLF & Localize("Professions_Asset_ManatArms") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset_Footman") Then $text &= @CRLF & @CRLF & Localize("Professions_Asset_Footman") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset_Guard") Then $text &= @CRLF & @CRLF & Localize("Professions_Asset_Guard") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
        If ScreenDetection_ImageSearch("Professions_Asset_Mercenary") Then $text &= @CRLF & @CRLF & Localize("Professions_Asset_Mercenary") & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
    EndIf
    ScreenDetection_Splash($text)
    Sleep(500)
WEnd
