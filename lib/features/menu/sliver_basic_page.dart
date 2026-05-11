import 'package:flutter/material.dart';

class SliverBasicPage extends StatelessWidget {
  const SliverBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            centerTitle: true,
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Sliver Header'),
              background: Image.network(
                'https://picsum.photos/200',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Rekomendasi Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item #${index + 1}'),
                subtitle: const Text('Deskripsi singkat'),
                onTap: () {},
              );
            },
            itemCount: 30,
          ),
          SliverFillRemaining(child: const Center(child: Text('Remaining'))),
        ],
      ),
    );
  }
}
