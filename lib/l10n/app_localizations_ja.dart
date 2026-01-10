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
  String get folderExportRequired => '処理の前にエクスポートフォルダを選択してください！';

  @override
  String get guideTitle => 'ユーザーガイドとドキュメント';

  @override
  String get guideIntro =>
      'このアプリケーションはFFmpegを活用して、データをサーバーに送信することなく、デバイス上（Webまたはデスクトップ）で直接ビデオを変換します。';

  @override
  String get sectionSettings => '技術設定';

  @override
  String get paramVideoCodec => '1. ビデオコーデック';

  @override
  String get paramVideoCodecDesc => 'ビデオエンコーダー。画像データの圧縮方法を決定します。';

  @override
  String get paramVideoCodecDetails =>
      '- **H.264 (libx264):** 最も一般的で、ほぼすべてのデバイスと互換性があります。速度と品質のバランスが良いです。\n- **VP9 (libvpx-vp9):** Googleのオープンソースコーデックで、Web/YouTubeでよく使用されます。H.264よりも圧縮率は高いですが、エンコードは遅いです。';

  @override
  String get paramCrf => '2. Constant Rate Factor (CRF)';

  @override
  String get paramCrfDesc => '出力ビデオの品質を決定する指標。';

  @override
  String get paramCrfDetails =>
      '- 範囲: 0-51。\n- **0:** ロスレス (圧縮なし、ファイルサイズ大)。\n- **23:** デフォルト (バランス)。\n- **18:** 高品質 (視覚的にロスレス)。\n- **28:** 低品質 (ファイルサイズ小)。\n *ルール: 値が低いほど = 品質が高い = サイズが大きい。*';

  @override
  String get paramPreset => '3. プリセット';

  @override
  String get paramPresetDesc => '圧縮速度。';

  @override
  String get paramPresetDetails =>
      '- **ultrafast/superfast:** 非常に高速ですが、同じ品質でも出力ファイルが大きくなります。\n- **medium:** デフォルト。バランス。\n- **slow/veryslow:** 非常に遅いですが、最も効率的な圧縮（同じ品質で最小のファイル）。\n *推奨: 一般的な使用には \"medium\" または \"fast\"。*';

  @override
  String get paramResolution => '4. 解像度';

  @override
  String get paramResolutionDesc => 'ビデオの寸法を変更します。';

  @override
  String get paramResolutionDetails =>
      '- **Original:** 元のサイズを維持。\n- **1080p/720p/480p:** ビデオの高さを指定した値に変更します（幅は自動計算）。ファイルサイズを大幅に削減します。';

  @override
  String get sectionReferences => '参考文献';

  @override
  String get developedBy => '開発者';

  @override
  String get technologies => '使用技術';

  @override
  String get librariesLicenses => 'サードパーティライブラリとライセンス';
}
