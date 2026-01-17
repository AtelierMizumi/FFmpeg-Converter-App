// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FFmpeg Konverter Pro';

  @override
  String get tabConverter => 'Konverter';

  @override
  String get tabEditor => 'Editor';

  @override
  String get tabGuide => 'Anleitung';

  @override
  String get tabAbout => 'Über';

  @override
  String get dragDropText => 'Video hierher ziehen\noder klicken zum Auswählen';

  @override
  String fileSelected(Object filename) {
    return 'Ausgewählt:\n$filename';
  }

  @override
  String get pickOutputFolder => 'Exportordner';

  @override
  String get notSelected => 'Nicht ausgewählt...';

  @override
  String get startConversion => 'Konvertierung starten';

  @override
  String get processing => 'Verarbeite...';

  @override
  String get statusReady => 'Bereit';

  @override
  String get statusSuccess => 'Erfolg! Ausgabe bereit.';

  @override
  String statusError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get saveOutput => 'Ausgabe speichern';

  @override
  String get compareVideo => 'Visueller Vergleich';

  @override
  String get settingsTitle => 'Kodierungseinstellungen';

  @override
  String get containerFormat => 'Container-Format';

  @override
  String get videoCodec => 'Video-Codec';

  @override
  String get resolution => 'Auflösung';

  @override
  String get audioSettings => 'Audio-Einstellungen';

  @override
  String get presetSpeed => 'Voreinstellung (Geschwindigkeit)';

  @override
  String qualityCrf(Object crf) {
    return 'Videoqualität (CRF): $crf';
  }

  @override
  String get lowerBetter => 'Niedriger = Bessere Qualität (Größere Datei)';

  @override
  String get original => 'Original';

  @override
  String get newFile => 'Neu';

  @override
  String get folderExportRequired =>
      'Bitte wählen Sie vor der Verarbeitung den Exportordner aus!';

  @override
  String get guideTitle => 'Benutzerhandbuch & Dokumentation';

  @override
  String get guideIntro =>
      'Diese Anwendung nutzt FFmpeg, um Videos direkt auf Ihrem Gerät (Web oder Desktop) zu konvertieren, ohne Daten an einen Server zu senden.';

  @override
  String get sectionSettings => 'Technische Einstellungen';

  @override
  String get paramVideoCodec => '1. Video Codec';

  @override
  String get paramVideoCodecDesc =>
      'Der Video-Encoder. Bestimmt, wie Bilddaten komprimiert werden.';

  @override
  String get paramVideoCodecDetails =>
      '- **H.264 (libx264):** Am beliebtesten, kompatibel mit fast allen Geräten. Gute Balance zwischen Geschwindigkeit und Qualität.\n- **H.265 (libx265):** Höhere Komprimierungseffizienz als H.264 (ca. 50% kleinere Dateien). Erfordert mehr Rechenleistung zum Enkodieren/Dekodieren.\n- **VP9 (libvpx-vp9):** Googles Open-Source-Codec, oft verwendet für Web/YouTube. Bessere Komprimierung als H.264, aber langsamere Codierung.\n- **AV1 (libaom-av1):** Codec der nächsten Generation. Beste Komprimierung, lizenzfrei, aber sehr langsame Kodierung ohne Hardwarebeschleunigung.\n- **MPEG-4 (libxvid):** Älterer Standard. Sehr hohe Kompatibilität mit älteren Geräten, aber weniger effiziente Komprimierung.';

  @override
  String get paramCrf => '2. Constant Rate Factor (CRF)';

  @override
  String get paramCrfDesc =>
      'Die Kennzahl, die die Ausgabequalität des Videos bestimmt.';

  @override
  String get paramCrfDetails =>
      '- Bereich: 0-51.\n- **0:** Verlustfrei (Keine Komprimierung, riesige Dateigröße).\n- **23:** Standard (Ausgewogen).\n- **18:** Hohe Qualität (Visuell verlustfrei).\n- **28:** Geringere Qualität (Kleinere Dateigröße).\n *Regel: NIEDRIGERER Wert = HÖHERE Qualität = GRÖSSERE Größe.*';

  @override
  String get paramPreset => '3. Preset';

  @override
  String get paramPresetDesc => 'Komprimierungsgeschwindigkeit.';

  @override
  String get paramPresetDetails =>
      '- **ultrafast/superfast:** Sehr schnell, aber größere Ausgabedatei bei gleicher Qualität.\n- **medium:** Standard. Ausgewogen.\n- **slow/veryslow:** Sehr langsam, aber effizienteste Komprimierung (kleinste Datei bei gleicher Qualität).\n *Empfehlung: \"medium\" oder \"fast\" für den allgemeinen Gebrauch.*';

  @override
  String get paramResolution => '4. Auflösung';

  @override
  String get paramResolutionDesc => 'Videodimensionen ändern.';

  @override
  String get paramResolutionDetails =>
      '- **Original:** Originalgröße beibehalten.\n- **1080p/720p/480p:** Videohöhe auf bestimmten Wert ändern (Breite automatisch berechnet). Reduziert die Dateigröße erheblich.';

  @override
  String get sectionReferences => 'Referenzen';

  @override
  String get developedBy => 'Entwickelt von';

  @override
  String get technologies => 'Verwendete Technologien';

  @override
  String get librariesLicenses => 'Drittanbieter-Bibliotheken & Lizenzen';

  @override
  String get trimVideo => 'Trim Video';

  @override
  String get mergeVideo => 'Merge Video';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get addClip => 'Add Clip';

  @override
  String get processMerge => 'Process Merge';

  @override
  String get processTrim => 'Process Trim';

  @override
  String get editorMode => 'Editor Mode';

  @override
  String get modeTrim => 'Trim Mode';

  @override
  String get modeMerge => 'Merge Mode';
}
