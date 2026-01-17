import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:inclusive_connect/data/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AudioPostWidget extends StatefulWidget {
  final String? audioUrl;
  final String? filePath;
  final String colorHex;

  const AudioPostWidget({
    super.key,
    this.audioUrl,
    this.filePath,
    required this.colorHex,
  });

  @override
  State<AudioPostWidget> createState() => _AudioPostWidgetState();
}

class _AudioPostWidgetState extends State<AudioPostWidget> {
  late AudioPlayer _audioPlayer;
  String? _filePath;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  List<double> _barHeights = List.generate(30, (_) => 0.1);

  @override
  void initState() {
    super.initState();
    debugPrint("AudioPostWidgetState Audio URL: ${widget.audioUrl}");
    debugPrint("AudioPostWidgetState File path: ${widget.filePath}");
    debugPrint("AudioPostWidgetState Color Hex: ${widget.colorHex}");
    if (widget.filePath == null && widget.audioUrl == null) {
      throw Exception("File path and URL cannot both be null");
    }
    _audioPlayer = AudioPlayer();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      }
    });

    _loadAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.filePath != null) {
      debugPrint(
        "AudioPostWidgetState widget.filePath is not null, setting _filePath to ${widget.filePath}",
      );
      _filePath = widget.filePath;
    } else {
      debugPrint(
        "AudioPostWidgetState widget.filePath is null, downloading file from ${widget.audioUrl}",
      );
      final storageService = context.read<StorageService>();
      final url = await storageService.getDownloadUrl(widget.audioUrl!);
      // Download file locally
      _filePath = await _downloadFile(url);
      debugPrint(
        "AudioPostWidgetState _filePath set to $_filePath after downloading file from ${widget.audioUrl}",
      );
    }

    await _audioPlayer.setFilePath(_filePath!);
    await _extractWaveform(_filePath!);
    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });
  }

  Future<String?> _downloadFile(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/audio.mp3';
      final file = File(tempPath);
      if (await file.exists()) {
        return tempPath;
      }

      await Dio().download(url, tempPath);
      return tempPath;
    } catch (e) {
      debugPrint("Error downloading file for waveform: $e");
      return null;
    }
  }

  Future<void> _extractWaveform(String? path) async {
    try {
      if (path == null) {
        if (mounted) _fallbackToRandom();
        return;
      }
      final controller = PlayerController();

      final List<double> extractedData = [];
      final completer = Completer<void>();

      // Use dynamic to bypass potential lint if version mismatch,
      // but targeting audio_waveforms 2.0+ API.
      // onCurrentExtractedWaveformData is a Stream<List<double>>.

      StreamSubscription? subscription;

      try {
        final stream =
            (controller as dynamic).onCurrentExtractedWaveformData
                as Stream<List<double>>;
        subscription = stream.listen(
          (data) {
            extractedData.addAll(data);
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete();
          },
          onError: (e) {
            debugPrint("Waveform stream error: $e");
            if (!completer.isCompleted) completer.complete();
          },
        );
      } catch (e) {
        debugPrint("Stream access failed (API mismatch?): $e");
      }

      // Prepare player (triggers extraction)
      // casting preparePlayer too just in case of slight signature mismatch, though unlikely.
      await controller.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 30,
        volume: 0.0,
      );

      // Wait for data collection
      int checks = 0;
      // Wait roughly 2 seconds max
      while (extractedData.length < 30 && checks < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        checks++;
      }

      await subscription?.cancel();
      controller.dispose();

      if (extractedData.isNotEmpty) {
        _processAndSetBars(extractedData);
      } else {
        // Try one last check of .waveformData property if stream was empty
        try {
          final List<double> fallbackData =
              (controller as dynamic).waveformData;
          if (fallbackData.isNotEmpty) {
            _processAndSetBars(fallbackData);
            return;
          }
        } catch (e) {}

        debugPrint("No waveform data extracted from $path");
        if (mounted) _fallbackToRandom();
      }
    } catch (e) {
      debugPrint("Error extracting waveform: $e");
      if (mounted) _fallbackToRandom();
    }
  }

  void _fallbackToRandom() {
    setState(() {
      _barHeights = _generateRandomHeights();
    });
  }

  void _processAndSetBars(List<double> rawData) {
    // Downsample/Upsample to fixed 30 bars
    List<double> samples = rawData;
    if (samples.isEmpty) return;

    // If we have many, we take averages.
    // audio_waveforms tries to respect noOfSamples but might give more/less.

    List<double> finalBars = [];
    if (samples.length >= 30) {
      int chunkSize = (samples.length / 30).floor();
      if (chunkSize < 1) chunkSize = 1;

      for (int i = 0; i < 30; i++) {
        // take max in chunk
        double maxInChunk = 0;
        int start = i * chunkSize;
        int end = min(start + chunkSize, samples.length);
        for (int j = start; j < end; j++) {
          if (samples[j].abs() > maxInChunk) maxInChunk = samples[j].abs();
        }
        finalBars.add(maxInChunk);
      }
    } else {
      // If less than 30, we stretch? or just pad?
      // Let's stretch. logic is complex for simple task.
      // Just use what we have and loop/pad?
      // Or just standard resize algo.

      // Simple: interpolate
      double step = samples.length / 30;
      for (int i = 0; i < 30; i++) {
        int idx = (i * step).floor();
        if (idx >= samples.length) idx = samples.length - 1;
        finalBars.add(samples[idx].abs());
      }
    }

    double maxAmplitude = finalBars.reduce(max);
    if (maxAmplitude == 0) maxAmplitude = 1;

    final normalized = finalBars.map((h) {
      double norm = h / maxAmplitude;
      return 0.2 + (norm * 0.8);
    }).toList();

    if (mounted) {
      setState(() {
        _barHeights = normalized;
      });
    }
  }

  // _processSamples is no longer needed if we get 30 samples directly,
  // or we can reuse logic if we get raw data.
  // extractWaveformData returns List<double>.

  List<double> _generateRandomHeights() {
    final random = Random();
    return List.generate(30, (_) => 0.3 + (random.nextDouble() * 0.7));
  }

  Future<void> _togglePlay() async {
    try {
      if (!_isInitialized) {
        setState(() {
          _isLoading = true;
        });
        await _loadAudio();
      }

      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to play audio')));
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      final random = Random();
      return Colors.primaries[random.nextInt(Colors.primaries.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(widget.colorHex);
    // Using AspectRatio 1 to create a square canvas.
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.3)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 0.8 * MediaQuery.of(context).size.width,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black87,
                    size: 32,
                  ),
                  onPressed: _togglePlay,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshotPosition) {
                    final position = snapshotPosition.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: _audioPlayer.durationStream,
                      builder: (context, snapshotDuration) {
                        final duration = snapshotDuration.data ?? Duration.zero;
                        final maxDurationMs = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;
                        final currentMs = position.inMilliseconds.toDouble();
                        final progress = (currentMs / maxDurationMs).clamp(
                          0.0,
                          1.0,
                        );

                        // Custom waveform visualization
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                final dx = details.localPosition.dx;
                                final width = constraints.maxWidth;
                                final percentage = (dx / width).clamp(0.0, 1.0);
                                final seekMs = maxDurationMs * percentage;
                                _audioPlayer.seek(
                                  Duration(milliseconds: seekMs.toInt()),
                                );
                              },
                              onHorizontalDragUpdate: (details) {
                                final dx = details.localPosition.dx;
                                final width = constraints.maxWidth;
                                final percentage = (dx / width).clamp(0.0, 1.0);
                                final seekMs = maxDurationMs * percentage;
                                _audioPlayer.seek(
                                  Duration(milliseconds: seekMs.toInt()),
                                );
                              },
                              child: Container(
                                height: 30, // Height of the waveform area
                                color: Colors.transparent, // Hit test target
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: List.generate(_barHeights.length, (
                                    index,
                                  ) {
                                    // Determine if this bar is "active" (played)
                                    final barThreshold =
                                        index / _barHeights.length;
                                    final isPlayed = progress > barThreshold;
                                    final height =
                                        24 *
                                        _barHeights[index]; // Max height 24

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 3,
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: isPlayed
                                            ? Colors.black87
                                            : Colors.grey[400],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
