import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_model.freezed.dart';
part 'currency_model.g.dart';

@freezed
class Currency with _$Currency {
  const factory Currency({
    @JsonKey(name: 'name') required String name,
    @Default([]) @JsonKey(name: 'country_code') List<String> countryCode,
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'symbol') String? symbol,
    @JsonKey(name: 'flag') String? flag,
    @JsonKey(name: 'decimal_digits') int? decimalDigits,
    @JsonKey(name: 'number') int? number,
    @JsonKey(name: 'name_plural') String? namePlural,
    @JsonKey(name: 'thousands_separator') String? thousandsSeparator,
    @JsonKey(name: 'decimal_separator') String? decimalSeparator,
    @JsonKey(name: 'space_between_amount_and_symbol') bool? spaceBetweenAmountAndSymbol,
    @JsonKey(name: 'symbol_on_left') bool? symbolOnLeft,
  }) = _Currency;

  factory Currency.fromJson(Map<String, Object?> json) => _$CurrencyFromJson(json);
}
