#!/bin/bash
# Script to build portable Linux package

echo "Building Linux application..."
flutter build linux --release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Creating portable package..."

cd build/linux/x64/release/bundle

# Create a launch script
cat > ffmpeg-converter << 'EOF'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
exec "$SCRIPT_DIR/flutter_test_application" "$@"
EOF

chmod +x ffmpeg-converter

# Create README
cat > README.txt << 'EOF'
FFmpeg Converter - Linux Portable Version
==========================================

Installation:
1. Extract the tar.gz file (if not already extracted)
2. Run: ./ffmpeg-converter

Or double-click 'ffmpeg-converter' in your file manager.

Requirements:
- GTK3
- libmpv

Install on Ubuntu/Debian: sudo apt-get install libgtk-3-0 libmpv1
Install on Fedora: sudo dnf install gtk3 mpv-libs
Install on Arch: sudo pacman -S gtk3 mpv
EOF

cd ..
tar -czf ../../../../FFmpeg-Converter-Linux-Portable.tar.gz -C bundle .

cd ../../../..

echo ""
echo "✅ Build complete!"
echo "📦 Package: FFmpeg-Converter-Linux-Portable.tar.gz"
echo ""
echo "To test locally:"
echo "  cd build/linux/x64/release/bundle"
echo "  ./ffmpeg-converter"
