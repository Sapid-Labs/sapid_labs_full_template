import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:slapp/app/services.dart';

/// Represents a single onboarding tip
class OnboardingTip {
  final String id;
  final String title;
  final String message;
  final String buttonText;
  final GlobalKey targetKey;
  final VoidCallback? onDismiss;

  const OnboardingTip({
    required this.id,
    required this.title,
    required this.message,
    required this.targetKey,
    this.buttonText = 'Got it!',
    this.onDismiss,
  });
}

@singleton
class OnboardingService {
  static const String _tipShownPrefix = 'onboarding_tip_shown_';

  /// Check if a specific tip has been shown before
  bool hasTipBeenShown(String tipId) {
    return sharedPrefs.getBool('$_tipShownPrefix$tipId') ?? false;
  }

  /// Mark a specific tip as shown
  Future<void> markTipAsShown(String tipId) async {
    await sharedPrefs.setBool('$_tipShownPrefix$tipId', true);
  }

  /// Show a single tip if it hasn't been shown before
  Future<void> showTipIfNeeded(BuildContext context, OnboardingTip tip) async {
    if (!hasTipBeenShown(tip.id)) {
      // Wait a bit for the UI to settle
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted && tip.targetKey.currentContext != null) {
        _showTip(context, tip);
        await markTipAsShown(tip.id);
      }
    }
  }

  /// Show a sequence of tips one after another with smooth spotlight transitions
  Future<void> showTipSequence(
      BuildContext context, List<OnboardingTip> tips) async {
    // Filter tips that haven't been shown and have valid contexts
    final validTips = <OnboardingTip>[];
    for (final tip in tips) {
      if (!hasTipBeenShown(tip.id)) {
        // Wait a bit for the UI to settle
        await Future.delayed(const Duration(milliseconds: 100));

        if (context.mounted && tip.targetKey.currentContext != null) {
          validTips.add(tip);
        } else {
          debugPrint(
            'Tip ${tip.id} target key context is null, skipping',
          );
        }
      } else {
        debugPrint(
          'Tip ${tip.id} has already been shown, skipping',
        );
      }
    }

    if (validTips.isEmpty) return;

    // Show the sequence with animated transitions
    await _showAnimatedTipSequence(context, validTips);
  }

  /// Show an animated sequence of tips with smooth spotlight transitions
  Future<void> _showAnimatedTipSequence(
      BuildContext context, List<OnboardingTip> validTips) async {
    if (validTips.isEmpty) return;

    final completer = Completer<void>();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AnimatedOnboardingSequence(
          tips: validTips,
          onComplete: () async {
            Navigator.of(dialogContext).pop();
            completer.complete();
          },
          onTipShown: (tipId) async {
            await markTipAsShown(tipId);
          },
        );
      },
    );

    return completer.future;
  }

  /// Show a single tip overlay
  void _showTip(BuildContext context, OnboardingTip tip) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false, // Prevent accidental dismissal
      anchorPoint: Offset(0, 0),
      useSafeArea: false,
      builder: (BuildContext context) {
        return OnboardingTipOverlay(
          tip: tip,
          onDismiss: () {
            Navigator.of(context).pop();
            tip.onDismiss?.call();
          },
        );
      },
    );
  }

  /// Force show a tip (for testing purposes)
  void forceShowTip(BuildContext context, OnboardingTip tip) {
    _showTip(context, tip);
  }

  /// Reset a specific tip (for testing purposes)
  Future<void> resetTip(String tipId) async {
    await sharedPrefs.remove('$_tipShownPrefix$tipId');
  }

  /// Reset all tips (for testing purposes)
  Future<void> resetAllTips() async {
    final keys = sharedPrefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tipShownPrefix)) {
        await sharedPrefs.remove(key);
      }
    }
  }
}

class AnimatedOnboardingSequence extends StatefulWidget {
  final List<OnboardingTip> tips;
  final VoidCallback onComplete;
  final Function(String) onTipShown;

  const AnimatedOnboardingSequence({
    super.key,
    required this.tips,
    required this.onComplete,
    required this.onTipShown,
  });

  @override
  State<AnimatedOnboardingSequence> createState() =>
      _AnimatedOnboardingSequenceState();
}

class _AnimatedOnboardingSequenceState extends State<AnimatedOnboardingSequence>
    with TickerProviderStateMixin {
  late AnimationController _spotlightController;
  late AnimationController _tipController;
  Animation<Rect?>? _spotlightAnimation;
  late Animation<double> _tipOpacity;

  int _currentTipIndex = 0;
  Rect? _currentSpotlightRect;

  @override
  void initState() {
    super.initState();

    _spotlightController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _tipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tipOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tipController,
      curve: Curves.easeInOut,
    ));

    _initializeFirstTip();
  }

  @override
  void dispose() {
    _spotlightController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  void _initializeFirstTip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.tips.isNotEmpty) {
        final firstTip = widget.tips[0];
        final rect = _getRectFromTip(firstTip);
        if (rect != null) {
          setState(() {
            _currentSpotlightRect = rect;
          });
          _tipController.forward();
        }
      }
    });
  }

  Rect? _getRectFromTip(OnboardingTip tip) {
    final context = tip.targetKey.currentContext;
    if (context == null) return null;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );
  }

  Future<void> _nextTip() async {
    if (_currentTipIndex >= widget.tips.length - 1) {
      // Last tip, complete the sequence
      await widget.onTipShown(widget.tips[_currentTipIndex].id);
      widget.onComplete();
      return;
    }

    // Mark current tip as shown
    await widget.onTipShown(widget.tips[_currentTipIndex].id);

    // Prepare for next tip
    final nextIndex = _currentTipIndex + 1;
    final nextTip = widget.tips[nextIndex];
    final nextRect = _getRectFromTip(nextTip);

    if (nextRect == null) {
      // Skip to next tip if context is null
      setState(() {
        _currentTipIndex = nextIndex;
      });
      _nextTip();
      return;
    }

    // Fade out current tip
    await _tipController.reverse();

    // Animate spotlight to next position
    if (_currentSpotlightRect != null) {
      _spotlightAnimation = RectTween(
        begin: _currentSpotlightRect,
        end: nextRect,
      ).animate(CurvedAnimation(
        parent: _spotlightController,
        curve: Curves.easeInOut,
      ));

      _spotlightController.reset();
      await _spotlightController.forward();
    }

    // Update state and fade in new tip
    setState(() {
      _currentTipIndex = nextIndex;
      _currentSpotlightRect = nextRect;
    });

    await _tipController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tips.isEmpty || _currentTipIndex >= widget.tips.length) {
      return const SizedBox.shrink();
    }

    final currentTip = widget.tips[_currentTipIndex];
    final isLastTip = _currentTipIndex == widget.tips.length - 1;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Animated spotlight
          if (_currentSpotlightRect != null)
            AnimatedBuilder(
              animation: _spotlightController,
              builder: (context, child) {
                final targetRect =
                    _spotlightAnimation?.value ?? _currentSpotlightRect!;
                return Positioned.fill(
                  child: CustomPaint(
                    painter: SpotlightPainter(
                      targetRect: targetRect,
                      overlayColor: Colors.black.withOpacity(0.4),
                    ),
                  ),
                );
              },
            ),
          // Animated tip overlay
          if (_currentSpotlightRect != null)
            AnimatedBuilder(
              animation: _tipOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _tipOpacity.value,
                  child: OnboardingTipOverlay(
                    tip: OnboardingTip(
                      id: currentTip.id,
                      title: currentTip.title,
                      message: currentTip.message,
                      targetKey: currentTip.targetKey,
                      buttonText: isLastTip ? currentTip.buttonText : 'Next',
                      onDismiss: currentTip.onDismiss,
                    ),
                    onDismiss: _nextTip,
                    customTargetRect:
                        _spotlightAnimation?.value ?? _currentSpotlightRect!,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class OnboardingTipOverlay extends StatelessWidget {
  final OnboardingTip tip;
  final VoidCallback? onDismiss;
  final Rect? customTargetRect;

  const OnboardingTipOverlay({
    super.key,
    required this.tip,
    this.onDismiss,
    this.customTargetRect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Highlighted widget and tip box with spotlight effect
          if (customTargetRect != null || tip.targetKey.currentContext != null)
            _buildSpotlightEffect(context),
        ],
      ),
    );
  }

  Widget _buildSpotlightEffect(BuildContext context) {
    // Use custom target rect if provided, otherwise calculate from tip's target key
    Offset targetPosition;
    Size targetSize;

    if (customTargetRect != null) {
      targetPosition = customTargetRect!.topLeft;
      targetSize = customTargetRect!.size;
    } else if (tip.targetKey.currentContext != null) {
      final RenderBox targetBox =
          tip.targetKey.currentContext!.findRenderObject() as RenderBox;
      targetPosition = targetBox.localToGlobal(Offset.zero);
      targetSize = targetBox.size;
    } else {
      // Fallback if no target is available
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Create spotlight cutout for target widget
        _buildSpotlightCutout(context, targetPosition, targetSize),
        // Tip box with arrow
        _buildTipWithArrow(context, targetPosition, targetSize, screenSize),
      ],
    );
  }

  Widget _buildSpotlightCutout(
      BuildContext context, Offset targetPosition, Size targetSize) {
    // Apply the same visual adjustments that were applied to tip positioning
    // to ensure the spotlight aligns perfectly with the tip box positioning
    final adjustedTargetPosition = Offset(
      targetPosition.dx,
      targetPosition.dy,
    );

    return Positioned.fill(
      child: CustomPaint(
        painter: SpotlightPainter(
          targetRect: Rect.fromLTWH(
            adjustedTargetPosition.dx,
            adjustedTargetPosition.dy,
            targetSize.width,
            targetSize.height,
          ),
          overlayColor: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTipWithArrow(BuildContext context, Offset targetPosition,
      Size targetSize, Size screenSize) {
    // Calculate optimal tip size based on content
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500);

    const double padding = 32; // 16px on each side
    const double buttonHeight = 36;
    const double spacing = 8; // Between elements

    // Calculate size for title + message + button
    final titlePainter = tip.title.isNotEmpty
        ? TextPainter(
            text: TextSpan(
              text: tip.title,
              style: textStyle?.copyWith(fontWeight: FontWeight.w600),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )
        : null;
    titlePainter?.layout(maxWidth: 240);

    final messagePainter = TextPainter(
      text: TextSpan(text: tip.message, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    messagePainter.layout(maxWidth: 240 - padding);

    final double titleHeight = titlePainter?.height ?? 0;
    final double titleSpacing = tip.title.isNotEmpty ? spacing : 0;

    final double maxTextWidth = [
      titlePainter?.width ?? 0,
      messagePainter.width,
    ].reduce((a, b) => a > b ? a : b);

    final double tipWidth = (maxTextWidth + padding).clamp(200.0, 300.0);

    // Add extra height for multi-line messages to account for proper line spacing
    final int messageLines = messagePainter.computeLineMetrics().length;
    final double adjustedMessageHeight =
        messagePainter.height + (messageLines > 1 ? (messageLines - 1) * 4 : 0);

    final double tipHeight = titleHeight +
        titleSpacing +
        adjustedMessageHeight +
        spacing +
        buttonHeight +
        padding +
        16; // Extra padding for better visual spacing

    const double arrowSize = 12;
    const double margin = 16;

    // Calculate tip position - try below first, then above if no space
    final double spaceBelow =
        screenSize.height - (targetPosition.dy + targetSize.height);
    final double spaceAbove = targetPosition.dy;

    bool showBelow = spaceBelow >= tipHeight + arrowSize + margin;
    if (!showBelow && spaceAbove < tipHeight + arrowSize + margin) {
      // If neither position has enough space, choose the one with more space
      showBelow = spaceBelow > spaceAbove;
    }

    // Calculate horizontal position (center the tip with the target widget)
    double tipX = targetPosition.dx + (targetSize.width / 2) - (tipWidth / 2);

    // Ensure tip stays within screen bounds
    if (tipX < margin) {
      tipX = margin;
    } else if (tipX + tipWidth > screenSize.width - margin) {
      tipX = screenSize.width - tipWidth - margin;
    }

    // Calculate vertical position
    double tipY;
    if (showBelow) {
      // Position tip box accounting for internal arrow margin and padding
      // Add extra space between the target widget and tip box for better visual separation
      tipY = targetPosition.dy + targetSize.height + 16; // Added 16px spacing
    } else {
      // Position tip box accounting for container padding and visual spacing
      // Add extra space above the target widget for better visual separation
      tipY = targetPosition.dy - tipHeight - 16; // Added 16px spacing
    }

    // Ensure tip doesn't go off screen vertically
    if (showBelow) {
      // When showing below, ensure the bottom of the tip box doesn't exceed screen bounds
      if (tipY + tipHeight + arrowSize > screenSize.height - margin) {
        tipY = screenSize.height - tipHeight - arrowSize - margin;
      }
    } else {
      // When showing above, ensure the top doesn't go above screen bounds
      if (tipY < margin) {
        tipY = margin;
      }
    }

    // Calculate arrow position relative to tip box
    final double targetCenterX = targetPosition.dx + (targetSize.width / 2);
    double arrowX = targetCenterX - tipX;

    // Ensure arrow stays within tip box bounds (with some padding)
    const double arrowPadding = 20;
    arrowX = arrowX.clamp(arrowPadding, tipWidth - arrowPadding);

    return Positioned(
      left: tipX,
      top: tipY,
      child: TipBox(
        width: tipWidth,
        height: tipHeight,
        arrowPosition: arrowX,
        pointingUp: showBelow,
        arrowSize: arrowSize,
        tip: tip,
        onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}

class TipBox extends StatelessWidget {
  final double width;
  final double height;
  final double arrowPosition;
  final bool pointingUp;
  final double arrowSize;
  final OnboardingTip tip;
  final VoidCallback onDismiss;

  const TipBox({
    super.key,
    required this.width,
    required this.height,
    required this.arrowPosition,
    required this.pointingUp,
    required this.arrowSize,
    required this.tip,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height + arrowSize),
      painter: TipBoxPainter(
        arrowPosition: arrowPosition,
        pointingUp: pointingUp,
        arrowSize: arrowSize,
        backgroundColor: Theme.of(context).cardColor,
        borderColor: Theme.of(context).dividerColor,
      ),
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(
          top: pointingUp ? arrowSize : 0,
          bottom: pointingUp ? 0 : arrowSize,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tip.title.isNotEmpty) ...[
                    Text(
                      tip.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    tip.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36, // Fixed height for button
              child: TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  minimumSize: const Size(80, 36),
                ),
                child: Text(tip.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipBoxPainter extends CustomPainter {
  final double arrowPosition;
  final bool pointingUp;
  final double arrowSize;
  final Color backgroundColor;
  final Color borderColor;

  TipBoxPainter({
    required this.arrowPosition,
    required this.pointingUp,
    required this.arrowSize,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    const double radius = 8;
    final double boxHeight = size.height - arrowSize;

    // Calculate box position
    final double boxTop = pointingUp ? arrowSize : 0;
    final double boxBottom = pointingUp ? size.height : boxHeight;

    // Create the main box path
    final Path boxPath = Path();
    final RRect boxRect = RRect.fromLTRBR(
        0, boxTop, size.width, boxBottom, const Radius.circular(radius));
    boxPath.addRRect(boxRect);

    // Create arrow path
    final Path arrowPath = Path();

    // Ensure arrow position is within bounds
    final double clampedArrowPosition =
        arrowPosition.clamp(arrowSize + 5, size.width - arrowSize - 5);
    final double arrowLeft = clampedArrowPosition - arrowSize;
    final double arrowRight = clampedArrowPosition + arrowSize;

    if (pointingUp) {
      // Arrow pointing up
      arrowPath.moveTo(arrowLeft, arrowSize);
      arrowPath.lineTo(clampedArrowPosition, 0);
      arrowPath.lineTo(arrowRight, arrowSize);
    } else {
      // Arrow pointing down
      arrowPath.moveTo(arrowLeft, boxHeight);
      arrowPath.lineTo(clampedArrowPosition, size.height);
      arrowPath.lineTo(arrowRight, boxHeight);
    }

    // Combine box and arrow
    final Path fullPath = Path.combine(PathOperation.union, boxPath, arrowPath);

    // Draw shadow
    canvas.drawPath(fullPath, shadowPaint);

    // Draw filled shape
    canvas.drawPath(fullPath, paint);

    // Draw border
    canvas.drawPath(fullPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final Color overlayColor;

  SpotlightPainter({
    required this.targetRect,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Create the main overlay path covering the entire available area
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create the cutout path for the target widget with rounded corners
    // Add more generous padding around target for better visual effect
    final Path cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect.inflate(4),
        const Radius.circular(12), // Increased radius for smoother appearance
      ));

    // Subtract the cutout from the overlay to create the spotlight effect
    final Path spotlightPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      cutoutPath,
    );

    // Draw the overlay with cutout
    canvas.drawPath(spotlightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SpotlightPainter &&
        (oldDelegate.targetRect != targetRect ||
            oldDelegate.overlayColor != overlayColor);
  }
}
