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
    Local $aFileArr = StringSplit(StringStripCR($sReadFile), @LF), $aSplitKeyValue, $iValueWasWritten = 0, $sWriteFile = ""
    For $i = 1 To $aFileArr[0]
        If $i = 1 And StringRegExp($aFileArr[$i], "^\[.+\]$") Then $sWriteFile &= @CRLF
        If $iValueWasWritten Then
            If $aFileArr[$i] = "" And $i = $aFileArr[0] Then ExitLoop
            $sWriteFile &= $aFileArr[$i] & @CRLF
        ElseIf $aFileArr[$i] = "[" & $sSection & "]" Then
            $sWriteFile &= $aFileArr[$i] & @CRLF
            For $j = $i + 1 To $aFileArr[0]
                If $iValueWasWritten Then
                    If $aFileArr[$j] = "" And $j = $aFileArr[0] Then ExitLoop
                    $sWriteFile &= $aFileArr[$j] & @CRLF
                ElseIf StringRegExp(StringRegExpReplace($aFileArr[$j], '\s+=', '='), $sKey & '=') Then
                    $aSplitKeyValue = StringSplit($aFileArr[$j], "=")
                    $sWriteFile &= $aSplitKeyValue[1] & "=" & $sValue & @CRLF
                    $iValueWasWritten = 1
                ElseIf StringRegExp($aFileArr[$j], "^\[.+\]$") Then
                    $sWriteFile &= $sKey & "=" & $sValue & @CRLF & $aFileArr[$j] & @CRLF
                    $iValueWasWritten = 1
                ElseIf $j = $aFileArr[0] Then
                    Local $newline = @CRLF
                    If $aFileArr[$j] = "" Then $newline = ""
                    $sWriteFile &= $newline & $aFileArr[$j] & @CRLF & $sKey & "=" & $sValue & @CRLF
                    $iValueWasWritten = 1
                ElseIf $aFileArr[$j] = "" Then
                    For $k = $j + 1 To $aFileArr[0]
                        If $aFileArr[$k] <> "" Then
                            If StringRegExp($aFileArr[$k], "^\[.+\]$") Then
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
            If $aFileArr[$i] = "" Then $newline = ""
            $sWriteFile &= $newline & "[" & $sSection & "]" & @CRLF & $sKey & "=" & $sValue & @CRLF
            $iValueWasWritten = 1
        ElseIf $aFileArr[$i] = "" Then
            For $j = $i + 1 To $aFileArr[0]
                If $aFileArr[$j] <> "" Then
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
    Local $sText = Default
    If $bRemoveBlankLines Then
        $sText = FileRead($sIniFile)
        If @error <> 0 Then Return
        Local $sTextReplace = @CRLF & StringRegExpReplace(StringRegExpReplace(String($sText), "(\v)+", @CRLF), "(^\v*)|(\v*\Z)", "") & @CRLF
        If Not ($sTextReplace == $sText) Then
            Local $hFile = FileOpen($sIniFile, $FO_OVERWRITE + $iUTFMode)
            FileWrite($hFile, $sTextReplace)
            FileClose($hFile)
            Return
        EndIf
    EndIf
    If StringRegExp(String(FileReadLine($sIniFile, 1)), "^\[.+\]$") Then
        If VarGetType($sText) = "Keyword" Then
            $sText = FileRead($sIniFile)
            If @error <> 0 Then Return
        EndIf
        Local $hFile = FileOpen($sIniFile, $FO_OVERWRITE + $iUTFMode)
        FileWrite($hFile, @CRLF & $sText)
        FileClose($hFile)
    EndIf
EndFunc

Func _UnicodeIni_BinaryToString($value = "")
    If StringRegExp(String($value), "^0x.") Then Return BinaryToString($value, $SB_UTF8)
    Return BinaryToString(StringToBinary($value), $SB_UTF8)
EndFunc
