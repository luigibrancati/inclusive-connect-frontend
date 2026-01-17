import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/post_models.dart';
import 'post_card.dart';
import '../widgets/comments_sheet.dart';

class PostDetailsScreen extends StatelessWidget {
  final PostPublic post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.postDetailsScreenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostCard(post: post),
            SafeArea(
              child: CommentsSection(
                postId: post.id,
                postContext: '${post.title}. ${post.body ?? ""}',
                initialComments: post.comments,
                isInline: true,
                onCommentAdded: (CommentPublic comment) {
                  // Ideally update post comments count locally or rely on stream if available.
                  // Since Post public is passed, we might want to update it, but it's stateless here.
                  // PostCard maintains its own state, but PostDetailsScreen is stateless.
                  // If we want real-time updates reflected, we might need to make PostDetailsScreen Stateful or use Provider.
                  // For now, we just append to the list in memory which might not update UI elsewhere if not rebuilt.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
