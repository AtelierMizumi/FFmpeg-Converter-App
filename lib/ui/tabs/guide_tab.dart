import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideTab extends StatelessWidget {
  const GuideTab({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle error silently or show snackbar if context available
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hướng dẫn sử dụng & Tài liệu',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Gap(16),
              const Text(
                'Ứng dụng này sử dụng sức mạnh của FFmpeg để chuyển đổi video trực tiếp trên thiết bị của bạn (Web hoặc Desktop) mà không cần gửi dữ liệu lên máy chủ.',
              ),
              const Gap(24),

              _buildSectionTitle(context, 'Các thông số kỹ thuật (Settings)'),
              const Gap(8),

              _buildParamInfo(
                context,
                '1. Video Codec',
                'Bộ mã hóa video. Quyết định cách thức nén dữ liệu hình ảnh.',
                '- **H.264 (libx264):** Phổ biến nhất, tương thích mọi thiết bị. Cân bằng tốt giữa tốc độ và chất lượng.\n'
                    '- **VP9 (libvpx-vp9):** Codec mã nguồn mở của Google, thường dùng cho Web/YouTube. Nén tốt hơn H.264 nhưng encode chậm hơn.',
                'https://trac.ffmpeg.org/wiki/Encode/H.264',
              ),

              _buildParamInfo(
                context,
                '2. Constant Rate Factor (CRF)',
                'Chỉ số quyết định chất lượng video đầu ra.',
                '- Dải giá trị: 0-51.\n'
                    '- **0:** Lossless (Không nén, dung lượng cực lớn).\n'
                    '- **23:** Mặc định (Cân bằng).\n'
                    '- **18:** Chất lượng cao (Gần như gốc).\n'
                    '- **28:** Chất lượng thấp hơn (Dung lượng nhỏ).\n'
                    ' *Nguyên tắc: Giá trị càng NHỎ, chất lượng càng CAO, dung lượng càng LỚN.*',
                'https://trac.ffmpeg.org/wiki/Encode/H.264#crf',
              ),

              _buildParamInfo(
                context,
                '3. Preset',
                'Tốc độ nén (Encoding Speed).',
                '- **ultrafast/superfast:** Rất nhanh, nhưng file output sẽ lớn hơn với cùng một chất lượng.\n'
                    '- **medium:** Mặc định. Cân bằng.\n'
                    '- **slow/veryslow:** Rất chậm, nhưng nén file hiệu quả nhất (file nhỏ nhất với cùng chất lượng).\n'
                    ' *Khuyên dùng: "medium" hoặc "fast" cho nhu cầu thông thường.*',
                null,
              ),

              _buildParamInfo(
                context,
                '4. Resolution (Độ phân giải)',
                'Thay đổi kích thước khung hình video.',
                '- **Original:** Giữ nguyên gốc.\n'
                    '- **1080p/720p/480p:** Resize video về chiều cao tương ứng (chiều rộng tự động tính theo tỉ lệ). Giúp giảm dung lượng đáng kể.',
                'https://trac.ffmpeg.org/wiki/Scaling',
              ),

              const Gap(24),
              _buildSectionTitle(context, 'Tài liệu tham khảo'),
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
