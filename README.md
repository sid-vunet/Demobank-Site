# UCO Bank CBS Browser Application Simulator

A Java web application that simulates UCO Bank's CBS (Core Banking System) Finacle browser application with proper rendering support for legacy Internet Explorer mode content.

## Overview

This application recreates the UCO Bank Finacle CBS login and authentication flow that was originally designed for Internet Explorer. The server includes proper IE compatibility headers and serves JSP/CSS/JavaScript that mimics the original application behavior.

## Features

- ✅ Internet Explorer 10 compatibility mode headers
- ✅ SSO (Single Sign-On) simulation
- ✅ Session management via HttpSession
- ✅ Virtual keyboard support (placeholder)
- ✅ Two-factor authentication framework
- ✅ Static asset serving with proper MIME types
- ✅ Modular 4-section Finacle layout
- ✅ UAT environment banner and branding

## Prerequisites

Before running this application, you need to install:

1. **Java Development Kit (JDK)** (version 11 or higher)
   - Download from: https://adoptium.net/ or https://openjdk.org/
   - Verify installation: `java -version`

2. **Apache Maven** (version 3.6 or higher)
   - Download from: https://maven.apache.org/download.cgi
   - Verify installation: `mvn -version`

3. **Apache Tomcat** (version 9 or higher) or **Jetty** (version 10+)
   - Download Tomcat from: https://tomcat.apache.org/

## Project Structure

```
Uco-Finnacle-Site/
├── .github/
│   └── copilot-instructions.md    # Project guidelines
├── java-webapp/
│   ├── pom.xml                    # Maven build configuration
│   └── src/
│       └── main/
│           ├── java/com/ucobank/finacle/
│           │   ├── filter/
│           │   │   ├── AuthenticationFilter.java
│           │   │   └── IECompatibilityFilter.java
│           │   ├── model/
│           │   │   ├── MenuItem.java
│           │   │   └── User.java
│           │   ├── service/
│           │   │   ├── AuthenticationService.java
│           │   │   ├── FunctionService.java
│           │   │   └── MenuService.java
│           │   └── servlet/
│           │       ├── FunctionServlet.java
│           │       ├── LoginServlet.java
│           │       ├── MenuServlet.java
│           │       └── SSOServlet.java
│           └── webapp/
│               ├── WEB-INF/web.xml
│               └── fininfra/ui/
│                   └── SSOLogin.jsp        # Single rendering template
├── static/                         # Static assets
│   ├── javascripts/
│   │   └── ssodomain.js           # SSO domain configuration
│   └── ui/
│       ├── login.css              # Login page styles
│       ├── images/
│       │   ├── loginbg.gif        # Login background
│       │   └── logo.gif           # UCO Bank logo
│       └── javascripts/
│           ├── SSOLogin_INFENG.js # English resources
│           ├── tfaAuth.js         # Two-factor auth
│           ├── sso.js             # SSO main module
│           ├── ssojsutils.js      # SSO utilities
│           └── login.js           # Login page logic
└── README.md                       # This file
```

## Architecture

### CRITICAL RULE: Single JSP Rendering

**`SSOLogin.jsp` renders ALL content** - this is exactly how real Finacle works:
- Login page
- Home page with all 4 sections (header, banner, left menu, content)
- All function screens (Audit Trail, Edit Entity, etc.)
- Error messages and logout confirmation

### Data Flow
```
Browser Request → Servlet (validates, sets data) → Forward to SSOLogin.jsp → Renders view
```

### 4-Section Layout
1. **Header** - Gray bar with user info, solution selector, calendar
2. **Banner** - Blue Finacle banner with icons and shortcuts
3. **Left Menu** - Expandable navigation tree (CIF Retail, CIF Corporate)
4. **Content Area** - Dynamic function screens

## Installation & Setup

### Step 1: Install Java & Maven

**macOS:**
```bash
# Using Homebrew
brew install openjdk@11
brew install maven

# Verify installation
java -version
mvn -version
```

**Windows:**
```powershell
# Download and install JDK from https://adoptium.net/
# Download and install Maven from https://maven.apache.org/

# Verify installation
java -version
mvn -version
```

**Linux:**
```bash
sudo apt update
sudo apt install openjdk-11-jdk maven

# Verify installation
java -version
mvn -version
```

### Step 2: Build the Application

```bash
cd java-webapp
mvn clean package
```

This will create `target/finacle.war`

### Step 3: Deploy to Tomcat

**Option A: Copy WAR file**
```bash
cp target/finacle.war $CATALINA_HOME/webapps/
```

**Option B: Use Maven Tomcat plugin**
```bash
mvn tomcat7:run
```

**Option C: Use embedded Jetty**
```bash
mvn jetty:run
```

### Step 4: Access the Application

Open your browser and navigate to:
- **Main page:** http://localhost:8080/finacle
- **Direct login:** http://localhost:8080/finacle/fininfra/ui/SSOLogin.jsp

## Usage

### Login Flow

1. Navigate to http://localhost:8080/finacle
2. Enter username and password (any non-empty values work)
3. Click "Login" to authenticate
4. You'll see the Finacle home page with 4-section layout

### Test Credentials

Any non-empty username and password will work:
- Username: `testuser`
- Password: `testpass`

## How It Works

### Internet Explorer Compatibility

The `IECompatibilityFilter` adds headers for IE10 rendering:
```java
response.setHeader("X-UA-Compatible", "IE=10");
```

### Session Management

Sessions are managed via `HttpSession`:
- Stores: `authenticated`, `username`, `loginTime`
- Protected routes check session via `AuthenticationFilter`

### Servlet Routes

| Route | Servlet | Purpose |
|-------|---------|---------|
| `/login` | LoginServlet | Authentication handler |
| `/function` | FunctionServlet | Function screen handler |
| `/menu` | MenuServlet | AJAX menu data |
| `/sso` | SSOServlet | SSO simulation |

## Customization

### Change Server Port

Edit Tomcat's `server.xml` or use:
```bash
mvn jetty:run -Djetty.http.port=9090
```

### Add Real Images

Replace placeholder files in `static/ui/images/`:
- `loginbg.gif` - Login background image
- `logo.gif` - UCO Bank logo

### Enable Real Authentication

Modify `AuthenticationService.java` to:
- Connect to a real user database
- Validate credentials against LDAP/Active Directory
- Implement password hashing/verification

## Troubleshooting

### Maven Build Fails

```bash
# Clean and rebuild
mvn clean install -U
```

### Port Already in Use

```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>
```

### JSP Compilation Errors

- Check Java version matches `pom.xml` settings
- Verify servlet-api dependency is present

## Technical Details

### Dependencies (from pom.xml)

- **javax.servlet-api** 4.0.1 - Servlet API
- **javax.servlet.jsp-api** 2.3.3 - JSP API
- **jstl** 1.2 - JSP Standard Tag Library
- **gson** 2.10.1 - JSON processing

### Browser Compatibility

- ✅ Microsoft Edge (with IE mode)
- ✅ Microsoft Edge (standard mode)
- ✅ Internet Explorer 10+
- ✅ Chrome/Firefox (works with compatibility headers)

## Security Notes

⚠️ **This is a simulation/development tool. For production:**
- Implement real authentication
- Use HTTPS/TLS encryption
- Secure session management
- Add input validation and sanitization
- Implement CSRF protection
- Add security headers (CSP, HSTS, etc.)

## Known Limitations

1. Virtual keyboard is a placeholder
2. Two-factor authentication is framework only
3. No real user database integration
4. Image assets are placeholders

## Future Enhancements

- [ ] Implement functional virtual keyboard
- [ ] Add real two-factor authentication
- [ ] Database integration for users
- [ ] LDAP/Active Directory support
- [ ] Complete audit logging
- [ ] Admin panel for user management

---

**Version:** 1.0.0  
**Last Updated:** December 2025  
**Java Version:** 11+
