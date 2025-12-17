@echo off
REM ========================================================
REM UNIVERSAL WEB SCRAPER - Maximum Detail Extraction
REM Scrapes any website with comprehensive resource fetching
REM ========================================================

setlocal enabledelayedexpansion

echo.
echo ========================================================
echo       UNIVERSAL WEB SCRAPER - MAXIMUM DETAIL
echo ========================================================
echo.

REM Get URL input from user
set "TARGET_URL="
set /p TARGET_URL="Enter URL to scrape (e.g., https://example.com/page.jsp): "

if "%TARGET_URL%"=="" (
    echo ERROR: URL cannot be empty!
    pause
    exit /b 1
)

REM Get output folder name
set "OUTPUT_NAME="
set /p OUTPUT_NAME="Enter output folder name (e.g., uco_bank_scrape): "

if "%OUTPUT_NAME%"=="" (
    echo ERROR: Folder name cannot be empty!
    pause
    exit /b 1
)

REM Create timestamped output directory
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set OUTPUT_DIR=%OUTPUT_NAME%_%dt:~0,8%_%dt:~8,6%
mkdir "%OUTPUT_DIR%" 2>nul
mkdir "%OUTPUT_DIR%\html" 2>nul
mkdir "%OUTPUT_DIR%\css" 2>nul
mkdir "%OUTPUT_DIR%\js" 2>nul
mkdir "%OUTPUT_DIR%\images" 2>nul
mkdir "%OUTPUT_DIR%\resources" 2>nul

echo.
echo Target URL: %TARGET_URL%
echo Output Directory: %OUTPUT_DIR%
echo.
echo Starting comprehensive scrape...
echo.

REM Extract base URL for relative paths
for /f "tokens=1-3 delims=:/" %%a in ("%TARGET_URL%") do (
    set PROTOCOL=%%a
    set DOMAIN=%%b
)

REM Parse URL to get base path
echo %TARGET_URL% > "%OUTPUT_DIR%\temp_url.txt"
for /f "tokens=1,2,3 delims=/" %%a in ('type "%OUTPUT_DIR%\temp_url.txt"') do (
    set BASE_URL=%%a//%%b
)
del "%OUTPUT_DIR%\temp_url.txt" 2>nul

echo Base URL: %BASE_URL%
echo.

REM ========================================================
REM STEP 1: Download Main HTML Page - Multiple Methods
REM ========================================================
echo [STEP 1/10] Downloading main HTML page (trying multiple methods)...

REM Method 1: curl with full headers
echo     Method 1: Using curl...
curl -k -v -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/119.0" ^
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" ^
  -H "Accept-Language: en-US,en;q=0.5" ^
  -H "Connection: keep-alive" ^
  -H "Upgrade-Insecure-Requests: 1" ^
  -H "Cache-Control: no-cache" ^
  --cookie-jar "%OUTPUT_DIR%\cookies.txt" ^
  --cookie "%OUTPUT_DIR%\cookies.txt" ^
  -o "%OUTPUT_DIR%\html\main_page_curl.html" ^
  "%TARGET_URL%" 2>"%OUTPUT_DIR%\curl_headers.txt"

REM Method 2: VBScript with full HTTP support
echo     Method 2: Using VBScript (handles JSP better)...
(
echo On Error Resume Next
echo url = "%TARGET_URL%"
echo outputFile = "%CD%\%OUTPUT_DIR%\html\main_page.html"
echo.
echo ' Try WinHttp first ^(better for HTTPS^)
echo Set http = CreateObject^("WinHttp.WinHttpRequest.5.1"^)
echo http.Option^(0^) = 13056
echo http.SetTimeouts 30000, 30000, 30000, 30000
echo http.Open "GET", url, False
echo http.setRequestHeader "User-Agent", "Mozilla/5.0 ^(Windows NT 10.0; Win64; x64^) AppleWebKit/537.36"
echo http.setRequestHeader "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
echo http.setRequestHeader "Accept-Language", "en-US,en;q=0.5"
echo http.setRequestHeader "Cache-Control", "no-cache"
echo http.setRequestHeader "Pragma", "no-cache"
echo http.Send
echo.
echo If http.Status = 200 Then
echo     content = http.ResponseText
echo     Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo     Set f = fso.CreateTextFile^(outputFile, True^)
echo     f.Write content
echo     f.Close
echo     WScript.Echo "Success - Downloaded " ^& Len^(content^) ^& " characters"
echo     WScript.Echo "Status: " ^& http.Status
echo     WScript.Echo "Content-Type: " ^& http.getResponseHeader^("Content-Type"^)
echo Else
echo     WScript.Echo "HTTP Status: " ^& http.Status
echo     Set http2 = CreateObject^("MSXML2.ServerXMLHTTP.6.0"^)
echo     http2.setOption 2, 13056
echo     http2.Open "GET", url, False
echo     http2.setRequestHeader "User-Agent", "Mozilla/5.0"
echo     http2.Send
echo     If http2.Status = 200 Then
echo         Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo         Set f = fso.CreateTextFile^(outputFile, True^)
echo         f.Write http2.ResponseText
echo         f.Close
echo         WScript.Echo "Fallback Success - " ^& Len^(http2.ResponseText^) ^& " characters"
echo     End If
echo End If
) > "%CD%\%OUTPUT_DIR%\download_jsp.vbs"

cscript //nologo "%CD%\%OUTPUT_DIR%\download_jsp.vbs"

REM Check which method got data
set SIZE1=0
set SIZE2=0
if exist "%OUTPUT_DIR%\html\main_page.html" for %%A in ("%OUTPUT_DIR%\html\main_page.html") do set SIZE1=%%~zA
if exist "%OUTPUT_DIR%\html\main_page_curl.html" for %%A in ("%OUTPUT_DIR%\html\main_page_curl.html") do set SIZE2=%%~zA

if not defined SIZE1 set SIZE1=0
if not defined SIZE2 set SIZE2=0

if %SIZE1% GTR 1000 (
    echo     [SUCCESS] VBScript download: %SIZE1% bytes
) else if %SIZE2% GTR 1000 (
    echo     [SUCCESS] curl download: %SIZE2% bytes  
    copy "%OUTPUT_DIR%\html\main_page_curl.html" "%OUTPUT_DIR%\html\main_page.html" >nul 2>nul
) else (
    echo     [WARNING] Both methods got limited data - VBS:%SIZE1% bytes, curl:%SIZE2% bytes
    if %SIZE2% GTR %SIZE1% (
        copy "%OUTPUT_DIR%\html\main_page_curl.html" "%OUTPUT_DIR%\html\main_page.html" >nul 2>nul
    )
)
echo.

REM ========================================================
REM STEP 2: Extract and Download All CSS Files
REM ========================================================
echo [STEP 2/10] Extracting and downloading CSS files...
findstr /i /C:"<link" /C:"stylesheet" /C:".css" /C:"href=" "%OUTPUT_DIR%\html\main_page.html" > "%OUTPUT_DIR%\css_links.txt" 2>nul

REM Create VBScript to extract and download CSS properly
(
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo Set htmlFile = fso.OpenTextFile^("%CD%\%OUTPUT_DIR%\html\main_page.html", 1^)
echo html = htmlFile.ReadAll
echo htmlFile.Close
echo.
echo baseUrl = "%BASE_URL%"
echo targetUrl = "%TARGET_URL%"
echo.
echo ' Extract CSS URLs using regex
echo Set objRegEx = CreateObject^("VBScript.RegExp"^)
echo objRegEx.Global = True
echo objRegEx.IgnoreCase = True
echo objRegEx.Pattern = "href=[""']([^""']+\.css[^""']*)[""']"
echo.
echo Set objMatches = objRegEx.Execute^(html^)
echo cssCount = 0
echo.
echo For Each objMatch in objMatches
echo     cssUrl = objMatch.SubMatches^(0^)
echo     cssCount = cssCount + 1
echo     
echo     ' Build full URL
echo     If Left^(cssUrl, 4^) = "http" Then
echo         fullUrl = cssUrl
echo     ElseIf Left^(cssUrl, 1^) = "/" Then
echo         fullUrl = baseUrl ^& cssUrl
echo     Else
echo         fullUrl = baseUrl ^& "/" ^& cssUrl
echo     End If
echo     
echo     WScript.Echo "CSS " ^& cssCount ^& ": " ^& cssUrl
echo     
REM ========================================================
REM STEP 3: Extract and Download All JavaScript Files
REM ========================================================
echo [STEP 3/10] Extracting and downloading JavaScript files...

REM Create VBScript to extract and download JS properly
(
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo Set htmlFile = fso.OpenTextFile^("%CD%\%OUTPUT_DIR%\html\main_page.html", 1^)
echo html = htmlFile.ReadAll
echo htmlFile.Close
echo.
echo baseUrl = "%BASE_URL%"
echo.
echo ' Extract JavaScript URLs using regex
echo Set objRegEx = CreateObject^("VBScript.RegExp"^)
echo objRegEx.Global = True
echo objRegEx.IgnoreCase = True
echo objRegEx.Pattern = "src=[""']([^""']+\.js[^""']*)[""']"
REM ========================================================
REM STEP 4: Extract Inline JavaScript Content
REM ========================================================
echo [STEP 4/10] Extracting inline JavaScript...
(
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo Set htmlFile = fso.OpenTextFile^("%CD%\%OUTPUT_DIR%\html\main_page.html", 1^)
echo html = htmlFile.ReadAll
echo htmlFile.Close
echo.
echo Set outFile = fso.CreateTextFile^("%CD%\%OUTPUT_DIR%\js\inline_javascript.js", True^)
echo outFile.WriteLine "// Inline JavaScript extracted from: %TARGET_URL%"
echo outFile.WriteLine "// Extraction time: " ^& Now
echo outFile.WriteLine ""
echo.
echo ' Extract all script blocks
echo Set objRegEx = CreateObject^("VBScript.RegExp"^)
echo objRegEx.Global = True
echo objRegEx.IgnoreCase = True
echo objRegEx.Pattern = "^<script[^^>]*^>([^<]*(?:(?!^</script^>)^<[^<]*)*?)^</script^>"
echo.
echo Set objMatches = objRegEx.Execute^(html^)
echo scriptCount = 0
echo.
echo For Each objMatch in objMatches
echo     If InStr^(objMatch.Value, "src="^) = 0 Then
echo         scriptContent = objMatch.SubMatches^(0^)
echo         If Len^(Trim^(scriptContent^)^) ^> 0 Then
echo             scriptCount = scriptCount + 1
echo             outFile.WriteLine "// ===== Inline Script Block " ^& scriptCount ^& " ====="
echo             outFile.WriteLine scriptContent
echo             outFile.WriteLine ""
echo         End If
echo     End If
echo Next
echo.
echo outFile.Close
echo WScript.Echo "Extracted " ^& scriptCount ^& " inline script blocks"
) > "%CD%\%OUTPUT_DIR%\extract_inline_js.vbs"

cscript //nologo "%CD%\%OUTPUT_DIR%\extract_inline_js.vbs"
echo.    ElseIf Left^(jsUrl, 1^) = "/" Then
echo         fullUrl = baseUrl ^& jsUrl
echo     Else
echo         ' Try to build relative path
echo         fullUrl = baseUrl ^& "/" ^& jsUrl
echo     End If
echo     
echo     WScript.Echo "JS " ^& jsCount ^& ": " ^& jsUrl
echo     
echo     ' Download JS
echo     On Error Resume Next
echo     Set http = CreateObject^("WinHttp.WinHttpRequest.5.1"^)
echo     http.Option^(0^) = 13056
echo     http.Open "GET", fullUrl, False
echo     http.Send
echo     
echo     If http.Status = 200 Then
echo         ' Clean filename
echo         fileName = Replace^(jsUrl, "/", "_"^)
echo         fileName = Replace^(fileName, "\", "_"^)
echo         fileName = Replace^(fileName, ":", "_"^)
echo         If Len^(fileName^) ^> 50 Then fileName = "script_" ^& jsCount ^& ".js"
echo         
echo         Set outFile = fso.CreateTextFile^("%CD%\%OUTPUT_DIR%\js\" ^& fileName, True^)
echo         outFile.Write http.ResponseText
echo         outFile.Close
echo         WScript.Echo "  Downloaded: " ^& Len^(http.ResponseText^) ^& " bytes"
echo     End If
echo Next
echo.
echo WScript.Echo "Total JS files found: " ^& jsCount
) > "%CD%\%OUTPUT_DIR%\extract_js.vbs"

cscript //nologo "%CD%\%OUTPUT_DIR%\extract_js.vbs"
echo.
cscript //nologo "%CD%\%OUTPUT_DIR%\extract_css.vbs"
echo.

REM ========================================================
REM STEP 3: Extract and Download All JavaScript Files
REM ========================================================
echo [STEP 3/10] Extracting and downloading JavaScript files...
findstr /i /C:"<script" /C:"src=" "%OUTPUT_DIR%\html\main_page.html" > "%OUTPUT_DIR%\js_links.txt" 2>nul

set JS_COUNT=0
for /f "tokens=*" %%a in ('type "%OUTPUT_DIR%\js_links.txt" 2^>nul') do (
    set "line=%%a"
    echo !line! | findstr /i "src=" >nul
    if !ERRORLEVEL! EQU 0 (
        set /a JS_COUNT+=1
        echo     Processing JS !JS_COUNT!
        REM Will be downloaded in next step with better parser
    )
)
echo     [INFO] Found %JS_COUNT% JavaScript references
echo.

REM ========================================================
REM STEP 4: Extract Inline JavaScript Content
REM ========================================================
echo [STEP 4/10] Extracting inline JavaScript...
(
    echo // Inline JavaScript extracted from: %TARGET_URL%
    echo // Extraction time: %date% %time%
    echo.
    findstr /i /C:"var " /C:"function " /C:"const " /C:"let " "%OUTPUT_DIR%\html\main_page.html" 2>nul
) > "%OUTPUT_DIR%\js\inline_javascript.js"
echo     [SUCCESS] Inline JavaScript extracted
echo.

REM ========================================================
REM STEP 5: Extract All Image References
REM ========================================================
echo [STEP 5/10] Extracting image references...
findstr /i /C:"<img" /C:"src=" /C:".jpg" /C:".png" /C:".gif" /C:".svg" /C:".ico" "%OUTPUT_DIR%\html\main_page.html" > "%OUTPUT_DIR%\image_links.txt" 2>nul
echo     [SUCCESS] Image references extracted
echo.

REM ========================================================
REM STEP 6: Extract All Form Elements
REM ========================================================
echo [STEP 6/10] Extracting form elements...
(
    echo ========================================================
    echo FORM ELEMENTS ANALYSIS
    echo ========================================================
    echo Source: %TARGET_URL%
    echo Extracted: %date% %time%
    echo ========================================================
    echo.
    echo --- FORMS ---
    findstr /i /C:"<form" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- INPUT FIELDS ---
    findstr /i /C:"<input" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- TEXTAREA FIELDS ---
    findstr /i /C:"<textarea" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- SELECT FIELDS ---
    findstr /i /C:"<select" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- BUTTONS ---
    findstr /i /C:"<button" /C:"type=\"submit\"" /C:"type=\"button\"" "%OUTPUT_DIR%\html\main_page.html" 2>nul
) > "%OUTPUT_DIR%\form_elements.txt"
echo     [SUCCESS] Form elements extracted
echo.

REM ========================================================
REM STEP 7: Extract Meta Tags and Page Information
REM ========================================================
echo [STEP 7/10] Extracting meta tags and page info...
(
    echo ========================================================
    echo PAGE METADATA ANALYSIS
    echo ========================================================
    echo Source: %TARGET_URL%
    echo Extracted: %date% %time%
    echo ========================================================
    echo.
    echo --- TITLE ---
    findstr /i /C:"<title>" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- META TAGS ---
    findstr /i /C:"<meta" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- CHARSET/ENCODING ---
    findstr /i /C:"charset" /C:"encoding" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- X-UA-Compatible ---
    findstr /i /C:"X-UA-Compatible" "%OUTPUT_DIR%\html\main_page.html" 2>nul
) > "%OUTPUT_DIR%\page_metadata.txt"
echo     [SUCCESS] Metadata extracted
echo.

REM ========================================================
REM STEP 8: Extract JavaScript Variables and Configuration
REM ========================================================
echo [STEP 8/10] Extracting JavaScript variables and config...
(
    echo ========================================================
    echo JAVASCRIPT VARIABLES ANALYSIS
    echo ========================================================
    echo Source: %TARGET_URL%
    echo Extracted: %date% %time%
    echo ========================================================
    echo.
    echo --- GLOBAL VARIABLES ---
    findstr /b /i /C:"var " "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- CONST DECLARATIONS ---
    findstr /b /i /C:"const " "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- LET DECLARATIONS ---
    findstr /b /i /C:"let " "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- FUNCTION DECLARATIONS ---
    findstr /b /i /C:"function " "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- CONFIGURATION OBJECTS ---
    findstr /i /C:"Config" /C:"config" /C:"settings" "%OUTPUT_DIR%\html\main_page.html" 2>nul
) > "%OUTPUT_DIR%\js_variables.txt"
echo     [SUCCESS] JavaScript variables extracted
echo.

REM ========================================================
REM STEP 9: Extract Links and Navigation
REM ========================================================
echo [STEP 9/10] Extracting links and navigation...
(
    echo ========================================================
    echo LINKS AND NAVIGATION ANALYSIS
    echo ========================================================
    echo Source: %TARGET_URL%
    echo Extracted: %date% %time%
    echo ========================================================
    echo.
    echo --- HYPERLINKS ---
    findstr /i /C:"<a " /C:"href=" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- IFRAMES ---
    findstr /i /C:"<iframe" "%OUTPUT_DIR%\html\main_page.html" 2>nul
    echo.
    echo --- FRAMES ---
    findstr /i /C:"<frame" "%OUTPUT_DIR%\html\main_page.html" 2>nul
) > "%OUTPUT_DIR%\links_navigation.txt"
echo     [SUCCESS] Links and navigation extracted
echo.

REM ========================================================
REM STEP 10: Create VBScript for Advanced HTML Parsing
REM ========================================================
echo [STEP 10/10] Running advanced HTML parser...

REM Create advanced VBScript parser
(
echo Set objFSO = CreateObject^("Scripting.FileSystemObject"^)
echo Set objFile = objFSO.OpenTextFile^("%CD%\%OUTPUT_DIR%\html\main_page.html", 1^)
echo content = objFile.ReadAll
echo objFile.Close
echo.
echo Set outFile = objFSO.CreateTextFile^("%CD%\%OUTPUT_DIR%\advanced_analysis.txt", True^)
echo.
echo outFile.WriteLine "========================================================"
echo outFile.WriteLine "ADVANCED HTML ANALYSIS"
echo outFile.WriteLine "========================================================"
echo outFile.WriteLine "Source: %TARGET_URL%"
echo outFile.WriteLine "Extracted: " ^& Now
echo outFile.WriteLine "File Size: " ^& Len^(content^) ^& " characters"
echo outFile.WriteLine "========================================================"
echo outFile.WriteLine ""
echo.
echo ' Count different elements
echo scriptTags = 0
echo linkTags = 0
echo formTags = 0
echo inputTags = 0
echo imgTags = 0
echo.
echo pos = 1
echo Do While pos ^< Len^(content^)
echo     If Mid^(content, pos, 7^) = "^<script" Then scriptTags = scriptTags + 1
echo     If Mid^(content, pos, 5^) = "^<link" Then linkTags = linkTags + 1
echo     If Mid^(content, pos, 5^) = "^<form" Then formTags = formTags + 1
echo     If Mid^(content, pos, 6^) = "^<input" Then inputTags = inputTags + 1
echo     If Mid^(content, pos, 4^) = "^<img" Then imgTags = imgTags + 1
echo     pos = pos + 1
echo Loop
echo.
echo outFile.WriteLine "--- ELEMENT COUNTS ---"
echo outFile.WriteLine "Script tags: " ^& scriptTags
echo outFile.WriteLine "Link tags: " ^& linkTags
echo outFile.WriteLine "Form tags: " ^& formTags
echo outFile.WriteLine "Input tags: " ^& inputTags
echo outFile.WriteLine "Image tags: " ^& imgTags
echo outFile.WriteLine ""
echo.
echo ' Extract all URLs
echo outFile.WriteLine "--- ALL URLS FOUND ---"
echo Set objRegEx = CreateObject^("VBScript.RegExp"^)
echo objRegEx.Global = True
echo objRegEx.IgnoreCase = True
echo objRegEx.Pattern = "https?://[^\s""'<>]+"
echo Set objMatches = objRegEx.Execute^(content^)
echo For Each objMatch in objMatches
echo     outFile.WriteLine objMatch.Value
echo Next
echo outFile.WriteLine ""
echo.
echo outFile.WriteLine "========================================================"
echo outFile.WriteLine "END OF ANALYSIS"
echo outFile.WriteLine "========================================================"
echo outFile.Close
echo.
echo WScript.Echo "Advanced analysis complete"
) > "%OUTPUT_DIR%\advanced_parser.vbs"

cscript //nologo "%OUTPUT_DIR%\advanced_parser.vbs"
echo.

REM ========================================================
REM Generate Master Report
REM ========================================================
echo.
echo ========================================================
echo GENERATING MASTER REPORT
echo ========================================================
echo.

(
    echo ========================================================
    echo UNIVERSAL WEB SCRAPER - MASTER REPORT
    echo ========================================================
    echo Target URL: %TARGET_URL%
    echo Base URL: %BASE_URL%
    echo Scrape Time: %date% %time%
    echo Output Directory: %OUTPUT_DIR%
    echo ========================================================
    echo.
    echo === FILE SUMMARY ===
    dir /b "%OUTPUT_DIR%\html" 2>nul
    echo.
    echo CSS Files:
    dir /b "%OUTPUT_DIR%\css" 2>nul
    echo.
    echo JavaScript Files:
    dir /b "%OUTPUT_DIR%\js" 2>nul
    echo.
    echo === MAIN PAGE SIZE ===
    for %%A in ("%OUTPUT_DIR%\html\main_page.html") do echo %%~zA bytes
    echo.
    echo === EXTRACTED RESOURCES ===
    echo - HTML page with full content
    echo - CSS stylesheets
    echo - JavaScript files
    echo - Inline scripts
    echo - Form elements
    echo - Meta tags
    echo - Links and navigation
    echo - Images references
    echo - Configuration variables
    echo.
    echo === DETAILED ANALYSIS FILES ===
    echo [1] main_page.html - Main HTML content
    echo [2] form_elements.txt - All form fields and inputs
    echo [3] page_metadata.txt - Meta tags and page info
    echo [4] js_variables.txt - JavaScript variables and config
    echo [5] links_navigation.txt - All links, iframes, frames
    echo [6] advanced_analysis.txt - Element counts and URLs
    echo [7] curl_headers.txt - HTTP headers from request
    echo [8] css_links.txt - CSS references found
    echo [9] js_links.txt - JavaScript references found
    echo [10] image_links.txt - Image references found
    echo.
    echo === OPEN FILES ===
    echo To view all files, run: explorer "%OUTPUT_DIR%"
    echo To view HTML: "%OUTPUT_DIR%\html\main_page.html"
    echo To view report: "%OUTPUT_DIR%\MASTER_REPORT.txt"
    echo.
    echo ========================================================
    echo SCRAPING COMPLETE - ALL DATA SAVED
    echo ========================================================
) > "%OUTPUT_DIR%\MASTER_REPORT.txt"

type "%OUTPUT_DIR%\MASTER_REPORT.txt"

REM ========================================================
REM Ask to open output folder
REM ========================================================
echo.
set /p OPEN_FOLDER="Open output folder in Explorer? (Y/N): "
if /i "%OPEN_FOLDER%"=="Y" (
    explorer "%OUTPUT_DIR%"
)

echo.
set /p OPEN_HTML="Open scraped HTML in browser? (Y/N): "
if /i "%OPEN_HTML%"=="Y" (
    start "" "%OUTPUT_DIR%\html\main_page.html"
)

echo.
echo ========================================================
echo All files saved to: %CD%\%OUTPUT_DIR%
echo ========================================================
echo.

pause
