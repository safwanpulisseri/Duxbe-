import 'package:freezed_annotation/freezed_annotation.dart';

part 'fiscal_year_model.freezed.dart';
part 'fiscal_year_model.g.dart';

@freezed
class FiscalYear with _$FiscalYear {
  const factory FiscalYear({
    @JsonKey(name: 'fiscal_id') required String fiscalId,
    required String name,
    @JsonKey(name: 'start_month') required int startMonth,
    @JsonKey(name: 'end_month') required int endMonth,
  }) = _FiscalYear;

  factory FiscalYear.fromJson(Map<String, dynamic> json) => _$FiscalYearFromJson(json);
}
