import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _db = DatabaseHelper.instance;

  Map<String, dynamic> _user = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await _db.getUser(widget.username);
    if (!mounted) return;
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final accent = Theme.of(context).colorScheme.primary;
    final name = (_user['name'] as String?) ?? 'Player';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),

        // FIND: profile picture
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: accent,
            child: const Icon(Icons.person, size: 56, color: Colors.black),
          ),
        ),

        const SizedBox(height: 16),

        // FIND: name
        Center(
          child: Text(name,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),

        // FIND: username
        Center(
          child: Text('@${widget.username}',
              style: TextStyle(color: Colors.grey[500])),
        ),

        const SizedBox(height: 24),

        // FIND : user info cards
        _infoTile(Icons.badge_outlined, 'Name', name),
        _infoTile(Icons.person_outline, 'Username', widget.username),
        _infoTile(
            Icons.email_outlined, 'Email', (_user['email'] as String?) ?? '-'),
        _infoTile(
            Icons.phone_outlined, 'Phone', (_user['phone'] as String?) ?? '-'),
        _infoTile(Icons.school_outlined, 'Student ID',
            (_user['studentId'] as String?) ?? '-'),
        _infoTile(Icons.menu_book_outlined, 'Course',
            (_user['course'] as String?) ?? '-'),

        const SizedBox(height: 28),

        // FIND: logout button
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label,
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
