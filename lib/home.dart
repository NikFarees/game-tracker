import 'package:flutter/material.dart';

import 'all_games.dart';
import 'database_helper.dart';
import 'form_page.dart';
import 'game_list.dart';

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

  // Open the form to add a new game. Reload on return.
  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormPage()),
    );
    if (saved == true) _load();
  }

  // Show the full library, then reload in case anything changed there.
  Future<void> _openAllGames() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllGamesPage()),
    );
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
                  onPressed: _openAllGames,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View All'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Recent Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Expanded(
            child: GameList(
              games: _games.take(5).toList(),
              onChanged: _load,
            ),
          ),
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
}
