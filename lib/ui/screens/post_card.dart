import 'package:flutter/foundation.dart';
import '../widgets/audio_post_widget.dart';
import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/post_models.dart';
import 'package:provider/provider.dart';
import '../widgets/cached_storage_image.dart';
import '../widgets/image_carousel.dart';
import '../../data/services/feed_service.dart';
import '../../data/services/auth_service.dart';
import '../widgets/tts_button.dart';

import '../widgets/comments_sheet.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/gemini_service.dart';

import 'package:visibility_detector/visibility_detector.dart';
import '../../data/services/storage_service.dart';

class PostCard extends StatefulWidget {
  final PostPublic post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likesCount;
  late int _commentsCount;
  late TtsService _ttsService;

  @override
  void initState() {
    super.initState();
    _initializeLikeStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsService = context.read<TtsService>();
    _checkIfLiked();
  }

  @override
  void dispose() {
    // Stop TTS if this post is being disposed (e.g. navigation)
    _ttsService.stopIfId('post_${widget.post.id}');
    super.dispose();
  }

  void _initializeLikeStatus() {
    // We need to check if current user liked the post.
    // Accessing provider in initState via context.read is safe if done in callback or just assuming default false then update in didChangeDependencies
    // But simpler: just default false, and we might need to pass currentUserId to PostCard or fetch it.
    _likesCount = widget.post.likes.length;
    _commentsCount = widget.post.comments.length;
    _isLiked = false; // Default
  }

  void _checkIfLiked() async {
    final authService = context.read<AuthService>();
    final currentUser = await authService.getCurrentUser();
    if (currentUser != null) {
      int currentUserId = currentUser.userId;

      if (mounted) {
        setState(() {
          _isLiked = widget.post.likes.any(
            (like) => like.author.userId == currentUserId,
          );
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    final feedService = context.read<FeedService>();
    final originalState = _isLiked;

    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        await feedService.likePost(widget.post.id);
      } else {
        await feedService.unlikePost(widget.post.id);
      }
    } catch (e) {
      if (mounted) {
        // Revert
        setState(() {
          _isLiked = originalState;
          _likesCount += _isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToUpdateLike),
          ),
        );
      }
    }
  }

  String? _simplifiedText;
  bool _isSimplifying = false;

  Future<void> _simplifyContent() async {
    setState(() {
      _isSimplifying = true;
      _simplifiedText = null;
    });

    try {
      final gemini = context.read<GeminiService>();
      final textToSimplify = '${widget.post.title}. ${widget.post.body ?? ""}';
      final result = await gemini.simplifyText(textToSimplify);

      if (mounted) {
        setState(() {
          _simplifiedText = result;
        });
      }
    } catch (e) {
      debugPrint("Failed to simplify text: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.simplificationFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSimplifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('post_${widget.post.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 0.2) {
          _ttsService.stopIfId('post_${widget.post.id}');
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/users/${widget.post.author.userId}');
                    },
                    child: Row(
                      children: [
                        widget.post.author.profilePicUrl != null
                            ? CachedStorageImage(
                                widget.post.author.profilePicUrl,
                                width: 40,
                                height: 40,
                                circle: true,
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.author.username,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.post.createdAt != null
                                  ? DateTime.parse(
                                      widget.post.createdAt!,
                                    ).toIso8601String().split('T')[0]
                                  : AppLocalizations.of(context)!.justNow,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TTSButton(
                    text:
                        '${widget.post.author.username} ${AppLocalizations.of(context)!.posted}: ${widget.post.title}. ${widget.post.body ?? ""}',
                    id: 'post_${widget.post.id}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Content
            InkWell(
              onTap: () {
                context.push('/post_details', extra: widget.post);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.audioUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AudioPostWidget(
                          audioUrl: widget.post.audioUrl!,
                          colorHex: widget.post.audioBackgroundColorHex!,
                        ),
                      )
                    else if (widget.post.title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          widget.post.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (widget.post.body != null &&
                        widget.post.body!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(widget.post.body!),
                      ),

                    // Simplified Content Box
                    if (_isSimplifying)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    if (_simplifiedText != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100], // High contrast background
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.accessibility_new,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.simplifiedTextLabel,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  onPressed: () =>
                                      setState(() => _simplifiedText = null),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _simplifiedText!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Image Carousel
            if (widget.post.imageUrls.isNotEmpty)
              ImageCarousel(imageUrls: widget.post.imageUrls),

            // Actions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : null,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text('$_likesCount'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SafeArea(
                          child: CommentsSection(
                            postId: widget.post.id,
                            postContext:
                                '${widget.post.title}. ${widget.post.body ?? ""}',
                            initialComments: widget.post.comments,
                            onCommentAdded: (CommentPublic comment) {
                              setState(() {
                                _commentsCount++;
                                widget.post.comments.add(comment);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Text('$_commentsCount'),

                  // Simplify Button
                  IconButton(
                    icon: const Icon(Icons.auto_fix_high), // Wand icon usually
                    tooltip: AppLocalizations.of(
                      context,
                    )!.simplifyContentButtonTooltip,
                    onPressed: _simplifyContent,
                  ),

                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
