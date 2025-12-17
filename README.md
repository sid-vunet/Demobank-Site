# UCO Bank CBS Browser Application Simulator

A Go web server that simulates UCO Bank's CBS (Core Banking System) browser application with proper rendering support for legacy Internet Explorer mode content.

## Overview

This application recreates the UCO Bank Finacle CBS login and authentication flow that was originally designed for Internet Explorer. The server includes proper IE compatibility headers and serves HTML/CSS/JavaScript that mimics the original application behavior.

## Features

- ✅ Internet Explorer 10 compatibility mode headers
- ✅ SSO (Single Sign-On) simulation
- ✅ Session management with cookies
- ✅ Virtual keyboard support (placeholder)
- ✅ Two-factor authentication framework
- ✅ Static asset serving with proper MIME types
- ✅ Interlinking between HTML pages
- ✅ UAT environment banner and branding

## Prerequisites

Before running this application, you need to install:

1. **Go Programming Language** (version 1.21 or higher)
   - Download from: https://go.dev/dl/
   - Installation guide: https://go.dev/doc/install
   - Verify installation: `go version`

2. **Go Dependencies** (automatically installed when running the app)
   - gorilla/mux - HTTP router
   - gorilla/sessions - Session management

## Project Structure

```
Uco-Finnacle-Site/
├── .github/
│   └── copilot-instructions.md    # Project guidelines
├── main.go                         # Main Go server application
├── go.mod                          # Go module definition
├── go.sum                          # Go dependencies (auto-generated)
├── templates/                      # HTML templates
│   ├── index.html                  # Landing page with iframe
│   └── login.html                  # Login page with virtual keyboard
├── static/                         # Static assets
│   ├── javascripts/
│   │   └── ssodomain.js           # SSO domain configuration
│   ├── ui/
│   │   ├── login.css              # Login page styles
│   │   ├── dskFrame.html          # Desktop frame (hidden)
│   │   ├── images/
│   │   │   ├── loginbg.gif        # Login background (placeholder)
│   │   │   └── logo.gif           # UCO Bank logo (placeholder)
│   │   └── javascripts/
│   │       ├── SSOLogin_INFENG.js # English resources
│   │       ├── tfaAuth.js         # Two-factor auth
│   │       ├── sso.js             # SSO main module
│   │       ├── ssojsutils.js      # SSO utilities
│   │       └── login.js           # Login page logic
│   ├── images/
│   │   └── favicon.ico            # Favicon (placeholder)
│   └── ruxitagentjs_*.js          # Dynatrace placeholder
└── README.md                       # This file
```

## Installation & Setup

### Step 1: Install Go

If you don't have Go installed:

**Windows:**
```powershell
# Download and run the installer from https://go.dev/dl/
# Or use Chocolatey:
choco install golang

# Verify installation:
go version
```

**Linux/Mac:**
```bash
# Download and extract
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# Add to PATH
export PATH=$PATH:/usr/local/go/bin

# Verify installation
go version
```

### Step 2: Install Dependencies

Navigate to the project directory and install dependencies:

```powershell
# Windows PowerShell
cd c:\Users\Sidharth\Documents\Uco-Finnacle-Site
go mod download
go mod tidy
```

This will automatically download:
- `github.com/gorilla/mux` - HTTP router for Go
- `github.com/gorilla/sessions` - Session management

### Step 3: Run the Application

```powershell
# Start the server
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

### Step 4: Access the Application

Open your browser and navigate to:
- **Main page:** http://localhost:8080
- **Direct login:** http://localhost:8080/login

## Usage

### Login Flow

1. Navigate to http://localhost:8080
2. The index page will load with an iframe pointing to the SSO servlet
3. Enter any username and password (authentication is simulated)
4. Click "Login" to authenticate
5. You'll be redirected to the home page with session information

### Testing

**Test credentials:** Any non-empty username and password will work

Example:
- Username: `testuser`
- Password: `testpass`

## How It Works

### Internet Explorer Compatibility

The server includes special headers to ensure proper rendering in modern browsers while maintaining IE10 compatibility:

```go
w.Header().Set("X-UA-Compatible", "IE=10")
```

This header instructs Edge and other browsers to use IE10 rendering mode for legacy content.

### Session Management

Sessions are managed using encrypted cookies:
- Session cookie name: `uco-session`
- Stores: `authenticated`, `username`, `loginTime`
- Persists across requests until logout

### Route Structure

| Route | Purpose |
|-------|---------|
| `/` | Landing page (index.html with iframe) |
| `/SSOServlet` | SSO servlet simulation (query params: CALLTYPE) |
| `/login` | Direct login page access |
| `/authenticate` | POST endpoint for login form |
| `/home` | Protected home page (requires authentication) |
| `/ui/*` | Static UI assets (CSS, JS, images) |
| `/javascripts/*` | Global JavaScript files |

### Static File Serving

All static files are served with:
- Proper MIME types
- IE compatibility headers
- Cache control headers (1 hour cache)

## Customization

### Change Server Port

Edit `main.go`:
```go
port := ":8080"  // Change to your desired port
```

### Add Real Images

Replace placeholder files:
- `static/ui/images/loginbg.gif` - Login background image
- `static/ui/images/logo.gif` - UCO Bank logo
- `static/images/favicon.ico` - Browser favicon

### Customize Branding

Edit `templates/login.html`:
- Modify the marquee text for environment banner
- Update the "FINACLE 10.2.25 UCO UAT AREA" text
- Adjust colors in `static/ui/login.css`

### Enable Real Authentication

Modify the `handleAuthenticate` function in `main.go` to:
- Connect to a real user database
- Validate credentials against LDAP/Active Directory
- Implement password hashing/verification

## Troubleshooting

### Go is not recognized

**Error:** `go : The term 'go' is not recognized...`

**Solution:**
1. Install Go from https://go.dev/dl/
2. Restart your terminal/PowerShell
3. Verify: `go version`

### Port Already in Use

**Error:** `bind: address already in use`

**Solution:**
- Change the port in `main.go`
- Or kill the process using port 8080:
  ```powershell
  # Windows
  netstat -ano | findstr :8080
  taskkill /PID <PID> /F
  ```

### CSS/JS Not Loading

**Issue:** Styles or scripts not applying

**Solution:**
- Check browser console for 404 errors
- Verify file paths in `static/` directory
- Clear browser cache (Ctrl+F5)

### IE Compatibility Issues

**Issue:** Page doesn't render correctly in Edge

**Solution:**
- Open Edge Settings
- Search for "Internet Explorer mode"
- Add `http://localhost:8080` to IE mode sites
- Reload the page

## Building for Production

### Compile Binary

```powershell
# Windows
go build -o uco-finnacle-site.exe

# Linux/Mac
go build -o uco-finnacle-site
```

### Run Compiled Binary

```powershell
# Windows
.\uco-finnacle-site.exe

# Linux/Mac
./uco-finnacle-site
```

### Production Considerations

1. **Security:**
   - Change session secret key in `main.go`
   - Enable HTTPS/TLS
   - Implement real authentication
   - Add rate limiting
   - Enable CSRF protection

2. **Performance:**
   - Add response compression (gzip)
   - Implement caching strategies
   - Use a reverse proxy (nginx/Apache)
   - Enable HTTP/2

3. **Monitoring:**
   - Add logging middleware
   - Implement health check endpoints
   - Monitor session usage
   - Track error rates

## Technical Details

### Dependencies

- **gorilla/mux** v1.8.1 - HTTP request router and dispatcher
- **gorilla/sessions** v1.2.2 - Session management with cookie store

### Browser Compatibility

- ✅ Microsoft Edge (with IE mode)
- ✅ Microsoft Edge (standard mode with compatibility headers)
- ✅ Internet Explorer 10+
- ⚠️ Chrome/Firefox (may require Edge IE mode for full compatibility)

### Security Notes

⚠️ **This is a simulation/development tool. Do not use in production without:**
- Implementing real authentication
- Using HTTPS/TLS encryption
- Securing session management
- Adding input validation and sanitization
- Implementing proper error handling
- Adding security headers (CSP, HSTS, etc.)

## Known Limitations

1. Virtual keyboard is a placeholder (not fully functional)
2. Two-factor authentication is framework only
3. No real user database integration
4. Session secret is hardcoded (change for production)
5. Image assets are placeholders
6. No password encryption in transit (add HTTPS)

## Future Enhancements

- [ ] Implement functional virtual keyboard
- [ ] Add real two-factor authentication
- [ ] Database integration for users
- [ ] LDAP/Active Directory support
- [ ] Complete audit logging
- [ ] Admin panel for user management
- [ ] Multi-language support
- [ ] Mobile responsive design

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the Go documentation: https://go.dev/doc/
3. Check Gorilla toolkit docs: https://www.gorillatoolkit.org/

## License

This is a simulation tool for development and testing purposes.

## Acknowledgments

- Based on UCO Bank Finacle CBS application
- Uses Gorilla Web Toolkit for Go
- IE compatibility mode support

---

**Version:** 1.0.0  
**Last Updated:** December 2025  
**Go Version:** 1.21+
