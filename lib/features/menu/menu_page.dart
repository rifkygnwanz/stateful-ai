import 'package:flutter/material.dart';
import 'package:stateful_ai/features/menu/sliver_basic_page.dart';
import 'package:stateful_ai/features/menu/sliver_screen.dart';
import 'package:stateful_ai/features/menu/sliver_sticky_filter_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<MenuItems> items = [
      MenuItems('Sliver Screen', const SliverScreen()),
      MenuItems('Sliver Basic', const SliverBasicPage()),
      MenuItems('Sliver Sticky Filter', const SliverStickyFilterPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Widget')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.title),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                ),
          );
        },
      ),
    );
  }
}

class MenuItems {
  final String title;
  final Widget page;

  MenuItems(this.title, this.page);
}
