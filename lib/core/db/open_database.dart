import 'dart:io';

import 'package:desk_buddy/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

const databaseFileName = 'desk_buddy.sqlite';

/// Opens the shared database file in the app-support folder.
///
/// Both windows (two Flutter engines) open their own connection to this file,
/// so: WAL lets one write while the other reads, and `busy_timeout` makes a
/// writer wait briefly instead of failing with `SQLITE_BUSY`.
Future<AppDatabase> openAppDatabase({File? file}) async {
  final target =
      file ??
      File(
        '${(await getApplicationSupportDirectory()).path}'
        '${Platform.pathSeparator}$databaseFileName',
      );
  await target.parent.create(recursive: true);
  return AppDatabase(
    NativeDatabase.createInBackground(target, setup: configureConnection),
  );
}

void configureConnection(Database db) {
  db
    ..execute('PRAGMA journal_mode = WAL')
    ..execute('PRAGMA busy_timeout = 3000')
    ..execute('PRAGMA synchronous = NORMAL');
}
