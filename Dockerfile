# Build stage - Gradle 7.3 requires JDK 17 or lower
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app

COPY . .

# Build the Linux distribution - no Windows exe involved
RUN ./gradlew installDist --no-daemon

# Runtime stage - use OpenJDK 25 as requested
FROM eclipse-temurin:25-jdk

# Install X11 libraries and fonts for Java GUI
RUN apt-get update && apt-get install -y \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libfreetype6 \
    fonts-dejavu \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only the built distribution (jar, libs, scripts, data dirs)
COPY --from=builder /app/build/install/pcgen/ .

# Ensure the Linux launch script is executable
RUN chmod +x bin/pcgen

# Add persistent volume to store local config
VOLUME ["/root/.pcgen"]

ENTRYPOINT ["bin/pcgen"]
