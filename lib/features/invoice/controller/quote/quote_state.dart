part of 'quote_notifier.dart';

enum QuoteStatus {
    initial,
    loading,
    success,
    error,
}

extension QuoteStatusExtension on QuoteStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case QuoteStatus.initial:
          return initial();
        case QuoteStatus.loading:
          return loading();
        case QuoteStatus.success:
          return success();
        case QuoteStatus.error:
          return error();
      }
    }
  }

@freezed
class QuoteState with _$QuoteState {
    const factory QuoteState({
    @Default(QuoteStatus.initial) QuoteStatus status,
    @Default([]) List<Quote> quotes,
    @Default(0) int count,
    @Default(1) int pageNumber,
    @Default(10) int pageSize,
    PlutoGridStateManager? stateManager,
    String? query,
    ItemType? selectedItemType,
    List<ItemCategory>? selectedCategories,
    DateTime? startDate,
    DateTime? endDate,
    PagingController<int, Quote>? pagingController,
    PagingController<int, Quote>? quoteDetailsPagingController,
    String? selectedQuoteId,
  }) = _QuoteState;

  factory QuoteState.initial() => const QuoteState();
}
