import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ja'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg Converter Pro'**
  String get appTitle;

  /// No description provided for @tabConverter.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get tabConverter;

  /// No description provided for @tabGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get tabGuide;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tabAbout;

  /// No description provided for @dragDropText.
  ///
  /// In en, this message translates to:
  /// **'Drag & drop video here\nor click to pick file'**
  String get dragDropText;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected:\n{filename}'**
  String fileSelected(Object filename);

  /// No description provided for @pickOutputFolder.
  ///
  /// In en, this message translates to:
  /// **'Export Folder'**
  String get pickOutputFolder;

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected...'**
  String get notSelected;

  /// No description provided for @startConversion.
  ///
  /// In en, this message translates to:
  /// **'Start Conversion'**
  String get startConversion;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success! Output ready.'**
  String get statusSuccess;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String statusError(Object error);

  /// No description provided for @saveOutput.
  ///
  /// In en, this message translates to:
  /// **'Save Output'**
  String get saveOutput;

  /// No description provided for @compareVideo.
  ///
  /// In en, this message translates to:
  /// **'Visual Comparison'**
  String get compareVideo;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Encode Settings'**
  String get settingsTitle;

  /// No description provided for @containerFormat.
  ///
  /// In en, this message translates to:
  /// **'Container Format'**
  String get containerFormat;

  /// No description provided for @videoCodec.
  ///
  /// In en, this message translates to:
  /// **'Video Codec'**
  String get videoCodec;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @audioSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audioSettings;

  /// No description provided for @presetSpeed.
  ///
  /// In en, this message translates to:
  /// **'Preset (Speed)'**
  String get presetSpeed;

  /// No description provided for @qualityCrf.
  ///
  /// In en, this message translates to:
  /// **'Video Quality (CRF): {crf}'**
  String qualityCrf(Object crf);

  /// No description provided for @lowerBetter.
  ///
  /// In en, this message translates to:
  /// **'Lower = Better Quality (Larger Size)'**
  String get lowerBetter;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @newFile.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newFile;

  /// No description provided for @folderExportRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select Export Folder before processing!'**
  String get folderExportRequired;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide & Documentation'**
  String get guideTitle;

  /// No description provided for @guideIntro.
  ///
  /// In en, this message translates to:
  /// **'This application leverages FFmpeg to convert videos directly on your device (Web or Desktop) without processing data on a server.'**
  String get guideIntro;

  /// No description provided for @sectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Technical Settings'**
  String get sectionSettings;

  /// No description provided for @paramVideoCodec.
  ///
  /// In en, this message translates to:
  /// **'1. Video Codec'**
  String get paramVideoCodec;

  /// No description provided for @paramVideoCodecDesc.
  ///
  /// In en, this message translates to:
  /// **'The video encoder. Determines how image data is compressed.'**
  String get paramVideoCodecDesc;

  /// No description provided for @paramVideoCodecDetails.
  ///
  /// In en, this message translates to:
  /// **'- **H.264 (libx264):** Most popular, compatible with almost all devices. Good balance of speed and quality.\n- **H.265 (libx265):** Higher compression efficiency than H.264 (about 50% smaller files). Requires more processing power to encode/decode.\n- **VP9 (libvpx-vp9):** Google\'s open source codec, often used for Web/YouTube. Better compression than H.264 but slower encoding.\n- **AV1 (libaom-av1):** Next-gen codec. Best compression, royalty-free, but very slow encoding without hardware acceleration.\n- **MPEG-4 (libxvid):** Older standard. Very high compatibility with legacy devices, but less efficient compression.'**
  String get paramVideoCodecDetails;

  /// No description provided for @paramCrf.
  ///
  /// In en, this message translates to:
  /// **'2. Constant Rate Factor (CRF)'**
  String get paramCrf;

  /// No description provided for @paramCrfDesc.
  ///
  /// In en, this message translates to:
  /// **'The metric determining output video quality.'**
  String get paramCrfDesc;

  /// No description provided for @paramCrfDetails.
  ///
  /// In en, this message translates to:
  /// **'- Range: 0-51.\n- **0:** Lossless (No compression, huge file size).\n- **23:** Default (Balanced).\n- **18:** High Quality (Visually lossless).\n- **28:** Lower Quality (Smaller file size).\n *Rule: LOWER value = HIGHER quality = LARGER size.*'**
  String get paramCrfDetails;

  /// No description provided for @paramPreset.
  ///
  /// In en, this message translates to:
  /// **'3. Preset'**
  String get paramPreset;

  /// No description provided for @paramPresetDesc.
  ///
  /// In en, this message translates to:
  /// **'Compression Speed.'**
  String get paramPresetDesc;

  /// No description provided for @paramPresetDetails.
  ///
  /// In en, this message translates to:
  /// **'- **ultrafast/superfast:** Very fast, but larger output file for the same quality.\n- **medium:** Default. Balanced.\n- **slow/veryslow:** Very slow, but most efficient compression (smallest file for same quality).\n *Recommendation: \"medium\" or \"fast\" for general use.*'**
  String get paramPresetDetails;

  /// No description provided for @paramResolution.
  ///
  /// In en, this message translates to:
  /// **'4. Resolution'**
  String get paramResolution;

  /// No description provided for @paramResolutionDesc.
  ///
  /// In en, this message translates to:
  /// **'Resize video dimensions.'**
  String get paramResolutionDesc;

  /// No description provided for @paramResolutionDetails.
  ///
  /// In en, this message translates to:
  /// **'- **Original:** Keep original size.\n- **1080p/720p/480p:** Resize video height to specific value (width calculated automatically). Significantly reduces file size.'**
  String get paramResolutionDetails;

  /// No description provided for @sectionReferences.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get sectionReferences;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @technologies.
  ///
  /// In en, this message translates to:
  /// **'Technologies Used'**
  String get technologies;

  /// No description provided for @librariesLicenses.
  ///
  /// In en, this message translates to:
  /// **'Third Party Libraries & Licenses'**
  String get librariesLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ja', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
