import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'form_page.dart';

class GameList extends StatelessWidget {
  final List<Game> games;
  final Future<void> Function() onChanged;
  final String emptyMessage;

  const GameList({
    super.key,
    required this.games,
    required this.onChanged,
    this.emptyMessage = 'No games yet. Tap "Add Game" to start.',
  });

  Future<bool> _confirmDelete(BuildContext context, Game game) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete game?'),
        content: Text('Remove "${game.title}" from your library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _confirmAndDelete(BuildContext context, Game game) async {
    if (!await _confirmDelete(context, game)) return;
    await DatabaseHelper.instance.deleteGame(game.id!);
    await onChanged();
  }

  Future<void> _edit(BuildContext context, Game game) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormPage(existing: game)),
    );
    if (saved == true) await onChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: TextStyle(color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, i) {
        final game = games[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              child: Icon(Icons.videogame_asset, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(game.title),
            subtitle: Text('${game.platform} · ${game.status} · ${game.hours}h'),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'Delete',
              onPressed: () => _confirmAndDelete(context, game),
            ),
            onTap: () => _edit(context, game),
          ),
        );
      },
    );
  }
}
