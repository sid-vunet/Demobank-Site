# Finacle JSP Architecture - Component-Based Layout

## Overview
The SSOLogin.jsp now implements exact Finacle-style modular rendering where each section of the page is loaded separately, mimicking the real Finacle system architecture.

## Component Structure

### Main JSP: `SSOLogin.jsp`
- **Purpose**: Main controller handling authentication and view routing
- **Views**: 
  - `login` - Standard login form
  - `home` - Complete Finacle dashboard with modular components

### Modular Components (includes/)

#### 1. `includes/header.jsp`
**Section 1 - Gray Header Bar**
- User dropdown with solution selector (CRM, CoreServer, FIPAdministrator, FININFRA, GBM)
- Calendar dropdown (Gregorian, Islamic)
- Timezone display (IST)
- Search icon
- Red scrolling notification banner

**Loaded**: Top of every page after login  
**Styling**: Gray background (#e8e8e8), 11px Arial font  
**Dynamic**: Reads session.getAttribute("username") and session.getAttribute("solution")

#### 2. `includes/banner.jsp`
**Section 2 - Blue Finacle Banner**
- Finacle® logo with "Universal Banking Solution from Infosys" tagline
- Icon buttons (Home, Profile, Messages, Email, Calculator, Notepad)
- Right-side info panel:
  - Customer Call status
  - Consort Call status
  - Rep Status
  - Infosys logo
- Menu shortcut input field

**Loaded**: Below header after login  
**Styling**: Blue gradient (#4a90e2 to #2e5f9e), white text  
**Interactive**: Icon buttons with onclick handlers, shortcut search

#### 3. `includes/leftmenu.jsp`
**Section 3 - Functions Navigation Panel**
- Expandable/collapsible menu tree
- Two main sections visible:
  - **CIF Retail**
    - Audit Trail
    - Edit Entity
    - Entity Queue
    - New Entity
    - Operations
    - Relationship Manager Maintenance
  - **CIF Corporate**
    - Audit Trail
    - Edit Entity
    - Entity Queue
    - Group Mapping
    - New Entity
    - Operations
    - Relationship Manager Maintenance
- Scroll controls at bottom (◄ progress bar ►)

**Loaded**: Left side of main area (250px fixed width)  
**Styling**: Light gray (#f9f9f9), folder icons, hover effects  
**Interactive**: 
- `toggleSubmenu(menuId)` - Expands/collapses menu sections
- `loadContent(functionName)` - Loads function in content area
- `scrollMenu(direction)` - Scrolls menu up/down

#### 4. `includes/content.jsp`
**Section 4 - Dynamic Content Area**
- Welcome screen (default)
- Audit Trail form
- Edit Entity form
- Other function screens

**Loaded**: Right side of main area (flex: 1, fills remaining space)  
**Styling**: White background, forms with Finacle styling  
**Dynamic**: Changes based on `?function=` parameter  
**Functions**:
- `welcome` - Dashboard with quick access tiles
- `auditTrail` - Search form with date range, customer ID filters
- `editEntity` - Customer search and edit form
- Others render as "under development"

## URL Patterns

### Login
```
/fininfra/ui/SSOLogin.jsp
/fininfra/ui/SSOLogin.jsp?view=login
/fininfra/ui/SSOLogin.jsp?CALLTYPE=GET_LOGIN_PAGE
```

### Home (Component-Based)
```
/fininfra/ui/SSOLogin.jsp?view=home
/fininfra/ui/SSOLogin.jsp?view=home&function=welcome (default)
/fininfra/ui/SSOLogin.jsp?view=home&function=auditTrail
/fininfra/ui/SSOLogin.jsp?view=home&function=editEntity
/fininfra/ui/SSOLogin.jsp?view=home&function=entityQueue
/fininfra/ui/SSOLogin.jsp?view=home&function=operations
```

### Actions
```
/fininfra/ui/SSOLogin.jsp?action=login (POST with form data)
/fininfra/ui/SSOLogin.jsp?action=logout
```

## Page Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│ SECTION 1: header.jsp - Gray Bar                           │
│ User: DXCRAJEN | Solution: FININFRA | Calendar | Timezone  │
├─────────────────────────────────────────────────────────────┤
│ SECTION 2: banner.jsp - Blue Finacle Bar                   │
│ [Finacle Logo] [🏠 👤 ✉ 📧 🔢 📝 Icons]    Info Panel    │
│ Menu Shortcut: [___________] [Go]                          │
├──────────────────┬──────────────────────────────────────────┤
│ SECTION 3:       │ SECTION 4: content.jsp                   │
│ leftmenu.jsp     │                                          │
│                  │ Dynamic content area based on selected   │
│ Functions        │ function from left menu                  │
│ ├─ CIF Retail ▼  │                                          │
│ │  ├─ Audit Trail│ [Function-specific forms and displays]   │
│ │  ├─ Edit Entity│                                          │
│ │  └─ ...        │                                          │
│ └─ CIF Corporate │                                          │
│    ├─ ...        │                                          │
│                  │                                          │
│ [◄══════►]       │                                          │
└──────────────────┴──────────────────────────────────────────┘
```

## Component Communication

### Navigation Flow
1. User clicks menu item in `leftmenu.jsp`
2. Calls `loadContent('functionName')` JavaScript function
3. Which calls parent `loadFunction('functionName')`
4. Redirects to `SSOLogin.jsp?view=home&function=functionName`
5. Server re-renders entire page with new function parameter
6. `content.jsp` detects function parameter and renders appropriate content

### Session Management
All components access same session:
```jsp
<%= session.getAttribute("username") %>
<%= session.getAttribute("userId") %>
<%= session.getAttribute("loginTime") %>
<%= session.getId() %>
```

### JavaScript Communication
- **Left Menu → Content**: `window.parent.loadFunction(funcName)`
- **Banner Icons → Actions**: Direct `onclick` handlers
- **Header Dropdown → Session**: `alert()` for solution switching
- **Menu Shortcut**: `executeShortcut()` function (stub)

## Styling Approach

### CSS Location
- **Global**: In `<style>` tags within `SSOLogin.jsp` `<head>`
- **Component-specific**: Inline styles within each JSP include
- **External**: `static/ui/login.css` for login form elements

### Key Style Classes
```css
.finacle-container - Full viewport container (100vh)
.finacle-header - Gray top bar
.finacle-banner - Blue Finacle logo bar
.finacle-menubar - Menu shortcut bar below banner
.finacle-leftmenu - Left navigation panel (250px fixed)
.finacle-content - Main content area (flex: 1)
.menu-section - Menu category container
.menu-header - Clickable menu category title
.menu-item - Individual menu item with hover effect
```

### Layout Technique
- **Flexbox**: Used for main layout (column direction, then row for main area)
- **Fixed widths**: Left menu is 250px fixed
- **Fluid content**: Content area fills remaining space
- **Overflow handling**: 
  - `overflow: hidden` on body and container
  - `overflow-y: auto` on leftmenu and content for independent scrolling

## Adding New Functions

### Step 1: Add Menu Item
Edit `includes/leftmenu.jsp`:
```jsp
<div class="menu-item" onclick="loadContent('myNewFunction')" style="...">
    <img src="..." alt="Doc" />
    My New Function
</div>
```

### Step 2: Add Content Handler
Edit `includes/content.jsp`:
```jsp
<% } else if ("myNewFunction".equals(currentFunction)) { %>
    <h2>My New Function</h2>
    <div>
        <!-- Your form/content here -->
    </div>
<% } %>
```

### Step 3: Test
```
http://localhost:8080/fininfra/ui/SSOLogin.jsp?view=home&function=myNewFunction
```

## Image Assets Needed

Create these placeholder images in `static/ui/images/`:

### Icons (32x32 or 16x16)
- `home_icon.gif` - House icon
- `profile_icon.gif` - User profile icon
- `messages_icon.gif` - Messages/inbox icon
- `email_icon.gif` - Email envelope icon
- `calculator_icon.gif` - Calculator icon
- `notepad_icon.gif` - Notepad/notes icon
- `search.gif` - Search/magnifier icon
- `folder_icon.gif` - Folder icon for Functions header
- `close_icon.gif` - X/close icon
- `folder_closed.gif` - Closed folder icon
- `folder_open.gif` - Open folder icon
- `document.gif` - Document/file icon

### Logos
- `infosys_logo.gif` - Infosys text logo (white)

### Fallback
If images don't exist, they'll show as broken icons. To fix:
1. Create simple colored placeholders
2. Or update includes to use Unicode symbols (🏠 👤 ✉ etc.)
3. Or use inline SVG icons

## Server-Side Processing

### Request Flow
```
1. Browser Request: GET /fininfra/ui/SSOLogin.jsp?view=home&function=auditTrail
2. SSOLogin.jsp processes:
   - Reads session to check authentication
   - Extracts 'view' and 'function' parameters
   - Renders home view
3. JSP includes execute:
   - header.jsp renders with session data
   - banner.jsp renders with current date
   - leftmenu.jsp renders with currentFunction highlighting
   - content.jsp renders auditTrail form
4. Response: Complete HTML page sent to browser
```

### Parameter Handling
```jsp
<%
String view = request.getParameter("view"); // "home"
String currentFunction = request.getParameter("function"); // "auditTrail"
String action = request.getParameter("action"); // "login", "logout", null
%>
```

### Session Variables
Set on login:
```jsp
session.setAttribute("username", username);
session.setAttribute("userId", username);
session.setAttribute("loginTime", new java.util.Date().toString());
session.setAttribute("authenticated", "true");
session.setAttribute("sessionId", session.getId());
```

## Testing

### Test Login → Home
1. Access: `http://localhost:8080/fininfra/ui/SSOLogin.jsp`
2. Enter any username/password
3. Submit
4. Should see: Modular Finacle home page with 4 sections

### Test Menu Navigation
1. Click "CIF Retail" header → Should expand/collapse
2. Click "Audit Trail" → Should load audit trail form in content area
3. Click "Edit Entity" → Should load edit entity form

### Test Components Load
1. Check gray header appears with user dropdown
2. Check blue Finacle banner with logo and icons
3. Check left menu with expandable sections
4. Check content area shows welcome or specific function

## Differences from Real Finacle

### Simplified
- No database backend (forms don't submit to real DB)
- Placeholder images instead of actual Finacle icons
- Stub JavaScript functions (calculator, notepad don't actually open)
- Limited menu items (real Finacle has 100+ functions)

### Authentic Elements
✅ Four-section modular layout  
✅ Component-based JSP includes  
✅ Expandable menu tree structure  
✅ Gray header, blue banner, white content  
✅ Session management with cookies  
✅ Menu shortcut input  
✅ Solution dropdown  
✅ Exact function names (Audit Trail, Edit Entity, etc.)  
✅ Finacle® branding and colors

## Performance Notes

- Each page load re-renders all components (no client-side SPA)
- Session state maintained server-side
- No AJAX - full page refreshes for navigation
- Minimal JavaScript - mostly event handlers
- CSS is inline for component isolation

## Browser Compatibility

- **IE10 Mode**: `<meta http-equiv="X-UA-Compatible" content="IE=10"/>`
- **Modern Browsers**: Fallback flexbox, CSS3 features
- **Mobile**: Not optimized (Finacle is desktop application)

## Summary

The SSOLogin.jsp now renders a complete, modular Finacle interface exactly like the screenshot:

1. **Gray header** - User/solution/calendar/timezone (separate include)
2. **Blue banner** - Logo/icons/info panel (separate include)  
3. **Left menu** - Expandable Functions tree (separate include)
4. **Content area** - Dynamic forms based on selection (separate include)

All loaded by **one main JSP** that handles routing, authentication, and session management internally.

Perfect simulation of real Finacle architecture! 🎯
