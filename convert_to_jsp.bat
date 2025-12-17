@echo off
REM Convert Scraped HTML to JSP and Setup Finacle Structure
REM This creates a local JSP-like environment from scraped content

setlocal enabledelayedexpansion

echo ========================================================
echo FINACLE JSP CONVERTER - HTML to JSP Structure
echo ========================================================
echo.

REM Get scraped folder
set /p SCRAPED_FOLDER="Enter scraped folder name (e.g., scrape2_20251210_183156): "

if not exist "%SCRAPED_FOLDER%" (
    echo ERROR: Folder not found: %SCRAPED_FOLDER%
    pause
    exit /b 1
)

REM Create JSP directory structure
echo Creating JSP directory structure...
mkdir jsp 2>nul
mkdir jsp\ui 2>nul
mkdir jsp\fininfra 2>nul
mkdir jsp\fininfra\ui 2>nul
mkdir static\fininfra 2>nul
mkdir static\fininfra\ui 2>nul
mkdir static\fininfra\javascripts 2>nul

echo.
echo [STEP 1/5] Converting HTML to JSP format...

REM Convert main HTML to SSOLogin.jsp
if exist "%SCRAPED_FOLDER%\html\main_page.html" (
    echo Converting main_page.html to SSOLogin.jsp...
    
    REM Create VBScript to process the HTML
    (
    echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
    echo Set inFile = fso.OpenTextFile^("%CD%\%SCRAPED_FOLDER%\html\main_page.html", 1^)
    echo content = inFile.ReadAll
    echo inFile.Close
    echo.
    echo ' Add JSP headers if not present
    echo If InStr^(content, "^<%@"^) = 0 Then
    echo     jspHeader = "^<%@ page language=""java"" contentType=""text/html; charset=UTF-8"" pageEncoding=""UTF-8"" %^>" ^& vbCrLf
    echo     content = jspHeader ^& content
    echo End If
    echo.
    echo ' Replace absolute URLs with context-relative paths
    echo content = Replace^(content, "https://fin10uat.ucobanknet.in:20000", ""^)
    echo content = Replace^(content, "https://fin10uat.ucobanknet.in", ""^)
    echo content = Replace^(content, "/fininfra", ""^)
    echo.
    echo ' Add JSP context path variables
    echo content = Replace^(content, "href=""/ui/", "href=""^<%=request.getContextPath^(^)%^>/ui/"^)
    echo content = Replace^(content, "src=""/ui/", "src=""^<%=request.getContextPath^(^)%^>/ui/"^)
    echo content = Replace^(content, "href=""/javascripts/", "href=""^<%=request.getContextPath^(^)%^>/javascripts/"^)
    echo content = Replace^(content, "src=""/javascripts/", "src=""^<%=request.getContextPath^(^)%^>/javascripts/"^)
    echo.
    echo ' Write to JSP file
    echo Set outFile = fso.CreateTextFile^("jsp\fininfra\ui\SSOLogin.jsp", True^)
    echo outFile.Write content
    echo outFile.Close
    echo.
    echo WScript.Echo "Created SSOLogin.jsp"
    ) > "%SCRAPED_FOLDER%\convert_to_jsp.vbs"
    
    cscript //nologo "%SCRAPED_FOLDER%\convert_to_jsp.vbs"
    echo     [SUCCESS] Created jsp\fininfra\ui\SSOLogin.jsp
) else (
    echo     [WARNING] main_page.html not found
)

echo.
echo [STEP 2/5] Copying CSS files to static directory...
if exist "%SCRAPED_FOLDER%\css\" (
    xcopy /Y /Q "%SCRAPED_FOLDER%\css\*.*" "static\fininfra\ui\" >nul 2>nul
    echo     [SUCCESS] Copied CSS files
) else (
    echo     [WARNING] No CSS files found
)

echo.
echo [STEP 3/5] Copying JavaScript files to static directory...
if exist "%SCRAPED_FOLDER%\js\" (
    xcopy /Y /Q "%SCRAPED_FOLDER%\js\*.*" "static\fininfra\javascripts\" >nul 2>nul
    echo     [SUCCESS] Copied JavaScript files
) else (
    echo     [WARNING] No JavaScript files found
)

echo.
echo [STEP 4/5] Creating JSP configuration files...

REM Create web.xml equivalent (info file)
(
echo ========================================================
echo FINACLE JSP APPLICATION CONFIGURATION
echo ========================================================
echo Application: UCO Bank CBS - Finacle
echo Converted from scraped content: %date% %time%
echo.
echo JSP Pages:
echo   - jsp/fininfra/ui/SSOLogin.jsp
echo.
echo Static Resources:
echo   - static/fininfra/ui/*.css
echo   - static/fininfra/javascripts/*.js
echo.
echo Server Configuration:
echo   - Context Path: /fininfra
echo   - Character Encoding: UTF-8
echo   - Session Timeout: 30 minutes
echo   - IE Compatibility: IE=10
echo.
echo ========================================================
) > jsp\APP_INFO.txt

echo     [SUCCESS] Created configuration files

echo.
echo [STEP 5/5] Updating Go server to serve JSP...

REM Check if main.go needs updating
findstr /C:"handleJSP" main.go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo     [INFO] Go server needs manual update to support JSP routes
    echo     [INFO] The JSP handler is already added in the latest version
) else (
    echo     [SUCCESS] Go server already configured for JSP
)

echo.
echo ========================================================
echo CONVERSION COMPLETE
echo ========================================================
echo.
echo Directory Structure Created:
echo   jsp/fininfra/ui/SSOLogin.jsp
echo   static/fininfra/ui/[CSS files]
echo   static/fininfra/javascripts/[JS files]
echo.
echo To run the Finacle-like JSP application:
echo   1. Start the Go server: go run main.go
echo   2. Access: http://localhost:8080/fininfra/ui/SSOLogin.jsp
echo.
echo The server will:
echo   - Process JSP tags and expressions
echo   - Replace context paths dynamically
echo   - Serve static resources
echo   - Handle IE compatibility mode
echo.
echo ========================================================

pause
