// withOpacity is deprecated in newer Flutter versions but withValues is not supported in the project's target SDK range.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _scale = 1 - _controller.value;

    final primaryStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: theme.primaryColor.withOpacity(0.6),
    );

    final secondaryStyle = OutlinedButton.styleFrom(
      foregroundColor: theme.primaryColor,
      side: BorderSide(color: theme.primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: const Size.fromHeight(52),
    );

    Widget buttonContent;
    if (widget.isLoading) {
      buttonContent = const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      buttonContent = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: 8),
          ],
          Text(widget.label),
        ],
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: widget.isPrimary
              ? ElevatedButton(
                  style: primaryStyle,
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  child: buttonContent,
                )
              : OutlinedButton(
                  style: secondaryStyle,
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  child: buttonContent,
                ),
        ),
      ),
    );
  }
}
