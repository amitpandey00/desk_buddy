import 'package:desk_buddy/features/settings/data/settings_repository.dart';
import 'package:meta/meta.dart';

/// Where the buddy's top-left corner was, in physical virtual-screen pixels.
@immutable
class BuddyPosition {
  const BuddyPosition(this.x, this.y);

  final double x;
  final double y;

  @override
  bool operator ==(Object other) =>
      other is BuddyPosition && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// Persists the buddy's position across launches.
abstract interface class BuddyPositionStore {
  Future<BuddyPosition?> load();
  Future<void> save(BuddyPosition position);
}

/// Backed by the settings row (`buddyX` / `buddyY`).
class SettingsBuddyPositionStore implements BuddyPositionStore {
  SettingsBuddyPositionStore(this._settings);

  final SettingsRepository _settings;

  @override
  Future<BuddyPosition?> load() async {
    final s = await _settings.get();
    final (x, y) = (s.buddyX, s.buddyY);
    return x == null || y == null ? null : BuddyPosition(x, y);
  }

  @override
  Future<void> save(BuddyPosition position) =>
      _settings.saveBuddyPosition(position.x, position.y);
}
