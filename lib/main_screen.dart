import 'package:flutter/material.dart';

import 'form_page.dart';
import 'home.dart';
import 'login.dart';
import 'media.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  final String username;
  const MainScreen({super.key, required this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  // FIND: sidebar titles for each tab
  static const _titles = ['Home', 'Media', 'Profile', 'Add Game'];

  // FIND: _pageFor returns the correct page for the selected tab.
  Widget _pageFor(int i) {
    switch (i) {
      case 0:
        return HomePage(username: widget.username);
      case 1:
        return const MediaPage();
      case 2:
        return ProfilePage(username: widget.username);
      default:
        return const FormPage(isEmbedded: true);
    }
  }

  void _select(int i) => setState(() => _index = i);

  // FIND: logout
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // FIND: bottom navigation bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: _buildDrawer(context),
      body: _pageFor(_index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _select,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined), label: 'Media'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Form'),
        ],
      ),
    );
  }

  // FIND: side navigation bar
  Widget _buildDrawer(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    Widget tile(IconData icon, String label, int i) => ListTile(
          leading: Icon(icon),
          title: Text(label),
          selected: _index == i,
          selectedColor: accent,
          onTap: () {
            Navigator.pop(context);
            _select(i);
          },
        );

    return Drawer(
      backgroundColor: const Color(0xFF161616),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // FIND: user avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accent,
                  child:
                      const Icon(Icons.person, color: Colors.black, size: 30),
                ),

                const SizedBox(height: 10),

                // FIND: Username and role.
                Text(
                  widget.username,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text('GameLog member',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // FIND: navigation tiles for each tab
          tile(Icons.home_outlined, 'Home', 0),
          tile(Icons.article_outlined, 'Media', 1),
          tile(Icons.person_outline, 'Profile', 2),
          tile(Icons.add_box_outlined, 'Add Game', 3),

          const Divider(),

          // FIND: Logout button
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
