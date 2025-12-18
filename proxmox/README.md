# Deploy UCO Finacle to Proxmox

## Option 1: Docker inside LXC Container (Recommended)

### Step 1: Create LXC Container in Proxmox

```bash
# SSH into your Proxmox host
ssh root@<proxmox-ip>

# Create a new privileged LXC container (Docker requires privileged mode)
pct create 200 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname uco-finacle \
  --memory 2048 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --storage local-lvm \
  --rootfs local-lvm:8 \
  --unprivileged 0 \
  --features nesting=1

# Start the container
pct start 200

# Enter the container
pct enter 200
```

### Step 2: Install Docker inside LXC

```bash
# Update and install dependencies
apt update && apt upgrade -y
apt install -y curl gnupg lsb-release ca-certificates

# Add Docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
systemctl enable docker
systemctl start docker
```

### Step 3: Transfer and Run the Image

**From your Mac:**
```bash
# Save the Docker image to a tar file
docker save uco-finacle:latest | gzip > uco-finacle.tar.gz

# Copy to Proxmox LXC (replace with your LXC IP)
scp uco-finacle.tar.gz root@<lxc-ip>:/root/
```

**Inside the LXC:**
```bash
# Load the Docker image
gunzip -c /root/uco-finacle.tar.gz | docker load

# Run the container
docker run -d \
  --name uco-finacle \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DB_HOST=10.1.92.130 \
  -e DB_PORT=1521 \
  -e DB_SERVICE=XEPDB1 \
  -e DB_USERNAME=system \
  -e DB_PASSWORD=Oracle123! \
  uco-finacle:latest

# Verify it's running
docker ps
```

### Step 4: Access the Application

Open browser: `http://<lxc-ip>:8080/`

---

## Option 2: Direct LXC (No Docker)

If you prefer native LXC without Docker overhead:

### Step 1: Create LXC with Tomcat

```bash
# On Proxmox host
pct create 201 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname uco-finacle-native \
  --memory 1024 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --storage local-lvm \
  --rootfs local-lvm:4

pct start 201
pct enter 201
```

### Step 2: Install Java & Tomcat

```bash
apt update && apt upgrade -y
apt install -y openjdk-11-jdk tomcat9

# Enable Tomcat
systemctl enable tomcat9
```

### Step 3: Deploy WAR file

**From your Mac:**
```bash
# Build the WAR
cd /Users/sidharthan/Documents/Uco-Finnacle-Site/java-webapp
mvn clean package -DskipTests

# Copy WAR to LXC
scp target/finacle.war root@<lxc-ip>:/var/lib/tomcat9/webapps/
```

**Inside LXC:**
```bash
# Restart Tomcat
systemctl restart tomcat9

# Check status
systemctl status tomcat9
```

Access: `http://<lxc-ip>:8080/finacle/fininfra/ui/SSOLogin.jsp`

---

## Quick Reference

| Method | Pros | Cons |
|--------|------|------|
| Docker in LXC | Portable, same as Mac | Requires privileged LXC |
| Native LXC | Lightweight, less overhead | Manual Tomcat setup |

## Firewall (if needed)

```bash
# On the LXC
apt install -y ufw
ufw allow 8080/tcp
ufw enable
```
