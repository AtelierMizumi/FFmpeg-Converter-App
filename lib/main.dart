import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_test_application/l10n/app_localizations.dart';
import 'ui/tabs/converter_tab.dart';
import 'ui/tabs/guide_tab.dart';
import 'ui/tabs/credits_tab.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env is missing (e.g., in production/release if secrets are passed via build args),
    // we might ignore or handle gracefully.
    // However, dotenv is typically used for local dev.
    if (kDebugMode) {
      print('Warning: .env file not found or failed to load: $e');
    }
  }

  // Initialize MediaKit
  if (!kIsWeb) {
    MediaKit.ensureInitialized();
  }

  // Initialize Analytics
  await AnalyticsService.instance.initialize();

  runApp(const FFmpegConverterApp());
}

class FFmpegConverterApp extends StatefulWidget {
  const FFmpegConverterApp({super.key});

  @override
  State<FFmpegConverterApp> createState() => _FFmpegConverterAppState();

  static _FFmpegConverterAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FFmpegConverterAppState>();
}

class _FFmpegConverterAppState extends State<FFmpegConverterApp>
    with WidgetsBindingObserver {
  Locale _locale = const Locale(
    'vi',
  ); // Default VI as requested by context cues (Vietnamese user)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Track app lifecycle changes
    switch (state) {
      case AppLifecycleState.resumed:
        AnalyticsService.instance.onAppResumed();
        break;
      case AppLifecycleState.paused:
        AnalyticsService.instance.onAppPaused();
        break;
      default:
        break;
    }
  }

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
