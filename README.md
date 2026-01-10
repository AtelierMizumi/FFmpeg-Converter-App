# FFmpeg Converter App (flutter_test_application)

![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20Web-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Development-orange)

An efficient, cross-platform video conversion application built with Flutter and FFmpeg. This tool allows you to easily convert video formats, adjust quality, resize resolutions, and modify audio settings with a simple and intuitive user interface.

---

## 🇬🇧 English

### Description
The FFmpeg Converter App is a powerful desktop and web application designed to simplify video processing tasks. Whether you need to compress a video for the web, change containers (e.g., MP4 to MKV), or strip audio, this app provides a GUI wrapper around the robust FFmpeg library.

### Key Features
- **Drag & Drop Support**: Easily drag video files directly into the application to start processing.
- **Format Flexibility**: Support for popular containers including `MP4`, `WebM`, `MKV`, and `MOV`.
- **Quality Control**: Adjustable CRF (Constant Rate Factor) and preset speeds (Success/Speed balance).
- **Resolution Scaling**: Quickly resize videos to 1080p, 720p, or 480p, or keep original dimensions.
- **Audio Management**: Options to transcode audio (AAC), copy existing stream (no quality loss), or mute audio entirely.
- **Video Comparison**: Built-in tool to compare the original and processed videos.
- **Multi-language Support**: Available in English, Vietnamese, German, and Japanese.

### Getting Started

#### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [FFmpeg](https://ffmpeg.org/) (Required for Linux runtimes if not bundled in your specific distro configuration, though often handled by the app's internal logic or system calls).

#### Installation & Running
1. **Clone the repository:**
   ```bash
   git clone https://github.com/AtelierMizumi/flutter_test_application.git
   cd flutter_test_application
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   - **Linux:**
     ```bash
     flutter run -d linux
     ```
   - **Windows:**
     ```bash
     flutter run -d windows
     ```

### Usage
1. **Select a File**: Click to browse or drag and drop a video file onto the "Select File" area.
2. **Choose Output Folder**: (Desktop only) Select a destination folder for your converted file.
3. **Configure Settings**:
   - Select your desired **Container** (e.g., MP4).
   - Adjust **Video Codec**, **Preset**, and **Quality (CRF)**.
   - Choose a target **Resolution**.
   - Set **Audio** preferences.
4. **Convert**: Click the **Start Conversion** button.
5. **Review**: Once finished, you can view the output file or compare it with the original.

---

## 🇻🇳 Tiếng Việt

### Mô tả
FFmpeg Converter App là ứng dụng đa nền tảng (Desktop/Web) mạnh mẽ giúp đơn giản hóa việc xử lý video. Cho dù bạn cần nén video để đăng tải web, đổi định dạng đuôi file (ví dụ: MP4 sang MKV), hay loại bỏ âm thanh, ứng dụng sẽ cung cấp một giao diện trực quan tận dụng sức mạnh của thư viện FFmpeg.

### Tính năng chính
- **Kéo & Thả**: Dễ dàng kéo file video trực tiếp vào ứng dụng để bắt đầu xử lý.
- **Đa dạng định dạng**: Hỗ trợ các container phổ biến như `MP4`, `WebM`, `MKV`, và `MOV`.
- **Kiểm soát chất lượng**: Tuỳ chỉnh chỉ số CRF (Chất lượng) và Preset (Tốc độ nén).
- **Thay đổi độ phân giải**: Dễ dàng resize video về 1080p, 720p, 480p hoặc giữ nguyên gốc.
- **Quản lý âm thanh**: Tuỳ chọn mã hoá lại âm thanh (AAC), copy stream gốc (không mất chất lượng), hoặc tắt tiếng (Mute).
- **So sánh Video**: Công cụ tích hợp giúp so sánh video gốc và video sau khi xử lý.
- **Đa ngôn ngữ**: Hỗ trợ tiếng Anh, tiếng Việt, tiếng Đức và tiếng Nhật.

### Cài đặt & Bắt đầu

#### Yêu cầu
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [FFmpeg](https://ffmpeg.org/) (Cần thiết cho Linux nếu chưa được cấu hình sẵn trong hệ thống).

#### Cài đặt & Chạy ứng dụng
1. **Clone repository:**
   ```bash
   git clone https://github.com/AtelierMizumi/flutter_test_application.git
   cd flutter_test_application
   ```

2. **Cài đặt thư viện:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng:**
   - **Linux:**
     ```bash
     flutter run -d linux
     ```
   - **Windows:**
     ```bash
     flutter run -d windows
     ```

### Hướng dẫn sử dụng
1. **Chọn File**: Nhấn vào khu vực chọn file hoặc kéo thả video vào đó.
2. **Chọn thư mục lưu**: (Dành cho Desktop) Chọn thư mục nơi file sau khi convert sẽ được lưu.
3. **Cấu hình**:
   - Chọn **Container** (Đuôi file) mong muốn (ví dụ: MP4).
   - Điều chỉnh **Video Codec**, **Preset**, và **Chất lượng (CRF)**.
   - Chọn **Độ phân giải** output.
   - Cài đặt **Âm thanh** (Mặc định, Copy hoặc Tắt tiếng).
4. **Chuyển đổi**: Nhấn nút bắt đầu chuyển đổi (Start/Convert).
5. **Xem kết quả**: Sau khi hoàn tất, bạn có thể xem file kết quả hoặc so sánh trực tiếp với file gốc.

---

Built with ❤️ using [Flutter](https://flutter.dev)
