import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'game_list.dart';

/// The full library — every tracked game. Pushed from Home's "View All" button.
class AllGamesPage extends StatefulWidget {
  const AllGamesPage({super.key});

  @override
  State<AllGamesPage> createState() => _AllGamesPageState();
}

class _AllGamesPageState extends State<AllGamesPage> {
  final _db = DatabaseHelper.instance;

  List<Game> _games = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final games = await _db.getGames();
    if (!mounted) return;
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Games (${_games.length})')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GameList(
                games: _games,
                onChanged: _load,
                emptyMessage: 'Your library is empty.',
              ),
            ),
    );
  }
}
