// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FFmpeg Converter Pro';

  @override
  String get tabConverter => 'Converter';

  @override
  String get tabGuide => 'Guide';

  @override
  String get tabAbout => 'About';

  @override
  String get dragDropText => 'Drag & drop video here\nor click to pick file';

  @override
  String fileSelected(Object filename) {
    return 'Selected:\n$filename';
  }

  @override
  String get pickOutputFolder => 'Export Folder';

  @override
  String get notSelected => 'Not selected...';

  @override
  String get startConversion => 'Start Conversion';

  @override
  String get processing => 'Processing...';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusSuccess => 'Success! Output ready.';

  @override
  String statusError(Object error) {
    return 'Error: $error';
  }

  @override
  String get saveOutput => 'Save Output';

  @override
  String get compareVideo => 'Visual Comparison';

  @override
  String get settingsTitle => 'Encode Settings';

  @override
  String get containerFormat => 'Container Format';

  @override
  String get videoCodec => 'Video Codec';

  @override
  String get resolution => 'Resolution';

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get presetSpeed => 'Preset (Speed)';

  @override
  String qualityCrf(Object crf) {
    return 'Video Quality (CRF): $crf';
  }

  @override
  String get lowerBetter => 'Lower = Better Quality (Larger Size)';

  @override
  String get original => 'Original';

  @override
  String get newFile => 'New';

  @override
  String get folderExportRequired =>
      'Please select Export Folder before processing!';
}
