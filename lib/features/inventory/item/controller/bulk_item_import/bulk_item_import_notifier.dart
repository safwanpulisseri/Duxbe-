import 'dart:async';

import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bulk_item_import_notifier.freezed.dart';
part 'bulk_item_import_notifier.g.dart';

@Riverpod(keepAlive: false)
class BulkItemImportNotifier extends _$BulkItemImportNotifier {
  late IItemRepository _itemRepository;

  @override
  BulkItemImportState build() {
    _itemRepository = ref.watch(itemRepoProvider);
    return const BulkItemImportState.initial();
  }

  Future<void> createBulkItem(List<Map<String, dynamic>> validRows, {required bool skipDuplicates}) async {
    state = const BulkItemImportState.loading();
    try {
      await _itemRepository.createBulkItem(validRows, skipDuplicates: skipDuplicates);
      state = const BulkItemImportState.success();
      Alert.showSnackBar('Items imported successfully!', type: SnackBarType.success);
    } catch (e) {
      state = BulkItemImportState.error(e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }
}

@freezed
class BulkItemImportState with _$BulkItemImportState {
  const factory BulkItemImportState.initial() = _Initial;
  const factory BulkItemImportState.loading() = _Loading;
  const factory BulkItemImportState.success() = _Success;
  const factory BulkItemImportState.error(String message) = _Error;
}
