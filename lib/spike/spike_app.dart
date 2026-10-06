import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/features/buddy/data/buddy_position_store.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/movement/walker.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_bubble.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_character.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/scheduler/application/alert_view.dart';
import 'package:desk_buddy/features/scheduler/application/scheduler_service.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/format/countdown.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/spike/bench.dart';
import 'package:desk_buddy/spike/overlay_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Overlay strategies under test.
///
/// * A — small window that moves with the buddy (`SetWindowPos` per frame).
/// * B — work-area-sized window, click-through toggled by polling the cursor
///   every 50 ms (the spec's Option B).
/// * C — same window as B, but click-through comes from a native window
///   region that follows the buddy: no polling, no input race.
enum Strategy { a, b, c }

const _strategyName = String.fromEnvironment('SPIKE', defaultValue: 'A');
const _hz = int.fromEnvironment('HZ', defaultValue: 60);
const _benchSeconds = int.fromEnvironment('BENCH');
const _out = String.fromEnvironment('OUT');

// Logical sizes (design units). The buddy's own size comes from settings.
const _padX = 10.0;
const _padTop = 16.0;
const _bubbleW = 310.0;
const _bubbleArea = 190.0; // A: room above the buddy for the bubble

class SpikeApp extends StatefulWidget {
  const SpikeApp({
    required this.data,
    required this.scheduler,
    this.onActivateRequested,
    this.registerQuitHook,
    super.key,
  });

  final AppData data;
  final SchedulerService scheduler;

  /// A second launch of the app (single instance): open the dashboard.
  final void Function()? onActivateRequested;

  /// Receives a function `main` calls before quitting (saves the position).
  final void Function(Future<void> Function() beforeQuit)? registerQuitHook;

  @override
  State<SpikeApp> createState() => _SpikeAppState();
}

class _SpikeAppState extends State<SpikeApp>
    with SingleTickerProviderStateMixin {
  final Strategy strategy = Strategy.values.byName(
    _strategyName.toLowerCase(),
  );
  final native = OverlayNative();
  late final Ticker _ticker = createTicker(_onTick);
  // BENCH is a compile-time define, so the analyzer sees its default.
  // ignore: avoid_redundant_argument_values
  final walker = Walker(random: Random(7), alwaysWalk: _benchSeconds > 0);
  BuddyLook look = LookPresets.classic;
  AppSettings _settings = const AppSettings();
  AlertView? _alert;
  String _peekText = Strings.peekNothing;
  final _subs = <StreamSubscription<Object?>>[];

  double get _bw => _settings.buddySize.toDouble();
  double get _bh => _bw * 222 / 120;
  double get _speed => _settings.walkSpeed.toDouble();

  /// The bubble's tail sits this far down the buddy (prototype: 8%).
  double get _bubbleOverlap => _bh * .08;

  /// Walking allowed right now (setting, and not paused by the benchmark).
  bool get _walkOn => _walk && _settings.walkEnabled;

  List<NativeDisplay> _displays = const [];
  NativeDisplay? _display;
  double _buddyY = 0;
  bool _walk = true;
  bool _staticRender = false;

  // OS accessibility state (native, live).
  bool _osReduceMotion = false;
  bool _screenReader = false;
  bool _focusRequested = false;

  /// Whether the buddy is on screen right now. With "Always on screen" off
  /// (the default) it only appears while a pop-up is showing; benchmarks
  /// always show it.
  bool get _visible =>
      _settings.buddyVisible &&
      (_settings.buddyAlwaysOn || _alert != null || _benchSeconds > 0);

  /// What the native window was last told (null = not yet).
  bool? _windowShown;

  /// Shows or hides the overlay window to match [_visible].
  Future<void> _applyVisibility() async {
    final want = _visible;
    if (want == _windowShown) return;
    _windowShown = want;
    await native.setVisible(visible: want);
    if (want) _startTicker();
  }

  Duration _last = Duration.zero;
  Timer? _resumeWalk;

  // Bubble: taps alternate between the peek and a demo alert.
  _Bubble _bubble = _Bubble.none;
  int _bubbleSerial = 0;
  Timer? _bubbleTimer;
  final GlobalKey _bubbleKey = GlobalKey();

  // Drag, tracked with the native cursor (see decisions D3).
  Offset? _grab;
  late Offset _dragStart;
  bool _moved = false;
  bool _dragPoll = false;

  // Persistence.
  BuddyPositionStore? _store;
  BuddyPosition? _saved;
  Timer? _saveTimer;

  // A
  Offset? _sentPos;
  Size? _sentSize;
  bool _framePending = false;
  Duration _lastSend = Duration.zero;

  // B
  Timer? _hitPoll;
  bool? _clickThrough;
  bool _hitPending = false;

  // C
  List<Rect>? _sentRegion;
  bool _regionPending = false;

  NativeDisplay get display => _display!;
  double get scale => display.scale;
  bool get dragging => _grab != null;
  bool get alerting => _bubble == _Bubble.alert;

  BuddyState get buddyState {
    if (dragging) return BuddyState.dragging;
    if (alerting) return BuddyState.alert;
    if (!_walkOn || walker.mode == WalkMode.idle) return BuddyState.idle;
    return BuddyState.walking;
  }

  Rect get buddyRect =>
      Rect.fromLTWH(walker.x, _buddyY, _bw * scale, _bh * scale);

  /// The laid-out bubble in physical screen pixels, or null.
  Rect? get bubbleRect {
    final box = _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final local = box.localToGlobal(Offset.zero) & box.size;
    final origin = strategy == Strategy.a
        ? (_sentPos ?? Offset.zero)
        : display.work.topLeft;
    return Rect.fromLTWH(
      origin.dx + local.left * scale,
      origin.dy + local.top * scale,
      local.width * scale,
      local.height * scale,
    );
  }

  Size get _aWindowLogical => _bubble != _Bubble.none
      ? Size(max(_bw + 2 * _padX, _bubbleW + 24), _bh + _bubbleArea)
      : Size(_bw + 2 * _padX, _bh + _padTop);

  /// A: is there room for the bubble above the buddy on this display?
  bool get _aBubbleAbove =>
      buddyRect.top + (_bubbleOverlap - _bubbleArea) * scale >=
      display.work.top;

  /// A: the window rect (physical), kept inside the work area horizontally
  /// so the bubble is never cut off at a screen edge; it extends below the
  /// buddy instead of above when there's no room up there.
  Rect get _aFrame {
    final logical = _aWindowLogical;
    final w = (logical.width * scale).roundToDouble();
    final h = (logical.height * scale).roundToDouble();
    final b = buddyRect;
    final work = display.work;
    final x = (b.center.dx - w / 2).clamp(
      work.left,
      max<double>(work.left, work.right - w),
    );
    final y = _bubble == _Bubble.none || _aBubbleAbove
        ? b.bottom - h
        : b.top - _padTop * scale;
    return Rect.fromLTWH(x.roundToDouble(), y.roundToDouble(), w, h);
  }

  @override
  void initState() {
    super.initState();
    // Wired first, so a second launch during startup isn't lost.
    native
      ..onAccessibilityChanged = _readAccessibility
      ..onActivateRequested = widget.onActivateRequested;
    widget.registerQuitHook?.call(() async {
      _saveTimer?.cancel();
      await _savePosition();
    });
    unawaited(_init());
  }

  Future<void> _init() async {
    _settings = await widget.data.settings.get();
    look = await widget.data.settings.getLook();
    _displays = await native.displays();
    _display = _displays.firstWhere(
      (d) => d.primary,
      orElse: () => _displays.first,
    );
    walker.x = display.work.left + 40 * scale;
    _buddyY = display.work.bottom - (_bh + 8) * scale;
    if (_benchSeconds == 0) await _restorePosition();
    native.onDisplaysChanged = _reloadDisplays;
    await _readAccessibility();
    if (strategy != Strategy.a) await _coverDisplay();
    if (strategy == Strategy.c) {
      // Nothing is hittable until the first region sync.
      await native.setHitRegion(const []);
    }
    if (strategy == Strategy.b) {
      await _setClickThrough(on: true);
      _hitPoll = Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => _pollHit(),
      );
    }
    _saveTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _savePosition(),
    );
    _subs
      ..add(widget.data.settings.watch().listen(_onSettings))
      ..add(
        widget.data.settings.watchLook().listen(
          (l) => setState(() => look = l),
        ),
      )
      ..add(widget.scheduler.alerts.listen(_onAlert));
    // A reminder overdue at launch may have popped before we listened.
    if (widget.scheduler.current != null) _onAlert(widget.scheduler.current);
    await _applyVisibility();
    setState(() {});
    _startTicker();
    if (_benchSeconds > 0) unawaited(_runBench());
  }

  // ---- persistence ----

  Future<void> _restorePosition() async {
    _store = SettingsBuddyPositionStore(widget.data.settings);
    final p = await _store!.load();
    if (p == null) return;
    // The saved top-left (nudged inside) decides the monitor; its scale
    // isn't known until we know which monitor it is.
    final corner = Offset(p.x + 1, p.y + 1);
    final home = _displays.where((d) => d.bounds.contains(corner)).firstOrNull;
    if (home == null) return; // that monitor is gone: default placement
    _display = home;
    walker.x = p.x;
    _buddyY = p.y;
    _saved = p;
    _clamp();
  }

  Future<void> _savePosition() async {
    final store = _store;
    if (store == null || _display == null) return;
    final p = BuddyPosition(walker.x.roundToDouble(), _buddyY.roundToDouble());
    if (p == _saved) return;
    _saved = p;
    await store.save(p);
  }

  // ---- displays ----

  Future<void> _coverDisplay() async {
    _sentRegion = null;
    await native.setFrame(
      position: display.work.topLeft,
      size: display.work.size,
    );
  }

  NativeDisplay _displayAt(Offset p) => _displays.firstWhere(
    (d) => d.bounds.contains(p),
    orElse: () => display,
  );

  Future<void> _switchDisplay(NativeDisplay d) async {
    final same = d.id == _display?.id && d.work == _display?.work;
    // Always take the fresh object: the scale may have changed even when
    // the work area didn't.
    _display = d;
    if (!same && strategy != Strategy.a) await _coverDisplay();
  }

  Future<void> _reloadDisplays() async {
    if (_display == null) return; // still starting up
    _displays = await native.displays();
    if (_displays.isEmpty) return;
    final keep = _displays.where((d) => d.id == _display?.id).firstOrNull;
    final center = buddyRect.center;
    // The buddy's monitor was unplugged: use the one under it now, else the
    // primary, and never the stale, vanished one.
    final home =
        keep ??
        _displays.where((d) => d.bounds.contains(center)).firstOrNull ??
        _displays.firstWhere((d) => d.primary, orElse: () => _displays.first);
    await _switchDisplay(home);
    _clamp();
    _sync();
  }

  void _clamp() {
    final w = display.work;
    final maxX = max<double>(w.left, w.right - _bw * scale);
    final maxY = max<double>(w.top, w.bottom - _bh * scale);
    walker.x = walker.x.clamp(w.left, maxX);
    _buddyY = _buddyY.clamp(w.top, maxY);
  }

  // ---- frame loop: only runs while something moves ----

  void _startTicker() {
    _resumeWalk?.cancel();
    if (_ticker.isActive) return;
    _last = Duration.zero;
    unawaited(_ticker.start());
  }

  Future<void> _readAccessibility() async {
    final a = await native.accessibility();
    if (!mounted) return;
    setState(() {
      _osReduceMotion = a.reduceMotion;
      _screenReader = a.screenReader;
    });
  }

  void _onTick(Duration elapsed) {
    if (!_visible) {
      // Hidden: no frames at all; the scheduler keeps its own 1 s timer.
      _ticker.stop();
      return;
    }
    final dt = min(.05, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    if (dragging) {
      unawaited(_pollDrag());
    } else if (_walkOn && !alerting) {
      walker.step(
        dt,
        minX: display.work.left,
        maxX: display.work.right - _bw * scale,
        speed: _speed * scale,
      );
    }
    _clamp();
    setState(() {});
    _sync(elapsed);
    if (!dragging && buddyState != BuddyState.walking) _pauseTicker();
  }

  /// Idle: stop the frame loop and wake up when the walker would walk again.
  void _pauseTicker() {
    _ticker.stop();
    if (!_walkOn || alerting) return;
    final idleFor = walker.remaining;
    _resumeWalk = Timer(Duration(microseconds: (idleFor * 1e6).round()), () {
      walker.step(
        idleFor + 1e-6,
        minX: display.work.left,
        maxX: display.work.right - _bw * scale,
        speed: 0,
      );
      setState(() {});
      _startTicker();
    });
  }

  void _sync([Duration? elapsed]) {
    switch (strategy) {
      case Strategy.a:
        _syncWindow(elapsed);
      case Strategy.b:
        break;
      case Strategy.c:
        _syncRegion();
    }
  }

  // ---- drag & tap ----

  Future<void> _startDrag() async {
    if (dragging) return;
    final c = await native.cursor();
    _grab = c.position - buddyRect.topLeft;
    _dragStart = c.position;
    _moved = false;
    setState(() {});
    _startTicker();
  }

  Future<void> _pollDrag() async {
    if (_dragPoll) return;
    _dragPoll = true;
    try {
      final c = await native.cursor();
      if (_grab == null) return;
      if (!c.buttonDown) {
        _grab = null;
        if (_moved) {
          unawaited(_savePosition());
        } else {
          _onTap();
        }
        setState(() {});
        _startTicker();
        return;
      }
      if ((c.position - _dragStart).distance > 4 * scale) _moved = true;
      await _switchDisplay(_displayAt(c.position));
      final p = c.position - _grab!;
      walker.x = p.dx;
      _buddyY = p.dy;
    } finally {
      _dragPoll = false;
    }
  }

  void _onTap() {
    if (alerting) return;
    final next = widget.scheduler.upcoming().firstOrNull;
    final now = widget.data.clock.now().millisecondsSinceEpoch;
    _peekText = next == null
        ? Strings.peekNothing
        : Strings.peekNext(
            next.emoji,
            next.title,
            formatCountdown(next.nextDueAt! - now),
          );
    _show(_Bubble.peek);
  }

  void _onAlert(AlertView? alert) {
    _alert = alert;
    // Appears for the pop-up (if it isn't always on screen) and leaves
    // again once it's answered or missed.
    unawaited(_applyVisibility());
    if (alert != null) {
      _show(_Bubble.alert);
      // Keyboard / screen-reader users need the pop-up focused; everyone
      // else keeps typing undisturbed (D24).
      if (_visible && (_settings.focusPopups || _screenReader)) {
        // Recorded now, not when the call returns, so the release below
        // always happens, even if focus was only partly granted.
        _focusRequested = true;
        unawaited(native.focusForAlert());
      }
    } else {
      if (_bubble == _Bubble.alert) _hideBubble();
      if (_focusRequested) {
        _focusRequested = false;
        unawaited(native.releaseFocus());
      }
    }
  }

  Future<void> _onSettings(AppSettings s) async {
    final old = _settings;
    setState(() => _settings = s);
    await _applyVisibility();
    _clamp();
    _sync();
    if (s.walkEnabled && !old.walkEnabled) _startTicker();
  }

  void _show(_Bubble b) {
    _bubbleTimer?.cancel();
    setState(() {
      _bubble = b;
      _bubbleSerial++;
    });
    if (b == _Bubble.peek) {
      _bubbleTimer = Timer(const Duration(milliseconds: 2800), _hideBubble);
    }
    // Region / window size must follow once the bubble has laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _hideBubble() {
    _bubbleTimer?.cancel();
    setState(() => _bubble = _Bubble.none);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    _startTicker();
  }

  // ---- A: move the window ----

  void _syncWindow(Duration? elapsed) {
    if (_framePending) {
      // A bubble toggle must not be lost behind an in-flight move.
      if (elapsed == null) {
        Timer(const Duration(milliseconds: 4), () => _syncWindow(null));
      }
      return;
    }
    if (elapsed != null) {
      const minGap = Duration(microseconds: 1000000 ~/ _hz - 2000);
      if (elapsed - _lastSend < minGap) return;
      _lastSend = elapsed;
    }
    final frame = _aFrame;
    final size = frame.size;
    final pos = frame.topLeft;
    if (pos == _sentPos && size == _sentSize) return;
    _framePending = true;
    final sendSize = size != _sentSize;
    _sentPos = pos;
    _sentSize = size;
    unawaited(
      native
          .setFrame(position: pos, size: sendSize ? size : null)
          .whenComplete(() => _framePending = false),
    );
  }

  // ---- B: poll the cursor, toggle click-through ----

  Future<void> _setClickThrough({required bool on}) async {
    if (_clickThrough == on) return;
    _clickThrough = on;
    await native.setClickThrough(enabled: on);
  }

  Future<void> _pollHit() async {
    if (_hitPending) return;
    _hitPending = true;
    try {
      if (dragging) return await _setClickThrough(on: false);
      if (!_visible) return;
      final c = await native.cursor();
      final hit =
          buddyRect.inflate(4 * scale).contains(c.position) ||
          (bubbleRect?.inflate(4 * scale).contains(c.position) ?? false);
      await _setClickThrough(on: !hit);
    } finally {
      _hitPending = false;
    }
  }

  // ---- C: window region follows the buddy ----

  void _syncRegion() {
    if (_regionPending) {
      // Don't drop it: the bubble may just have appeared (A does the same).
      Timer(const Duration(milliseconds: 4), _syncRegion);
      return;
    }
    final origin = display.work.topLeft;
    Rect snap(Rect r) => Rect.fromLTRB(
      r.left.floorToDouble(),
      r.top.floorToDouble(),
      r.right.ceilToDouble(),
      r.bottom.ceilToDouble(),
    );
    final bubble = bubbleRect;
    // Padding hides the one-frame lag between the region and the paint.
    final rects = [
      snap(buddyRect.inflate(24 * scale).shift(-origin)),
      if (bubble != null) snap(bubble.inflate(12 * scale).shift(-origin)),
    ];
    if (listEquals(rects, _sentRegion)) return;
    _regionPending = true;
    _sentRegion = rects;
    unawaited(
      native.setHitRegion(rects).whenComplete(() => _regionPending = false),
    );
  }

  // ---- benchmark ----

  Future<void> _runBench() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final results = <String, Object?>{
      'strategy': strategy.name.toUpperCase(),
      if (strategy == Strategy.a) 'hz': _hz,
      'displays': [
        for (final d in _displays)
          {
            'bounds': '${d.bounds}',
            'work': '${d.work}',
            'scale': d.scale,
            'primary': d.primary,
          },
      ],
    };
    final phases = <Map<String, Object?>>[];
    Future<void> phase(String name, int seconds) async {
      final r = PhaseRecorder(name, native);
      await r.start();
      await Future<void>.delayed(Duration(seconds: seconds));
      phases.add(await r.stop());
    }

    await phase('walking', _benchSeconds);
    setState(() => _walk = false); // host loop pauses; buddy breathes at 15 fps
    await phase('idleAnimating', _benchSeconds ~/ 2);
    setState(() => _staticRender = true); // reduce-motion: nothing repaints
    await phase('static', _benchSeconds ~/ 2);
    results['phases'] = phases;
    writeResults(_out.isEmpty ? 'spike_results.json' : _out, results);
    exit(0);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    unawaited(_savePosition());
    _ticker.dispose();
    _hitPoll?.cancel();
    _bubbleTimer?.cancel();
    _resumeWalk?.cancel();
    _saveTimer?.cancel();
    super.dispose();
  }

  // ---- UI ----

  Widget _buddy() => Listener(
    onPointerDown: (_) => unawaited(_startDrag()),
    child: Focus(
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent &&
            (e.logicalKey == LogicalKeyboardKey.enter ||
                e.logicalKey == LogicalKeyboardKey.space)) {
          _onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: BuddyCharacter(
        look: look,
        width: _bw,
        state: buddyState,
        // During a pop-up the buddy holds what the reminder asks for.
        propId: alerting ? _alert?.propId : null,
        flip: walker.dir < 0,
        // Forced on when we know (Windows setting, benchmark); otherwise
        // BuddyView asks MediaQuery (macOS reports it there).
        reduceMotion: (_staticRender || _osReduceMotion) ? true : null,
      ),
    ),
  );

  Widget _alertBubble(AlertView? a) {
    if (a == null) return const SizedBox.shrink();
    final scheduler = widget.scheduler;
    return BuddyBubble(
      emoji: a.emoji,
      message: a.message,
      progress: a.progress,
      actions: [
        BubbleAction(
          a.doneLabel,
          () => unawaited(
            scheduler.respond(LogAction.done, firedAt: a.firedAt),
          ),
          primary: true,
        ),
        BubbleAction(
          a.snoozeLabel,
          () => unawaited(
            scheduler.respond(LogAction.snoozed, firedAt: a.firedAt),
          ),
        ),
      ],
    );
  }

  Widget _bubbleWidget() {
    final bubble = switch (_bubble) {
      _Bubble.none => const SizedBox.shrink(),
      _Bubble.peek => BuddyBubble(message: _peekText, compact: true),
      _Bubble.alert => _alertBubble(_alert),
    };
    // Measured outside the pop-in's scale transform, so the hit region and
    // click-through rect are the bubble's final layout, not a mid-animation
    // frame.
    return KeyedSubtree(
      key: _bubbleKey,
      child: PopIn(
        key: ValueKey(_bubbleSerial),
        animate: !_osReduceMotion,
        child: bubble,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (_display == null || !_visible) {
      content = const SizedBox.shrink();
    } else if (strategy == Strategy.a) {
      // Laid out relative to the window's own (clamped) frame.
      final win = _aFrame;
      final b = buddyRect;
      final buddyLeft = (b.left - win.left) / scale;
      final buddyTop = (b.top - win.top) / scale;
      final winW = win.width / scale;
      final winH = win.height / scale;
      final bubbleLeft = (buddyLeft + _bw / 2 - _bubbleW / 2).clamp(
        0.0,
        max<double>(0, winW - _bubbleW),
      );
      final above = _aBubbleAbove;
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: buddyLeft, top: buddyTop, child: _buddy()),
          if (_bubble != _Bubble.none)
            Positioned(
              left: bubbleLeft,
              width: min(_bubbleW, winW),
              bottom: above ? winH - (buddyTop + _bubbleOverlap) : null,
              top: above ? null : buddyTop + _bh + 6,
              child: Center(child: _bubbleWidget()),
            ),
        ],
      );
    } else {
      content = LayoutBuilder(
        builder: (context, c) {
          final o = display.work.topLeft;
          final b = (buddyRect.topLeft - o) / scale;
          final centerX = b.dx + _bw / 2;
          final left = (centerX - _bubbleW / 2).clamp(
            12.0,
            max<double>(12, c.maxWidth - _bubbleW - 12),
          );
          final roomAbove = b.dy + _bubbleOverlap;
          final above = roomAbove > 170;
          return Stack(
            children: [
              Positioned(left: b.dx, top: b.dy, child: _buddy()),
              if (_bubble != _Bubble.none)
                Positioned(
                  left: left,
                  width: _bubbleW,
                  // Grow upward from the buddy's head; flip below if no room.
                  bottom: above ? c.maxHeight - roomAbove : null,
                  top: above ? null : b.dy + _bh + 6,
                  child: Center(child: _bubbleWidget()),
                ),
            ],
          );
        },
      );
    }
    return WidgetsApp(
      color: const Color(0x00000000),
      debugShowCheckedModeBanner: false,
      // No Navigator here, so provide the focus scope it normally would.
      builder: (context, _) => FocusScope(
        autofocus: true,
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'Figtree',
            fontSize: 15,
            color: Color(0xFF1C2733),
          ),
          child: content,
        ),
      ),
    );
  }
}

enum _Bubble { none, peek, alert }
