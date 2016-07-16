RELEASE NOTES
=============

7.2
- Added Run Now option to the Unattended Launcher's tray icon menu.

7.1
- Will now detect if the login server is unavailable and wait 15 minutes to retry login.
- Will now detect if there is a version mismatch and try to patch the server if detected.
- Added option to disable overflow XP collection.

7.0.3
- Added VIPAccountRewardCharacter option that can be added to the Settings.ini file. ( This may be set to the character number that you want to claim the VIP account reward on. )

7.0.2
- Put session start indicator back in the log files.

7.0.1
- Added time remaining to the Unattended Launcher tool-tip.
- Added NoInputBlocking option that can be added to the Settings.ini file, to disable the blocking of your keyboard and mouse inputs when the script is running.

7.0
- Will now try to patch the game client if you have the arc client.
- Will now check the status of the game server before trying to log into the game.
- When installing, will now ask to run the unattended launcher on startup.
- Now always checks to see if there is a newer version instead of asking to check.
- Added some fixes for recursion errors.

6.9
- Added tray icon tooltips, colored taskbar tray icons, flashing, and removed auto pausing on click.
- Fixed ability to close game client.

6.8
- Repaired server reset time checking.
- Added Unattended.exe that can continuously run the invoke bot once a day while it is running.

6.7.2
- Unattended mode will now resume after started again if paused.
- Removed ListPID.

6.7.1
- Will now only use a maximum of one log file per session.

6.7
- Added log files. ( One log file per day is created. By default, only the latest 30 of these files are kept. )

6.6
- All statistics collection now saved in Statistics.ini instead of Settings.ini.

6.5.1
- Fixed account bound VIP reward claiming detection.

6.5
- Fixed and replaced statistics collection.

6.4.3
- The delay from the ClaimCofferDelay option in Settings.ini has been added between more steps when trying to claim a coffer.

6.4.2
- ListPID will no longer write to text file if no processes are found.

6.4.1
- Fixed ImageCapture game client resizing.

6.4
- Fixed bug with game client window detection.

6.3.5
- Will now count failed invoke attempts.

6.3.4
- Rearranged coffer selection to show before account total selection.

6.3.3
- Now looks at all processes for the game window.

6.3.2
- Installer now allows the choice of the install location.

6.3.1
- Changed default coffer to Coffer of Celestial Enchantments.

6.3
- Will now claim the account bound VIP reward.

6.2
- Added drop down list option to change the item to spend celestial coins on.

6.1
- Improved account switching logic.

6.0
- Added multi-account support.

5.6
- Removed UPX compression. (May have been causing some anti-virus false positives.)
- Added icon image.

5.5.2
- Added Russian uninstall translations.

5.5.1
- Allowed the ability to use login server domain addresses.

5.5
- Added Russian client support. ( Thanks to mef-t for all the translations and screen shots that made this possible. )

5.4.8
- User name and password now saved in a binary unicode format.
- Now using right arrow keys and backspace keys instead of ctrl+a to clear user name text field.

5.4.7
- Added Localize function.

5.4.6
- Added Russian translation for Invoking. Will not yet work with the Russian game client.

5.4.5
- Fixed problem with Russian language not displaying properly. Will not yet work with the Russian game client.

5.4.4
- Improved ability to get minutes until server resets.

5.4.3
- Added option for language. Will not yet work with the Russian game client.

5.4.2
- The mouse clicks after detecting an image will now randomly click a random location within the image.

5.4.1
- The mouse clicks will now randomly click within 5 pixels of the selected location.

5.4
- Added ability to get the minutes until server resets by synchronizing to a time server.

5.3
- Added auto-updater.

5.2.1
- Added an additional arrow key press to get the selected character from the character selection screen aligned correctly for pixel detection.

5.2
- Moved settings files to Application Data folder.
- Added uninstaller.

5.1.2
- Error messages set back to always being on top.

5.1.1
- Added donation link to desktop.

5.1
- The input and message boxes are no longer set to always on top.

5.0
- Added installer.

4.0
- Total number of characters, username and password are now saved to the settings files from the user interface.

3.37
- Modified the CelestialSynergyTab.png file.

3.36
- Fixed run GameClient.exe syntax error.

3.35.6
- Changed a few default values for the character selection screen pixel detection.

3.35.5
- Will no longer update the splash window text if the text is the same.

3.35.4
- Moved splash window to top right of screen when waiting.

3.35.3
- Splash window is now able to be moved when waiting.

3.35.2
- Added total number of possible invokes to the paused and completed message.

3.35.1
- Changed the wording of an error message.

3.35
- Changed the script to only run one instance at a time.

3.34
- The settings files will now be created the first time you start the Neverwinter Invoke Bot.
- (This is so that you no longer have to worry about overwriting them when upgrading to a newer version.)

3.33
- Will no longer give a message if the game client window is moved or resized unless it fails to move or resize the window.
- Will reset the number of failed login attempts when manually starting the script. (Be careful not to manually start the script too many times if logins are failing!)

3.32
- Removed initial jump command when logging into every character.

3.31.1
- Will no longer exit the script when giving an error message.

3.31
- Will no longer send jump commands while logging into a character if the first character has already been logged into.

3.30.4
- Changed the default BottomScrollBar and BottomSelectedCharacter values.

3.30.3
- Changed the EndAtLoop default number to 8. It will still stop early if 100% invokes are detected.

3.30.2
- Fixed an error that happens when the game crashes.

3.30.1
- Added press F4 hot-key to pause every time the splash window is used.

3.30
- Replaced au3 settings files with ini settings files.

3.29.1
- Removed a space for better readability.

3.29
- Added $MaxLogInAttempts option in the Settings.au3 file.

3.28
- Will now try to send the jump command when the script looks for the in game screen.
- (This is to clear the home page so that an image is not required to detect it.)

3.27
- Added dependency Shared.au3 to consolidate some shared code.

3.26
- Now finding the game window from its handle instead of its title.

3.25
- Replaced the Vault of Piety images.

3.24.1
- Changed the default color and location of the character selection screen scroll bar when it is all the way down.

3.24
- Updated images for login and character selection screens.
- Will now right click on the character selection menu to use the arrow keys.

3.23.2
- Will now show the character numbers that the script was working on during an idle logout.

3.23.1
- Will now show the character numbers that the script was working on during a time-out.

3.23
- Will now stop the script early if 100% invokes have been reached if more than 6 loops have been set.

3.22.1
- Shows how many times the script timed out.

3.22
- Will now restart the game if the script times out.

3.21
- Re-added idle log out message box detection, but now will skip to the next character when detected.
- Shows how many times an idle logout happened.
- (An idle logout usually only happens when an image search repeatedly fails to detect the image on a character.)

3.20
- Removed idle log out message box detection.

3.19.1
- Added idle log out message box detection to the screen detection script.

3.19
- Added option to specify location of login username box.
- Added detection of idle logout message box.

3.18.6
- Removed a few unnecessary tables from the loop timer. (No change in functionality.)

3.18.5
- Fixed an improper time out.

3.18.4
- Fixed percentage for successful invokes.

3.18.3
- Added a percentage for successful invokes, based on maximum invokes for total characters.

3.18.2
- Will not add a re-log to the counter when, logging in for the first time when the script is first ran.

3.18.1
- Will now always keep track of start delay time immediately.

3.18
- Replaced $GrayedOutInvoke setting with added Invoked.png image.
- Reduced default $ImageSearchTolerance to 50, because of false positives.
- Added the option to use unlimited loops.
- Replaced the $ExtraLoop setting with the $EndAtLoop setting.
- Added $LogInDelaySeconds setting.
- Will now show how many successful invokes have been done.

3.17.1
- Disabled always on top window setting when waiting for delays.

3.17
- Added extra file check for GameClient.exe.

3.16
- Will now detect the location of the GameClient.exe file from the registry.

3.15
- Modified restart game option.

3.14
- Modified restart game counter.

3.13
- Fixed restart game option.

3.12
- Added the option to restart the game if it crashes.

3.11
- Renamed the coffer files to remove the word Coffer.
- Added detection images for Elixir of Fate and the Blessed Professions Elemental Pack.

3.10
- Will now show how many characters have collected experience point rewards.

3.9.2
- Removed unneeded check.

3.9.1
- Now moves the mouse a shorter distance when moving it out of the way. Will also check first to see if it has to move out of the way.

3.9
- Now checks a second time a half second after the first detection to see if the congratulations window is still up.

3.8.6
- Changed the login function to prevent a possible endless loop.

3.8.5
- No longer requires all images to exist, when searching for more than one, while at least one exists.

3.8.4
- Improved screen resolution checking.

3.8.3
- No longer moves the game window unless it needs to be moved.

3.8.2
- Fixed screen resolution checking.

3.8.1
- Now checks to see if your screen resolution is high enough.

3.8
- Added an additional image for the Vault of Piety Button for better detection.
- Fixed overflow experience point reward collection.
- Added $CursorModeKey option.

3.7
- Will now collect overflow experience point rewards after a successful invoke.

3.6.4
- Added the version number in the title.

3.6.3
- Renamed a few utility script files.

3.6.2
- Added short descriptions to the top of the utility scripts.

3.6.1
- Unused code removed.

3.6
- Improved timers.

3.5.4
- A few insignificant changes. :p

3.5.3
- Fixed all mouse movement to be relative to the game client window.

3.5.2
- Restricted searching for images to within the game client screen instead of the entire window.

3.5.1
- Fixed bug that was not detecting if the game window is found.

3.5
- Changed the relative screen position to use the game client window space.
- Added simple screen capture tool to capture the client window to your clipboard.

3.4.1
- Filled in default pixel detection settings as a reference.
- Replaced the SelectionScreen image.

3.4
- Will now only check for GrayedOutInvoke once at the start of an invoke.
- Replaced GrayedOutInvoke image detection back to pixel detection.
- (GrayedOutInvoke is only to save time at the start of an invoke to see if the character has already invoked.)

3.3
- Set WinTitleMatchMode to exact.
- Changed default log in screen detection image.

3.2
- Added warning message to run the script using the 32 bit version of AutoIt.
- Changed default in game detection image.
- Changed default $ImageSearchTolerance to 80.

3.1
- Moved splash window out of the way of the game window.

3.0
- Added image searching and window resizing.

2.22
- Moved private information such as login credentials to the PrivateSettings.au3 file.

2.21
- Added option to include a password hash.

2.20
- Added option to leave the username or password blank in the Settings.au3 file, if you want to be prompted to enter them each time you run the script.

2.19
- Added return command to invoke function.

2.18
- Removed extra jump command.

2.17
- Replaced the GrayedOutInvokeButton options with GrayedOutInvoke and CongratulationsWindow options.

2.16.1
- Increased invoke retry seconds when screen detection is not set up to 5 seconds, but reduced retries to 3 times from 4.

2.16
- Decreased invoke retry delay by 5 seconds.

2.15
- Increased invoke retry delay by 9 more seconds.

2.14
- Added a one second delay between invoke retries.

2.13
- Will now try to clear windows such as inventory with a jump before looking for grayed out invoke pixel colors.

2.12
- Will now click on screen before trying to log back in after being disconnected.

2.11
- Will no longer try to detect screens before using the waiting to start option.

2.10.1
- Small delay before enter press added if change character button location is not defined.

2.10
- Added escape key commands in case the game menu key is changed

2.9
- Added option for change character confirmation detection

2.8.4
- Will now check window position before each screen detection

2.8.3
- Small change to the way text is updated

2.8.2
- First character selection screen detection now made to work the same as all others

2.8.1
- Changed the KeyDelaySeconds default to 0.15 seconds

2.8
- Changed command for default invoke key
- Added KeyDelaySeconds option with a default of 0.2 seconds

2.7.1
- Will now only set the default number for $EndAt if it is starting as 0

2.7
- Limited invoking tries to a set amount so that the script may continue if a character fails to invoke

2.6
- Added "Screen Detection.au3" file

2.5.1
- Added optional ability to separately specify the location that is clicked for the Vault of Piety button

2.5
- Will now look for pixel locations relative to the window location
- This can be disabled if a full screen fixed location is required

2.4.1
- Added #include for "Settings.au3" file

2.4
- Added option to specify the location of the Change Character button

2.3.1
- Removed Dim declarations

2.3
- Created separate "Settings.au3" file

2.2.1
- Clear ETA text if there is an invoke delay in the middle of a loop

2.2
- Added an option for an extra loop

2.1.2
- Fixed coffer counting

2.1.1
- Clear start delay when completed

2.1
- Added a start delay option

2.0.2
- Limited splash text refreshing for identical text

2.0.1
- Improved ETA calculation

2.0
- Added top and bottom character selection detection