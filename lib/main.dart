import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_test_application/l10n/app_localizations.dart';
import 'ui/tabs/converter_tab.dart';
import 'ui/tabs/guide_tab.dart';
import 'ui/tabs/credits_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const FFmpegConverterApp());
}

class FFmpegConverterApp extends StatefulWidget {
  const FFmpegConverterApp({super.key});

  @override
  State<FFmpegConverterApp> createState() => _FFmpegConverterAppState();

  static _FFmpegConverterAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FFmpegConverterAppState>();
}

class _FFmpegConverterAppState extends State<FFmpegConverterApp> {
  Locale _locale = const Locale(
    'vi',
  ); // Default VI as requested by context cues (Vietnamese user)

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFmpeg Converter Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('vi'), // Vietnamese
        Locale('ja'), // Japanese
        Locale('de'), // German
      ],
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.movie_creation_outlined),
              const SizedBox(width: 12),
              Text(l10n.appTitle),
            ],
          ),
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: (Locale locale) {
                FFmpegConverterApp.of(context)?.setLocale(locale);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: Locale('vi'),
                  child: Text('Tiếng Việt'),
                ),
                const PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const PopupMenuItem(value: Locale('ja'), child: Text('日本語')),
                const PopupMenuItem(
                  value: Locale('de'),
                  child: Text('Deutsch'),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
          centerTitle: false,
          elevation: 2,
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.transform), text: l10n.tabConverter),
              Tab(icon: const Icon(Icons.menu_book), text: l10n.tabGuide),
              Tab(icon: const Icon(Icons.info), text: l10n.tabAbout),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ConverterTab(), GuideTab(), CreditsTab()],
        ),
      ),
    );
  }
}
