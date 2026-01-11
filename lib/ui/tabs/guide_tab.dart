import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ffmpeg_converter_app/l10n/app_localizations.dart';

class GuideTab extends StatelessWidget {
  const GuideTab({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.guideTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Gap(16),
              Text(l10n.guideIntro),
              const Gap(24),

              _buildSectionTitle(context, l10n.sectionSettings),
              const Gap(8),

              _buildParamInfo(
                context,
                l10n.paramVideoCodec,
                l10n.paramVideoCodecDesc,
                l10n.paramVideoCodecDetails,
                'https://trac.ffmpeg.org/wiki/Encode/H.264',
              ),

              _buildParamInfo(
                context,
                l10n.paramCrf,
                l10n.paramCrfDesc,
                l10n.paramCrfDetails,
                'https://trac.ffmpeg.org/wiki/Encode/H.264#crf',
              ),

              _buildParamInfo(
                context,
                l10n.paramPreset,
                l10n.paramPresetDesc,
                l10n.paramPresetDetails,
                null,
              ),

              _buildParamInfo(
                context,
                l10n.paramResolution,
                l10n.paramResolutionDesc,
                l10n.paramResolutionDetails,
                'https://trac.ffmpeg.org/wiki/Scaling',
              ),

              const Gap(24),
              _buildSectionTitle(context, l10n.sectionReferences),
              const Gap(8),
              _buildLinkButton(
                'FFmpeg Official Documentation',
                'https://ffmpeg.org/documentation.html',
              ),
              _buildLinkButton(
                'H.264 Encoding Guide',
                'https://trac.ffmpeg.org/wiki/Encode/H.264',
              ),
              _buildLinkButton(
                'VP9 Encoding Guide',
                'https://trac.ffmpeg.org/wiki/Encode/VP9',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildParamInfo(
    BuildContext context,
    String title,
    String summary,
    String details,
    String? link,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (link != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'Xem tài liệu chi tiết',
                    onPressed: () => _launchUrl(link),
                  ),
              ],
            ),
            const Gap(4),
            Text(summary, style: const TextStyle(fontStyle: FontStyle.italic)),
            const Divider(),
            Text(details),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            const Icon(Icons.link, size: 20, color: Colors.blue),
            const Gap(8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
