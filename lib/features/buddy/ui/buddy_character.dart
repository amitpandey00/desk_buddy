import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_view.dart';
import 'package:desk_buddy/features/buddy/ui/rive_buddy_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

/// The buddy, drawn by Rive when `assets/rive/buddy.riv` ships and loads,
/// otherwise by [BuddyView] (the CustomPainter, always available).
class BuddyCharacter extends StatelessWidget {
  const BuddyCharacter({
    required this.look,
    required this.state,
    this.propId,
    this.flip = false,
    this.width = 120,
    this.reduceMotion,
    this.idleFps = 15,
    super.key,
  });

  final BuddyLook look;
  final BuddyState state;
  final String? propId;
  final bool flip;
  final double width;
  final bool? reduceMotion;
  final int idleFps;

  @override
  Widget build(BuildContext context) => FutureBuilder<rive.File?>(
    future: RiveCharacterFile.load(),
    builder: (context, snap) {
      final file = snap.data;
      if (file == null) {
        return BuddyView(
          look: look,
          state: state,
          propId: propId,
          flip: flip,
          width: width,
          reduceMotion: reduceMotion,
          idleFps: idleFps,
        );
      }
      return RiveBuddyView(
        file: file,
        look: look,
        state: state,
        propId: propId,
        flip: flip,
        width: width,
        reduceMotion:
            reduceMotion ??
            MediaQuery.maybeDisableAnimationsOf(context) ??
            false,
      );
    },
  );
}

/// Loads the Rive character once per engine; null when absent or broken.
abstract final class RiveCharacterFile {
  static Future<rive.File?>? _loading;

  static Future<rive.File?> load() => _loading ??= _load();

  static Future<rive.File?> _load() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (!manifest.listAssets().contains(riveBuddyAsset)) return null;
      await rive.RiveNative.init();
      final file = await rive.File.asset(
        riveBuddyAsset,
        riveFactory: rive.Factory.rive,
      );
      if (file == null) return null;
      // A file that parses but doesn't follow docs/rive-contract.md (no
      // `Buddy` artboard, `Main` state machine or default view model) would
      // throw inside the widget; probe it here so we fall back instead.
      final probe = RiveBuddyView.controllerFor(file);
      probe.dataBind(rive.DataBind.auto()).dispose();
      probe.dispose();
      return file;
    } on Object catch (e) {
      // A bad file must never cost the user their buddy: use the painter.
      debugPrint('Rive character unavailable, using the painter: $e');
      return null;
    }
  }

  /// Tests: forget the cached result.
  @visibleForTesting
  static void reset() => _loading = null;
}
