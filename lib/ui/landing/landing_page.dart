import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<void> _launchDownloadUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildDownloadSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            size: 100,
            color: Colors.white,
          ),
          const Gap(24),
          Text(
            'FFmpeg Converter Pro',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Text(
            'Convert videos instantly. No internet required for desktop app.\nFast, private, and open source.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(40),
          FilledButton.icon(
            onPressed: () {
              // Scroll down manually or just link to releases
              _launchDownloadUrl(
                'https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases',
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Now'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildFeatureCard(
            context,
            Icons.speed,
            'Lightning Fast',
            'Powered by FFmpeg 7.0. Native performance on Windows and Linux.',
          ),
          _buildFeatureCard(
            context,
            Icons.security,
            'Privacy First',
            'All conversions happen locally on your device. Your files never leave your computer.',
          ),
          _buildFeatureCard(
            context,
            Icons.format_shapes,
            'All Formats',
            'Support for MP4, MKV, WebM, AVI, MOV, and many more codecs like H.264, H.265, VP9, AV1.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const Gap(16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Download for your Platform',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildDownloadButton(
                context,
                Icons.window,
                'Windows',
                'Portable .zip',
                'https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases/latest/download/FFmpeg-Converter-Windows-Portable.zip',
              ),
              _buildDownloadButton(
                context,
                Icons.terminal,
                'Linux',
                'Portable .tar.gz',
                'https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases/latest/download/FFmpeg-Converter-Linux-x86_64-Portable.tar.gz',
              ),
              _buildDownloadButton(
                context,
                Icons.android,
                'Android',
                'APK (Coming Soon)',
                'https://github.com/AtelierMizumi/FFmpeg-Converter-App/releases',
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    IconData icon,
    String platform,
    String subtitle,
    String url, {
    bool enabled = true,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: enabled ? () => _launchDownloadUrl(url) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const Gap(16),
                Text(
                  platform,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const Gap(24),
                FilledButton(
                  onPressed: enabled ? () => _launchDownloadUrl(url) : null,
                  child: Text(enabled ? 'Download' : 'Unavailable'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextButton(
            onPressed: () => _launchDownloadUrl(
              'https://github.com/AtelierMizumi/FFmpeg-Converter-App',
            ),
            child: const Text('View Source on GitHub'),
          ),
          const Gap(8),
          Text(
            '© 2026 Atelier Mizumi. Open Source MIT License.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
