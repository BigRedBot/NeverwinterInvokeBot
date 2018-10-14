#NoTrayIcon
Global $Title = "Neverwinter Invoke Bot: Screen Detection Professions"
#include "Shared.au3"
If _Singleton("Neverwinter Invoke Bot: Screen Detection Professions" & "Jp4g9QRntjYP", 1) = 0 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("ScreenDetectionAlreadyRunning"))
If @AutoItX64 Then Exit MsgBox($MB_ICONWARNING + $MB_TOPMOST, $Title, Localize("Use32bit"))
TraySetIcon(@ScriptDir & "\images\black.ico")
TrayItemSetOnEvent(TrayCreateItem(Localize("Exit")), "ExitScript")
TraySetToolTip($Title)
#include "_ImageSearch.au3"

Func ExitScript()
    Exit
EndFunc

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

Func ImageSearch($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $tolerance = GetValue("ImageTolerance"))
    If Not FileExists($ImagePath & $image & ".png") Then Return 0
    If _ImageSearch($ImagePath & $image & ".png", $left, $top, $right, $bottom, $tolerance) Then Return 1
    Local $i = 2
    While FileExists($FullImagePath & $image & "-" & $i & ".png")
        If _ImageSearch($ImagePath & $image & "-" & $i & ".png", $left, $top, $right, $bottom, $tolerance) Then Return $i
        $i += 1
    WEnd
    Return 0
EndFunc

Func CheckImage($image, $left = $ClientLeft, $top = $ClientTop, $right = $ClientRight, $bottom = $ClientBottom, $intro = @CRLF & @CRLF, $ext = "")
    Local $i = ImageSearch($image, $left, $top, $right, $bottom), $n = ""
    If Not $i Then Return 0
    If $i > 1 Then $n = "-" & $i
    $text &= $intro & $image & $n & ".png" & $ext & @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
    Return $i
EndFunc

Local $MaxProfessionLevel = 25

HotKeySet("{Esc}", "ExitScript")
Splash()
While 1
    If Position() And $ClientWidth And $ClientHeight Then
        $timer = TimerInit()
        $count += 1
        If ImageSearch("Professions_Leadership") Then
            $text &= @CRLF & @CRLF & "Professions_Leadership.png"
            Local $text2 = @CRLF & $_ImageSearchLeft-$OffsetX & ", " & $_ImageSearchTop-$OffsetY & " - " & $_ImageSearchRight-$OffsetX & ", " & $_ImageSearchBottom-$OffsetY
            Local $left = $_ImageSearchLeft, $top = $_ImageSearchTop - 44, $right = $_ImageSearchLeft + 100, $bottom = $_ImageSearchTop - 31, $tens, $ones, $image1, $image2, $tolerance = GetValue("ProfessionLevelImageTolerance"), $ProfessionLevel = $MaxProfessionLevel
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
        CheckImage("Professions_Overview")
        CheckImage("Professions_CollectResult")
        CheckImage("Professions_TakeRewards")
        CheckImage("Professions_EmptySlot")
        CheckImage("Professions_Search")
        CheckImage("Professions_Continue")
        CheckImage("Professions_Details")
        CheckImage("Professions_StartTask")
        If CheckImage("Professions_Asset", $ClientLeft, $ClientTop, $ClientRight, $ClientBottom, @CRLF & @CRLF, " 1") Then
            CheckImage("Professions_Asset", $_ImageSearchLeft, $_ImageSearchBottom + 100, $_ImageSearchRight, $_ImageSearchBottom + 150, @CRLF, " 2")
            CheckImage("Professions_AssetBorder", $_ImageSearchLeft, $_ImageSearchTop, $_ImageSearchRight + 200, $ClientBottom, @CRLF)
        EndIf
        CheckImage("Professions_Asset_Hero")
        CheckImage("Professions_Asset_Adventurer")
        CheckImage("Professions_Asset_ManatArms")
        CheckImage("Professions_Asset_Footman")
        CheckImage("Professions_Asset_Guard")
        CheckImage("Professions_Asset_Mercenary")
        CheckImage("Professions_ResonantBag")
        CheckImage("Professions_ArtifactParaphenalia")
        CheckImage("Professions_ThaumaturgicBag")
        CheckImage("Professions_EnchantedCoffer")
        $time = Round(TimerDiff($timer) / 1000, 2)
    EndIf
    Splash($count & "x " & $time & "s" & @CRLF & $text)
WEnd
