import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// A focusable surface for Android TV remotes.
///
/// Flutter's default focus traversal already moves between widgets; this adds
/// the pieces a 10-foot UI needs: a visible ring, a small scale-up, Enter /
/// D-pad-center activation and automatic scrolling of the item into view.
class TvFocusable extends StatefulWidget {
  const TvFocusable({
    required this.builder,
    required this.onActivate,
    super.key,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
    this.borderRadius = 6,
    this.scale = 1.05,
    this.revealOnFocus = true,
  });

  final Widget Function(BuildContext context, bool focused) builder;
  final VoidCallback? onActivate;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;
  final double borderRadius;
  final double scale;
  final bool revealOnFocus;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  FocusNode? _ownedNode;
  bool _focused = false;
  bool _hovered = false;

  FocusNode get _node => widget.focusNode ?? (_ownedNode ??= FocusNode());

  @override
  void dispose() {
    _ownedNode?.dispose();
    super.dispose();
  }

  void _activate() {
    if (widget.enabled) widget.onActivate?.call();
  }

  void _handleFocus(bool focused) {
    if (mounted) setState(() => _focused = focused);
    if (!focused || !widget.revealOnFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _focused || _hovered;
    return FocusableActionDetector(
      focusNode: _node,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onShowFocusHighlight: _handleFocus,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      mouseCursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? _activate : null,
          child: AnimatedScale(
            scale: _focused ? widget.scale : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: highlighted
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: widget.builder(context, highlighted),
            ),
          ),
        ),
      ),
    );
  }
}
