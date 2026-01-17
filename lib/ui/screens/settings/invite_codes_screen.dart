import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../data/services/invite_code_service.dart';
import '../../../data/models/common_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_models.dart';

class InviteCodesScreen extends StatefulWidget {
  const InviteCodesScreen({super.key});

  @override
  State<InviteCodesScreen> createState() => _InviteCodesScreenState();
}

class _InviteCodesScreenState extends State<InviteCodesScreen> {
  late Future<List<InviteCode>> _codesFuture;
  UserPublic? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshCodes();
  }

  void _refreshCodes() {
    final authService = context.read<AuthService>();
    final inviteService = context.read<InviteCodeService>();

    setState(() {
      _codesFuture = authService.getCurrentUser().then((user) {
        if (user == null || user.userType != UserType.organization) {
          throw Exception('Unauthorized');
        }
        _currentUser = user;
        // UserPublic uses userId (int) but InviteCode logic assumes we have an orgId.
        // For Organizations, userId IS the organizationId conceptually in our simplified model?
        // Let's assume userId is what we pass as organizationId.
        return inviteService.getInviteCodes(user.userId);
      });
    });
  }

  Future<void> _generateCode() async {
    if (_currentUser == null) return;
    final inviteService = context.read<InviteCodeService>();

    try {
      await inviteService.createInviteCode(
        _currentUser!.userId,
        maxUses: 10, // Default for now, maybe allow user customization later
        // Expires in 30 days
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.inviteCodeGeneratedSuccessfully,
            ),
          ),
        );
      }
      _refreshCodes();
    } catch (e) {
      debugPrint('Errore nella generazione del codice di invito: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.inviteCodeGenerationFailed,
            ),
          ),
        );
      }
    }
  }

  Future<void> _revokeCode(InviteCode code) async {
    final inviteService = context.read<InviteCodeService>();
    try {
      await inviteService.revokeInviteCode(code.code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.inviteCodeRevokedSuccessfully,
            ),
          ),
        );
      }
      _refreshCodes();
    } catch (e) {
      debugPrint('Errore durante la revoca del codice di invito: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.inviteCodeRevocationFailed,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inviteCodesScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshCodes();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.inviteCodesScreenRefreshed,
                  ),
                ),
              );
            },
            tooltip: AppLocalizations.of(
              context,
            )!.inviteCodesScreenRefreshTooltip,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateCode,
        tooltip: AppLocalizations.of(context)!.inviteCodesScreenGenerateTooltip,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<InviteCode>>(
        future: _codesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint(
              'Errore durante il recupero dei codici di invito: ${snapshot.error}',
            );
            return Center(
              child: Text(AppLocalizations.of(context)!.inviteCodesScreenError),
            );
          }

          final codes = snapshot.data ?? [];

          if (codes.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.inviteCodesScreenNoCodesGenerated,
              ),
            );
          }

          // Sort by validity (active first) then creation date (newest first)
          codes.sort((a, b) {
            if (a.isValid != b.isValid) {
              return a.isValid ? -1 : 1;
            }
            return b.createdAt.compareTo(a.createdAt);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: codes.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final code = codes[index];
              final isExpired =
                  code.expiresAt != null &&
                  DateTime.now().isAfter(DateTime.parse(code.expiresAt!));
              final isFullyUsed =
                  code.maxUses != null && code.currentUses >= code.maxUses!;

              final bool isActive = code.isValid && !isExpired && !isFullyUsed;

              return ListTile(
                title: Row(
                  children: [
                    Text(
                      code.code,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: !isActive
                            ? TextDecoration.lineThrough
                            : null,
                        color: !isActive ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.inviteCodesScreenCopiedToClipboard,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.inviteCodesScreenCreatedAt}: ${_formatDate(code.createdAt)}',
                    ),
                    if (code.maxUses != null)
                      Text(
                        '${AppLocalizations.of(context)!.inviteCodesScreenUses}: ${code.currentUses} / ${code.maxUses}',
                      ),
                    if (!code.isValid)
                      Text(
                        AppLocalizations.of(context)!.inviteCodesScreenInvalid,
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (code.isValid && isExpired)
                      Text(
                        AppLocalizations.of(context)!.inviteCodesScreenExpired,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    if (code.isValid && !isExpired && isFullyUsed)
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.inviteCodesScreenFullyUsed,
                        style: TextStyle(color: Colors.orange),
                      ),
                  ],
                ),
                trailing: isActive
                    ? IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        tooltip: AppLocalizations.of(
                          context,
                        )!.inviteCodesScreenRevokeTooltip,
                        onPressed: () => _showRevokeDialog(context, code),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoString) {
    // Simple formatter, preferably use intl package but keeping dependencies low as per instructions unless needed
    final dt = DateTime.parse(isoString);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showRevokeDialog(BuildContext context, InviteCode code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.inviteCodesScreenRevokeTitle),
        content: Text(
          AppLocalizations.of(context)!.inviteCodesScreenRevokeCodeConfirmText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.inviteCodesScreenRevokeCodeCancel,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _revokeCode(code);
              _refreshCodes();
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              AppLocalizations.of(context)!.inviteCodesScreenRevokeCodeConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
