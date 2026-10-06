import 'package:desk_buddy/shared/strings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

enum ThemePreference { system, light, dark }

/// The single settings row. Defaults are the spec's.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// Fills `{name}`.
    @Default(Strings.defaultUserName) String userName,

    /// Logical px wide, [sizeMin]–[sizeMax].
    @Default(120) int buddySize,

    /// px per second, [speedMin]–[speedMax].
    @Default(45) int walkSpeed,
    @Default(true) bool walkEnabled,
    @Default(true) bool buddyVisible,

    /// Walk on screen all the time. Off (default): the buddy only appears
    /// while a reminder pop-up is showing, then leaves again.
    @Default(false) bool buddyAlwaysOn,
    @Default(true) bool soundEnabled,

    /// One of [snoozeOptions].
    @Default(10) int snoozeMinutes,

    /// One of [autoMissOptions].
    @Default(5) int autoMissMinutes,
    @Default(false) bool doNotDisturb,
    @Default(ThemePreference.system) ThemePreference themeMode,
    @Default(false) bool launchAtLogin,

    /// Give a pop-up keyboard focus (so Enter answers it). Off by default:
    /// otherwise a reminder would grab the keys you're typing. Forced on
    /// while a screen reader is running.
    @Default(false) bool focusPopups,

    /// Buddy top-left in physical virtual-screen px; null = default spot.
    double? buddyX,
    double? buddyY,
  }) = _AppSettings;

  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  static const sizeMin = 70;
  static const sizeMax = 220;
  static const speedMin = 10;
  static const speedMax = 140;
  static const snoozeOptions = [5, 10, 15, 30, 60];
  static const autoMissOptions = [2, 5, 10, 15];

  /// Brings every field back inside its allowed range or option set, so a
  /// bad import or a stale UI can't store something the app can't show.
  AppSettings normalized() => copyWith(
    userName: userName.trim().isEmpty ? Strings.defaultUserName : userName,
    buddySize: buddySize.clamp(sizeMin, sizeMax),
    walkSpeed: walkSpeed.clamp(speedMin, speedMax),
    snoozeMinutes: _nearest(snoozeOptions, snoozeMinutes),
    autoMissMinutes: _nearest(autoMissOptions, autoMissMinutes),
  );

  static int _nearest(List<int> options, int v) => options.reduce(
    (best, o) => (o - v).abs() < (best - v).abs() ? o : best,
  );
}
