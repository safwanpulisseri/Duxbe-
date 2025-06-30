import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

@freezed
class Customer with _$Customer {
  @JsonSerializable(explicitToJson: true)
  const factory Customer({
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'phone') String? phone,
    @Default(0) @JsonKey(name: 'customer_balance') double customerBalance,
    @JsonKey(name: 'customer_id', includeIfNull: false) String? customerId,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'image') String? image,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}
