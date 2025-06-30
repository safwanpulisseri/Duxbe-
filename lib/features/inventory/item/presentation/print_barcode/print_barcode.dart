import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';

export 'print_barcode_list.dart';
export 'print_barcode_mobile.dart';
export 'print_barcode_web.dart';

class StickerProps {
  StickerProps({
    required this.title,
    required this.height,
    required this.width,
    required this.crossAxisCount,
    required this.maxStickerCountPerPage,
  });

  final String title;
  final double height;
  final double width;
  final int crossAxisCount;
  double get aspectRatio => width / height;
  final int maxStickerCountPerPage;
}

class PrintBarcodeScreen extends ConsumerWidget {
  const PrintBarcodeScreen({super.key, this.itemId});
  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      body: ref.watch(itemProvider(itemId)).when(
            data: (item) => ResponsiveWidget(
              smallScreen: PrintBarcodeScreenMobile(item: item),
              largeScreen: PrintBarcodeScreenWeb(item: item),
            ),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: Loader.new,
          ),
    );
  }
}
