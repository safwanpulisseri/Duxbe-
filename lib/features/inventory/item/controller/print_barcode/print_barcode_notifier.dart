import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_barcode_notifier.freezed.dart';
part 'print_barcode_notifier.g.dart';
part 'print_barcode_state.dart';

@Riverpod(keepAlive: false)
class PrintBarcodeNotifier extends _$PrintBarcodeNotifier {
  late IItemRepository _itemRepository;

  @override
  PrintBarcodeState build() {
    _itemRepository = ref.watch(itemRepoProvider);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Refresh the paging controller when business changes
      setFilter(pageNumber: 1);
    });

    state = PrintBarcodeState.initial();

    // This is to set infinte scrolling in mobile devices
    return state.copyWith(
      pagingController: PagingController<int, Item>(
        firstPageKey: state.pageNumber,
      )..addPageRequestListener(
          (pageKey) async {
            final items = await getItems(pageNumber: pageKey);
            final isLastPage = items.data.length < state.pageSize;
            if (isLastPage) {
              state.pagingController!.appendLastPage(items.data);
            } else {
              final nextPageKey = pageKey + 1;
              state.pagingController!.appendPage(items.data, nextPageKey);
            }
          },
        ),
    );
  }

  void setFilter({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) {
    state = state.copyWith(query: query ?? state.query, pageSize: pageSize ?? state.pageSize, pageNumber: pageNumber ?? state.pageNumber);
    state.pagingController?.refresh();
  }

  Future<PaginatedResponse<Item>> getItems({
    String? query,
    int? pageSize,
    int? pageNumber,
  }) async {
    try {
      final items = await _itemRepository.getItems(
        query: query ?? state.query,
        pageSize: pageSize ?? state.pageSize,
        pageNumber: pageNumber ?? state.pageNumber,
      );
      return items;
    } catch (e) {
      state = state.copyWith(
        status: PrintBarcodeStatus.error,
        error: e.toString(),
      );
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      rethrow;
    }
  }
}
