import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_model.freezed.dart';
part 'country_model.g.dart';

@freezed
class Country with _$Country {
  const factory Country({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'iso_code') required String isoCode,
    @JsonKey(name: 'emoji') String? emoji,
    @JsonKey(name: 'emojiU') String? emojiU,
    @JsonKey(name: 'currency') String? currency,
  }) = _Country;

  factory Country.fromJson(Map<String, Object?> json) => _$CountryFromJson(json);
}

@freezed
class CountryState with _$CountryState {
  const factory CountryState({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'country_id') required int countryId,
  }) = _CountryState;

  factory CountryState.fromJson(Map<String, Object?> json) => _$CountryStateFromJson(json);
}

@freezed
class City with _$City {
  const factory City({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'state_id') required int stateId,
  }) = _City;

  factory City.fromJson(Map<String, Object?> json) => _$CityFromJson(json);
}
