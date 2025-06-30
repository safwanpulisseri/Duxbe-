import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class Settings with _$Settings {
  factory Settings({
    int? id,
    @Default(false) @JsonKey(name: 'allow_walkin_customer') bool allowWalkinCustomer,
    @Default(false) @JsonKey(name: 'allow_out_of_stock') bool allowOutofStock,
    @Default(true) @JsonKey(name: 'print_on_sale') bool printOnSale,
    @Default(true) @JsonKey(name: 'print_on_purchase') bool printOnPurchase,
    @Default(true) @JsonKey(name: 'print_barcode') bool printBarcode,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
}

@freezed
class AuthApiErrorResponse with _$AuthApiErrorResponse {
  @JsonSerializable(explicitToJson: true)
  factory AuthApiErrorResponse({
    @JsonKey(name: 'error') required String error,
    @JsonKey(name: 'details') String? details,
  }) = _AuthApiErrorResponse;

  factory AuthApiErrorResponse.fromJson(Map<String, dynamic> json) => _$AuthApiErrorResponseFromJson(json);
}

@freezed
class AuthApiResponse with _$AuthApiResponse {
  @JsonSerializable(explicitToJson: true)
  factory AuthApiResponse({
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'token') String? token,
    @JsonKey(name: 'details') String? details,
    @JsonKey(name: 'code') int? code,
  }) = _AuthApiResponse;

  factory AuthApiResponse.fromJson(Map<String, dynamic> json) => _$AuthApiResponseFromJson(json);
}
