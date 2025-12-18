# UCO Bank CBS Browser Application Simulator

## Project Overview
This is a Java web application that simulates UCO Bank's CBS (Core Banking System) Finacle browser application.

## CRITICAL ARCHITECTURE RULES

### 1. SINGLE URL ONLY
**The browser URL must ALWAYS be exactly:** `/fininfra/ui/SSOLogin.jsp`
- NO query parameters (no `?view=home`, no `?functionId=xxx`)
- NO hash fragments
- NO URL changes during navigation
- This matches exactly how real Finacle works

### 2. SINGLE JSP FILE
**`SSOLogin.jsp` renders ALL content:**
- Login page
- Home page with all 4 sections (header, banner, left menu, content)
- All function screens (Audit Trail, Edit Entity, etc.)
- Error messages
- Logout confirmation
- ALL workflows and interactions

### 3. STATE MANAGEMENT
**All navigation is handled internally via:**
- **Session attributes** (`currentView`, `currentFunction`, `authenticated`)
- **POST form submissions** (never GET with query params)
- **Forward** (not redirect) from servlets

## Architecture Pattern
```
Browser POST → JSP handles formAction → Updates session state → Renders appropriate view
```

## Data Flow
1. User clicks menu/button → JavaScript submits hidden form via POST
2. SSOLogin.jsp receives POST, reads `formAction` parameter
3. JSP updates session attributes (`currentView`, `currentFunction`)
4. JSP renders appropriate view based on session state
5. URL never changes - always `/fininfra/ui/SSOLogin.jsp`

## Checklist

- [x] Create .github directory and copilot-instructions.md
- [x] Create Java web application structure (Maven)
- [x] Create HTML files from attachments
- [x] Create static assets structure
- [x] Create README documentation
- [x] Create comprehensive SSOLogin.jsp with login and home views
- [x] Create modular JSP components (header, banner, leftmenu, content)
- [x] Create Finacle-exact 4-section layout
- [x] Create Java Servlets (Login, Function, Menu, SSO)
- [x] Create Java Services (Authentication, Function, Menu)
- [x] Create Java Models (User, MenuItem)
- [x] Create Filters (Authentication, IE Compatibility)
- [x] Create placeholder images for UI icons (10 SVG icons in webapp/ui/images/)
- [x] Test complete modular component rendering
- [x] Test menu navigation and function loading
- [x] Deploy to servlet container (Tomcat 9.0.113)

## Deployment Scripts
- `./deploy.sh` - Builds WAR, downloads/installs Tomcat, deploys app, opens browser
- `./stop.sh` - Stops the running Tomcat server

## Prerequisites Installation (macOS)
To complete testing and deployment, install Java and Maven:
```bash
# Install Java JDK 11+
brew install openjdk@11
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install Maven
brew install maven
```

## Project Structure
```
java-webapp/
├── pom.xml                          # Maven build configuration
├── src/main/java/com/ucobank/finacle/
│   ├── filter/
│   │   ├── AuthenticationFilter.java    # Session validation
│   │   └── IECompatibilityFilter.java   # IE10 headers
│   ├── model/
│   │   ├── MenuItem.java                # Menu tree model
│   │   └── User.java                    # User session model
│   ├── service/
│   │   ├── AuthenticationService.java   # Login/logout logic
│   │   ├── FunctionService.java         # Function data provider
│   │   └── MenuService.java             # Menu tree builder
│   └── servlet/
│       ├── FunctionServlet.java         # Function screen handler
│       ├── LoginServlet.java            # Authentication handler
│       ├── MenuServlet.java             # AJAX menu data
│       └── SSOServlet.java              # SSO simulation
└── src/main/webapp/
    ├── WEB-INF/web.xml                  # Servlet configuration
    └── fininfra/ui/
        └── SSOLogin.jsp                 # SINGLE rendering template
```

Static assets:
- `static/ui/` - UI assets (login.css, JavaScript modules, images)
- `static/javascripts/` - Global JavaScript files (ssodomain.js)

## Database Configuration
- **Host:** 10.1.92.130
- **Port:** 1521
- **Service:** XEPDB1
- **Username:** system
- **Password:** Oracle123!

Configuration is in `java-webapp/src/main/java/com/ucobank/finacle/config/DatabaseConfig.java`
and can be overridden via environment variables: `DB_HOST`, `DB_PORT`, `DB_SERVICE`, `DB_USERNAME`, `DB_PASSWORD`

---

## Docker Deployment

### Build Docker Image (AMD64 for servers)
```bash
# Build for AMD64 architecture (required for Linux servers)
docker buildx build --platform linux/amd64 -t uco-finacle:latest --load .

# Build for local Mac testing (ARM64)
docker build -t uco-finacle:latest .
```

### Run Locally with Docker
```bash
docker run -d --name uco-finacle -p 8080:8080 uco-finacle:latest

# With custom database
docker run -d --name uco-finacle -p 8080:8080 \
  -e DB_HOST=10.1.92.130 \
  -e DB_PORT=1521 \
  -e DB_SERVICE=XEPDB1 \
  -e DB_USERNAME=system \
  -e DB_PASSWORD=Oracle123! \
  uco-finacle:latest
```

### Docker Compose
```bash
docker-compose up -d
docker-compose down
```

---

## Deployment to Individual Linux VM (Bare Metal)

### Create Deployment Bundle
```bash
cd bundle
./create-bundle.sh
```
This creates `uco-finacle-bundle.tar.gz` (~215MB) containing everything needed.

### Deploy to Any Linux VM
```bash
# 1. Copy bundle to server
scp uco-finacle-bundle.tar.gz user@server:/tmp/

# 2. SSH and extract
ssh user@server
cd /tmp && tar -xzf uco-finacle-bundle.tar.gz

# 3. Deploy with single command (auto-installs Docker if needed)
sudo ./deploy.sh

# With custom database:
export DB_HOST=your-db-host
export DB_PASSWORD=your-password
sudo -E ./deploy.sh
```

**Supported OS:** Ubuntu 20.04/22.04/24.04, Debian 11/12, RHEL/CentOS/Rocky 8/9

---

## Proxmox LXC Deployment

### Initial Deployment
```bash
# 1. Build AMD64 image and export
docker buildx build --platform linux/amd64 -t uco-finacle:latest --load .
docker save uco-finacle:latest | gzip > uco-finacle.tar.gz

# 2. Copy to Proxmox host
scp uco-finacle.tar.gz proxmox/create_finacle_lxc.sh root@<proxmox-ip>:/root/

# 3. Run on Proxmox host
ssh root@<proxmox-ip>
./create_finacle_lxc.sh
```

### Update/Refresh LXC with New Changes
After making source code changes, run this to update the running LXC:

```bash
# On your Mac - rebuild and export
cd /path/to/Uco-Finnacle-Site
docker buildx build --platform linux/amd64 -t uco-finacle:latest --load .
docker save uco-finacle:latest | gzip > uco-finacle.tar.gz
scp uco-finacle.tar.gz root@<proxmox-ip>:/root/

# On Proxmox host - update the LXC container
CTID=210  # Your LXC container ID

# Copy new image to LXC
pct push $CTID /root/uco-finacle.tar.gz /root/uco-finacle.tar.gz

# Load new image and restart container
pct exec $CTID -- bash -c "docker stop uco-finacle && docker rm uco-finacle"
pct exec $CTID -- bash -c "gunzip -c /root/uco-finacle.tar.gz | docker load"
pct exec $CTID -- bash -c "docker run -d --name uco-finacle --restart unless-stopped -p 8080:8080 \
  -e DB_HOST=10.1.92.130 -e DB_PORT=1521 -e DB_SERVICE=XEPDB1 \
  -e DB_USERNAME=system -e DB_PASSWORD=Oracle123! uco-finacle:latest"
pct exec $CTID -- bash -c "rm /root/uco-finacle.tar.gz"

# Verify
pct exec $CTID -- docker ps
```

### Quick Update Script (proxmox/update-lxc.sh)
```bash
#!/bin/bash
# Usage: ./update-lxc.sh <proxmox-ip> <ctid>
PROXMOX_IP=${1:-10.1.92.10}
CTID=${2:-210}

echo "Building AMD64 image..."
docker buildx build --platform linux/amd64 -t uco-finacle:latest --load .

echo "Exporting image..."
docker save uco-finacle:latest | gzip > uco-finacle.tar.gz

echo "Uploading to Proxmox..."
scp uco-finacle.tar.gz root@$PROXMOX_IP:/root/

echo "Updating LXC container..."
ssh root@$PROXMOX_IP << EOF
pct push $CTID /root/uco-finacle.tar.gz /root/uco-finacle.tar.gz
pct exec $CTID -- bash -c "docker stop uco-finacle; docker rm uco-finacle"
pct exec $CTID -- bash -c "gunzip -c /root/uco-finacle.tar.gz | docker load"
pct exec $CTID -- bash -c "docker run -d --name uco-finacle --restart unless-stopped -p 8080:8080 -e DB_HOST=10.1.92.130 -e DB_PORT=1521 -e DB_SERVICE=XEPDB1 -e DB_USERNAME=system -e DB_PASSWORD=Oracle123! uco-finacle:latest"
pct exec $CTID -- bash -c "rm /root/uco-finacle.tar.gz"
rm /root/uco-finacle.tar.gz
EOF

echo "✅ Update complete!"
```

---

## Scripts Reference

| Script | Location | Purpose |
|--------|----------|---------|
| `deploy.sh` | Root | Build WAR + run local Tomcat |
| `stop.sh` | Root | Stop local Tomcat |
| `Dockerfile` | Root | Docker image definition |
| `docker-compose.yml` | Root | Docker Compose config |
| `create-bundle.sh` | bundle/ | Create portable deployment package |
| `deploy.sh` | bundle/ | Self-contained VM deployment |
| `create_finacle_lxc.sh` | proxmox/ | Create new Proxmox LXC |
| `update-lxc.sh` | proxmox/ | Update existing LXC |

---

## Development Guidelines
- Use Java 11 or higher
- Use Maven 3.6+ for building
- Build with: `cd java-webapp && mvn clean package`
- Deploy WAR to Tomcat 9+ or Jetty 10+
- Server typically runs on http://localhost:8080/finacle
- Handles session management via HttpSession
- Supports IE10 compatibility mode headers (`X-UA-Compatible: IE=10`)
- Uses servlet filters for cross-cutting concerns

## Access URLs
- **Local Tomcat:** http://localhost:8080/finacle/fininfra/ui/SSOLogin.jsp
- **Docker:** http://localhost:8080/
- **Proxmox LXC:** http://<lxc-ip>:8080/
- **Login:** admin / admin123

