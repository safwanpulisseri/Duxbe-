import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'item_details_mobile.dart';
export 'item_details_web.dart';

class ItemDetailsScreen extends ConsumerWidget {
  const ItemDetailsScreen({super.key, this.itemId});
  final String? itemId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ref.watch(itemProvider(itemId)).when(
            data: (item) => ResponsiveWidget(
              smallScreen: ItemDetailsScreenMobile(item: item),
              largeScreen: ItemDetailsScreenWeb(item: item),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
