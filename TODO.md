# TODO List - FFmpeg Converter App

Danh sách các task cần thực hiện và cải thiện cho dự án.

**Cập nhật**: February 2026  
**Tổng số task**: 30 items  
**Trạng thái**: 2 commits chờ push

---

## 🔴 CRITICAL PRIORITY (Ngay lập tức)

### critical-1: Push commits to GitHub
- **Mô tả**: Push 2 commits đã hoàn thành lên GitHub
- **Chi tiết**:
  - Commit 1: `08dd601` - Bug fixes và mobile stability
  - Commit 2: `c8738c0` - Documentation (SETUP.md, DEVELOPMENT.md)
- **Lý do**: Trigger CI/CD tests, đồng bộ code với team
- **Lệnh**:
  ```bash
  git push origin main
  ```
- **Thời gian ước tính**: 5 phút
- **Phụ thuộc**: Không

### critical-2: Fix code analysis warnings
- **Mô tả**: Sửa 33 warnings từ `flutter analyze`
- **Chi tiết**:
  - 4 unused imports
  - 23 `avoid_print` warnings (dùng `print()` thay vì `debugPrint()`)
  - 4 deprecated API warnings
  - 2 code style issues
- **Lý do**: Clean code, pass CI/CD analysis
- **File cần sửa**:
  - `lib/main.dart` - Unused import `dart:io`
  - `lib/services/analytics_service.dart` - 7 print statements
  - `lib/services/error_reporter.dart` - 4 print statements
  - `lib/services/event_tracker.dart` - 1 print statement
  - `lib/services/network_service.dart` - 11 print statements
  - `lib/ui/editor/editor_tab.dart` - Unused import, style issues
  - `lib/ui/landing/landing_page.dart` - Deprecated `.withOpacity()`
  - `test/services/ffmpeg_service_mobile_test.dart` - Unused imports/variables
- **Thời gian ước tính**: 1-2 giờ
- **Phụ thuộc**: Không

---

## 🟠 HIGH PRIORITY (Tuần này)

### high-1: Replace print() with debugPrint()
- **Mô tả**: Thay thế tất cả `print()` bằng `debugPrint()` trong analytics services
- **Lý do**: 
  - `debugPrint()` throttles output, tránh crash khi log quá nhiều
  - Best practice cho production code
  - Pass linting rules
- **File cần sửa**: 4 files (analytics_service, error_reporter, event_tracker, network_service)
- **Thời gian ước tính**: 30 phút
- **Phụ thuộc**: critical-2

### high-2: Update outdated dependencies
- **Mô tả**: Cập nhật 7 packages có phiên bản mới
- **Packages cần update**:
  - `connectivity_plus`: 6.1.5 → 7.0.0 (major update)
  - `device_info_plus`: 10.1.2 → 12.3.0 (major update)
  - `package_info_plus`: 8.3.1 → 9.0.0 (major update)
  - `cross_file`: 0.3.5+1 → 0.3.5+2
  - `file_picker`: 10.3.8 → 10.3.10
- **Lưu ý**: Major updates cần test kỹ để tránh breaking changes
- **Lệnh**:
  ```bash
  flutter pub upgrade
  flutter test  # Verify no breaking changes
  ```
- **Thời gian ước tính**: 1 giờ (bao gồm testing)
- **Phụ thuộc**: Không

### high-3: Remove unused imports
- **Mô tả**: Xóa các import không sử dụng
- **File cần sửa**:
  - `lib/main.dart` - `import 'dart:io'`
  - `lib/ui/editor/editor_tab.dart` - `import 'package:url_launcher/url_launcher.dart'`
  - `test/services/ffmpeg_service_mobile_test.dart` - `cross_file`, `dart:typed_data`
- **Thời gian ước tính**: 15 phút
- **Phụ thuộc**: Không

### high-4: Add integration tests
- **Mô tả**: Tạo integration tests cho complete workflows
- **Scenarios cần test**:
  - Complete conversion workflow (select file → convert → verify output)
  - Video trimming workflow
  - Video merging workflow
  - Permission handling on Android
  - Error handling and recovery
- **File mới**:
  - `integration_test/app_test.dart`
  - `integration_test/conversion_test.dart`
  - `integration_test/editor_test.dart`
- **Thời gian ước tính**: 4-6 giờ
- **Phụ thuộc**: Không

### high-5: Implement retry mechanism for failed conversions
- **Mô tả**: Tự động retry khi conversion fails
- **Features**:
  - Retry up to 3 times with exponential backoff
  - User can manually retry
  - Show retry count in UI
  - Log retry attempts for analytics
- **File cần tạo/sửa**:
  - `lib/services/retry_service.dart` (new)
  - `lib/services/ffmpeg_service_*.dart` (modify)
  - `lib/ui/tabs/converter_tab.dart` (add retry button)
- **Thời gian ước tính**: 3-4 giờ
- **Phụ thuộc**: Không

---

## 🟡 MEDIUM PRIORITY (Tháng này)

### medium-1: Add proper logging framework
- **Mô tả**: Implement structured logging system
- **Solution**: Sử dụng package `logger` hoặc `logging`
- **Features**:
  - Different log levels (DEBUG, INFO, WARNING, ERROR)
  - File logging for production
  - Console logging for development
  - Log rotation to prevent disk fill
  - Integration với analytics
- **File cần tạo**:
  - `lib/services/logger_service.dart`
- **Thời gian ước tính**: 4-5 giờ
- **Phụ thuộc**: high-1

### medium-2: Implement conversion queue system
- **Mô tả**: Batch processing cho multiple files
- **Features**:
  - Add multiple files to queue
  - Process one by one automatically
  - Show queue status in UI
  - Pause/resume queue
  - Drag to reorder queue
  - Skip/remove items from queue
- **File cần tạo/sửa**:
  - `lib/models/conversion_job.dart` (new)
  - `lib/services/queue_service.dart` (new)
  - `lib/ui/tabs/queue_tab.dart` (new - new tab in app)
  - `lib/main.dart` (add queue tab)
- **Thời gian ước tính**: 6-8 giờ
- **Phụ thuộc**: Không

### medium-3: Add codec presets explanation tooltips
- **Mô tả**: Giải thích các settings cho users
- **Chi tiết**:
  - Tooltip cho từng codec (H.264, H.265, VP9, AV1)
  - Giải thích preset (ultrafast → veryslow)
  - Giải thích CRF values
  - Recommendations dựa trên use case
- **File cần sửa**:
  - `lib/ui/tabs/converter_tab.dart` (add Tooltip widgets)
  - `lib/l10n/app_*.arb` (add translations)
- **Thời gian ước tính**: 2-3 giờ
- **Phụ thuộc**: Không

### medium-4: Improve progress calculation accuracy
- **Mô tả**: Better progress estimation cho different codecs
- **Vấn đề hiện tại**: Progress dựa trên time, không accurate cho all codecs
- **Solution**:
  - Track frame count instead of just time
  - Different calculation for each codec
  - Estimate remaining time
  - Show current speed (fps)
- **File cần sửa**:
  - `lib/services/ffmpeg_service_desktop.dart`
  - `lib/services/ffmpeg_service_mobile.dart`
  - `lib/ui/tabs/converter_tab.dart` (show more details)
- **Thời gian ước tính**: 3-4 giờ
- **Phụ thuộc**: Không

### medium-5: Add output file preview/thumbnail
- **Mô tả**: Generate và show preview của output file
- **Features**:
  - Generate thumbnail sau khi convert xong
  - Show thumbnail trong history
  - Quick preview without opening full file
  - Generate animated GIF preview
- **Packages cần thêm**: `video_thumbnail`, `flutter_image_compress`
- **File cần tạo/sửa**:
  - `lib/services/thumbnail_service.dart` (new)
  - `lib/ui/widgets/video_thumbnail.dart` (new)
  - `lib/ui/tabs/converter_tab.dart` (show thumbnail)
- **Thời gian ước tính**: 4-5 giờ
- **Phụ thuộc**: Không

### medium-6: Implement conversion history
- **Mô tả**: Track conversion history với local storage
- **Features**:
  - Save conversion parameters
  - Save input/output file paths
  - Save timestamps
  - Save file sizes (before/after)
  - Show savings (compression ratio)
  - Export history as CSV
  - Clear history option
- **Packages cần thêm**: `sqflite` hoặc `hive`
- **File cần tạo**:
  - `lib/models/conversion_history.dart`
  - `lib/services/history_service.dart`
  - `lib/ui/tabs/history_tab.dart`
- **Thời gian ước tính**: 5-6 giờ
- **Phụ thuộc**: Không

### medium-7: Add dark mode support
- **Mô tả**: Implement dark theme
- **Features**:
  - System theme detection
  - Manual theme toggle
  - Persist theme preference
  - Smooth theme transition
  - Theme preview
- **File cần sửa**:
  - `lib/main.dart` (add ThemeMode)
  - `lib/config/theme_config.dart` (new - define dark theme)
  - `lib/services/preferences_service.dart` (save theme preference)
- **Thời gian ước tính**: 3-4 giờ
- **Phụ thuộc**: Không

### medium-8: Create iOS build configuration
- **Mô tả**: Setup và test iOS builds
- **Tasks**:
  - Configure iOS project settings
  - Setup code signing (development)
  - Test on iOS simulator
  - Test on physical iPhone
  - Add iOS to CI/CD pipeline
  - Create iOS release workflow
- **Yêu cầu**: macOS machine, Xcode, Apple Developer account
- **File cần sửa**:
  - `ios/Runner.xcodeproj/project.pbxproj`
  - `ios/Runner/Info.plist`
  - `.github/workflows/build_and_release.yml`
- **Thời gian ước tính**: 4-6 giờ
- **Phụ thuộc**: macOS environment

### ui-2: Add conversion presets
- **Mô tả**: Quick presets cho common use cases
- **Presets**:
  - **Fast**: ultrafast preset, CRF 28, 720p
  - **Balanced**: medium preset, CRF 23, 1080p
  - **Quality**: slow preset, CRF 18, original resolution
  - **Mobile**: H.264, superfast, CRF 25, 720p, AAC audio
  - **Web**: VP9, medium, CRF 30, 1080p, optimize for streaming
  - **Archive**: H.265, slow, CRF 20, original, preserve quality
- **File cần tạo/sửa**:
  - `lib/models/conversion_preset.dart` (new)
  - `lib/ui/tabs/converter_tab.dart` (add preset selector)
- **Thời gian ước tính**: 3-4 giờ
- **Phụ thuộc**: Không

### ui-3: Implement multi-file drag-and-drop
- **Mô tả**: Support dragging multiple files at once
- **Features**:
  - Accept multiple files in one drag
  - Show all files in list
  - Batch convert all files
  - Individual progress for each file
  - Cancel individual files
- **File cần sửa**:
  - `lib/ui/tabs/converter_tab.dart`
- **Thời gian ước tính**: 3-4 giờ
- **Phụ thuộc**: medium-2 (queue system)

### perf-1: Optimize memory usage
- **Mô tả**: Reduce memory footprint during large conversions
- **Optimizations**:
  - Stream processing instead of loading full file
  - Dispose resources properly
  - Implement memory pooling
  - Monitor memory usage
  - Automatic GC triggering for large files
  - Warning khi memory usage cao
- **File cần sửa**:
  - All `ffmpeg_service_*.dart` files
  - `lib/services/memory_monitor.dart` (new)
- **Thời gian ước tính**: 5-6 giờ
- **Phụ thuộc**: medium-1 (logging)

### perf-2: Implement hardware acceleration
- **Mô tả**: Detect và sử dụng hardware acceleration
- **Features**:
  - Detect GPU capabilities (NVENC, QuickSync, AMD VCE)
  - Use hardware encoders when available
  - Fallback to software encoding if hardware fails
  - Show acceleration status in UI
  - Performance comparison (HW vs SW)
- **FFmpeg flags**:
  - NVIDIA: `-c:v h264_nvenc`
  - Intel: `-c:v h264_qsv`
  - AMD: `-c:v h264_amf`
  - Apple: `-c:v h264_videotoolbox`
- **File cần tạo/sửa**:
  - `lib/services/hardware_detector.dart` (new)
  - `lib/services/ffmpeg_service_desktop.dart` (add HW encoder support)
- **Thời gian ước tính**: 6-8 giờ
- **Phụ thuộc**: Không

### test-1: Increase test coverage
- **Mô tả**: Aim for 80%+ code coverage
- **Current coverage**: Unknown (chạy `flutter test --coverage` để check)
- **Areas cần thêm tests**:
  - Analytics services (currently no tests)
  - Video validator (no tests)
  - Desktop FFmpeg service (no tests)
  - Web FFmpeg service (no tests)
  - UI widgets (minimal tests)
  - Edge cases và error scenarios
- **Thời gian ước tính**: 8-10 giờ
- **Phụ thuộc**: Không

### test-2: Add end-to-end tests
- **Mô tả**: Complete workflow testing
- **Scenarios**:
  - Full conversion with real video files
  - Permission flows on Android
  - File picker integration
  - Video comparison feature
  - Settings persistence
  - Multi-language support
- **Package**: `integration_test`
- **File cần tạo**:
  - `integration_test/e2e_test.dart`
  - `integration_test/android_permissions_test.dart`
- **Thời gian ước tính**: 6-8 giờ
- **Phụ thuộc**: high-4

---

## 🟢 LOW PRIORITY (Future)

### low-1: Add analytics events
- **Mô tả**: Track conversion success/failure rates
- **Events cần track**:
  - Conversion started
  - Conversion completed
  - Conversion failed (with error type)
  - Average conversion time per codec
  - Popular codecs/formats
  - User settings preferences
- **File cần sửa**:
  - `lib/services/ffmpeg_service_*.dart` (add tracking)
  - `lib/services/analytics_service.dart` (add events)
- **Thời gian ước tính**: 2-3 giờ
- **Phụ thuộc**: medium-1

### low-2: App rating prompt
- **Mô tả**: Prompt users to rate app sau khi sử dụng
- **Trigger conditions**:
  - After 5 successful conversions
  - Only show once every 30 days
  - Only if user hasn't rated
- **Package**: `in_app_review`
- **Thời gian ước tính**: 2 giờ
- **Phụ thuộc**: medium-6 (history)

### low-3: Keyboard shortcuts
- **Mô tả**: Desktop keyboard shortcuts
- **Shortcuts**:
  - `Ctrl+O`: Open file
  - `Ctrl+S`: Select output folder
  - `Ctrl+Enter`: Start conversion
  - `Ctrl+P`: Pause conversion
  - `Esc`: Cancel conversion
  - `Ctrl+,`: Open settings
  - `F1`: Open help
- **Package**: `flutter_keyboard_shortcuts`
- **Thời gian ước tính**: 2-3 giờ
- **Phụ thuộc**: Không

### low-4: Video tutorial
- **Mô tả**: Tạo video hướng dẫn sử dụng
- **Content**:
  - Basic conversion tutorial (3-5 phút)
  - Advanced features tutorial (5-7 phút)
  - Tips & tricks (3-5 phút)
  - Troubleshooting common issues (3-5 phút)
- **Platform**: YouTube
- **Ngôn ngữ**: English, Vietnamese
- **Thời gian ước tính**: 8-10 giờ (quay, edit, upload)
- **Phụ thuộc**: Không

### low-5: Custom output filename templates
- **Mô tả**: Allow users to customize output filenames
- **Template variables**:
  - `{name}`: Original filename
  - `{date}`: Current date
  - `{time}`: Current time
  - `{codec}`: Video codec
  - `{resolution}`: Output resolution
  - `{format}`: Output format
- **Example**: `{name}_converted_{date}_{codec}.{format}`
- **File cần tạo/sửa**:
  - `lib/services/filename_template_service.dart` (new)
  - `lib/ui/tabs/converter_tab.dart` (add template editor)
- **Thời gian ước tính**: 3-4 giờ
- **Phụ thuộc**: Không

### perf-3: Multi-threading for batch
- **Mô tả**: Convert multiple files simultaneously
- **Features**:
  - User configurable (1-4 concurrent conversions)
  - Auto-detect CPU cores
  - Balance between speed and system load
  - Priority queue
- **Thời gian ước tính**: 4-5 giờ
- **Phụ thuộc**: medium-2 (queue system)

### ui-1: Material Design 3 redesign
- **Mô tả**: Update UI to Material Design 3
- **Changes**:
  - New color schemes
  - Updated typography
  - Modern components (Cards, Buttons, etc.)
  - Better spacing and alignment
  - Improved animations
- **Thời gian ước tính**: 10-12 giờ
- **Phụ thuộc**: Không

### doc-1: API documentation
- **Mô tả**: Generate dartdoc cho code
- **Tasks**:
  - Add doc comments to all public APIs
  - Generate dartdoc HTML
  - Host on GitHub Pages hoặc pub.dev
  - Add examples trong comments
- **Lệnh**:
  ```bash
  dart doc .
  ```
- **Thời gian ước tính**: 6-8 giờ
- **Phụ thuộc**: Không

### doc-2: User manual
- **Mô tả**: Comprehensive user guide
- **Content**:
  - Installation guide
  - Feature explanations
  - Step-by-step tutorials
  - FAQ
  - Troubleshooting
  - Best practices
- **Format**: Markdown + PDF export
- **Thời gian ước tính**: 8-10 giờ
- **Phụ thuộc**: Không

---

## 📊 Thống kê

### Theo Priority
- **CRITICAL**: 2 tasks
- **HIGH**: 5 tasks
- **MEDIUM**: 15 tasks
- **LOW**: 8 tasks
- **Total**: 30 tasks

### Theo Category
- **Code Quality**: 5 tasks
- **Features**: 12 tasks
- **Performance**: 3 tasks
- **Testing**: 4 tasks
- **Documentation**: 2 tasks
- **UI/UX**: 4 tasks

### Thời gian ước tính tổng
- **CRITICAL**: 1-2 giờ
- **HIGH**: 10-15 giờ
- **MEDIUM**: 70-85 giờ
- **LOW**: 55-70 giờ
- **Total**: 136-172 giờ (~3-4 tuần full-time)

---

## 🎯 Roadmap Đề xuất

### Sprint 1 (Tuần 1): Code Quality & Stability
1. ✅ Push commits to GitHub
2. ✅ Fix code analysis warnings
3. ✅ Remove unused imports
4. ✅ Replace print() with debugPrint()
5. ✅ Update outdated dependencies
6. ✅ Add integration tests

**Goal**: Clean codebase, pass all CI/CD checks

### Sprint 2 (Tuần 2): Core Features
1. ✅ Implement retry mechanism
2. ✅ Add proper logging framework
3. ✅ Add codec tooltips
4. ✅ Add conversion presets
5. ✅ Improve progress calculation

**Goal**: Better user experience, fewer errors

### Sprint 3 (Tuần 3): Advanced Features
1. ✅ Implement queue system
2. ✅ Add conversion history
3. ✅ Multi-file drag-and-drop
4. ✅ Output file thumbnails
5. ✅ Dark mode support

**Goal**: Power user features

### Sprint 4 (Tuần 4): Performance & Polish
1. ✅ Optimize memory usage
2. ✅ Hardware acceleration
3. ✅ Increase test coverage
4. ✅ iOS build setup
5. ✅ UI polish

**Goal**: Production-ready quality

### Future Sprints: Nice-to-have
- Analytics events
- App rating
- Keyboard shortcuts
- Video tutorials
- Material Design 3
- API documentation
- User manual

---

## 📝 Notes

### Breaking Changes to Watch
- `connectivity_plus` 6.x → 7.x: API changes
- `device_info_plus` 10.x → 12.x: API changes
- `package_info_plus` 8.x → 9.x: API changes

### Testing Requirements
- All new features must have unit tests
- Critical paths must have integration tests
- UI changes need widget tests
- Aim for 80%+ code coverage

### Code Review Checklist
- [ ] No `print()` statements
- [ ] No unused imports
- [ ] All warnings fixed
- [ ] Tests added
- [ ] Documentation updated
- [ ] Changelog updated

---

**Last Updated**: February 2026  
**Maintained by**: Development Team
