#!/bin/bash
# Script to build Android APK with Java 17

# Try to find Java 17 installation (Temurin or OpenJDK)
if [ -d "/usr/lib/jvm/java-17-temurin" ]; then
    JAVA17_HOME="/usr/lib/jvm/java-17-temurin"
elif [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
    JAVA17_HOME="/usr/lib/jvm/java-17-openjdk"
else
    echo "Error: Java 17 is not installed"
    echo "Please install it with: sudo pacman -S jdk17-temurin or jdk17-openjdk"
    exit 1
fi

# Set JAVA_HOME to Java 17
export JAVA_HOME=$JAVA17_HOME
export PATH=$JAVA_HOME/bin:$PATH

echo "Using Java version:"
java -version

echo ""
echo "Building Android APK..."
flutter build apk --release "$@"

echo ""
echo "Build complete!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
