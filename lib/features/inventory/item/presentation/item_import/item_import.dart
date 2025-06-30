import 'package:duxbe/features/inventory/item/presentation/item_import/item_import_mobile.dart';
import 'package:duxbe/features/inventory/item/presentation/item_import/item_import_web.dart';
import 'package:duxbe/shared/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'item_import_mobile.dart';

class ItemImportScreen extends ConsumerWidget {
  const ItemImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ItemImportScreenMobile(),
        largeScreen: ItemImportScreenWeb(),
      ),
    );
  }
}
