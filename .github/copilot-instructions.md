# UCO Bank CBS Browser Application Simulator

## Project Overview
This is a Java web application that simulates UCO Bank's CBS (Core Banking System) Finacle browser application.

## CRITICAL ARCHITECTURE RULE
**SINGLE JSP FILE ONLY** - `SSOLogin.jsp` renders ALL content:
- Login page
- Home page with all 4 sections (header, banner, left menu, content)
- All function screens (Audit Trail, Edit Entity, etc.)
- Error messages
- Logout confirmation
- Password incorrect pages
- ALL workflows and interactions

The Java servlets/services provide DATA to the JSP, but `SSOLogin.jsp` is the ONLY rendering template. This is exactly how real Finacle works.

## Architecture Pattern
```
Browser Request → Servlet (processes, sets data) → Forward to SSOLogin.jsp → JSP renders based on data
```

## Data Flow
1. User requests `/login` or `/function?id=xxx`
2. Servlet processes request, validates, fetches data
3. Servlet sets request/session attributes
4. Servlet forwards to `SSOLogin.jsp`
5. JSP checks attributes and renders appropriate view
6. Single HTML response with complete page

## Checklist

- [x] Create .github directory and copilot-instructions.md
- [x] Get project setup information
- [x] Create Go project structure
- [x] Create HTML files from attachments
- [x] Create static assets structure
- [x] Create Go server with IE compatibility
- [x] Create README documentation
- [x] Create JSP processing engine in Go
- [x] Create comprehensive SSOLogin.jsp with login and home views
- [x] Create modular JSP components (header, banner, leftmenu, content)
- [x] Create Finacle-exact 4-section layout
- [ ] Create placeholder images for UI icons
- [ ] Test complete modular component rendering
- [ ] Test menu navigation and function loading

## Project Structure
- `main.go` - Main Go server with JSP processing engine and IE10 compatibility
- `go.mod` / `go.sum` - Go module definition (gorilla/mux, gorilla/sessions)
- `jsp/fininfra/ui/` - JSP files with server-side logic
  - `SSOLogin.jsp` - Main controller (login + home routing)
  - `includes/header.jsp` - Gray header bar (user/solution/calendar)
  - `includes/banner.jsp` - Blue Finacle banner with icons
  - `includes/leftmenu.jsp` - Functions navigation tree
  - `includes/content.jsp` - Dynamic content area
- `static/` - Static assets (CSS, JS, images)
  - `ui/` - UI assets (login.css, JavaScript modules, images)
  - `javascripts/` - Global JavaScript files (ssodomain.js)
- `templates/` - Legacy HTML templates (kept for compatibility)
- `README.md` / `QUICKSTART.md` / `FINACLE_ARCHITECTURE.md` - Documentation
- `universal_scraper.bat` - Multi-method website scraper
- `create_placeholder_images.bat` - Image placeholder generator

## Development Guidelines
- Use Go 1.21 or higher
- Install Go from: https://go.dev/dl/
- Run with: `go run main.go` or build with: `go build`
- Server runs on http://localhost:8080
- Serves static files with proper MIME types
- Handles session management for SSO simulation with cookies
- Supports IE10 compatibility mode headers (`X-UA-Compatible: IE=10`)
- Implements proper routing for interlinking HTML pages
- Uses Gorilla Mux for routing and Gorilla Sessions for session management

## Next Steps
1. Install Go if not already installed
2. Run `go mod download` to install dependencies
3. Run `go run main.go` to start the server
4. Access http://localhost:8080 in your browser
