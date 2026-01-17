import 'package:flutter/material.dart';

class InstaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;

  const InstaButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    // Accessible touch target size (minimum 48x48)
    return Semantics(
      button: true,
      tooltip: tooltip,
      child: Container(
        margin: const EdgeInsets.all(4), // Visual breathing room
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              // Padding/Style handled by Theme/AppTheme, but we ensure size here
              minimumSize: const Size(48, 48),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
