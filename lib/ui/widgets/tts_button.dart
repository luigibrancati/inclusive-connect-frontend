import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/tts_service.dart';

class TTSButton extends StatelessWidget {
  final String text;
  final String id;
  final IconData startIcon;
  final IconData stopIcon;
  final double iconSize;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;

  const TTSButton({
    super.key,
    required this.text,
    required this.id,
    this.startIcon = Icons.volume_up,
    this.stopIcon = Icons.stop_circle_outlined,
    this.iconSize = 24.0,
    this.color,
    this.padding = const EdgeInsets.all(8.0),
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // Watch the service to react to changes in speaking state
    final ttsService = context.watch<TtsService>();
    final isPlaying = ttsService.currentSpeakingId == id;

    return IconButton(
      icon: Icon(
        isPlaying ? stopIcon : startIcon,
        size: iconSize,
        color: color,
      ),
      padding: padding,
      constraints: constraints,
      onPressed: () async {
        if (isPlaying) {
          await ttsService.stop();
        } else {
          // Stop any current speech before starting new one (optional, but good practice)
          // The service.speak usually handles overriding, but explicit stop is safe.
          await ttsService.stop();
          await ttsService.speak(text, id: id);
        }
      },
    );
  }
}
