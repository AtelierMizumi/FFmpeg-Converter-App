# Reducing FFmpeg Asset Size

## Current Status
- Linux FFmpeg: 77MB
- Windows FFmpeg: 97MB
- Total: 174MB

## Solutions

### Option 1: Use Static Builds (Recommended)
Use statically-linked FFmpeg binaries with minimal codecs:
- Remove support for codecs not commonly used
- Disable features like filters, postprocessors
- Can reduce size by 60-70%

### Option 2: Download on First Run
- Don't bundle FFmpeg binaries in app
- Download them on first launch from CDN
- Pros: Smaller initial app size
- Cons: Requires internet, slower first launch

### Option 3: Use System FFmpeg (Desktop Only)
- Check if FFmpeg is installed on user's system
- Only bundle if not found
- Pros: No bundle needed for many users
- Cons: Version compatibility issues

### Option 4: Compress Binaries
- Use UPX (Ultimate Packer for eXecutables)
- Can reduce size by 50-60%
- Minimal performance impact

## Recommended Implementation

**Combined Approach:**
1. Try system FFmpeg first (desktop)
2. If not found, download minimal static build from CDN
3. Fallback to bundled compressed binary

## Commands to Reduce Binary Size

### For Linux (static build)
```bash
./configure \
  --disable-everything \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-gpl \
  --enable-static \
  --disable-shared \
  --prefix=release
make install
```

### Compress with UPX
```bash
upx --best --lzma ffmpeg
upx --best --lzma ffmpeg.exe
```

## Expected Results
- Linux: 77MB → ~25-35MB
- Windows: 97MB → ~35-45MB
- Total: 174MB → ~60-80MB (65% reduction)
