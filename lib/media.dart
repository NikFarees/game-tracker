import 'package:flutter/material.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  static const _items = [
    _NewsItem(Icons.emoji_events_outlined, 'Top 10 RPGs of 2025',
        'Our picks for the year, ranked.'),
    _NewsItem(Icons.self_improvement_outlined, 'How to avoid gaming burnout',
        'Small habits that keep it fun.'),
    _NewsItem(Icons.headset_mic_outlined, 'Best budget gaming gear',
        'Solid kit that will not break the bank.'),
    _NewsItem(Icons.calendar_month_outlined, 'Upcoming releases this month',
        'What to add to your wishlist.'),
    _NewsItem(Icons.speed_outlined, 'Speedrun basics',
        'Where to start if you want to go fast.'),
    _NewsItem(Icons.savings_outlined, 'Where to find the best sales',
        'Stretch your backlog budget further.'),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return Card(
          child: ListTile(
            leading: Icon(item.icon, color: accent),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class _NewsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _NewsItem(this.icon, this.title, this.subtitle);
}
