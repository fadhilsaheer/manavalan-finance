import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme.dart';

Duration motionDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 280);

/// Keeps ledger pages mounted while animating only the two visible pages.
class AnimatedTabDeck extends StatefulWidget {
  final int index;
  final List<Widget> children;
  const AnimatedTabDeck({
    super.key,
    required this.index,
    required this.children,
  });
  @override
  State<AnimatedTabDeck> createState() => _AnimatedTabDeckState();
}

class _AnimatedTabDeckState extends State<AnimatedTabDeck>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
        value: 1,
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && previous != null) {
          setState(() => previous = null);
        }
      });
  int? previous;
  double direction = 1;
  @override
  void didUpdateWidget(AnimatedTabDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      direction = widget.index > oldWidget.index ? 1 : -1;
      if (MediaQuery.disableAnimationsOf(context)) {
        previous = null;
        controller.value = 1;
      } else {
        previous = oldWidget.index;
        controller.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      previous = null;
      controller.value = 1;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final progress = Curves.easeOutCubic.transform(controller.value);
      final arriving = Curves.easeOutCubic.transform(
        ((controller.value - .18) / .82).clamp(0.0, 1.0),
      );
      final leaving = (1 - controller.value / .32).clamp(0.0, 1.0);
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              Offstage(
                key: ValueKey(i),
                offstage: i != widget.index && i != previous,
                child: TickerMode(
                  enabled: i == widget.index,
                  child: IgnorePointer(
                    ignoring: i != widget.index,
                    child: ExcludeSemantics(
                      excluding: i != widget.index,
                      child: FractionalTranslation(
                        translation: Offset(
                          i == widget.index
                              ? direction * .055 * (1 - progress)
                              : -direction * .035 * progress,
                          0,
                        ),
                        child: Opacity(
                          opacity: i == widget.index ? arriving : leaving,
                          child: widget.children[i],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class FrostedNavigation extends StatelessWidget {
  final int index;
  final List<IconData> icons;
  final List<String> labels;
  final ValueChanged<int> onSelected;
  const FrostedNavigation({
    super.key,
    required this.index,
    required this.icons,
    required this.labels,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(38),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(
                alpha: MediaQuery.highContrastOf(context) ? .96 : .72,
              ),
              Colors.white.withValues(
                alpha: MediaQuery.highContrastOf(context) ? .9 : .40,
              ),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: .65)),
          borderRadius: BorderRadius.circular(38),
        ),
        child: SizedBox(
          height: 68,
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                AnimatedPositioned(
                  key: const ValueKey('navigation-indicator'),
                  duration: motionDuration(context),
                  curve: Curves.easeOutCubic,
                  left:
                      constraints.maxWidth / labels.length * (index + .5) - 26,
                  top: 8,
                  width: 52,
                  height: 52,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.text,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Row(
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Expanded(
                          child: Semantics(
                            selected: index == i,
                            button: true,
                            child: Tooltip(
                              message: labels[i],
                              child: InkResponse(
                                onTap: () => onSelected(i),
                                radius: 28,
                                child: SizedBox(
                                  height: 68,
                                  child: Center(
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: motionDuration(context),
                                      curve: Curves.easeOutCubic,
                                      tween: ColorTween(
                                        end: index == i
                                            ? Colors.white
                                            : AppTheme.text,
                                      ),
                                      builder: (context, color, _) => Icon(
                                        icons[i],
                                        size: 23,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
