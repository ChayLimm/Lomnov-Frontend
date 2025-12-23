// Conditional export for browser helper
// Exports a web implementation when running on web, otherwise a stub.
export 'browser_utils_stub.dart'
    if (dart.library.html) 'browser_utils_web.dart';
