import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'item_view_mobile.dart';
export 'item_view_web.dart';

class ItemViewScreen extends ConsumerWidget {
  const ItemViewScreen({super.key, this.itemId});
  final String? itemId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ref.watch(itemProvider(itemId)).when(
            data: (item) => ResponsiveWidget(
              smallScreen: ItemViewScreenMobile(item: item),
              largeScreen: ItemViewScreenWeb(item: item),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
