import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = DatabaseHelper.instance;

  List<Game> _games = [];
  int _total = 0;
  int _playing = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final games = await _db.getGames();
    final total = await _db.getTotalCount();
    final playing = await _db.getNowPlayingCount();
    if (!mounted) return;
    setState(() {
      _games = games;
      _total = total;
      _playing = playing;
      _loading = false;
    });
  }

  // Open the form to add a new game, or edit an existing one. Reload on return.
  Future<void> _openForm({Game? game}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormPage(existing: game)),
    );
    if (saved == true) _load();
  }

  Future<bool> _confirmDelete(Game game) async {
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

  Future<void> _delete(Game game) async {
    await _db.deleteGame(game.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Welcome back, ${widget.username}!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Here is your library at a glance.', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),

          // Stat cards
          Row(
            children: [
              _statCard('Total Games', '$_total', Icons.videogame_asset_outlined),
              const SizedBox(width: 12),
              _statCard('Now Playing', '$_playing', Icons.play_circle_outline),
            ],
          ),
          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Game'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View All'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Recent Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Expanded(child: _recentList()),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    final accent = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentList() {
    if (_games.isEmpty) {
      return Center(
        child: Text(
          'No games yet. Tap "Add Game" to start.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      itemCount: _games.length,
      itemBuilder: (context, i) {
        final game = _games[i];
        // Swipe to delete, tap to edit, long-press also deletes.
        return Dismissible(
          key: ValueKey(game.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(game),
          onDismissed: (_) => _delete(game),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                child: Icon(Icons.videogame_asset, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text(game.title),
              subtitle: Text('${game.platform} · ${game.status}'),
              trailing: Text('${game.hours}h', style: TextStyle(color: Colors.grey[400])),
              onTap: () => _openForm(game: game),
              onLongPress: () async {
                if (await _confirmDelete(game)) _delete(game);
              },
            ),
          ),
        );
      },
    );
  }
}
