import 'package:flutter/material.dart';
import '../theme/color_scheme.dart';
import '../theme/typography.dart';

/// Premium cosmic button with gradient and shimmer
class CosmicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final List<Color>? gradientColors;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const CosmicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradientColors,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.textStyle,
  });

  const CosmicButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradientColors,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.textStyle,
  }) : isOutlined = true;

  @override
  State<CosmicButton> createState() => _CosmicButtonState();
}

class _CosmicButtonState extends State<CosmicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) return _buildOutlined(context);
    return _buildFilled(context);
  }

  Widget _buildFilled(BuildContext context) {
    final gradientColors = widget.gradientColors ??
        [CosmicColors.goldDeep, CosmicColors.gold, CosmicColors.goldLight];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                colors: widget.onPressed == null
                    ? [Colors.grey.shade600, Colors.grey.shade500]
                    : gradientColors,
              ),
              boxShadow: widget.onPressed == null
                  ? null
                  : [
                      BoxShadow(
                        color: CosmicColors.gold.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(child: _buildContent(dark: true)),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlined(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: CosmicColors.gold.withValues(alpha: 0.6),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _buildContent(dark: false),
      ),
    );
  }

  Widget _buildContent({required bool dark}) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: dark ? CosmicColors.bgDeep : CosmicColors.gold,
        ),
      );
    }

    final textStyle = widget.textStyle ??
        TextStyle(
          fontFamily: CosmicTypography.cinzel,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: dark ? CosmicColors.bgDeep : CosmicColors.gold,
        );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 18,
            color: dark ? CosmicColors.bgDeep : CosmicColors.gold,
          ),
          const SizedBox(width: 8),
          Text(widget.label, style: textStyle),
        ],
      );
    }

    return Text(widget.label, style: textStyle);
  }
}

/// Small icon action button
class CosmicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final String? tooltip;

  const CosmicIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (color ?? CosmicColors.gold).withValues(alpha: 0.12),
            border: Border.all(
              color: (color ?? CosmicColors.gold).withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: color ?? CosmicColors.gold,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}
