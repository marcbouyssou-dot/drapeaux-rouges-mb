import 'startup_debug_overlay_stub.dart'
    if (dart.library.html) 'startup_debug_overlay_web.dart';

void setStartupDebugStep(String step) {
  platformSetStartupDebugStep(step);
}
