import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/color_scheme.dart';
import '../theme/typography.dart';

/// A custom Material 3-styled time picker that correctly handles the circular
/// dial gesture without any left/right sliding conflict.
class CosmicTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  const CosmicTimePicker({super.key, required this.initialTime});

  /// Show the time picker dialog and return the selected [TimeOfDay].
  static Future<TimeOfDay?> show(BuildContext context, TimeOfDay initialTime) {
    return showDialog<TimeOfDay>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => CosmicTimePicker(initialTime: initialTime),
    );
  }

  @override
  State<CosmicTimePicker> createState() => _CosmicTimePickerState();
}

enum _TimeMode { hour, minute }

class _CosmicTimePickerState extends State<CosmicTimePicker>
    with SingleTickerProviderStateMixin {
  late int _hour24; // 0–23
  late int _minute; // 0–59
  _TimeMode _mode = _TimeMode.hour;
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  double _lastAngle = 0.0;

  // 12-hour display value (1–12)
  int get _hour12 {
    final h = _hour24 % 12;
    return h == 0 ? 12 : h;
  }

  bool get _isAm => _hour24 < 12;

  @override
  void initState() {
    super.initState();
    _hour24 = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _handAnimation = CurvedAnimation(
      parent: _handController,
      curve: Curves.easeOut,
    );
    _handController.forward();
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  void _switchMode(_TimeMode mode) {
    setState(() => _mode = mode);
    _handController.forward(from: 0.0);
  }

  /// Converts a touch position on the dial to an angle (0° = top, clockwise).
  double _angleFromOffset(Offset pos, Offset center) {
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;
    // atan2(x, -y) gives 0 at top, going clockwise
    return ((math.atan2(dx, -dy) * 180.0 / math.pi) + 360.0) % 360.0;
  }

  void _onPanDown(DragDownDetails details, Size dialSize) {
    final center = Offset(dialSize.width / 2, dialSize.height / 2);
    _lastAngle = _angleFromOffset(details.localPosition, center);
  }

  void _onPanUpdate(DragUpdateDetails details, Size dialSize) {
    final center = Offset(dialSize.width / 2, dialSize.height / 2);
    final dist = (details.localPosition - center).distance;
    // Dead-zone at center to avoid accidental jumps
    if (dist < 16) return;

    final angle = _angleFromOffset(details.localPosition, center);
    _lastAngle = angle;
    HapticFeedback.selectionClick();

    setState(() {
      if (_mode == _TimeMode.hour) {
        final h = ((angle / 30.0).round()) % 12;
        _hour24 = _isAm ? h : h + 12;
      } else {
        _minute = ((angle / 6.0).round()) % 60;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Auto-advance to minute selection after choosing an hour
    if (_mode == _TimeMode.hour) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _switchMode(_TimeMode.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CosmicColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header label ─────────────────────────────────────────
            Text(
              'SELECT TIME',
              style: TextStyle(
                fontFamily: CosmicTypography.inter,
                fontSize: 11,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w600,
                color: CosmicColors.textMed,
              ),
            ),
            const SizedBox(height: 16),

            // ── Time display row ──────────────────────────────────────
            Row(
              children: [
                _TimeSegment(
                  value: _hour12.toString().padLeft(2, '0'),
                  isSelected: _mode == _TimeMode.hour,
                  onTap: () => _switchMode(_TimeMode.hour),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontFamily: CosmicTypography.cinzel,
                      fontSize: 44,
                      color: CosmicColors.textHigh,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _TimeSegment(
                  value: _minute.toString().padLeft(2, '0'),
                  isSelected: _mode == _TimeMode.minute,
                  onTap: () => _switchMode(_TimeMode.minute),
                ),
                const SizedBox(width: 12),

                // ── AM/PM column ───────────────────────────────────
                Column(
                  children: [
                    _AmPmChip(
                      label: 'AM',
                      isSelected: _isAm,
                      onTap: () {
                        if (!_isAm) setState(() => _hour24 -= 12);
                      },
                    ),
                    const SizedBox(height: 6),
                    _AmPmChip(
                      label: 'PM',
                      isSelected: !_isAm,
                      onTap: () {
                        if (_isAm) setState(() => _hour24 += 12);
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Dial ─────────────────────────────────────────────────
            Center(
              child: Builder(builder: (context) {
                const double dialSize = 260.0;
                return SizedBox(
                  width: dialSize,
                  height: dialSize,
                  child: GestureDetector(
                    // The GestureDetector here is isolated — there's no
                    // conflicting PageView or ScrollView in this custom dialog,
                    // so pan gestures map cleanly to dial rotation.
                    onPanDown: (d) =>
                        _onPanDown(d, const Size(dialSize, dialSize)),
                    onPanUpdate: (d) =>
                        _onPanUpdate(d, const Size(dialSize, dialSize)),
                    onPanEnd: _onPanEnd,
                    child: AnimatedBuilder(
                      animation: _handAnimation,
                      builder: (_, __) => CustomPaint(
                        painter: _DialPainter(
                          mode: _mode,
                          hour12: _hour12,
                          minute: _minute,
                          primaryColor: CosmicColors.gold,
                          faceColor: CosmicColors.bgDeep,
                          textColor: CosmicColors.textHigh,
                          animValue: _handAnimation.value,
                        ),
                        size: const Size(dialSize, dialSize),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // ── Action buttons ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Mode hint
                Expanded(
                  child: Text(
                    _mode == _TimeMode.hour ? 'Tap to set minutes' : 'Tap to set hours',
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 11,
                      color: CosmicColors.textMed,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      color: CosmicColors.textMed,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    TimeOfDay(hour: _hour24, minute: _minute),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      color: CosmicColors.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────

class _TimeSegment extends StatelessWidget {
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeSegment({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 80,
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? CosmicColors.gold.withValues(alpha: 0.18)
              : CosmicColors.bgDeep,
          border: Border.all(
            color: isSelected
                ? CosmicColors.gold
                : CosmicColors.gold.withValues(alpha: 0.0),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            fontFamily: CosmicTypography.cinzel,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: isSelected ? CosmicColors.gold : CosmicColors.textHigh,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _AmPmChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmPmChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 54,
        height: 31,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? CosmicColors.gold
              : CosmicColors.bgDeep,
          border: Border.all(
            color: isSelected
                ? CosmicColors.gold
                : CosmicColors.textMed.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: CosmicTypography.inter,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? CosmicColors.bgDeep : CosmicColors.textMed,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ─── Custom Dial Painter ───────────────────────────────────────────────────

class _DialPainter extends CustomPainter {
  final _TimeMode mode;
  final int hour12; // 1–12
  final int minute; // 0–59
  final Color primaryColor;
  final Color faceColor;
  final Color textColor;
  final double animValue;

  const _DialPainter({
    required this.mode,
    required this.hour12,
    required this.minute,
    required this.primaryColor,
    required this.faceColor,
    required this.textColor,
    this.animValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Clock face background ───────────────────────────────────────
    canvas.drawCircle(center, radius, Paint()..color = faceColor);

    if (mode == _TimeMode.hour) {
      _paintHours(canvas, center, radius);
    } else {
      _paintMinutes(canvas, center, radius);
    }

    // ── Center pivot dot ───────────────────────────────────────────
    canvas.drawCircle(center, 5, Paint()..color = primaryColor);
  }

  // ── Hours ────────────────────────────────────────────────────────────────

  void _paintHours(Canvas canvas, Offset center, double radius) {
    const labels = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    final numberRadius = radius * 0.76;
    final handAngleDeg = (hour12 % 12) * 30.0;
    final handAngle = handAngleDeg * math.pi / 180 - math.pi / 2;
    final handLength = numberRadius * animValue;

    // Hand line
    final handEnd = Offset(
      center.dx + handLength * math.cos(handAngle),
      center.dy + handLength * math.sin(handAngle),
    );
    canvas.drawLine(
      center,
      handEnd,
      Paint()
        ..color = primaryColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Numbers
    for (int i = 0; i < 12; i++) {
      final angleDeg = i * 30.0;
      final angle = angleDeg * math.pi / 180 - math.pi / 2;
      final nx = center.dx + numberRadius * math.cos(angle);
      final ny = center.dy + numberRadius * math.sin(angle);
      final isSelected = labels[i] == hour12;

      if (isSelected) {
        canvas.drawCircle(
          Offset(nx, ny),
          radius * 0.125,
          Paint()..color = primaryColor,
        );
      }

      _drawLabel(canvas, Offset(nx, ny), labels[i].toString(),
          isSelected ? faceColor : textColor, radius * 0.115);
    }

    // Dot at hand tip (inside the selected circle)
    canvas.drawCircle(handEnd, radius * 0.125, Paint()..color = primaryColor);
  }

  // ── Minutes ───────────────────────────────────────────────────────────────

  void _paintMinutes(Canvas canvas, Offset center, double radius) {
    final numberRadius = radius * 0.80;
    final handAngle = minute * 6.0 * math.pi / 180 - math.pi / 2;
    final handLength = numberRadius * animValue;

    // Hand line
    final handEnd = Offset(
      center.dx + handLength * math.cos(handAngle),
      center.dy + handLength * math.sin(handAngle),
    );
    canvas.drawLine(
      center,
      handEnd,
      Paint()
        ..color = primaryColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 5-minute number labels
    for (int i = 0; i < 12; i++) {
      final m = i * 5;
      final angleDeg = m * 6.0;
      final angle = angleDeg * math.pi / 180 - math.pi / 2;
      final nx = center.dx + numberRadius * math.cos(angle);
      final ny = center.dy + numberRadius * math.sin(angle);
      final isSelected = minute == m;

      if (isSelected) {
        canvas.drawCircle(
          Offset(nx, ny),
          radius * 0.115,
          Paint()..color = primaryColor,
        );
      }

      _drawLabel(canvas, Offset(nx, ny), m.toString().padLeft(2, '0'),
          isSelected ? faceColor : textColor, radius * 0.105);
    }

    // Small tick marks for non-5 minutes
    final tickPaint = Paint()
      ..color = textColor.withValues(alpha: 0.28)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 60; i++) {
      if (i % 5 == 0) continue;
      final angle = i * 6.0 * math.pi / 180 - math.pi / 2;
      final isSelected = minute == i;
      if (isSelected) {
        final selX = center.dx + numberRadius * math.cos(angle);
        final selY = center.dy + numberRadius * math.sin(angle);
        canvas.drawCircle(
          Offset(selX, selY),
          radius * 0.05,
          Paint()..color = primaryColor,
        );
      } else {
        final outerX = center.dx + radius * 0.90 * math.cos(angle);
        final outerY = center.dy + radius * 0.90 * math.sin(angle);
        final innerX = center.dx + radius * 0.86 * math.cos(angle);
        final innerY = center.dy + radius * 0.86 * math.sin(angle);
        canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
      }
    }

    // Dot at hand tip
    canvas.drawCircle(handEnd, radius * 0.115, Paint()..color = primaryColor);
  }

  // ── Text helper ───────────────────────────────────────────────────────────

  void _drawLabel(Canvas canvas, Offset pos, String text, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.mode != mode ||
      old.hour12 != hour12 ||
      old.minute != minute ||
      old.animValue != animValue;
}
