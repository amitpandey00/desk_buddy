import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/core/db/seed/seed_data.dart';
import 'package:desk_buddy/features/categories/data/category_repository.dart';
import 'package:desk_buddy/features/reminders/data/log_repository.dart';
import 'package:desk_buddy/features/reminders/data/reminder_repository.dart';
import 'package:desk_buddy/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Opened in `main()` (it's async) and injected with
/// `appDataProvider.overrideWithValue(data)`.
@Riverpod(keepAlive: true)
AppData appData(Ref ref) =>
    throw UnimplementedError('Override appDataProvider in main()');

/// Seed templates, loaded once at startup alongside [appData].
@Riverpod(keepAlive: true)
SeedData seedData(Ref ref) =>
    throw UnimplementedError('Override seedDataProvider in main()');

@Riverpod(keepAlive: true)
DataChanges dataChanges(Ref ref) => ref.watch(appDataProvider).changes;

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    ref.watch(appDataProvider).categories;

@Riverpod(keepAlive: true)
ReminderRepository reminderRepository(Ref ref) =>
    ref.watch(appDataProvider).reminders;

@Riverpod(keepAlive: true)
LogRepository logRepository(Ref ref) => ref.watch(appDataProvider).log;

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    ref.watch(appDataProvider).settings;
