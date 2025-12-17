@echo off
REM ========================================================
REM Create Placeholder Images for Finacle UI
REM Creates simple colored placeholder GIF files
REM ========================================================

echo.
echo ========================================================
echo    Creating Placeholder Images for Finacle UI
echo ========================================================
echo.

set IMAGE_DIR=static\ui\images
mkdir "%IMAGE_DIR%" 2>nul

echo Creating placeholder images...

REM Create VBScript to generate placeholder images
(
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo.
echo ' Create simple text placeholder files ^(since GIF generation requires complex libs^)
echo ' These will be replaced with actual images later
echo.
echo imageDir = "%CD%\%IMAGE_DIR%"
echo.
echo ' Create placeholder marker files
echo images = Array^( _
echo     "home_icon.gif", _
echo     "profile_icon.gif", _
echo     "messages_icon.gif", _
echo     "email_icon.gif", _
echo     "calculator_icon.gif", _
echo     "notepad_icon.gif", _
echo     "search.gif", _
echo     "folder_icon.gif", _
echo     "close_icon.gif", _
echo     "folder_closed.gif", _
echo     "folder_open.gif", _
echo     "document.gif", _
echo     "infosys_logo.gif", _
echo     "loginbg.gif", _
echo     "logo.gif" _
echo ^)
echo.
echo For Each img In images
echo     Set f = fso.CreateTextFile^(imageDir ^& "\" ^& img, True^)
echo     f.WriteLine "GIF89a placeholder"
echo     f.Close
echo     WScript.Echo "Created: " ^& img
echo Next
echo.
echo WScript.Echo "All placeholder images created!"
) > "%IMAGE_DIR%\create_placeholders.vbs"

cscript //nologo "%IMAGE_DIR%\create_placeholders.vbs"

echo.
echo ========================================================
echo NOTE: Placeholder files created!
echo.
echo These are simple placeholder files. For actual images:
echo 1. Find real Finacle icons online
echo 2. Use image editing software to create proper icons
echo 3. Replace placeholders in: %IMAGE_DIR%
echo.
echo The application will work with these placeholders,
echo but icons will appear as broken images in browser.
echo.
echo Alternative: Update JSP includes to use Unicode symbols
echo instead of image files ^(emoji work in modern browsers^)
echo ========================================================
echo.

pause
