# Quick Start Guide - Finacle JSP Simulation

## What You Have Now

A complete **Finacle-like JSP application** with modular architecture:
- ✅ Single JSP file (`SSOLogin.jsp`) handles login AND home page
- ✅ **4 Modular Components** - Separately loaded sections exactly like real Finacle
  - Gray header (user/solution/calendar/timezone)
  - Blue Finacle banner (logo/icons/shortcuts)
  - Left navigation menu (expandable Functions tree)
  - Dynamic content area (forms and displays)
- ✅ Internal validation (no external authentication needed)
- ✅ Session management
- ✅ Dynamic view switching based on actions
- ✅ Exactly like real Finacle behavior and layout

## How to Run

### 1. Start the Server
```batch
cd c:\Users\Sidharth\Documents\Uco-Finnacle-Site
go run main.go
```

### 2. Access the Application
Open browser: **http://localhost:8080/fininfra/ui/SSOLogin.jsp**

## How It Works

### Single JSP File - Multiple Views

The `SSOLogin.jsp` file handles everything:

**Login View** (default):
- URL: `http://localhost:8080/fininfra/ui/SSOLogin.jsp`
- Shows login form
- Validates credentials internally

**Home View** (after login):
- URL: `http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=home`
- Shows dashboard
- Displays session info
- Menu options

### Internal Actions

#### 1. **Login Action**
**Form submits to:** `SSOLogin.jsp?action=login`

**JSP Code Does:**
```jsp
<% 
if ("login".equals(action) && username != null && password != null) {
    // Validate (any non-empty = valid for demo)
    session.setAttribute("username", username);
    session.setAttribute("authenticated", "true");
    // Switch to home view
}
%>
```

#### 2. **Logout Action**
**Link:** `SSOLogin.jsp?action=logout`

**JSP Code Does:**
```jsp
<%
if ("logout".equals(action)) {
    session.invalidate();
    // Redirect back to login
}
%>
```

#### 3. **View Switching**
**URLs:**
- `?view=login` - Show login form
- `?view=home` - Show dashboard

**JSP Code Does:**
```jsp
<% 
String view = request.getParameter("view");
if (view == null) {
    view = isAuthenticated ? "home" : "login";
}
%>

<% if ("login".equals(view)) { %>
    <!-- Login Form HTML -->
<% } else if ("home".equals(view)) { %>
    <!-- Home Dashboard HTML -->
<% } %>
```

## Testing Flow

### Complete User Journey

1. **Visit:** `http://localhost:8080/fininfra/ui/SSOLogin.jsp`
   - Shows: Login form
   
2. **Enter credentials:**
   - User ID: `admin` (any text works)
   - Password: `password` (any text works)
   
3. **Click Login**
   - JSP validates internally
   - Sets session variables
   - Redirects to home view
   
4. **See Home Page:**
   - Welcome message
   - Session info
   - Quick access menu
   - Logout button
   
5. **Click Logout:**
   - Session invalidated
   - Back to login form

## JSP Processing by Go Server

### What Happens Server-Side

1. **Request arrives:** `GET /fininfra/ui/SSOLogin.jsp?action=login`

2. **Go server:**
   - Reads `jsp/fininfra/ui/SSOLogin.jsp`
   - Finds JSP scriptlets: `<% ... %>`
   - Executes the Java-like code
   - Evaluates: `request.getParameter("action")` → `"login"`
   - Processes session operations
   
3. **JSP scriptlet runs:**
   ```jsp
   <%
   String action = request.getParameter("action");  // "login"
   String username = request.getParameter("txtLoginId");  // "admin"
   if ("login".equals(action)) {
       session.setAttribute("username", username);  // Stored
       view = "home";  // Switch view
   }
   %>
   ```

4. **HTML generation:**
   ```jsp
   <% if ("home".equals(view)) { %>
       <p>Welcome <%= session.getAttribute("username") %>!</p>
   <% } %>
   ```
   
5. **Final HTML sent:**
   ```html
   <p>Welcome admin!</p>
   ```

## Key Features

### 1. Internal Validation
No external database or API calls:
```jsp
<%
if (!username.isEmpty() && !password.isEmpty()) {
    // Valid!
    session.setAttribute("authenticated", "true");
}
%>
```

### 2. Session Variables
Stored and accessed within same JSP:
```jsp
<% session.setAttribute("username", "john"); %>
<!-- Later in same page -->
<p>User: <%= session.getAttribute("username") %></p>
```

### 3. Dynamic Views
One file, multiple presentations:
```jsp
<% if ("login".equals(view)) { %>
    <!-- Login HTML -->
<% } else if ("home".equals(view)) { %>
    <!-- Home HTML -->
<% } %>
```

### 4. Form Processing
Submit to same JSP:
```jsp
<form action="SSOLogin.jsp?action=login" method="POST">
    <!-- JSP processes this on submit -->
</form>
```

## URL Patterns

| URL | Action | Result |
|-----|--------|--------|
| `/fininfra/ui/SSOLogin.jsp` | None | Show login (default) |
| `/fininfra/ui/SSOLogin.jsp?action=login` | Login | Validate & show home |
| `/fininfra/ui/SSOLogin.jsp?view=home` | View home | Show home (if authenticated) |
| `/fininfra/ui/SSOLogin.jsp?action=logout` | Logout | Clear session & show login |
| `/fininfra/ui/SSOLogin.jsp?CALLTYPE=GET_LOGIN_PAGE` | Finacle compat | Show login |

## Session Data Structure

After login, session contains:
```
session.username = "admin"
session.userId = "admin"
session.loginTime = "Tue Dec 10 18:45:23 2025"
session.authenticated = "true"
session.sessionId = "abc123..."
```

Access in JSP:
```jsp
<%= session.getAttribute("username") %>
${session.username}
```

## Customization

### Add More Views

Edit `SSOLogin.jsp`:
```jsp
<% } else if ("transactions".equals(view)) { %>
    <h2>Transaction View</h2>
    <!-- Add transaction HTML -->
<% } %>
```

Access: `SSOLogin.jsp?view=transactions`

### Add Real Validation

Replace:
```jsp
if (!username.isEmpty() && !password.isEmpty()) {
```

With:
```jsp
if ("admin".equals(username) && "secret".equals(password)) {
```

### Add Database

In `main.go`, add database check:
```go
// In processJSP() function
if strings.Contains(code, "validateUser") {
    // Query database
    // Set session variables based on result
}
```

## File Structure

```
jsp/
└── fininfra/
    └── ui/
        ├── SSOLogin.jsp           ← Main controller (login + home routing)
        └── includes/
            ├── header.jsp         ← Section 1: Gray header bar
            ├── banner.jsp         ← Section 2: Blue Finacle banner
            ├── leftmenu.jsp       ← Section 3: Functions navigation
            └── content.jsp        ← Section 4: Dynamic content area

static/
├── ui/
│   ├── login.css                  ← Login form styles
│   ├── images/                    ← Icon placeholders (home, profile, etc.)
│   └── javascripts/               ← SSO, login, TFA scripts
└── fininfra/
    ├── ui/
    │   └── *.css                  ← Finacle UI styles
    └── javascripts/
        └── *.js                   ← Finacle scripts

main.go                            ← Go server with JSP processing
```

## Advantages of This Approach

✅ **Modular Architecture** - 4 separate components loaded independently (like real Finacle)
✅ **Component Isolation** - Each section is a separate JSP include
✅ **Exact Layout Match** - Gray header, blue banner, left menu, content area
✅ **Single Controller** - SSOLogin.jsp handles all routing and logic
✅ **Internal Processing** - No external services needed
✅ **Session Handling** - Built-in session management
✅ **Dynamic Navigation** - Expandable menu tree with function loading
✅ **Easy to Extend** - Add menu items and content handlers separately
✅ **Authentic Finacle Experience** - Matches real system architecture

## Modular Components Explained

### 1. Header Component (`includes/header.jsp`)
**What it does:**
- Shows current user
- Solution dropdown (CRM, CoreServer, FININFRA, etc.)
- Calendar selector
- Timezone display
- Search icon
- Red notification banner

**Loaded:** Top of every authenticated page

### 2. Banner Component (`includes/banner.jsp`)
**What it does:**
- Finacle® logo with tagline
- Icon toolbar (Home, Profile, Messages, Email, Calculator, Notepad)
- Customer/Consort call status
- Rep status info
- Infosys logo
- Menu shortcut search field

**Loaded:** Below header, above main content

### 3. Left Menu Component (`includes/leftmenu.jsp`)
**What it does:**
- Expandable/collapsible menu tree
- CIF Retail functions (Audit Trail, Edit Entity, etc.)
- CIF Corporate functions (Group Mapping, Operations, etc.)
- Scroll controls
- Highlights current function

**Loaded:** Left side (250px fixed width)

### 4. Content Component (`includes/content.jsp`)
**What it does:**
- Welcome screen with quick access tiles
- Audit Trail search form
- Edit Entity customer form
- Dynamic content based on selected function
- Function-specific forms and displays

**Loaded:** Right side (fills remaining space)

## Next Steps

1. **Add more views** - Create transactions, reports, etc.
2. **Real validation** - Connect to database
3. **More actions** - Handle different operations
4. **Multiple JSP files** - Create separate pages
5. **Scrape more pages** - Use `universal_scraper.bat` for other Finacle pages

## Troubleshooting

### Can't see home page
**Check:** Are you logged in? Session valid?
**Fix:** Login first at `/fininfra/ui/SSOLogin.jsp`

### Session lost
**Check:** Cookie enabled in browser?
**Fix:** Enable cookies, don't use incognito mode

### JSP code visible in browser
**Check:** Is Go server running?
**Fix:** Start server with `go run main.go`

## Summary

You now have a **complete, self-contained Finacle JSP simulator** that:
- Handles login internally
- Manages sessions
- Switches views dynamically
- Processes forms
- Works exactly like the real Finacle system

**Perfect for development and testing!** 🚀
