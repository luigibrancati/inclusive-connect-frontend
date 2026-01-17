import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'cached_storage_image.dart';
import 'tts_button.dart';

import '../../data/services/tts_service.dart';
import '../../data/services/gemini_service.dart';

import '../../data/services/storage_service.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late TtsService _ttsService;
  // Carousel & Alt Text State
  int _currentImageIndex = 0;
  // Cache generated ALT text per image index
  final Map<int, String> _altTextCache = {};
  // Track loading state per image index
  final Set<int> _loadingAltIndices = {};
  // Track visibility state of ALT overlay per image index
  final Set<int> _visibleAltIndices = {};
  final String widgetId = UniqueKey().toString();
  late String ttsId;

  @override
  void initState() {
    super.initState();
    ttsId = 'image_carousel_$widgetId';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsService = context.read<TtsService>();
    ttsId = 'image_carousel_$widgetId';
  }

  @override
  void dispose() {
    // Stop TTS if this post is being disposed (e.g. navigation)
    _ttsService.stopIfId(ttsId);
    super.dispose();
  }

  Future<void> _generateAltText(int index) async {
    if (index >= widget.imageUrls.length) return;

    // Check availability in cache
    if (_altTextCache.containsKey(index)) {
      setState(() {
        if (_visibleAltIndices.contains(index)) {
          _visibleAltIndices.remove(index);
        } else {
          _visibleAltIndices.add(index);
        }
      });
      return;
    }

    setState(() {
      _loadingAltIndices.add(index);
    });

    try {
      final storage = context.read<StorageService>();
      final gemini = context.read<GeminiService>();

      // Fetch image bytes
      final imagePath = widget.imageUrls[index];
      final bytes = await storage.getImageData(imagePath);

      if (bytes == null) {
        throw Exception("Failed to load image data");
      }

      // Generate Alt Text
      final text = await gemini.generateAltText(bytes);

      if (mounted) {
        setState(() {
          _altTextCache[index] = text;
          _visibleAltIndices.add(index);
        });
      }
    } catch (e) {
      debugPrint("Failed to generate alt text: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToGenerateAltText,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingAltIndices.remove(index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 512, // Fixed height for carousel
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl = widget.imageUrls[index];
                final bool isLoadingAlt = _loadingAltIndices.contains(
                  index,
                );
                final bool isAltVisible = _visibleAltIndices.contains(
                  index,
                );
                final String? altText = _altTextCache[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (kIsWeb)
                      CachedStorageImage(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain, // maintain aspect ratio
                        placeholder: const ColoredBox(
                          color: Colors.grey,
                        ),
                      ),
                    if (!kIsWeb)
                      CachedStorageImage(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain, // maintain aspect ratio
                        placeholder: const ColoredBox(
                          color: Colors.grey,
                        ),
                      ),

                    // ALT Button (Only if not loading and not visible)
                    if (!isLoadingAlt && !isAltVisible)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => _generateAltText(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "ALT",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Loading Indicator
                    if (isLoadingAlt)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black54,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                semanticsLabel: AppLocalizations.of(
                                  context,
                                )!.loadingAltTextLoadingText,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.loadingAltTextLoadingText,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Alt Text Overlay
                    if (isAltVisible && altText != null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.85),
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TTSButton(
                                        text: altText,
                                        id: '${ttsId}_$index',
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _visibleAltIndices.remove(
                                              index,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Expanded(
                                    child: Text(
                                      altText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.white,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Indicators (Only if multiple images)
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
