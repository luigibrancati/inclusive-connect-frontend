import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../widgets/cached_storage_image.dart';
import '../../data/models/user_models.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_service.dart';
import '../../data/services/feed_service.dart';
import '../../data/services/relationship_service.dart';
import '../../data/models/post_models.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<dynamic> _userFuture;

  UserPublic? _organization;
  RelationshipType _relationshipStatus = RelationshipType.none;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  void _refreshUser() {
    setState(() {
      _userFuture = _loadData();
    });
  }

  Future<Map<String, dynamic>> _loadData() async {
    UserPublic? user;
    List<PostPublic> posts = [];
    final userService = context.read<UserService>();
    final authService = context.read<AuthService>();
    final feedService = context.read<FeedService>();
    final relationshipService = context.read<RelationshipService>();

    try {
      if (widget.userId != null) {
        user = await userService.getUser(widget.userId!);
      } else {
        user = await authService.getCurrentUser();
      }

      if (user != null) {
        if (user.userType == UserType.member && user.organizationId != null) {
          try {
            _organization = await userService.getUser(user.organizationId!);
          } catch (e) {
            debugPrint('Failed to load organization: $e');
          }
        }
        try {
          posts = await feedService.getPostsByUser(user.userId);
        } catch (e) {
          debugPrint('Failed to load posts: $e');
        }
      }

      RelationshipType relStatus = RelationshipType.none;
      if (user != null && widget.userId != null) {
        // If viewing another user's profile
        final currentUser = await authService.getCurrentUser();
        if (currentUser != null && currentUser.userId != user.userId) {
          relStatus = await relationshipService.getRelationshipStatus(
            UserReference(
              userId: currentUser.userId,
              userType: currentUser.userType,
            ),
            UserReference(userId: user.userId, userType: user.userType),
          );
        }
      }

      return {'user': user, 'posts': posts, 'relationship': relStatus};
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data as Map<String, dynamic>;
        final user = data['user'] as UserPublic?;
        final posts = data['posts'] as List<PostPublic>;
        final relationship =
            data['relationship'] as RelationshipType? ?? RelationshipType.none;
        _relationshipStatus = relationship;

        if (user == null) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                child: Text(AppLocalizations.of(context)!.loginButton),
              ),
            ),
          );
        }

        // Determine if member or organization for display differences
        String username = '';
        String? profilePic;
        String? bio;

        username = user.username;
        profilePic = user.profilePicUrl;
        bio = user.bio;

        return Scaffold(
          appBar: AppBar(
            actions: widget.userId == null
                ? [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        // Settings or Logout
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.accessibility_new),
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.accessibilitySettings,
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  context.push('/settings/accessibility');
                                },
                              ),
                              if (user.userType == UserType.organization)
                                ListTile(
                                  leading: const Icon(Icons.vpn_key),
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.manageInviteCodesSettings,
                                  ),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    context.push('/invite-codes');
                                  },
                                ),
                              ListTile(
                                leading: const Icon(Icons.edit_document),
                                title: Text(
                                  AppLocalizations.of(context)!.editProfile,
                                ),
                                onTap: () async {
                                  final result = await context.push(
                                    '/edit-profile',
                                    extra: user,
                                  );
                                  if (result == true) {
                                    _refreshUser();
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.share),
                                title: Text(
                                  AppLocalizations.of(context)!.shareProfile,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Coming soon!'),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: Text(
                                  AppLocalizations.of(context)!.logout,
                                ),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  await context.read<AuthService>().logout();
                                  if (ctx.mounted && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Successfully logged out',
                                        ),
                                      ),
                                    );
                                    context.go('/');
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ]
                : [],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Profile Header
                  Center(
                    child: profilePic != null && profilePic.isNotEmpty
                        ? SizedBox(
                            width: 100,
                            height: 100,
                            child: CachedStorageImage(
                              profilePic,
                              width: 100,
                              height: 100,
                              circle: true,
                            ),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          username,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.userType == UserType.organization
                              ? AppLocalizations.of(context)!.organization
                              : AppLocalizations.of(context)!.member,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        // Organization Address or Membership
                        if (user.userType == UserType.organization &&
                            user.residentialData != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${user.residentialData!.street} ${user.residentialData!.streetNumber}, ${user.residentialData!.city} ${user.residentialData!.postalCode}, ${user.residentialData!.country}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (user.userType == UserType.member &&
                            _organization != null) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.memberOfOrganization}: ",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                              InkWell(
                                onTap: () {
                                  context.push(
                                    '/users/${_organization!.userId}',
                                  );
                                },
                                child: Text(
                                  _organization!.username,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ), // Removed extra closing bracket here
                  const SizedBox(height: 16),
                  if (widget.userId != null) ...[
                    Center(child: _buildRelationshipButton(user, context)),
                    const SizedBox(height: 16),
                  ],
                  if (bio != null && bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.profileBioLabel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bio,
                                    textAlign: TextAlign.left,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Stats Row (Mocked for now as API might not give counts directly in user object yet)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          AppLocalizations.of(context)!.postsStats,
                          '12',
                        ),
                        _buildStat(
                          AppLocalizations.of(context)!.followersStats,
                          '120',
                        ),
                        _buildStat(
                          AppLocalizations.of(context)!.followingStats,
                          '45',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      AppLocalizations.of(context)!.postsProfileSectionTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Post Section
                  Center(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      separatorBuilder: (context, index) =>
                          const Divider(thickness: 0.5, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: InkWell(
                            onTap: () {
                              context.push('/post_details', extra: post);
                            },
                            child: Text(
                              post.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                          subtitle: post.body != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    post.body!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRelationshipButton(UserPublic targetUser, BuildContext context) {
    if (widget.userId == null) return const SizedBox.shrink(); // Self profile

    String label = '';
    VoidCallback? onPressed;
    Color? color;

    switch (_relationshipStatus) {
      case RelationshipType.none:
        if (targetUser.userType == UserType.organization) {
          label = 'Follow';
          onPressed = () => _handleFollow(targetUser);
        } else {
          label = 'Add Friend';
          onPressed = () => _handleFriendRequest(targetUser);
        }
        break;
      case RelationshipType.following:
        label = 'Unfollow';
        onPressed = () => _handleUnfollow(targetUser);
        break;
      case RelationshipType.friend:
        label = 'Friend';
        break;
      case RelationshipType.requested:
        label = 'Requested';
        color = Colors.grey;
        break;
      case RelationshipType.pending:
        label = 'Accept Request';
        onPressed = () => _handleAcceptRequest(targetUser);
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label),
    );
  }

  Future<void> _handleFollow(UserPublic targetUser) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        await context.read<RelationshipService>().followUser(
          UserReference(
            userId: currentUser.userId,
            userType: currentUser.userType,
          ),
          UserReference(
            userId: targetUser.userId,
            userType: targetUser.userType,
          ),
        );
        setState(() {
          _refreshUser();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleUnfollow(UserPublic targetUser) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        await context.read<RelationshipService>().unfollowUser(
          currentUser.userId,
          targetUser.userId,
        );
        setState(() {
          _refreshUser();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleFriendRequest(UserPublic targetUser) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        await context.read<RelationshipService>().sendFriendRequest(
          currentUser.userId,
          targetUser.userId,
        );
        setState(() {
          _refreshUser();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleAcceptRequest(UserPublic targetUser) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        await context.read<RelationshipService>().acceptFriendRequest(
          currentUser.userId,
          targetUser.userId,
        );
        setState(() {
          _refreshUser();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
