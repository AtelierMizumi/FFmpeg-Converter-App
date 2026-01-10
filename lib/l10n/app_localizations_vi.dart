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
}
