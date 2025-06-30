part of 'credit_note_notifier.dart';

enum CreditNoteStatus {
    initial,
    loading,
    success,
    error,
}

extension CreditNoteStatusExtension on CreditNoteStatus {
    R when<R>({
      required R Function() initial,
      required R Function() loading,
      required R Function() success,
      required R Function() error,
    }) {
      switch (this) {
        case CreditNoteStatus.initial:
          return initial();
        case CreditNoteStatus.loading:
          return loading();
        case CreditNoteStatus.success:
          return success();
        case CreditNoteStatus.error:
          return error();
      }
    }
  }

@freezed
class CreditNoteState with _$CreditNoteState {
    const factory CreditNoteState({
    @Default(CreditNoteStatus.initial) CreditNoteStatus status,
    @Default([]) List<CreditNote> credit,
    @Default(0) int count,
    @Default(1) int pageNumber,
    @Default(10) int pageSize,
    PlutoGridStateManager? stateManager,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    PagingController<int, CreditNote>? pagingController,
    PagingController<int, CreditNote>? creditDetailsPagingController,
    String? selectedCreditId,
    }) = _CreditNoteState;

    factory CreditNoteState.initial() => const CreditNoteState();
}
