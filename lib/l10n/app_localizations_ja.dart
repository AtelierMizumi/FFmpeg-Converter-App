// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FFmpeg コンバーター Pro';

  @override
  String get tabConverter => '変換';

  @override
  String get tabGuide => 'ガイド';

  @override
  String get tabAbout => '情報';

  @override
  String get dragDropText => 'ここに動画をドラッグ＆ドロップ\nまたはクリックしてファイルを選択';

  @override
  String fileSelected(Object filename) {
    return '選択中:\n$filename';
  }

  @override
  String get pickOutputFolder => '出力フォルダ (Export)';

  @override
  String get notSelected => '未選択...';

  @override
  String get startConversion => '変換開始';

  @override
  String get processing => '処理中...';

  @override
  String get statusReady => '準備完了';

  @override
  String get statusSuccess => '成功！ 出力準備完了。';

  @override
  String statusError(Object error) {
    return 'エラー: $error';
  }

  @override
  String get saveOutput => '結果を保存';

  @override
  String get compareVideo => '比較 (Visual Comparison)';

  @override
  String get settingsTitle => 'エンコード設定';

  @override
  String get containerFormat => 'コンテナ形式';

  @override
  String get videoCodec => 'ビデオコーデック';

  @override
  String get resolution => '解像度';

  @override
  String get audioSettings => '音声設定';

  @override
  String get presetSpeed => 'プリセット (速度)';

  @override
  String qualityCrf(Object crf) {
    return 'ビデオ品質 (CRF): $crf';
  }

  @override
  String get lowerBetter => '低いほど高品質 (ファイルサイズ大)';

  @override
  String get original => 'オリジナル';

  @override
  String get newFile => '新規';

  @override
  String get folderExportRequired => '処理前に出力フォルダを選択してください！';
}
