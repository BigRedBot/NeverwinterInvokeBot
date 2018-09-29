#include-once
#include <InetConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstants.au3>
#include <FileConstants.au3>

Func _DownloadFile($DownloadURL, $Name, $DownloadTitle = "Downloading", $DownloadMsg = "Downloading: " & $DownloadURL, $Path = @ScriptDir)
    Local $DownloadFilePath = $Path & "\" & $Name & ".tmp"
    FileDelete($DownloadFilePath)
    If FileExists($DownloadFilePath) Then Return 0
    Local $DownloadSize = InetGetSize($DownloadURL, $INET_FORCERELOAD)
    If @error Then Return 0
    If Number($DownloadSize) > 0 Then
        Local $Download = InetGet($DownloadURL, $DownloadFilePath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
        If @error Then
            InetClose($Download)
            FileDelete($DownloadFilePath)
            Return 0
        EndIf
        Local $hGUI = GUICreate($DownloadTitle, 420, 84)
        Local $message = GUICtrlCreateLabel("0%", 10, 12, 400, 20, $SS_Left)
        Local $percent = GUICtrlCreateLabel("0%", 10, 59, 400, 20, $SS_CENTER)
        Local $progressbar = GUICtrlCreateProgress(10, 35, 400, 20, $PBS_SMOOTH)
        GUICtrlSetData($message, $DownloadMsg)
        GUISetState()
        Local $last = 0
        Do
            If GUIGetMsg() = $GUI_EVENT_CLOSE Then
                InetClose($Download)
                FileDelete($DownloadFilePath)
                GUIDelete($hGUI)
                Return 0
            Else
                Sleep(100)
                Local $Data = InetGetInfo($Download)
                If $Data[$INET_DOWNLOADREAD] <> $last Then
                    $last = $Data[$INET_DOWNLOADREAD]
                    Local $i = Floor(($Data[$INET_DOWNLOADREAD] / $DownloadSize) * 100)
                    GUICtrlSetData($progressbar, $i)
                    GUICtrlSetData($percent, "(" & _DownloadFileAddCommaToNumber($Data[$INET_DOWNLOADREAD]) & " / " & _DownloadFileAddCommaToNumber($DownloadSize) & ") " & $i & "%")
                EndIf
            EndIf
        Until InetGetInfo($Download, $INET_DOWNLOADCOMPLETE)
        GUIDelete($hGUI)
        Local $Data = InetGetInfo($Download)
        If @error Then
            InetClose($Download)
            FileDelete($DownloadFilePath)
            Return 0
        EndIf
        InetClose($Download)
        If $Data[$INET_DOWNLOADCOMPLETE] And $Data[$INET_DOWNLOADSUCCESS] And Not $Data[$INET_DOWNLOADERROR] And FileMove($DownloadFilePath, $Path & "\" & $Name, $FC_OVERWRITE) Then Return $Path & "\" & $Name
    EndIf
    FileDelete($DownloadFilePath)
    Return 0
EndFunc

Func _DownloadFileAddCommaToNumber($v)
    Local $s = String(Ceiling(Number($v)))
    If StringLen($s) > 3 Then
        $s = StringLeft($s, StringLen($s) - 3) & "," & StringRight($s,3)
        Do
           If Not StringInStr(StringLeft($s, 4), ",") Then
              $s = StringLeft($s, StringInStr($s, ",") - 4) & "," & StringRight($s, StringLen($s) - StringInStr($s, ",") + 4)
           EndIf
        Until StringInStr(StringLeft($s, 4), ",")
    EndIf
    Return $s
EndFunc
