#include-once
; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with Image Search
;                 Require that the ImageSearchDLL.dll be loadable
;
; ------------------------------------------------------------------------------

;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearch
; Parameter(s):
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;===============================================================================
Global $_ImageSearchLeft = 0, $_ImageSearchTop = 0, $_ImageSearchRight = 0, $_ImageSearchBottom = 0, $_ImageSearchWidth = 0, $_ImageSearchHeight = 0, $_ImageSearchWidthCenter = 0, $_ImageSearchHeightCenter = 0, $_ImageSearchX = 0, $_ImageSearchY = 0

Func _ImageSearch($findImage, $left = 0, $top = 0, $right = @DesktopWidth - 1, $bottom = @DesktopHeight - 1, $tolerance = 0)
    If $tolerance > 0 Then $findImage = "*" & $tolerance & " " & $findImage
    Local $result = DllCall("ImageSearchDLL.dll", "str", "ImageSearch", "int", $left, "int", $top, "int", $right, "int", $bottom, "str", $findImage)
    If Not IsArray($result) Or $result[0] = "0" Then Return 0
    Local $array = StringSplit($result[0], "|")
    $_ImageSearchLeft = Int(Number($array[2]))
    $_ImageSearchTop = Int(Number($array[3]))
    $_ImageSearchWidth = Int(Number($array[4]))
    $_ImageSearchHeight = Int(Number($array[5]))
    $_ImageSearchWidthCenter = $_ImageSearchLeft + Int(($_ImageSearchWidth - 1) / 2)
    $_ImageSearchHeightCenter = $_ImageSearchTop + Int(($_ImageSearchHeight - 1) / 2)
    $_ImageSearchRight = $_ImageSearchLeft + $_ImageSearchWidth - 1
    $_ImageSearchBottom = $_ImageSearchTop + $_ImageSearchHeight - 1
    $_ImageSearchX = Random($_ImageSearchLeft, $_ImageSearchRight, 1)
    $_ImageSearchY = Random($_ImageSearchTop, $_ImageSearchBottom, 1)
    Return 1
EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $left = 0, $top = 0, $right = @DesktopWidth - 1, $bottom = @DesktopHeight - 1, $tolerance = 0)
    Local $startTime = TimerInit()
    While TimerDiff($startTime) < $waitSecs * 1000
        If _ImageSearch($findImage, $left, $top, $right, $bottom, $tolerance) Then Return 1
        Sleep(100)
    WEnd
    Return 0
EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the ARRAY of images to locate on the desktop
;                              - ARRAY[0] is set to the number of images to loop through
;								 ARRAY[1] is the first image
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage, $waitSecs, $left = 0, $top = 0, $right = @DesktopWidth - 1, $bottom = @DesktopHeight - 1, $tolerance = 0)
    Local $startTime = TimerInit()
    While TimerDiff($startTime) < $waitSecs * 1000
        For $i = 1 To $findImage[0]
            If _ImageSearch($findImage[$i], $left, $top, $right, $bottom, $tolerance) Then Return $i
            Sleep(100)
        Next
    WEnd
    Return 0
EndFunc
