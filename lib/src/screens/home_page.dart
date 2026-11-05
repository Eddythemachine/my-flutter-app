import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Signed-in landing screen.
///
/// It is intentionally small: the point is to prove the auth flow works and to
/// give the notes feature somewhere to live next.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user, required this.onSignOut});

  final User user;
  final Future<void> Function() onSignOut;

  String get _displayName {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user.email ?? '';
    if (email.isEmpty) return 'there';
    return email.split('@').first;
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in with your email and password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, 44),
              maximumSize: const Size(140, 44),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    try {
      await onSignOut();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not sign out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('iNote'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _GreetingCard(user: user, displayName: _displayName),
                const SizedBox(height: 20),
                const _EmptyNotes(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The note editor is the next step.')),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New note'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.user, required this.displayName});

  final User user;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final initial = displayName.isEmpty
        ? '?'
        : displayName.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2A1817), const Color(0xFF1C1414)]
              : [const Color(0xFFFFF1EE), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primary,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email ?? 'No email on file',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Hey $displayName, ready to write something down?',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1919) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withAlpha(70)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: 30,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your notes will show up here as soon as you create the first one.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
