import 'ffmpeg_service_interface.dart';
import 'ffmpeg_service_stub.dart'
    if (dart.library.io) 'ffmpeg_service_desktop.dart'
    if (dart.library.js_interop) 'ffmpeg_service_web.dart';

export 'ffmpeg_service_interface.dart';

class FFmpegServiceFactory {
  static FFmpegService getService() {
    return FFmpegServiceImpl();
  }
}
