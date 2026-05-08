import 'package:flutter/material.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder list of recent activities
    final items = List.generate(8, (i) => 'Activity ${i + 1}');

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.history),
        title: Text(items[index]),
        subtitle: const Text('Details...'),
      ),
    );
  }
}
