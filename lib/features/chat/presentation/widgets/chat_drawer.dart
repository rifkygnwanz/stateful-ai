import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stateful_ai/features/menu/menu_page.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ListTile(
              title: Text(
                'Stateful AI',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Quick actions'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.now_widgets_outlined),
              title: const Text('Menu Widget'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
