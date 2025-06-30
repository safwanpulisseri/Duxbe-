import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'item_category_list_mobile.dart';
export 'item_category_list_web.dart';

class ItemCategoryListScreen extends ConsumerWidget {
  const ItemCategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ItemCategoryListScreenMobile(),
        largeScreen: ItemCategoryListScreenWeb(),
      ),
    );
  }
}
