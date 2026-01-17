import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/post_models.dart';
import '../../data/services/feed_service.dart';
import 'cached_storage_image.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/gemini_service.dart';
import 'tts_button.dart';

import 'package:visibility_detector/visibility_detector.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';

class CommentsSection extends StatefulWidget {
  final int postId;
  final String postContext; // Added context for AI
  final List<CommentPublic> initialComments;
  final void Function(CommentPublic comment)? onCommentAdded;
  final bool isInline;

  const CommentsSection({
    super.key,
    required this.postId,
    required this.postContext,
    required this.initialComments,
    this.onCommentAdded,
    this.isInline = false,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late List<CommentPublic> _comments;
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  List<String> _smartReplies = [];
  bool _isLoadingReplies = false;
  late TtsService _ttsService;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
    _generateReplies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsService = context.read<TtsService>();
  }

  @override
  void dispose() {
    // Stop any comment TTS if sheet is closed or widget completely disposed.
    // If inline, this happens on page navigation away from parent possibly.
    // If modal, happens on close.
    _ttsService.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateReplies() async {
    if (mounted) {
      setState(() {
        _isLoadingReplies = true;
      });
    }

    try {
      final gemini = context.read<GeminiService>();
      final replies = await gemini.generateSmartReplies(widget.postContext);
      if (mounted) {
        setState(() {
          _smartReplies = replies;
        });
      }
    } catch (e) {
      debugPrint("Error generating smart replies: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReplies = false;
        });
      }
    }
  }

  void _useSmartReply(String reply) {
    _controller.text = reply;
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final authService = context.read<AuthService>();
      final currentUser = await authService.getCurrentUser();

      if (!mounted) return;

      if (currentUser != null) {
        final feedService = context.read<FeedService>();
        final newComment = await feedService.addComment(widget.postId, text);

        if (mounted) {
          setState(() {
            _comments.add(newComment);
          });
          widget.onCommentAdded?.call(newComment);
        }
      }

      _controller.clear();
      // Optionally regenerate replies based on new conversation flow?
      // For now, keep as is or clear them.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToPostCommentSnackBarText}: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If inline, we don't need the bottom sheet decorations/constraints
    return Container(
      padding: widget.isInline
          ? EdgeInsets.zero
          : EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: widget.isInline
          ? null
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
      constraints: widget.isInline
          ? null
          : BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle - only if not inline
          if (!widget.isInline)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

          // Header
          Padding(
            padding: widget.isInline
                ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                : const EdgeInsets.only(
                    bottom: 12,
                    left: 16,
                    right: 16,
                  ), // consistent padding
            child: Text(
              AppLocalizations.of(context)!.commentsSectionTitle,
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          if (!widget.isInline) const Divider(height: 1),

          // List
          // If inline, we want it to take necessary height (shrinkWrap) and not scroll independently
          // If not inline (modal), it should be Expanded to take available space
          widget.isInline
              ? _buildCommentsList()
              : Expanded(child: _buildCommentsList()),

          if (!widget.isInline) const Divider(height: 1),

          // Smart Replies
          if (_isLoadingReplies)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 30,
                child: Text(
                  " ✨ ${AppLocalizations.of(context)!.smartRepliesLoadingText}",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          if (_smartReplies.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _smartReplies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.blue,
                      ),
                      label: Text(_smartReplies[index]),
                      onPressed: () => _useSmartReply(_smartReplies[index]),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Input
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Current user avatar could go here if we had it easily
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.addCommentHintText,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(),
                      ),
                      filled: false,
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return _comments.isEmpty
        ? Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noCommentsText,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        : ListView.builder(
            // Key properties for inline embedding:
            shrinkWrap: widget.isInline,
            physics: widget.isInline
                ? const NeverScrollableScrollPhysics()
                : null,
            padding: const EdgeInsets.all(16),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return VisibilityDetector(
                key: Key('comment_${comment.id}'),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction < 0.2) {
                    _ttsService.stopIfId('comment_${comment.id}');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push('/users/${comment.author.userId}');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            comment.author.profilePicUrl != null
                                ? CachedStorageImage(
                                    comment.author.profilePicUrl,
                                    width: 36,
                                    height: 36,
                                    circle: true,
                                  )
                                : const CircleAvatar(
                                    radius: 18,
                                    child: Icon(Icons.person, size: 20),
                                  ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push('/users/${comment.author.userId}');
                              },
                              child: Text(
                                comment.author.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.body,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      TTSButton(
                        text: comment.body,
                        id: 'comment_${comment.id}',
                        iconSize: 20,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
