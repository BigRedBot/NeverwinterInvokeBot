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
; Syntax:           _ImageSearchArea, _ImageSearch
; Parameter(s):
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned $_ImageSearchX, $_ImageSearchY location of the image is.
;                                     0 for centre of image, 1 or greater for random number of pixels away from center of image, -1 for top left of image,  -2 for random location within image
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================
Global $_ImageSearchLeft = 0, $_ImageSearchTop = 0, $_ImageSearchRight = 0, $_ImageSearchBottom = 0, $_ImageSearchWidth = 0, $_ImageSearchHeight = 0, $_ImageSearchCenterWidth = 0, $_ImageSearchCenterHeight = 0, $_ImageSearchX = 0, $_ImageSearchY = 0

Func _ImageSearch($findImage, $resultPosition, $tolerance, $width = @DesktopWidth, $height = @DesktopHeight)
    If $width = 0 Then $width = @DesktopWidth
    If $height = 0 Then $height = @DesktopHeight
    return _ImageSearchArea($findImage, $resultPosition, 0, 0, $width - 1, $height - 1, $tolerance)
EndFunc

Func _ImageSearchArea($findImage, $resultPosition, $left, $top, $right, $bottom, $tolerance)
    if $tolerance > 0 then $findImage = "*" & $tolerance & " " & $findImage
    Local $result = DllCall("ImageSearchDLL.dll", "str", "ImageSearch", "int", $left, "int", $top, "int", $right, "int", $bottom, "str", $findImage)
    if not IsArray($result) or $result[0] = "0" then return 0
    Local $array = StringSplit($result[0], "|")
    $_ImageSearchLeft = Floor(Number($array[2]))
    $_ImageSearchTop = Floor(Number($array[3]))
    $_ImageSearchWidth = Floor(Number($array[4]))
    $_ImageSearchHeight = Floor(Number($array[5]))
    $_ImageSearchCenterWidth = Floor(($_ImageSearchWidth-1)/2)
    $_ImageSearchCenterHeight = Floor(($_ImageSearchHeight-1)/2)
    $_ImageSearchRight = $_ImageSearchLeft + $_ImageSearchWidth-1
    $_ImageSearchBottom = $_ImageSearchTop + $_ImageSearchHeight-1
    $_ImageSearchX = $_ImageSearchLeft
    $_ImageSearchY = $_ImageSearchTop
    if $resultPosition >= 0 then
        if $resultPosition > 0 then
            $_ImageSearchX += Random(-$resultPosition, $resultPosition, 1)
            $_ImageSearchY += Random(-$resultPosition, $resultPosition, 1)
        else
            $_ImageSearchX += $_ImageSearchCenterWidth
            $_ImageSearchY += $_ImageSearchCenterHeight
        endif
    elseif $resultPosition < -1 then
        $_ImageSearchX = Random($_ImageSearchLeft, $_ImageSearchRight, 1)
        $_ImageSearchY = Random($_ImageSearchTop, $_ImageSearchBottom, 1)
    endif
    return 1
EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch, _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned $_ImageSearchX, $_ImageSearchY location of the image is.
;                                     0 for centre of image, 1 or greater for random number of pixels away from center of image, -1 for top left of image,  -2 for random location within image
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage, $waitSecs, $resultPosition, $tolerance, $width = @DesktopWidth, $height = @DesktopHeight)
    If $width = 0 Then $width = @DesktopWidth
    If $height = 0 Then $height = @DesktopHeight
    Local $startTime = TimerInit()
    While TimerDiff($startTime) < $waitSecs * 1000
        if _ImageSearch($findImage, $resultPosition, $tolerance, $width, $height) Then return 1
        sleep(100)
    WEnd
    return 0
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
;                   $resultPosition - Set where the returned $_ImageSearchX, $_ImageSearchY location of the image is.
;                                     0 for centre of image, 1 or greater for random number of pixels away from center of image, -1 for top left of image,  -2 for random location within image
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage, $waitSecs, $resultPosition, $tolerance, $width = @DesktopWidth, $height = @DesktopHeight)
    Local $startTime = TimerInit()
    While TimerDiff($startTime) < $waitSecs * 1000
        for $i = 1 to $findImage[0]
            if _ImageSearch($findImage[$i], $resultPosition, $tolerance, $width, $height) Then return $i
            sleep(100)
        Next
    WEnd
    return 0
EndFunc
