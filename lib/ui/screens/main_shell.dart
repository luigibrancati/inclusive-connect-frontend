import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_models.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final authService = context.read<AuthService>();
          try {
            final user = await authService.getCurrentUser();
            if (!context.mounted) return;

            final isOrganization = user?.userType == UserType.organization;

            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.post_add),
                      title: Text(
                        AppLocalizations.of(context)!.createPostButtonTitle,
                      ),
                      onTap: () {
                        context.pop();
                        context.push('/create_post');
                      },
                    ),
                    if (isOrganization)
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(
                          AppLocalizations.of(context)!.createEventButtonTitle,
                        ),
                        onTap: () {
                          context.pop();
                          context.push('/create_event');
                        },
                      ),
                  ],
                ),
              ),
            );
          } catch (e) {
            // Handle error, maybe show only post or nothing?
            // Fallback to allowing post creation if user fetch fails (unlikely if logged in)
            debugPrint("Error determining user type: $e");
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
              color: GoRouterState.of(context).uri.toString() == '/home'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.go('/discover'),
              color: GoRouterState.of(context).uri.toString() == '/discover'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: const Icon(Icons.people), // Community/Events
              onPressed: () => context.go('/community'),
              color: GoRouterState.of(context).uri.toString() == '/community'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
              color: GoRouterState.of(context).uri.toString() == '/profile'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
