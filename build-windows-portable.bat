@echo off
REM Script to build portable Windows package

echo Building Windows application...
flutter build windows --release

if %errorlevel% neq 0 (
    echo Build failed!
    exit /b 1
)

echo.
echo Creating portable package...

cd build\windows\x64\runner\Release

REM Rename executable to user-friendly name
if exist flutter_test_application.exe (
    ren flutter_test_application.exe FFmpeg-Converter.exe
    echo ✅ Renamed to FFmpeg-Converter.exe
)

REM Create README with better formatting
(
echo ╔══════════════════════════════════════════════╗
echo ║   FFmpeg Converter - Windows Portable       ║
echo ╚══════════════════════════════════════════════╝
echo.
echo 🚀 CÁCH CHẠY:
echo.
echo Double-click vào: FFmpeg-Converter.exe
echo.
echo Đơn giản vậy thôi!
echo.
echo ─────────────────────────────────────────────
echo.
echo 📌 TẠO SHORTCUT:
echo.
echo 1. Chuột phải vào FFmpeg-Converter.exe
echo 2. Chọn "Send to" -^> "Desktop ^(create shortcut^)"
echo 3. Giờ bạn có thể chạy từ Desktop!
echo.
echo ─────────────────────────────────────────────
echo.
echo ℹ️  LƯU Ý:
echo.
echo - Giữ tất cả files trong cùng thư mục này
echo - Không xóa các file .dll và thư mục data/
echo - Có thể copy toàn bộ thư mục sang máy khác
echo.
echo ─────────────────────────────────────────────
echo.
echo 📦 Portable Version - No Installation Required
) > README.txt

cd ..\..\..\..\..\

REM Create ZIP using PowerShell
powershell -Command "Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'FFmpeg-Converter-Windows-Portable.zip' -Force"

echo.
echo ✅ Build complete!
echo 📦 Package: FFmpeg-Converter-Windows-Portable.zip
echo.
echo Khi giải nén, bạn sẽ thấy:
echo   - FFmpeg-Converter.exe  ^(file chính để chạy^)
echo   - README.txt           ^(hướng dẫn^)
echo   - Các file .dll và thư mục data/ ^(dependencies^)
echo.
echo 💡 Tip: Giải nén và double-click FFmpeg-Converter.exe để chạy!
echo.
pause
