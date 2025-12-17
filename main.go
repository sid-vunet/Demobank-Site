package main

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
)

var (
	// Session store for SSO simulation
	store = sessions.NewCookieStore([]byte("uco-bank-secret-key-change-in-production"))
	// Template cache
	templates *template.Template
	// JSP pages directory
	jspDir = "jsp"
)

func main() {
	// Parse templates
	var err error
	templates, err = template.ParseGlob("templates/*.html")
	if err != nil {
		log.Printf("Warning: Could not parse templates: %v", err)
	}

	// Create router
	r := mux.NewRouter()

	// Serve static files - Original paths
	r.PathPrefix("/ui/").Handler(http.StripPrefix("/ui/", addIEHeaders(http.FileServer(http.Dir("static/ui")))))
	r.PathPrefix("/ux/").Handler(http.StripPrefix("/ux/", addIEHeaders(http.FileServer(http.Dir("static/ux")))))
	r.PathPrefix("/javascripts/").Handler(http.StripPrefix("/javascripts/", addIEHeaders(http.FileServer(http.Dir("static/javascripts")))))
	r.PathPrefix("/images/").Handler(http.StripPrefix("/images/", addIEHeaders(http.FileServer(http.Dir("static/images")))))

	// Serve static files - Fininfra paths (for JSP compatibility)
	r.PathPrefix("/fininfra/ui/").Handler(http.StripPrefix("/fininfra/ui/", addIEHeaders(http.FileServer(http.Dir("static/fininfra/ui")))))
	r.PathPrefix("/fininfra/javascripts/").Handler(http.StripPrefix("/fininfra/javascripts/", addIEHeaders(http.FileServer(http.Dir("static/fininfra/javascripts")))))
	r.PathPrefix("/fininfra/images/").Handler(http.StripPrefix("/fininfra/images/", addIEHeaders(http.FileServer(http.Dir("static/fininfra/images")))))

	// Main routes
	r.HandleFunc("/", handleRootRedirect).Methods("GET")
	r.HandleFunc("/SSOLogin.jsp", handleMainJSP).Methods("GET", "POST")
	r.HandleFunc("/SSOServlet", handleSSOServlet).Methods("GET")
	r.HandleFunc("/login", handleLogin).Methods("GET")
	r.HandleFunc("/authenticate", handleAuthenticate).Methods("POST")
	r.HandleFunc("/home", handleHome).Methods("GET")

	// JSP routes - mimics Finacle structure
	r.HandleFunc("/fininfra/ui/{jsp}", handleJSP).Methods("GET", "POST")
	r.HandleFunc("/fininfra/{path:.*\\.jsp}", handleJSP).Methods("GET", "POST")

	// Catch-all for JSP files
	r.PathPrefix("/").HandlerFunc(handleJSPFallback)

	// Start server
	port := ":8080"
	fmt.Printf("\n==============================================\n")
	fmt.Printf("UCO Bank CBS Browser Application Simulator\n")
	fmt.Printf("==============================================\n")
	fmt.Printf("Server starting on http://localhost%s\n", port)
	fmt.Printf("Press Ctrl+C to stop the server\n")
	fmt.Printf("==============================================\n\n")

	log.Fatal(http.ListenAndServe(port, r))
}

// addIEHeaders wraps a handler to add IE compatibility headers
func addIEHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Force IE10 compatibility mode
		w.Header().Set("X-UA-Compatible", "IE=10")
		// Cache control for static assets
		w.Header().Set("Cache-Control", "public, max-age=3600")
		next.ServeHTTP(w, r)
	})
}

// handleRootRedirect redirects root to SSOLogin.jsp
func handleRootRedirect(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, "/fininfra/ui/SSOLogin.jsp", http.StatusTemporaryRedirect)
}

// handleMainJSP handles requests to /SSOLogin.jsp (short form)
func handleMainJSP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("X-UA-Compatible", "IE=10")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	// Read JSP file
	jspPath := filepath.Join(jspDir, "fininfra", "ui", "SSOLogin.jsp")
	content, err := ioutil.ReadFile(jspPath)
	if err != nil {
		log.Printf("JSP file not found: %s", jspPath)
		http.NotFound(w, r)
		return
	}

	// Get session for processing
	session, _ := store.Get(r, "uco-session")

	// Process JSP content
	processedContent := processJSP(string(content), r)

	// Save session after processing
	session.Save(r, w)

	// Write response
	w.Write([]byte(processedContent))
}

// handleIndex serves the initial landing page
func handleIndex(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("X-UA-Compatible", "IE=10")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	http.ServeFile(w, r, "templates/index.html")
}

// handleSSOServlet simulates the SSO servlet
func handleSSOServlet(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("X-UA-Compatible", "IE=10")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	callType := r.URL.Query().Get("CALLTYPE")

	if callType == "GET_LOGIN_PAGE" {
		http.ServeFile(w, r, "templates/login.html")
		return
	}

	if callType == "GET_BANK_HOME_PAGE" {
		http.Redirect(w, r, "/home", http.StatusSeeOther)
		return
	}

	http.ServeFile(w, r, "templates/login.html")
}

// handleLogin serves the login page
func handleLogin(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("X-UA-Compatible", "IE=10")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	http.ServeFile(w, r, "templates/login.html")
}

// handleAuthenticate processes login form submission
func handleAuthenticate(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Error(w, "Error parsing form", http.StatusBadRequest)
		return
	}

	username := r.FormValue("txtLoginId")
	password := r.FormValue("txtPassword")

	// Simple authentication simulation
	if username != "" && password != "" {
		// Create session
		session, _ := store.Get(r, "uco-session")
		session.Values["authenticated"] = true
		session.Values["username"] = username
		session.Values["loginTime"] = time.Now().Format(time.RFC3339)
		session.Save(r, w)

		// Redirect to home
		http.Redirect(w, r, "/home", http.StatusSeeOther)
		return
	}

	// Authentication failed - redirect back to login
	http.Redirect(w, r, "/login?error=invalid", http.StatusSeeOther)
}

// handleHome serves the home page (requires authentication)
func handleHome(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("X-UA-Compatible", "IE=10")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	// Check session
	session, _ := store.Get(r, "uco-session")
	auth, ok := session.Values["authenticated"].(bool)

	if !ok || !auth {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}

	username := session.Values["username"].(string)

	// Serve home page with user info
	fmt.Fprintf(w, `<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=10"/>
	<title>UCO Bank - Home</title>
	<link rel="stylesheet" href="/ui/login.css">
</head>
<body>
	<div style="padding: 20px;">
		<h1>Welcome to UCO Bank CBS</h1>
		<p>Logged in as: <strong>%s</strong></p>
		<p>Login Time: %s</p>
		<p><a href="/login">Logout</a></p>
	</div>
</body>
</html>`, username, session.Values["loginTime"])
}

// handleJSP processes JSP files like Finacle does
func handleJSP(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	jspFile := vars["jsp"]
	if jspFile == "" {
		jspFile = vars["path"]
	}

	w.Header().Set("X-UA-Compatible", "IE=10")
	w.Header().Set("Content-Type", "text/html; charset=utf-8")

	// Build JSP path - check if it's fininfra/ui request
	var jspPath string
	if strings.Contains(r.URL.Path, "/fininfra/ui/") {
		// Extract filename and build path
		jspPath = filepath.Join(jspDir, "fininfra", "ui", jspFile)
	} else {
		// Use full path from vars
		jspPath = filepath.Join(jspDir, jspFile)
	}

	// Add .jsp extension if missing
	if !strings.HasSuffix(jspPath, ".jsp") {
		jspPath = jspPath + ".jsp"
	}

	// Read JSP file
	content, err := ioutil.ReadFile(jspPath)
	if err != nil {
		log.Printf("JSP file not found: %s (URL: %s)", jspPath, r.URL.Path)
		http.NotFound(w, r)
		return
	}

	// Get session for processing
	session, _ := store.Get(r, "uco-session")

	// Process JSP-like content
	processedContent := processJSP(string(content), r)

	// Save session after processing (in case JSP set session attributes)
	session.Save(r, w)

	// Write response
	w.Write([]byte(processedContent))
}

// handleJSPFallback catches all other .jsp requests
func handleJSPFallback(w http.ResponseWriter, r *http.Request) {
	if strings.HasSuffix(r.URL.Path, ".jsp") {
		handleJSP(w, r)
	} else {
		http.NotFound(w, r)
	}
}

// processJSP simulates JSP processing (server-side rendering)
func processJSP(content string, r *http.Request) string {
	// Get session data
	session, _ := store.Get(r, "uco-session")

	// Parse form data for POST requests
	if r.Method == "POST" {
		r.ParseForm()
	}

	// Determine view based on session and parameters
	view := getParam(r, "view", "")
	action := getParam(r, "action", "")

	// Check authentication status
	isAuthenticated := false
	if auth, ok := session.Values["authenticated"].(string); ok && auth == "true" {
		isAuthenticated = true
	}
	if username, ok := session.Values["username"].(string); ok && username != "" {
		isAuthenticated = true
	}

	// Handle login action
	if action == "login" && r.Method == "POST" {
		r.ParseForm()
		username := r.FormValue("txtLoginId")
		password := r.FormValue("txtPassword")

		if username != "" && password != "" {
			session.Values["username"] = username
			session.Values["userId"] = username
			session.Values["authenticated"] = "true"
			session.Values["loginTime"] = time.Now().Format("Mon Jan 2 15:04:05 2006")
			isAuthenticated = true
			view = "home"
		}
	}

	// Handle logout action
	if action == "logout" {
		// Clear session
		session.Values = make(map[interface{}]interface{})
		isAuthenticated = false
		view = "login"
	}

	// Default view logic
	if view == "" {
		if isAuthenticated {
			view = "home"
		} else {
			view = "login"
		}
	}

	// Force login view if not authenticated
	if view == "home" && !isAuthenticated {
		view = "login"
	}

	// Replace JSP variables with actual values
	replacements := map[string]string{
		"${pageContext.request.contextPath}": "",
		"${applicationScope.contextPath}":    "",
		"<%=request.getContextPath()%>":      "",
		"${param.LCLANG}":                    getParam(r, "LCLANG", "INFENG"),
		"${param.CALLTYPE}":                  getParam(r, "CALLTYPE", ""),
		"${param.action}":                    getParam(r, "action", ""),
		"${param.view}":                      getParam(r, "view", ""),
	}

	processed := content
	for jsp, value := range replacements {
		processed = strings.ReplaceAll(processed, jsp, value)
	}

	// Process JSP conditionals - handle <% if ("view".equals(view)) { %> blocks
	processed = processJSPConditionals(processed, view, isAuthenticated, r, session)

	// Execute remaining JSP scriptlets <% ... %> (server-side Java code simulation)
	processed = executeJSPScriptlets(processed, r, session)

	// Process JSP expressions <%= ... %>
	expressionRegex := regexp.MustCompile(`<%=([^%]*)%>`)
	processed = expressionRegex.ReplaceAllStringFunc(processed, func(match string) string {
		expr := expressionRegex.FindStringSubmatch(match)[1]
		expr = strings.TrimSpace(expr)

		// Evaluate simple expressions
		if strings.Contains(expr, "request.getContextPath()") {
			return ""
		}
		if strings.Contains(expr, "request.getParameter") {
			return evaluateRequestParameter(expr, r)
		}
		if strings.Contains(expr, "session.getAttribute") {
			return evaluateSessionAttribute(expr, session)
		}
		if strings.Contains(expr, "session.getId()") {
			return session.ID
		}

		// Handle direct session attribute references
		if strings.HasPrefix(expr, "session.getAttribute(") {
			return evaluateSessionAttribute(expr, session)
		}

		return ""
	})

	// Process JSP directives <%@ ... %>
	directiveRegex := regexp.MustCompile(`<%@([^%]*)%>`)
	processed = directiveRegex.ReplaceAllString(processed, "")

	// Process JSTL variables ${...}
	jstlRegex := regexp.MustCompile(`\$\{([^}]+)\}`)
	processed = jstlRegex.ReplaceAllStringFunc(processed, func(match string) string {
		varName := jstlRegex.FindStringSubmatch(match)[1]
		return evaluateJSTLVariable(varName, r, session)
	})

	// Process JSP includes <jsp:include page="..." />
	processed = processJSPIncludes(processed, r, session)

	return processed
}

// processJSPConditionals handles JSP if/else blocks for view switching
func processJSPConditionals(content string, view string, isAuthenticated bool, r *http.Request, session *sessions.Session) string {
	// Handle the main view conditionals in SSOLogin.jsp
	// Pattern: <% if ("login".equals(view)) { %> ... <% } else if ("home".equals(view)) { %> ... <% } %>

	// Find LOGIN VIEW section
	loginStartMarker := `<% if ("login".equals(view)) { %>`
	loginAltStart := `<!-- ========== LOGIN VIEW ========== -->`

	// Find HOME VIEW section
	homeStartMarker := `<% } else if ("home".equals(view)) { %>`
	homeAltStart := `<!-- ========== HOME VIEW`

	// Find end marker
	endMarker := `<% } %>`

	// Strategy: Find both sections and keep only the appropriate one

	// Look for login section
	loginStart := strings.Index(content, loginStartMarker)
	if loginStart == -1 {
		loginStart = strings.Index(content, loginAltStart)
	}

	// Look for home section
	homeStart := strings.Index(content, homeStartMarker)
	if homeStart == -1 {
		homeStart = strings.Index(content, homeAltStart)
	}

	// If we found both sections, process them
	if loginStart != -1 && homeStart != -1 {
		// Find the end of home section (last <% } %> before </body>)
		bodyEnd := strings.LastIndex(content, "</body>")
		if bodyEnd == -1 {
			bodyEnd = len(content)
		}

		// Extract content before conditionals
		beforeContent := content[:loginStart]

		// Extract login section (from loginStart to homeStart)
		loginSection := content[loginStart:homeStart]

		// Extract home section (from homeStart to end marker before </body>)
		homeSection := content[homeStart:bodyEnd]

		// Clean up JSP markers from sections
		loginSection = cleanJSPMarkers(loginSection)
		homeSection = cleanJSPMarkers(homeSection)

		// Extract content after (</body></html>)
		afterContent := content[bodyEnd:]

		// Return only the appropriate section
		if view == "login" || !isAuthenticated {
			return beforeContent + loginSection + afterContent
		} else {
			return beforeContent + homeSection + afterContent
		}
	}

	return content
}

// cleanJSPMarkers removes JSP control flow markers
func cleanJSPMarkers(content string) string {
	markers := []string{
		`<% if ("login".equals(view)) { %>`,
		`<% } else if ("home".equals(view)) { %>`,
		`<% } %>`,
		`<% if (!errorMsg.isEmpty()) { %>`,
		`<% } %>`,
	}

	result := content
	for _, marker := range markers {
		result = strings.ReplaceAll(result, marker, "")
	}

	return result
}

// processJSPIncludes handles <jsp:include> tags
func processJSPIncludes(content string, r *http.Request, session *sessions.Session) string {
	// Regex to match <jsp:include page="path/to/file.jsp" />
	includeRegex := regexp.MustCompile(`<jsp:include\s+page="([^"]+)"\s*/?>`)

	processed := includeRegex.ReplaceAllStringFunc(content, func(match string) string {
		matches := includeRegex.FindStringSubmatch(match)
		if len(matches) < 2 {
			return match
		}

		includePath := matches[1]

		// Resolve include path relative to JSP directory
		// If path starts with /, it's from webapp root, else relative to current JSP
		var fullPath string
		if strings.HasPrefix(includePath, "/") {
			fullPath = filepath.Join(jspDir, strings.TrimPrefix(includePath, "/"))
		} else {
			// Relative to current JSP location (fininfra/ui/)
			fullPath = filepath.Join(jspDir, "fininfra", "ui", includePath)
		}

		// Read include file
		includeContent, err := ioutil.ReadFile(fullPath)
		if err != nil {
			log.Printf("Warning: Could not read JSP include: %s (path: %s)", includePath, fullPath)
			return fmt.Sprintf("<!-- JSP Include Error: %s -->", includePath)
		}

		// Process the included JSP (recursive processing for nested includes)
		processedInclude := processJSP(string(includeContent), r)

		return processedInclude
	})

	return processed
}

// getParam safely gets URL parameter
func getParam(r *http.Request, key, defaultValue string) string {
	value := r.URL.Query().Get(key)
	if value == "" {
		return defaultValue
	}
	return value
}

// evaluateSessionAttribute evaluates session.getAttribute() expressions
func evaluateSessionAttribute(expr string, session *sessions.Session) string {
	// Extract attribute name
	re := regexp.MustCompile(`session\.getAttribute\("([^"]+)"\)`)
	matches := re.FindStringSubmatch(expr)
	if len(matches) > 1 {
		attrName := matches[1]
		if val, ok := session.Values[attrName]; ok {
			return fmt.Sprintf("%v", val)
		}
	}
	return ""
}

// evaluateJSTLVariable evaluates JSTL ${...} variables
func evaluateJSTLVariable(varName string, r *http.Request, session *sessions.Session) string {
	// Handle different variable scopes
	if strings.HasPrefix(varName, "param.") {
		paramName := strings.TrimPrefix(varName, "param.")
		return r.URL.Query().Get(paramName)
	}

	if strings.HasPrefix(varName, "session.") {
		attrName := strings.TrimPrefix(varName, "session.")
		if val, ok := session.Values[attrName]; ok {
			return fmt.Sprintf("%v", val)
		}
	}

	if strings.HasPrefix(varName, "request.") {
		// Handle request attributes
		return ""
	}

	// Default: try session first, then empty
	if val, ok := session.Values[varName]; ok {
		return fmt.Sprintf("%v", val)
	}

	return ""
}

// executeJSPScriptlets executes JSP scriptlet code blocks <% ... %>
func executeJSPScriptlets(content string, r *http.Request, session *sessions.Session) string {
	// This simulates executing Java code in scriptlets
	scriptletRegex := regexp.MustCompile(`<%([^%@=][^%]*)%>`)

	// Store scriptlet variables
	scriptletVars := make(map[string]string)

	processed := scriptletRegex.ReplaceAllStringFunc(content, func(match string) string {
		code := scriptletRegex.FindStringSubmatch(match)[1]
		code = strings.TrimSpace(code)

		// Handle variable declarations
		if strings.Contains(code, "String") && strings.Contains(code, "=") {
			parts := strings.Split(code, "=")
			if len(parts) == 2 {
				varName := strings.TrimSpace(strings.Replace(parts[0], "String", "", 1))
				varName = strings.TrimSpace(strings.Replace(varName, ";", "", -1))
				value := strings.TrimSpace(strings.Trim(parts[1], "\";"))
				scriptletVars[varName] = value
			}
		}

		// Handle request.getParameter()
		if strings.Contains(code, "request.getParameter") {
			re := regexp.MustCompile(`request\.getParameter\("([^"]+)"\)`)
			matches := re.FindStringSubmatch(code)
			if len(matches) > 1 {
				paramName := matches[1]
				varNameRe := regexp.MustCompile(`String\s+(\w+)\s*=`)
				varMatches := varNameRe.FindStringSubmatch(code)
				if len(varMatches) > 1 {
					scriptletVars[varMatches[1]] = getParam(r, paramName, "")
				}
			}
		}

		// Handle session.setAttribute()
		if strings.Contains(code, "session.setAttribute") {
			re := regexp.MustCompile(`session\.setAttribute\("([^"]+)",\s*"?([^")]+)"?\)`)
			matches := re.FindStringSubmatch(code)
			if len(matches) > 2 {
				attrName := matches[1]
				attrValue := matches[2]
				if val, ok := scriptletVars[strings.TrimSpace(attrValue)]; ok {
					session.Values[attrName] = val
				} else {
					session.Values[attrName] = attrValue
				}
			}
		}

		// Remove scriptlets from output
		return ""
	})

	return processed
}

// evaluateRequestParameter evaluates request.getParameter() expressions
func evaluateRequestParameter(expr string, r *http.Request) string {
	re := regexp.MustCompile(`request\.getParameter\("([^"]+)"\)`)
	matches := re.FindStringSubmatch(expr)
	if len(matches) > 1 {
		paramName := matches[1]
		return getParam(r, paramName, "")
	}
	return ""
}
