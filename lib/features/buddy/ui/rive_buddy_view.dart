import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/render/buddy_painter.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/shared/color_hex.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

/// Where the optional Rive character lives. See `docs/rive-contract.md`.
const riveBuddyAsset = 'assets/rive/buddy.riv';

/// Drives a commissioned Rive character through the contract in
/// `docs/rive-contract.md`: artboard `Buddy`, state machine `Main`, and a
/// view model whose properties mirror [BuddyLook] and [BuddyState].
///
/// Not exercised by tests (no `.riv` ships yet, and `rive_native` isn't
/// loaded under `flutter test`); `BuddyCharacter` falls back to the painter.
class RiveBuddyView extends StatefulWidget {
  const RiveBuddyView({
    required this.file,
    required this.look,
    required this.state,
    this.propId,
    this.flip = false,
    this.width = 120,
    this.reduceMotion = false,
    super.key,
  });

  final rive.File file;
  final BuddyLook look;
  final BuddyState state;
  final String? propId;
  final bool flip;
  final double width;
  final bool reduceMotion;

  /// The contract's artboard and state machine. Throws if the file lacks
  /// them (BuddyCharacter probes this before choosing Rive).
  static rive.RiveWidgetController controllerFor(rive.File file) =>
      rive.RiveWidgetController(
        file,
        artboardSelector: rive.ArtboardSelector.byName('Buddy'),
        stateMachineSelector: rive.StateMachineSelector.byName('Main'),
      );

  @override
  State<RiveBuddyView> createState() => _RiveBuddyViewState();
}

class _RiveBuddyViewState extends State<RiveBuddyView> {
  late final rive.RiveWidgetController _controller;
  late final rive.ViewModelInstance _vm;

  @override
  void initState() {
    super.initState();
    _controller = RiveBuddyView.controllerFor(widget.file);
    _vm = _controller.dataBind(rive.DataBind.auto());
    _apply();
  }

  @override
  void didUpdateWidget(RiveBuddyView old) {
    super.didUpdateWidget(old);
    _apply();
  }

  /// Pushes every input; unknown/missing properties are skipped so an
  /// older `.riv` keeps working.
  void _apply() {
    final w = widget;
    final l = w.look;
    void color(String name, String hex) =>
        _vm.color(name)?.value = colorFromHex(hex);
    void choice(String name, String value) =>
        _vm.enumerator(name)?.value = value;

    choice('state', w.state.name);
    _vm.boolean('flip')?.value = w.flip;
    _vm.boolean('reduceMotion')?.value = w.reduceMotion;
    color('skin', l.skinHex);
    color('hair', l.hairHex);
    color('jacket', l.jacketHex);
    color('shirt', l.shirtHex);
    color('pants', l.pantsHex);
    color('shoes', l.shoesHex);
    choice('hairStyle', l.hairStyle.name);
    choice('hat', l.hat.name);
    _vm.boolean('spectacles')?.value = l.spectacles;
    // Same fallback chain as the painter (resolveProp): reminder's prop,
    // else the look's usual item, else nothing.
    final wanted = (w.propId == null || w.propId == defaultPropId)
        ? l.defaultPropId
        : w.propId!;
    final prop = propRegistry.containsKey(wanted)
        ? wanted
        : propRegistry.containsKey(l.defaultPropId)
        ? l.defaultPropId
        : 'none';
    choice('prop', prop);
  }

  @override
  void dispose() {
    _vm.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: Strings.buddyLabel,
    hint: Strings.buddyHint,
    button: true,
    child: SizedBox(
      width: widget.width,
      height: widget.width * buddyDesignSize.height / buddyDesignSize.width,
      child: rive.RiveWidget(controller: _controller),
    ),
  );
}
