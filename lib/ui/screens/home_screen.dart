import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/services/feed_service.dart';
import '../../data/models/post_models.dart';
import 'post_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PostPublic>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = context.read<FeedService>().getFeed();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _feedFuture = context.read<FeedService>().getFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.diversity_1,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.communityFeedTitle),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                // Only show badge if there are notifications (would need to fetch count)
                // For now, static badge or remove if not easily fetchable without streams
              ],
            ),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  AppLocalizations.of(context)!.allPostsChipTitle,
                  true,
                ),
                _buildFilterChip(
                  AppLocalizations.of(context)!.trendingChipTitle,
                  false,
                ),
                _buildFilterChip(
                  AppLocalizations.of(context)!.sensoryFriendlyChipTitle,
                  false,
                ),
                _buildFilterChip(
                  AppLocalizations.of(context)!.meetupsChipTitle,
                  false,
                ),
                _buildFilterChip(
                  AppLocalizations.of(context)!.qaChipTitle,
                  false,
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<PostPublic>>(
              future: _feedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint('Error loading feed: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.errorLoadingFeed),
                        ElevatedButton(
                          onPressed: _refreshFeed,
                          child: Text(
                            AppLocalizations.of(context)!.retryButton,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noPostsFound),
                  );
                }

                final posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshFeed,
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: posts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool value) {},
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
