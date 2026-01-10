import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_test_application/l10n/app_localizations.dart';

class CreditsTab extends StatelessWidget {
  const CreditsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_filter, size: 80, color: Colors.deepPurple),
          const Gap(16),
          Text(
            'Local FFmpeg Converter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('Version 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
          const Gap(32),

          Text(
            l10n.developedBy,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text(
            'AtelierMizumi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Gap(24),

          Text(
            l10n.technologies,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(8),
          const Wrap(
            spacing: 12,
            children: [
              Chip(label: Text('Flutter')),
              Chip(label: Text('Dart')),
              Chip(label: Text('FFmpeg')),
              Chip(label: Text('FFmpeg WASM (Web)')),
            ],
          ),

          const Gap(32),
          Text(
            l10n.librariesLicenses,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          _buildLicenseRow('ffmpeg_wasm', 'MIT License'),
          _buildLicenseRow('desktop_drop', 'MIT License'),
          _buildLicenseRow('file_picker', 'MIT License'),
          _buildLicenseRow('FFmpeg', 'LGPL v2.1+ / GPL v2+'),

          const Gap(32),
          TextButton.icon(
            onPressed: () =>
                launchUrl(Uri.parse('https://github.com/AtelierMizumi')),
            icon: const Icon(Icons.code),
            label: const Text('Visit GitHub Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseRow(String lib, String license) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$lib • $license',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
