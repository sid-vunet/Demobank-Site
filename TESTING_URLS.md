# Testing URLs - Finacle JSP Application

## All Working URLs

After starting the server with `go run main.go`, you can access the application using any of these URLs:

### 1. Root URL (Automatic Redirect)
```
http://localhost:8080/
```
**What happens:** Automatically redirects to `/fininfra/ui/SSOLogin.jsp`

### 2. Short Form URL
```
http://localhost:8080/SSOLogin.jsp
```
**What happens:** Directly serves the SSOLogin.jsp (login page)

### 3. Full Finacle Path (Recommended)
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp
```
**What happens:** Serves the SSOLogin.jsp in authentic Finacle path structure

### 4. With Parameters
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=login
http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=home
http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=home&function=auditTrail
http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=home&function=editEntity
```

### 5. Finacle Compatibility URLs
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp?CALLTYPE=GET_LOGIN_PAGE
http://localhost:8080/fininfra/ui/SSOLogin.jsp?CALLTYPE=GET_BANK_HOME_PAGE
```

### 6. Action URLs (POST)
```
POST http://localhost:8080/fininfra/ui/SSOLogin.jsp?action=login
POST http://localhost:8080/fininfra/ui/SSOLogin.jsp?action=logout
```

## Complete Testing Flow

### Step 1: Start Server
```batch
cd c:\Users\Sidharth\Documents\Uco-Finnacle-Site
go run main.go
```

You should see:
```
==============================================
UCO Bank CBS Browser Application Simulator
==============================================
Server starting on http://localhost:8080
Press Ctrl+C to stop the server
==============================================
```

### Step 2: Open Any URL

**Option A: Simple**
```
http://localhost:8080/
```

**Option B: Short Form**
```
http://localhost:8080/SSOLogin.jsp
```

**Option C: Full Path**
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp
```

All three will show the login page!

### Step 3: Login
1. Enter any username (e.g., `admin`)
2. Enter any password (e.g., `password`)
3. Click **Login**

### Step 4: See Modular Home Page
After login, you'll see:

```
┌─────────────────────────────────────────────────┐
│ Section 1: Gray Header                          │
│ User: admin | Solution: FININFRA | Calendar...  │
├─────────────────────────────────────────────────┤
│ Section 2: Blue Finacle Banner                  │
│ [Finacle®] [Icons...] Menu Shortcut: [___]     │
├────────────┬────────────────────────────────────┤
│ Section 3: │ Section 4: Content Area            │
│ Left Menu  │                                    │
│            │ Welcome Dashboard                  │
│ Functions  │ [Quick Access Tiles]               │
│ ├ CIF      │                                    │
│ │ Retail ▼ │                                    │
│ │ ├ Audit  │                                    │
│ │ │ Trail   │                                    │
│ │ ├ Edit   │                                    │
│ │ │ Entity  │                                    │
│ └─...      │                                    │
└────────────┴────────────────────────────────────┘
```

### Step 5: Test Navigation
1. Click **CIF Retail** → Menu expands
2. Click **Audit Trail** → Content area shows Audit Trail form
3. Click **Edit Entity** → Content area shows Edit Entity form

URL will change to:
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=home&function=auditTrail
```

### Step 6: Test Logout
Click the logout button or access:
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp?action=logout
```

## What The Server Does

### 1. JSP Processing
```
Browser → http://localhost:8080/fininfra/ui/SSOLogin.jsp
         ↓
    Go Server (main.go)
         ↓
    Reads: jsp/fininfra/ui/SSOLogin.jsp
         ↓
    Processes JSP tags:
    - <% scriptlets %>
    - <%= expressions %>
    - ${JSTL variables}
    - <jsp:include page="..." />
         ↓
    Processes Includes:
    - includes/header.jsp
    - includes/banner.jsp
    - includes/leftmenu.jsp
    - includes/content.jsp
         ↓
    Returns Complete HTML
         ↓
    Browser displays page
```

### 2. Session Management
```
Login Form Submit
    ↓
POST /fininfra/ui/SSOLogin.jsp?action=login
    ↓
JSP Scriptlet Executes:
    if ("login".equals(action)) {
        session.setAttribute("username", username);
        session.setAttribute("authenticated", "true");
    }
    ↓
Go Server Saves Session
    ↓
Sets Cookie: uco-session
    ↓
Redirects to ?view=home
    ↓
All Components Read Session
```

### 3. Include Processing
```
SSOLogin.jsp contains:
    <jsp:include page="includes/header.jsp" />
         ↓
Go Server Detects Include Tag
         ↓
Reads: jsp/fininfra/ui/includes/header.jsp
         ↓
Processes that JSP:
    - Evaluates <%= session.getAttribute("username") %>
    - Replaces ${...} variables
    - Processes any nested includes
         ↓
Injects Processed Content into Parent
         ↓
Continues Processing Rest of SSOLogin.jsp
```

## Server Output

When you access pages, server console shows:
```
2025/12/10 12:00:00 Processing JSP: jsp/fininfra/ui/SSOLogin.jsp
2025/12/10 12:00:00 Including: jsp/fininfra/ui/includes/header.jsp
2025/12/10 12:00:00 Including: jsp/fininfra/ui/includes/banner.jsp
2025/12/10 12:00:00 Including: jsp/fininfra/ui/includes/leftmenu.jsp
2025/12/10 12:00:00 Including: jsp/fininfra/ui/includes/content.jsp
```

## Static Assets

The server also serves static files:
```
http://localhost:8080/ui/login.css                    → static/ui/login.css
http://localhost:8080/ui/images/logo.gif             → static/ui/images/logo.gif
http://localhost:8080/javascripts/ssodomain.js       → static/javascripts/ssodomain.js
http://localhost:8080/ui/javascripts/login.js        → static/ui/javascripts/login.js
```

## Troubleshooting

### Issue: "JSP file not found"
**Check:**
1. Is the file at `jsp/fininfra/ui/SSOLogin.jsp`?
2. Is the server running from the project root directory?

**Fix:**
```batch
cd c:\Users\Sidharth\Documents\Uco-Finnacle-Site
dir jsp\fininfra\ui\SSOLogin.jsp
go run main.go
```

### Issue: "404 Not Found"
**Check:**
1. Did you type the URL correctly?
2. Is `.jsp` extension included?

**Try:**
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp
```
(not `/fininfra/ui/SSOLogin`)

### Issue: "Components not loading"
**Check:**
1. Are include files present?
   - `jsp/fininfra/ui/includes/header.jsp`
   - `jsp/fininfra/ui/includes/banner.jsp`
   - `jsp/fininfra/ui/includes/leftmenu.jsp`
   - `jsp/fininfra/ui/includes/content.jsp`

**Server will show:**
```
Warning: Could not read JSP include: includes/header.jsp
```

### Issue: "Session not persisting"
**Check:**
1. Are cookies enabled in browser?
2. Not using incognito mode?
3. Server console shows session save?

**Enable cookies:**
- Chrome: Settings → Privacy → Cookies → Allow all
- Firefox: Settings → Privacy → Cookies → Accept

### Issue: "Styles not loading"
**Check:**
1. CSS files exist in `static/ui/login.css`?
2. Browser console (F12) shows 404 for CSS?

**Fix:**
```batch
dir static\ui\login.css
```

## Browser Developer Tools

Press **F12** to open developer tools:

### Console Tab
Shows JavaScript errors and logs

### Network Tab
Shows all HTTP requests:
- `SSOLogin.jsp` - Main page
- `login.css` - Stylesheet
- `ssodomain.js` - JavaScript
- `header.jsp`, `banner.jsp`, etc. - Should NOT appear (processed server-side)

### Application Tab
Shows cookies:
- `uco-session` - Session cookie with encoded data

## Summary

**To test the complete application:**

1. **Start server:** `go run main.go`
2. **Open browser:** `http://localhost:8080/`
3. **Login:** Any username/password
4. **See:** Complete modular Finacle home page
5. **Test:** Click menu items to load different functions

**All URLs work:**
- `/` (redirects)
- `/SSOLogin.jsp` (short form)
- `/fininfra/ui/SSOLogin.jsp` (full path - recommended)

**Components load automatically** from includes/ directory!

🎯 **Ready to use!**
