#include-once
#include <FileConstants.au3>
#include <StringConstants.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _SelfDelete
; Description ...: Delete the current executable after it's finished processing and/or the timer has been reached.
; Syntax ........: _SelfDelete([$iDelay = 5[, $fUsePID = False[, $fRemoveDir = False]]])
; Parameters ....: $iDelay              - [optional] An integer value for the delay to wait (in seconds) before stopping the process and deleting the executable.
;                                         If 0 is specified then the batch will wait indefinitely until the process no longer exits. Default is 5 (seconds).
;                  $fUsePID             - [optional] Use the process name (False) or PID (True). Default is False.
;                  $fRemoveDir          - [optional] Remove the script directory as well (True) or only the running executable (False). Default is False.
; Return values .: Success - Returns the PID of the batch file.
;                  Failure - Returns 0 & sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......: The idea for removing the directory came from: http://www.autoitscript.com/forum/topic/137287-delete-scriptdir/
; Example .......: Yes
; ===============================================================================================================================
Func _SelfDelete($iDelay = 5, $fUsePID = Default, $fRemoveDir = Default)
    If @Compiled = 0 Then
        Return SetError(1, 0, 0)
    EndIf

    Local $sTempFileName = @ScriptName
    $sTempFileName = StringLeft($sTempFileName, StringInStr($sTempFileName, '.', $STR_NOCASESENSEBASIC, -1) - 1)
    While FileExists(@TempDir & '\' & $sTempFileName & '.bat')
        $sTempFileName &= Chr(Random(65, 122, 1))
    WEnd
    $sTempFileName = @TempDir & '\' & $sTempFileName & '.bat'

    Local $sDelay = ''
    $iDelay = Int($iDelay)
    If $iDelay > 0 Then
        $sDelay = 'IF %TIMER% GTR ' & $iDelay & ' GOTO DELETE'
    EndIf

    Local $sRemoveDir = ''
    If $fRemoveDir Then
        $sRemoveDir = 'RD /S /Q "' & FileGetShortName(@ScriptDir) & '"' & @CRLF
    EndIf

    Local $sAppID = @ScriptName, $sImageName = 'IMAGENAME'
    If $fUsePID Then
        $sAppID = @AutoItPID
        $sImageName = 'PID'
    EndIf

    Local Const $iInternalDelay = 2, _
            $sScriptPath = FileGetShortName(@ScriptFullPath)
    Local Const $sData = 'SET TIMER=0' & @CRLF _
             & ':START' & @CRLF _
             & 'PING -n ' & $iInternalDelay & ' 127.0.0.1 > nul' & @CRLF _
             & $sDelay & @CRLF _
             & 'SET /A TIMER+=1' & @CRLF _
             & @CRLF _
             & 'TASKLIST /NH /FI "' & $sImageName & ' EQ ' & $sAppID & '" | FIND /I "' & $sAppID & '" >nul && GOTO START' & @CRLF _
             & 'GOTO DELETE' & @CRLF _
             & @CRLF _
             & ':DELETE' & @CRLF _
             & 'TASKKILL /F /FI "' & $sImageName & ' EQ ' & $sAppID & '"' & @CRLF _
             & 'DEL "' & $sScriptPath & '"' & @CRLF _
             & 'IF EXIST "' & $sScriptPath & '" GOTO DELETE' & @CRLF _
             & $sRemoveDir _
             & 'GOTO END' & @CRLF _
             & @CRLF _
             & ':END' & @CRLF _
             & 'DEL "' & $sTempFileName & '"'

    Local Const $hFileOpen = FileOpen($sTempFileName, $FO_OVERWRITE)
    If $hFileOpen = -1 Then
        Return SetError(2, 0, 0)
    EndIf
    FileWrite($hFileOpen, $sData)
    FileClose($hFileOpen)
    Return Run($sTempFileName, @TempDir, @SW_HIDE)
EndFunc   ;==>_SelfDelete