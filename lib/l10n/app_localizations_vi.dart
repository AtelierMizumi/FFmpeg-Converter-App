// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'FFmpeg Converter Pro';

  @override
  String get tabConverter => 'Chuyển đổi';

  @override
  String get tabGuide => 'Hướng dẫn';

  @override
  String get tabAbout => 'Thông tin';

  @override
  String get dragDropText => 'Kéo thả video vào đây\nhoặc click để chọn file';

  @override
  String fileSelected(Object filename) {
    return 'Đã chọn:\n$filename';
  }

  @override
  String get pickOutputFolder => 'Thư mục xuất file (Export)';

  @override
  String get notSelected => 'Chưa chọn thư mục...';

  @override
  String get startConversion => 'Bắt đầu chuyển đổi';

  @override
  String get processing => 'Đang xử lý...';

  @override
  String get statusReady => 'Sẵn sàng';

  @override
  String get statusSuccess => 'Thành công! File đã sẵn sàng.';

  @override
  String statusError(Object error) {
    return 'Lỗi: $error';
  }

  @override
  String get saveOutput => 'Lưu file kết quả';

  @override
  String get compareVideo => 'So sánh (Visual Comparison)';

  @override
  String get settingsTitle => 'Cấu hình Encode';

  @override
  String get containerFormat => 'Đuôi file (Container)';

  @override
  String get videoCodec => 'Video Codec';

  @override
  String get resolution => 'Độ phân giải';

  @override
  String get audioSettings => 'Thiết lập âm thanh';

  @override
  String get presetSpeed => 'Tốc độ (Preset)';

  @override
  String qualityCrf(Object crf) {
    return 'Chất lượng Video (CRF): $crf';
  }

  @override
  String get lowerBetter => 'Thấp hơn = Chất lượng tốt hơn (Dung lượng lớn)';

  @override
  String get original => 'Gốc';

  @override
  String get newFile => 'Mới';

  @override
  String get folderExportRequired =>
      'Vui lòng chọn thư mục lưu (Export Folder) trước khi xử lý!';

  @override
  String get guideTitle => 'Hướng dẫn sử dụng & Tài liệu';

  @override
  String get guideIntro =>
      'Ứng dụng này sử dụng sức mạnh của FFmpeg để chuyển đổi video trực tiếp trên thiết bị của bạn (Web hoặc Desktop) mà không cần gửi dữ liệu lên máy chủ.';

  @override
  String get sectionSettings => 'Các thông số kỹ thuật (Settings)';

  @override
  String get paramVideoCodec => '1. Video Codec';

  @override
  String get paramVideoCodecDesc =>
      'Bộ mã hóa video. Quyết định cách thức nén dữ liệu hình ảnh.';

  @override
  String get paramVideoCodecDetails =>
      '- **H.264 (libx264):** Phổ biến nhất, tương thích mọi thiết bị. Cân bằng tốt giữa tốc độ và chất lượng.\n- **VP9 (libvpx-vp9):** Codec mã nguồn mở của Google, thường dùng cho Web/YouTube. Nén tốt hơn H.264 nhưng encode chậm hơn.';

  @override
  String get paramCrf => '2. Constant Rate Factor (CRF)';

  @override
  String get paramCrfDesc => 'Chỉ số quyết định chất lượng video đầu ra.';

  @override
  String get paramCrfDetails =>
      '- Dải giá trị: 0-51.\n- **0:** Lossless (Không nén, dung lượng cực lớn).\n- **23:** Mặc định (Cân bằng).\n- **18:** Chất lượng cao (Gần như gốc).\n- **28:** Chất lượng thấp hơn (Dung lượng nhỏ).\n *Nguyên tắc: Giá trị càng NHỎ, chất lượng càng CAO, dung lượng càng LỚN.*';

  @override
  String get paramPreset => '3. Preset';

  @override
  String get paramPresetDesc => 'Tốc độ nén (Encoding Speed).';

  @override
  String get paramPresetDetails =>
      '- **ultrafast/superfast:** Rất nhanh, nhưng file output sẽ lớn hơn với cùng một chất lượng.\n- **medium:** Mặc định. Cân bằng.\n- **slow/veryslow:** Rất chậm, nhưng nén file hiệu quả nhất (file nhỏ nhất với cùng chất lượng).\n *Khuyên dùng: \"medium\" hoặc \"fast\" cho nhu cầu thông thường.*';

  @override
  String get paramResolution => '4. Resolution (Độ phân giải)';

  @override
  String get paramResolutionDesc => 'Thay đổi kích thước khung hình video.';

  @override
  String get paramResolutionDetails =>
      '- **Original:** Giữ nguyên gốc.\n- **1080p/720p/480p:** Resize video về chiều cao tương ứng (chiều rộng tự động tính theo tỉ lệ). Giúp giảm dung lượng đáng kể.';

  @override
  String get sectionReferences => 'Tài liệu tham khảo';

  @override
  String get developedBy => 'Phát triển bởi';

  @override
  String get technologies => 'Công nghệ sử dụng';

  @override
  String get librariesLicenses => 'Thư viện bên thứ ba & Giấy phép';
}
