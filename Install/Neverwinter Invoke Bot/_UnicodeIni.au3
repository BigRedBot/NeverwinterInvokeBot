#include-once
#include <File.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>

Func _UnicodeIniWrite($sIniFile, $sSection, $sKey, $sValue, $iUTFMode = $FO_UTF8)
    Local $read = _UnicodeIniRead($sIniFile, $sSection, $sKey)
    If $read == $sValue Or ( StringRegExp(String($sValue), "^0x.") And $read == BinaryToString($sValue, $SB_UTF8) ) Then Return SetError(0, 0, 1)
    If BitOR($iUTFMode, $FO_BINARY, $FO_UNICODE, $FO_UTF16_BE, $FO_UTF8) <> Number($FO_BINARY + $FO_UNICODE + $FO_UTF16_BE + $FO_UTF8) Then $iUTFMode = $FO_UTF8
    Local $sReadFile = FileRead($sIniFile), $hFile = FileOpen($sIniFile, $FO_OVERWRITE + $FO_CREATEPATH + $iUTFMode)
    If $hFile = -1 Then
        Local $r = IniWrite($sIniFile, $sSection, $sKey, $sValue), $e = @error
        Return SetError($e, 0, $r)
    EndIf
    If @error <> 0 Then
        FileWrite($hFile, $sReadFile & @CRLF & "[" & $sSection & "]" & @CRLF & $sKey & "=" & $sValue & @CRLF)
        FileClose($hFile)
        _UnicodeIni_BlankLines($sIniFile)
        Return SetError(0, 0, 1)
    EndIf
    Local $aFileArr = StringSplit(StringStripCR($sReadFile), @LF), $iValueWasWritten = 0, $sWriteFile = ""
    For $i = 1 To $aFileArr[0]
        If $i = 1 And StringRegExp($aFileArr[$i], "^\s*\[.+]") Then $sWriteFile &= @CRLF
        If $iValueWasWritten Then
            If StringRegExp($aFileArr[$i], "^\s*$") And $i = $aFileArr[0] Then ExitLoop
            $sWriteFile &= $aFileArr[$i] & @CRLF
        ElseIf StringRegExp($aFileArr[$i], "^\s*\[" & $sSection & "]") Then
            $sWriteFile &= $aFileArr[$i] & @CRLF
            For $j = $i + 1 To $aFileArr[0]
                If $iValueWasWritten Then
                    If StringRegExp($aFileArr[$j], "^\s*$") And $j = $aFileArr[0] Then ExitLoop
                    $sWriteFile &= $aFileArr[$j] & @CRLF
                ElseIf StringRegExp($aFileArr[$j], "^\s*" & $sKey & "\s*=") Then
                    $sWriteFile &= $sKey & "=" & $sValue & @CRLF
                    $iValueWasWritten = 1
                ElseIf StringRegExp($aFileArr[$j], "^\s*\[.+]") Then
                    $sWriteFile &= $sKey & "=" & $sValue & @CRLF & $aFileArr[$j] & @CRLF
                    $iValueWasWritten = 1
                ElseIf $j = $aFileArr[0] Then
                    Local $newline = @CRLF
                    If StringRegExp($aFileArr[$j], "^\s*$") Then $newline = ""
                    $sWriteFile &= $newline & $aFileArr[$j] & @CRLF & $sKey & "=" & $sValue & @CRLF
                    $iValueWasWritten = 1
                ElseIf StringRegExp($aFileArr[$j], "^\s*$") Then
                    For $k = $j + 1 To $aFileArr[0]
                        If Not StringRegExp($aFileArr[$k], "^\s*$") Then
                            If StringRegExp($aFileArr[$k], "^\s*\[.+]") Then
                                $sWriteFile &= $sKey & "=" & $sValue & @CRLF
                                $iValueWasWritten = 1
                            EndIf
                            ExitLoop
                        EndIf
                    Next
                EndIf
                If Not $iValueWasWritten Then $sWriteFile &= $aFileArr[$j] & @CRLF
            Next
            ExitLoop
        ElseIf $i = $aFileArr[0] Then
            Local $newline = @CRLF
            If StringRegExp($aFileArr[$i], "^\s*$") Then $newline = ""
            $sWriteFile &= $newline & "[" & $sSection & "]" & @CRLF & $sKey & "=" & $sValue & @CRLF
            $iValueWasWritten = 1
        ElseIf StringRegExp($aFileArr[$i], "^\s*$") Then
            For $j = $i + 1 To $aFileArr[0]
                If Not StringRegExp($aFileArr[$j], "^\s*$") Then
                    ExitLoop
                ElseIf $j = $aFileArr[0] Then
                    $sWriteFile &= "[" & $sSection & "]" & @CRLF & $sKey & "=" & $sValue & @CRLF
                    $iValueWasWritten = 1
                    ExitLoop
                EndIf
            Next
        EndIf
        If Not $iValueWasWritten Then $sWriteFile &= $aFileArr[$i] & @CRLF
    Next
    FileWrite($hFile, $sWriteFile)
    FileClose($hFile)
    _UnicodeIni_BlankLines($sIniFile)
    Return SetError(0, 0, 1)
EndFunc

Func _UnicodeIniRead($sIniFile, $sSection, $sKey, $sDefault = "")
    _UnicodeIni_BlankLines($sIniFile, 0)
    Local $r = IniRead($sIniFile, $sSection, $sKey, $sDefault)
    Return SetError(@error, 0, _UnicodeIni_BinaryToString($r))
EndFunc

Func _UnicodeIniDelete($sIniFile, $sSection, $sKey = 0)
    _UnicodeIni_BlankLines($sIniFile, 0)
    Local $r, $e
    If $sKey Then
        If _UnicodeIniRead($sIniFile, $sSection, $sKey) = "" Then Return SetError(0, 0, 1)
        Local $aArray = IniReadSection($sIniFile, $sSection)
        If @error = 0 And $aArray[0][0] = 1 And $aArray[1][0] == $sKey Then
            $r = IniDelete($sIniFile, $sSection)
            $e = @error
        Else
            $r = IniDelete($sIniFile, $sSection, $sKey)
            $e = @error
        EndIf
    Else
        $r = IniDelete($sIniFile, $sSection)
        $e = @error
    EndIf
    _UnicodeIni_BlankLines($sIniFile)
    Return SetError($e, 0, $r)
EndFunc

Func _UnicodeIni_BlankLines($sIniFile, $bRemoveBlankLines = 1, $iUTFMode = $FO_UTF8)
    If BitOR($iUTFMode, $FO_BINARY, $FO_UNICODE, $FO_UTF16_BE, $FO_UTF8) <> Number($FO_BINARY + $FO_UNICODE + $FO_UTF16_BE + $FO_UTF8) Then $iUTFMode = $FO_UTF8
    Local $lines = _FileCountLines($sIniFile)
    If @error <> 0 Then Return
    Local $hFile = FileOpen($sIniFile, $iUTFMode)
    If @error <> 0 Then Return FileClose($hFile)
    Local $sText = FileRead($hFile)
    If @error <> 0 Then Return FileClose($hFile)
    If $bRemoveBlankLines Or StringRegExp(FileReadLine($hFile, 1), "^\s*\[.+]") Or StringRegExp(FileReadLine($hFile, $lines), "^\s*\[.+]") Then
        FileClose($hFile)
        Local $sTextReplace = @CRLF & StringRegExpReplace(StringRegExpReplace($sText, "(\s*\v)+", @CRLF), "\A\s*\v|\v\s*\Z", "") & @CRLF
        If Not ($sTextReplace == $sText) Then
            $hFile = FileOpen($sIniFile, $FO_OVERWRITE + $iUTFMode)
            FileWrite($hFile, $sTextReplace)
            FileClose($hFile)
        EndIf
    Else
        FileClose($hFile)
    EndIf
EndFunc

Func _UnicodeIni_BinaryToString($value = "")
    If StringRegExp(String($value), "^0x.") Then Return BinaryToString($value, $SB_UTF8)
    Return BinaryToString(StringToBinary($value), $SB_UTF8)
EndFunc
