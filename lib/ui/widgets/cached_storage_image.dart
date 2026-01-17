import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/storage_service.dart';

/// Simple in-memory map cache for resolved download URLs.
class _DownloadUrlCache {
  static final Map<String, String> _cache = {};

  static String? get(String key) => _cache[key];
  static void set(String key, String value) => _cache[key] = value;
}

/// Widget that resolves a storage path (or uses an existing download URL)
/// via `StorageService.getDownloadUrl(...)` and displays a cached network
/// image using `cached_network_image`.
class CachedStorageImage extends StatefulWidget {
  final String? pathOrUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool circle;

  const CachedStorageImage(
    this.pathOrUrl, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = AlignmentGeometry.center,
    this.placeholder,
    this.errorWidget,
    this.circle = false,
  });

  @override
  State<CachedStorageImage> createState() => _CachedStorageImageState();
}

class _CachedStorageImageState extends State<CachedStorageImage> {
  String? _resolvedUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    final key = widget.pathOrUrl;
    if (key == null) return;

    final cached = _DownloadUrlCache.get(key);
    if (cached != null) {
      setState(() {
        _resolvedUrl = cached;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final storage = context.read<StorageService>();
      final url = await storage.getDownloadUrl(key);
      // debugPrint("Resolved URL for $key: $url");
      _DownloadUrlCache.set(key, url);
      if (mounted) {
        setState(() {
          _resolvedUrl = url;
        });
      }
    } catch (e) {
      // Leave _resolvedUrl null; UI will show placeholder or error widget.
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pathOrUrl == null) {
      debugPrint("Path or URL is null");
      return _buildPlaceholder();
    }

    if (_resolvedUrl == null) {
      debugPrint("Resolved URL for ${widget.pathOrUrl} is null");
      if (_loading) return _buildPlaceholder();
      // Try resolving once more (in case context wasn't available earlier)
      _resolveUrl();
      return _buildPlaceholder();
    }

    // Use CachedNetworkImage to display the image and leverage disk cache.
    // debugPrint("Resolved URL: $_resolvedUrl");

    if (widget.circle) {
      return CachedNetworkImage(
        imageUrl: _resolvedUrl!,
        imageBuilder: (context, imageProvider) {
          final decoration = BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: widget.fit,
              alignment: widget.alignment,
            ),
          );
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: decoration,
          );
        },
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.errorWidget ?? const ColoredBox(color: Colors.grey),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: _resolvedUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment as Alignment? ?? Alignment.center,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.errorWidget ?? const ColoredBox(color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.placeholder ?? const ColoredBox(color: Colors.grey),
    );
  }
}
