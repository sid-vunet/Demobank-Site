# Finacle JSP Local Environment Setup

## Overview
This setup creates a **local Finacle-like JSP environment** that processes JSP files exactly like the real UCO Bank Finacle system.

## How It Works

### 1. **Scraping Phase** (Get Real Content)
```batch
universal_scraper.bat
```
- Enter URL: `https://fin10uat.ucobanknet.in:20000/fininfra/ui/SSOLogin.jsp`
- Downloads the actual rendered HTML and all resources
- Saves to timestamped folder

### 2. **Conversion Phase** (HTML → JSP)
```batch
convert_to_jsp.bat
```
- Converts scraped HTML to proper JSP format
- Adds JSP tags: `<%@ %>`, `<%= %>`
- Creates Fininfra directory structure
- Copies CSS, JS, images to static folders

### 3. **Execution Phase** (Run JSP Locally)
```batch
go run main.go
```
- Server processes JSP files on-the-fly
- Evaluates JSP expressions like `<%=request.getContextPath()%>`
- Handles session variables
- Serves at: `http://localhost:8080/fininfra/ui/SSOLogin.jsp`

## Complete Workflow

### Step 1: Scrape the Live Site
```batch
universal_scraper.bat
```
**Input:**
- URL: `https://fin10uat.ucobanknet.in:20000/fininfra/ui/SSOLogin.jsp`
- Folder name: `uco_scrape`

**Output:**
```
uco_scrape_YYYYMMDD_HHMMSS/
├── html/main_page.html (actual JSP-rendered content)
├── css/*.css
├── js/*.js
└── analysis files
```

### Step 2: Convert to JSP Structure
```batch
convert_to_jsp.bat
```
**Input:**
- Scraped folder name: `uco_scrape_YYYYMMDD_HHMMSS`

**Output:**
```
jsp/
└── fininfra/
    └── ui/
        └── SSOLogin.jsp (proper JSP with tags)

static/
└── fininfra/
    ├── ui/*.css
    ├── javascripts/*.js
    └── images/*.gif
```

### Step 3: Run Local JSP Server
```batch
go run main.go
```

**Access:**
- JSP Page: `http://localhost:8080/fininfra/ui/SSOLogin.jsp`
- Direct Login: `http://localhost:8080/login`
- Home: `http://localhost:8080/home`

## JSP Processing Features

The Go server processes JSP tags exactly like a Java servlet container:

### Supported JSP Tags

#### 1. **Page Directives**
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
```
- Automatically added during conversion
- Sets character encoding

#### 2. **JSP Expressions** (Evaluated at runtime)
```jsp
<%=request.getContextPath()%>
```
Replaced with: `` (empty for root context)

```jsp
<%=session.getAttribute("username")%>
```
Replaced with actual session value

#### 3. **JSTL Variables** (EL expressions)
```jsp
${param.LCLANG}
```
Replaced with URL parameter value

```jsp
${session.username}
```
Replaced with session attribute

#### 4. **Context-Relative Paths**
```jsp
<link href="<%=request.getContextPath()%>/ui/login.css">
<script src="<%=request.getContextPath()%>/javascripts/sso.js">
<form action="<%=request.getContextPath()%>/authenticate">
```
All paths are dynamically resolved

## Directory Structure (After Conversion)

```
Uco-Finnacle-Site/
├── jsp/                          # JSP pages (server-side)
│   └── fininfra/
│       └── ui/
│           └── SSOLogin.jsp      # Main login JSP
│
├── static/                       # Static resources (client-side)
│   ├── ui/                       # Original UI assets
│   │   ├── login.css
│   │   └── javascripts/*.js
│   └── fininfra/                 # Finacle-specific assets
│       ├── ui/
│       │   └── *.css
│       ├── javascripts/
│       │   └── *.js
│       └── images/
│           └── *.gif
│
├── templates/                    # Static HTML templates
│   ├── index.html
│   └── login.html
│
├── main.go                       # Go server with JSP processing
├── universal_scraper.bat         # Step 1: Scrape content
├── convert_to_jsp.bat            # Step 2: Convert to JSP
└── README_JSP.md                 # This file
```

## JSP vs Static HTML

| Feature | Static HTML | JSP (This Setup) |
|---------|-------------|------------------|
| Server-side processing | ❌ No | ✅ Yes |
| Dynamic content | ❌ No | ✅ Yes |
| Session variables | ❌ No | ✅ Yes |
| Context paths | ❌ Hardcoded | ✅ Dynamic |
| Form processing | ❌ Limited | ✅ Full |
| Finacle-like behavior | ❌ No | ✅ Yes |

## How JSP Processing Works

### Example: Login Form

**Original JSP (SSOLogin.jsp):**
```jsp
<form action="<%=request.getContextPath()%>/authenticate" method="POST">
    <input type="text" name="txtLoginId" value="${session.lastUser}" />
</form>
```

**What Go Server Does:**
1. Reads `jsp/fininfra/ui/SSOLogin.jsp`
2. Finds `<%=request.getContextPath()%>` → replaces with ``
3. Finds `${session.lastUser}` → looks up session, replaces with value
4. Sends final HTML to browser:
```html
<form action="/authenticate" method="POST">
    <input type="text" name="txtLoginId" value="john.doe" />
</form>
```

### Example: Session Variables

**In JSP:**
```jsp
<p>Welcome, ${session.username}!</p>
<p>Last login: <%=session.getAttribute("loginTime")%></p>
```

**Go Server Processing:**
```go
session, _ := store.Get(r, "uco-session")
username := session.Values["username"]  // "john.doe"
loginTime := session.Values["loginTime"]  // "2025-12-10 18:30:00"
```

**Final HTML:**
```html
<p>Welcome, john.doe!</p>
<p>Last login: 2025-12-10 18:30:00</p>
```

## Adding More JSP Pages

### 1. Scrape Additional Pages
```batch
universal_scraper.bat
```
URL: `https://fin10uat.ucobanknet.in:20000/fininfra/ui/HomePage.jsp`

### 2. Convert and Save
```batch
convert_to_jsp.bat
```

### 3. Manual JSP Creation
Create `jsp/fininfra/ui/YourPage.jsp`:
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Your Page</title>
    <link href="<%=request.getContextPath()%>/ui/login.css" rel="stylesheet">
</head>
<body>
    <h1>Welcome ${session.username}</h1>
    <p>User ID: <%=session.getAttribute("userId")%></p>
</body>
</html>
```

### 4. Access
`http://localhost:8080/fininfra/ui/YourPage.jsp`

## Troubleshooting

### Issue: JSP page shows raw tags
**Problem:** `<%=request.getContextPath()%>` visible in browser

**Solution:** Go server not processing JSP. Check:
1. File is in `jsp/` directory
2. URL path matches JSP route pattern
3. Server logs for errors

### Issue: CSS/JS not loading
**Problem:** 404 errors for static resources

**Solution:**
1. Check files are in `static/fininfra/ui/` or `static/fininfra/javascripts/`
2. Verify paths use `<%=request.getContextPath()%>/`
3. Check browser console for actual paths

### Issue: Session variables empty
**Problem:** `${session.username}` is blank

**Solution:**
1. Login first to create session
2. Check session cookie exists
3. Verify Go server session handling

## Testing the Setup

### 1. Test JSP Processing
Visit: `http://localhost:8080/fininfra/ui/SSOLogin.jsp`

**Expected:**
- ✅ Page loads without JSP tags visible
- ✅ CSS and JS files load correctly
- ✅ Form action points to `/authenticate`
- ✅ No `<%=...%>` or `${...}` in source code

### 2. Test Session Handling
1. Login with any credentials
2. Visit: `http://localhost:8080/home`
3. See username and login time

**Expected:**
- ✅ Session created
- ✅ Username displayed
- ✅ Session persists across requests

### 3. Test Static Resources
Check browser Network tab:

**Expected:**
- ✅ 200 OK for `/fininfra/ui/*.css`
- ✅ 200 OK for `/fininfra/javascripts/*.js`
- ✅ `X-UA-Compatible: IE=10` header present

## Advanced: Mimicking Finacle Behavior

### Custom JSP Variables
Edit `main.go` → `processJSP()` function:

```go
replacements := map[string]string{
    "${finacleVersion}": "10.2.25",
    "${bankCode}": "UCO",
    "${environment}": "LOCAL",
}
```

### Session Timeout
Edit `main.go`:
```go
store.Options = &sessions.Options{
    MaxAge:   1800,  // 30 minutes
    HttpOnly: true,
    Secure:   false, // Set true for HTTPS
}
```

### Add More JSP Tags
Extend `processJSP()` to handle:
- `<jsp:include>`
- `<c:forEach>`
- `<c:if>`
- Custom taglibs

## Comparison with Real Finacle

| Feature | Real Finacle | This Setup |
|---------|--------------|------------|
| Technology | Java/JSP/Tomcat | Go/Template Processing |
| JSP Support | Full J2EE | Basic tags + JSTL |
| Database | Oracle/DB2 | None (simulated) |
| Session Management | J2EE Sessions | Cookie-based |
| Authentication | LDAP/SSO | Simulated |
| Performance | Java VM | Native Go |
| Deployment | WAR file | Single binary |

## Benefits of This Approach

✅ **No Java/Tomcat needed** - Pure Go server
✅ **Fast startup** - Milliseconds vs minutes
✅ **Easy debugging** - Simple Go code
✅ **Portable** - Single executable
✅ **Development friendly** - Edit JSP and refresh
✅ **Realistic** - Mimics actual Finacle behavior
✅ **Scraped content** - Uses real UCO Bank pages

## Next Steps

1. **Scrape more pages** - Get entire Finacle workflow
2. **Add database** - Connect to SQLite/PostgreSQL
3. **Implement auth** - Real LDAP integration
4. **Add logging** - Track user actions
5. **Deploy** - Build binary and deploy

## Summary

This setup provides a **complete Finacle-like JSP environment** that:
- Scrapes real UCO Bank pages
- Converts them to proper JSP format
- Processes JSP tags server-side
- Serves with full IE compatibility
- Handles sessions and forms
- Works exactly like the real Finacle system

**Perfect for development, testing, and learning!** 🚀
