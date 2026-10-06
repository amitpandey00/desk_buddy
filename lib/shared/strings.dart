/// Every user-facing string, in one place, so localization can be added
/// later without hunting through widgets.
abstract final class Strings {
  // Defaults stored in data
  static const defaultUserName = 'there';
  static const defaultDoneLabel = 'Done';
  static const defaultReminderEmoji = '⏰';
  static const defaultCategoryEmoji = '🏷️';
  static const newCategoryName = 'New category';
  static const uncategorized = 'Uncategorized';

  static const newReminderMessage = 'Hey, {name}! ';

  // Reminder editor validation
  static const problemTitleMissing = 'Give the reminder a title';
  static const problemDateMissing = 'Pick a date for a one-time reminder';
  static const problemTimePassed = 'That time has already passed';
  static const problemIntervalTooShort = 'Repeat every 1 minute or more';

  // Countdowns
  static const countdownNow = 'now';
  static const none = '—';
  static const plusOne = '+1';
  static const am = 'AM';
  static const pm = 'PM';
  static String hourShort(int h) =>
      '${h % 12 == 0 ? 12 : h % 12}${h < 12 ? 'a' : 'p'}';
  static const chartHoursEmpty = 'Completions by hour of day: none yet';
  static String countdownSeconds(int s) => '${s}s';
  static String countdownMinutes(int m) => '$m min';
  static String countdownHours(int h, int m) => '${h}h ${m}m';
  static String countdownDays(int d) => '${d}d';

  // Notifications (when the buddy is hidden)
  static const appName = 'Desk Buddy';

  // Schedules
  static const every = 'Every';
  static const minutesShort = 'min';
  static const everyDay = 'every day';
  static const weekdays = 'weekdays';
  static const weekends = 'weekends';
  static const dayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const dayLetter = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static String onceOn(String date, String time) => 'Once on $date at $time';

  // Tray
  static const trayTooltip = 'Desk Buddy';
  static const trayOpenDashboard = 'Open Dashboard';
  static const trayShowBuddy = 'Show Buddy';
  static const trayHideBuddy = 'Hide Buddy';
  static const trayDnd = 'Do Not Disturb';
  static const trayAlwaysOn = 'Always on Screen';
  static String traySnoozeAll(int minutes) => 'Snooze all for $minutes min';
  static const trayQuit = 'Quit';

  // Buddy & bubble
  static const buddyLabel = 'Reminder buddy';
  static const buddyHint = 'Drag to move. Press to see what is next.';
  static const peekNothing = 'Nothing scheduled. Enjoy!';
  static String peekNext(String emoji, String title, String countdown) =>
      '$emoji $title in $countdown';
  static String remindLater(int minutes) => 'Remind me in $minutes min';
  static const bubbleNo = 'No';
  static const sadReply = 'Oh… okay. Next time!';
  static const sadEmoji = '😢';
  static String goalProgress(int count, int goal, String unit) =>
      '$count / $goal${unit.isEmpty ? '' : ' $unit'} today';

  // ---------------------------------------------------------- dashboard app
  static const brandA = 'Desk';
  static const brandB = 'Buddy';
  static const sections = 'Sections';
  static const railFoot =
      'Your buddy walks along the bottom of the screen. Drag it anywhere; '
      'click it to see what’s next.';
  static const navDashboard = 'Dashboard';
  static const navReminders = 'Reminders';
  static const navCharacter = 'Character';
  static const navAnalytics = 'Analytics';
  static const navSettings = 'Settings';

  // Common
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static const edit = 'Edit';
  static const test = 'Test';
  static const undo = 'Undo';
  static const on = 'On';
  static const off = 'Off';
  static const other = 'Other';
  static const doNotDisturb = 'Do not disturb';
  static String minutesOption(int m) => '$m minutes';

  // Dashboard
  static String greeting(int hour, String name) {
    final hello = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    final n = name.trim();
    return n.isEmpty || n == defaultUserName ? hello : '$hello, $n';
  }

  static const dndNotice = 'Do not disturb is on — reminders are paused.';
  static const noneScheduled = 'No reminders scheduled.';
  static String nextUp(String emoji, String title) =>
      'Next up: $emoji $title in ';
  static String ringLabel(int percent, {required bool hasGoals}) =>
      hasGoals ? '$percent% of today’s goals done' : 'No goals set';
  static const ofTodaysGoals = 'of today’s goals';
  static const noGoalsSet = 'no goals set';
  static const todaysGoals = 'Today’s goals';
  static const goalsEmpty =
      'Give any reminder a daily goal and its progress shows up here.';
  static const setAGoal = 'Set a goal';
  static String goalLine(int count, int goal, String unit, int streak) =>
      '$count / $goal${unit.isEmpty ? '' : ' $unit'}'
      '${streak > 0 ? ' · $streak-day streak 🔥' : ''}';
  static String addOneTo(String title) => 'Add one to $title';
  static String goalBarLabel(String title, int count, int goal) =>
      '$title, $count of $goal';
  static String plusOneToast(String emoji, String unit) =>
      '$emoji +1 $unit'.trim();
  static const completedToday = 'completed today';
  static const snoozedLabel = 'snoozed';
  static const missedLabel = 'missed';
  static const previewNext = 'Preview next reminder';
  static const nothingToPreview = 'Add a reminder first.';
  static const comingUp = 'Coming up';
  static const addToStart = 'Add a reminder to get started.';
  static const todayTitle = 'Today';
  static const nothingYetToday = 'Nothing yet today.';
  static const deletedReminder = 'Deleted reminder';
  static const tagDone = 'done';
  static const tagSnoozed = 'snoozed';
  static const tagMissed = 'missed';
  static const tagSkipped = 'said no';
  static const tagLogged = 'logged';

  // Reminders
  static const remindersSubtitle =
      'Anything you want a nudge for — repeating, at a set time, or once.';
  static const yourReminders = 'Your reminders';
  static const noRemindersYet =
      'No reminders yet. Start from scratch or pick a starter.';
  static const newReminder = 'New reminder';
  static const editReminder = 'Edit reminder';
  static const starterLoaded = 'Starter loaded — adjust and save';
  static const reminderDeleted = 'Reminder deleted';
  static const reminderGone = 'That reminder was deleted in the meantime.';
  static String goalShort(int goal, String unit) => 'goal $goal $unit'.trim();
  static const nextIn = 'next in ';
  static String toggleReminder(String title) => 'Turn $title on or off';
  static const fieldTitle = 'Title';
  static const titleHint = 'e.g. Call mom';
  static const fieldIcon = 'Icon';
  static const fieldMessage = 'What your buddy says';
  static const messageHint =
      'Use {name}, {count}, {goal}, {unit}, {title} or {category} and '
      'they’re filled in.';
  static const fieldCategory = 'Category';
  static const fieldProp = 'Buddy holds';
  static const usualItem = 'Its usual item';
  static const when = 'When';
  static const fieldRepeat = 'Repeat';
  static const repeatInterval = 'Every few minutes';
  static const repeatDaily = 'At a set time';
  static const repeatOnce = 'Just once';
  static const fieldEvery = 'Every (minutes)';
  static const onlyBetween = 'Only between certain hours';
  static const fieldFrom = 'Only from';
  static const fieldUntil = 'Until';
  static const fieldTime = 'Time';
  static const fieldDate = 'Date';
  static const pickDate = 'Pick a date';
  static const daysHint = 'Days (none = every day)';
  static const goalLegend = 'Daily goal (optional)';
  static const fieldGoal = 'Times per day';
  static const goalZeroHint = '0 means no goal';
  static const fieldUnit = 'Counted as';
  static const unitHint = 'e.g. pages, sets, calls';
  static const fieldDoneLabel = 'Done button';
  static const addReminder = 'Add reminder';
  static const saveChanges = 'Save changes';
  static String added(String title) => 'Added “$title”';
  static const changesSaved = 'Changes saved';

  // Character
  static const characterTitle = 'Your buddy';
  static const characterSubtitle =
      'Changes show up on the walking buddy right away. Each reminder can '
      'also pick what the buddy holds when it pops up.';
  static const previewLabel = 'Preview of your buddy';
  static const startFromLook = 'Start from a look';
  static String presetName(String key) =>
      key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
  static const colors = 'Colors';
  static const colorSkin = 'Skin';
  static const colorHair = 'Hair';
  static const colorJacket = 'Jacket';
  static const colorShirt = 'Shirt';
  static const colorPants = 'Pants';
  static const colorShoes = 'Shoes';
  static String colorOf(String part) => '$part color';
  static const hexColor = 'Hex color';
  static const useColor = 'Use color';
  static const hair = 'Hair';
  static String hairName(String style) => switch (style) {
    'spiky' => 'Spiky',
    'short' => 'Short',
    'long' => 'Long',
    _ => 'None',
  };
  static const hat = 'Hat';
  static String hatName(String hat) => switch (hat) {
    'cap' => 'Cap',
    'beanie' => 'Beanie',
    _ => 'None',
  };
  static const usuallyHolding = 'Usually holding';
  static const spectacles = 'Glasses'; // guard-ok: eyewear, not a drink

  // Analytics
  static const analyticsSubtitle = 'The last 7 days.';
  static const analyticsSubtitleSample =
      'The last 7 days. Includes sample history so the charts have '
      'something to show.';
  static const noDataTitle = 'Nothing to chart yet';
  static const noDataBody =
      'Answer a few reminders (or tap +1 on a goal) and your week shows up '
      'here.';
  static const kpiRate = 'of reminders completed when they popped up';
  static const kpiResponse = 'average time to respond';
  static String kpiCompleted(int snoozed, int skipped, int missed) =>
      'completed ($snoozed snoozed, $skipped said no, $missed missed)';
  static const completedPerDay = 'Completed per day';
  static const goalProgressTitle = 'Goal progress';
  static const goalChartEmpty =
      'Set a daily goal on any reminder to track it here.';
  static String goalLineLabel(int goal) => 'goal $goal';
  static String goalFooter(double avg, String unit, int streak) =>
      'Average ${avg.toStringAsFixed(1)}${unit.isEmpty ? '' : ' $unit'} a day'
      ' · $streak-day streak';
  static const byReminder = 'By reminder';
  static const colReminder = 'Reminder';
  static const colDone = 'Done';
  static const colSnoozed = 'Snoozed';
  static const colSkipped = 'Said no';
  static const colMissed = 'Missed';
  static const colCompletion = 'Completion';
  static const whenYouRespond = 'When you respond';
  static String chartPerDayLabel(String summary) =>
      'Completed reminders per day: $summary';
  static String chartGoalLabel(String title, String series, int goal) =>
      '$title per day against a goal of $goal: $series';
  static String chartHoursLabel(String busiest) =>
      'Completions by hour of day; busiest around $busiest';
  static const removeSample = 'Remove sample history';
  static const sampleRemoved = 'Sample history removed';

  // Settings
  static const settingsSubtitle =
      'How your buddy behaves, and how reminders are grouped.';
  static const setName = 'Your name';
  static const setNameHint = 'Fills in {name} in messages';
  static const namePlaceholder = 'e.g. Sam';
  static const setShow = 'Show buddy';
  static const setShowHint =
      'Off: no character at all; reminders come as notifications';
  static const setAlways = 'Always on screen';
  static const setAlwaysHint =
      'Off: the buddy only appears when a reminder is due, then leaves';
  static const setWalk = 'Walk around';
  static const setWalkHint = 'Off keeps it where you put it';
  static const setSpeed = 'Walking speed';
  static String speedValue(int v) => '$v px per second';
  static const setSize = 'Buddy size';
  static String sizeValue(int v) => '${v}px wide';
  static const setSound = 'Sound';
  static const setSoundHint = 'Soft chime with each reminder';
  static const setSnooze = 'Snooze length';
  static const setSnoozeHint = 'What “Remind me later” waits';
  static const setAutoMiss = 'Mark as missed after';
  static const setAutoMissHint = 'If a pop-up sits unanswered';
  static const setDndHint = 'Pause every reminder';
  static const setLogin = 'Launch at login';
  static const setLoginHint = 'Start Desk Buddy when you sign in';
  static const setFocus = 'Focus pop-ups';
  static const setFocusHint =
      'Pop-ups take keyboard focus so Enter answers them (always on with a '
      'screen reader)';
  static const setTheme = 'Theme';
  static String themeName(String t) => switch (t) {
    'light' => 'Light',
    'dark' => 'Dark',
    _ => 'System',
  };
  static const setReset = 'Start over';
  static const setResetHint =
      'Deletes reminders, history and your buddy’s look';
  static const resetEverything = 'Reset everything';
  static const resetConfirmTitle = 'Reset everything?';
  static const resetConfirmBody =
      'This deletes all reminders, history, categories and settings, and '
      'brings back the starter reminders. It can’t be undone.';
  static const resetDone = 'Everything reset';
  static const setBackup = 'Back up & restore';
  static const setBackupHint =
      'Everything — reminders, history, settings and look — in one file';
  static const exportData = 'Export…';
  static const importData = 'Import…';
  static const backupFileType = 'Desk Buddy backup';
  static String backupFileName(String date) => 'desk-buddy-backup-$date.json';
  static const exported = 'Backup saved';
  static const importConfirmTitle = 'Replace everything with this backup?';
  static String importConfirmBody(int reminders, int entries, String? when) =>
      'This backup${when == null ? '' : ' from $when'} has $reminders '
      'reminder${reminders == 1 ? '' : 's'} and $entries history '
      'entr${entries == 1 ? 'y' : 'ies'}. Your current reminders, history, '
      'categories and settings will be replaced. This can’t be undone.';
  static const importAction = 'Replace';
  static const imported = 'Backup restored';
  static const backupNotOurs = 'That file isn’t a Desk Buddy backup.';
  static const backupTooNew =
      'That backup is from a newer version of Desk Buddy.';
  static const backupNoCategories = 'That backup has no categories.';
  static const backupDamaged = 'That backup file is damaged.';
  static const backupRestoreFailed =
      'Couldn’t restore that backup. Nothing was changed.';
  static const devTitle = 'Developer';
  static const devHint = 'Debug builds only';
  static const generateSample = 'Generate sample history';
  static const sampleAdded = 'Sample history added';
  static const categoriesTitle = 'Categories';
  static const categoriesHint = 'Used for colors on the dashboard and charts.';
  static const categoryIcon = 'Icon';
  static const categoryName = 'Name';
  static String categoryColor(String name) => '$name color';
  static String deleteMoves(int n) =>
      'Moves $n reminder${n == 1 ? '' : 's'} to the first category';
  static const categoryDeleted = 'Category deleted';
  static const addCategory = '+ Add category';
}
