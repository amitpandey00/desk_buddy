import 'dart:convert';

/// Which window an engine is running. The overlay is the process's main
/// window (empty arguments); the dashboard is created from the tray.
enum WindowRole {
  overlay,
  dashboard;

  /// The `desktop_multi_window` arguments string for this role.
  String encode() => jsonEncode({'role': name});

  /// Anything unrecognised (including the main window's empty string) is
  /// the overlay.
  static WindowRole parse(String arguments) {
    try {
      final json = jsonDecode(arguments);
      if (json is Map && json['role'] == dashboard.name) return dashboard;
    } on FormatException {
      // Empty or not JSON: the main window.
    }
    return overlay;
  }
}
