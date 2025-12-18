# UCO Bank Finacle Simulator - Docker Image
# Multi-stage build for optimized image size

# Stage 1: Build the WAR file
FROM maven:3.9-eclipse-temurin-11 AS builder

WORKDIR /build

# Copy pom.xml first for dependency caching
COPY java-webapp/pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY java-webapp/src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime with Tomcat
FROM tomcat:9.0-jdk11-temurin

LABEL maintainer="UCO Bank IT Team"
LABEL description="UCO Bank CBS Finacle Browser Application Simulator"

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file from builder stage
COPY --from=builder /build/target/finacle.war /usr/local/tomcat/webapps/finacle.war

# Copy static assets and index redirect to ROOT
COPY static /usr/local/tomcat/webapps/ROOT/

# Environment variables for database configuration
ENV DB_HOST=10.1.92.130
ENV DB_PORT=1521
ENV DB_SERVICE=XEPDB1
ENV DB_USERNAME=system
ENV DB_PASSWORD=Oracle123!

# Expose Tomcat port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/finacle/fininfra/ui/SSOLogin.jsp || exit 1

# Start Tomcat
CMD ["catalina.sh", "run"]
