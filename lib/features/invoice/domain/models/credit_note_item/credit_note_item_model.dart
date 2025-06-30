import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_note_item_model.freezed.dart';
part 'credit_note_item_model.g.dart';

@freezed
class CreditNoteItem with _$CreditNoteItem {
  const factory CreditNoteItem({
     @JsonKey(name: 'credit_note_item_id') required String creditNoteItemId,
    @JsonKey(name: 'item_id') required String itemId,
    required double quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'total_price') required double totalPrice,
  }) = _CreditNoteItem;

  factory CreditNoteItem.fromJson(Map<String, dynamic> json) =>
      _$CreditNoteItemFromJson(json);
}
