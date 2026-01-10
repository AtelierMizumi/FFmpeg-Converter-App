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
      'Bitte wählen Sie vor der Verarbeitung einen Exportordner!';
}
