import 'package:flutter/material.dart';

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minH;
  final double maxH;

  // ignore: unused_element_parameter
  _StickyHeaderDelegate({required this.child, this.minH = 56, double? maxH})
    : maxH = maxH ?? 56;

  @override
  double get minExtent => minH;
  @override
  double get maxExtent => maxH;

  @override
  Widget build(context, shrinkOffset, overlapsContent) => Material(
    color: Colors.white,
    elevation: overlapsContent ? 2 : 0,
    child: child,
  );

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
      old.child != child || old.minH != minH || old.maxH != maxH;
}

class SliverStickyFilterPage extends StatelessWidget {
  const SliverStickyFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Popular', 'Nearby', 'Promo'];
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Explore'),
              background: Image.network(
                'https://picsum.photos/200',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder:
                      (_, i) => ChoiceChip(
                        label: Text(filters[i]),
                        selected: i == 0,
                        onSelected: (_) {},
                      ),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: filters.length,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: 40,
            itemBuilder:
                (_, i) => ListTile(
                  leading: const Icon(Icons.place),
                  title: Text('Tempat #$i'),
                  subtitle: const Text('Detail singkat'),
                ),
          ),
        ],
      ),
    );
  }
}
