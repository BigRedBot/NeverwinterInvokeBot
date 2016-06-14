#include-once

Func LoadLocalizationDefaults()
    If GetValue("Language") = "Russian" Then
        SetDefault("InvokeKey", "{CTRLDOWN}i{CTRLUP}")
        SetDefault("JumpKey", "{SPACE}")
        SetDefault("GameMenuKey", "{ESC}")
        SetDefault("CursorModeKey", "{F2}")
        SetDefault("InputBoxWidth", -1)
        SetDefault("InputBoxHeight", 155)
        SetDefault("StartInputBoxWidth", 300)
        SetDefault("StartInputBoxHeight", -1)
        SetDefault("SplashWidth", 380)
        SetDefault("SplashHeight", 185)
        SetDefault("ScreenDetectionSplashWidth", 380)
        SetDefault("ScreenDetectionSplashHeight", 400)
        SetDefault("LogInServerAddress", "208.95.186.167, 208.95.186.168, 208.95.186.96")
    Else
        SetDefault("InvokeKey", "{CTRLDOWN}i{CTRLUP}")
        SetDefault("JumpKey", "{SPACE}")
        SetDefault("GameMenuKey", "{ESC}")
        SetDefault("CursorModeKey", "{ALT}")
        SetDefault("InputBoxWidth", -1)
        SetDefault("InputBoxHeight", 145)
        SetDefault("StartInputBoxWidth", 300)
        SetDefault("StartInputBoxHeight", -1)
        SetDefault("SplashWidth", 380)
        SetDefault("SplashHeight", 185)
        SetDefault("ScreenDetectionSplashWidth", 380)
        SetDefault("ScreenDetectionSplashHeight", 400)
        SetDefault("LogInServerAddress", "208.95.186.167, 208.95.186.168, 208.95.186.96")
    EndIf
EndFunc
