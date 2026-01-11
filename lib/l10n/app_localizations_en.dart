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

  @override
  String get guideTitle => 'User Guide & Documentation';

  @override
  String get guideIntro =>
      'This application leverages FFmpeg to convert videos directly on your device (Web or Desktop) without processing data on a server.';

  @override
  String get sectionSettings => 'Technical Settings';

  @override
  String get paramVideoCodec => '1. Video Codec';

  @override
  String get paramVideoCodecDesc =>
      'The video encoder. Determines how image data is compressed.';

  @override
  String get paramVideoCodecDetails =>
      '- **H.264 (libx264):** Most popular, compatible with almost all devices. Good balance of speed and quality.\n- **H.265 (libx265):** Higher compression efficiency than H.264 (about 50% smaller files). Requires more processing power to encode/decode.\n- **VP9 (libvpx-vp9):** Google\'s open source codec, often used for Web/YouTube. Better compression than H.264 but slower encoding.\n- **AV1 (libaom-av1):** Next-gen codec. Best compression, royalty-free, but very slow encoding without hardware acceleration.\n- **MPEG-4 (libxvid):** Older standard. Very high compatibility with legacy devices, but less efficient compression.';

  @override
  String get paramCrf => '2. Constant Rate Factor (CRF)';

  @override
  String get paramCrfDesc => 'The metric determining output video quality.';

  @override
  String get paramCrfDetails =>
      '- Range: 0-51.\n- **0:** Lossless (No compression, huge file size).\n- **23:** Default (Balanced).\n- **18:** High Quality (Visually lossless).\n- **28:** Lower Quality (Smaller file size).\n *Rule: LOWER value = HIGHER quality = LARGER size.*';

  @override
  String get paramPreset => '3. Preset';

  @override
  String get paramPresetDesc => 'Compression Speed.';

  @override
  String get paramPresetDetails =>
      '- **ultrafast/superfast:** Very fast, but larger output file for the same quality.\n- **medium:** Default. Balanced.\n- **slow/veryslow:** Very slow, but most efficient compression (smallest file for same quality).\n *Recommendation: \"medium\" or \"fast\" for general use.*';

  @override
  String get paramResolution => '4. Resolution';

  @override
  String get paramResolutionDesc => 'Resize video dimensions.';

  @override
  String get paramResolutionDetails =>
      '- **Original:** Keep original size.\n- **1080p/720p/480p:** Resize video height to specific value (width calculated automatically). Significantly reduces file size.';

  @override
  String get sectionReferences => 'References';

  @override
  String get developedBy => 'Developed by';

  @override
  String get technologies => 'Technologies Used';

  @override
  String get librariesLicenses => 'Third Party Libraries & Licenses';
}
