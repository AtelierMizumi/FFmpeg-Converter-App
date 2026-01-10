import 'package:flutter/material.dart';
import 'ui/tabs/converter_tab.dart';
import 'ui/tabs/guide_tab.dart';
import 'ui/tabs/credits_tab.dart';

void main() {
  runApp(const FFmpegConverterApp());
}

class FFmpegConverterApp extends StatelessWidget {
  const FFmpegConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FFmpeg Pro',
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.movie_creation_outlined),
              const SizedBox(width: 12),
              const Text('FFmpeg Converter Pro'),
            ],
          ),
          centerTitle: false,
          elevation: 2,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.transform), text: 'Chuyển đổi'),
              Tab(icon: Icon(Icons.menu_book), text: 'Hướng dẫn'),
              Tab(icon: Icon(Icons.info), text: 'Thông tin'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ConverterTab(),
            GuideTab(),
            CreditsTab(),
          ],
        ),
      ),
    );
  }
}
