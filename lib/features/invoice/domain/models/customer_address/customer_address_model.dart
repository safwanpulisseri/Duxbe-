import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_address_model.freezed.dart';
part 'customer_address_model.g.dart';

@freezed
class CustomerAddress with _$CustomerAddress {
  const factory CustomerAddress({
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'zipcode') String? zipcode,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'customer_addresses_id') String? customerAddressesId,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'is_default') bool? isDefault,
    @JsonKey(name: 'company_name') String? companyName,
  }) = _CustomerAddress;

  factory CustomerAddress.fromJson(Map<String, dynamic> json) => _$CustomerAddressFromJson(json);

  const CustomerAddress._();
  String get formattedAddress {
    final parts = <String>[];

    // Add name parts if available
    if (firstName != null || lastName != null) {
      parts.add([firstName, lastName].where((e) => e != null).join(' '));
    }

    // Add company name if available
    if (companyName != null) {
      parts.add(companyName!);
    }

    // Add address if available
    if (address != null) {
      parts.add(address!);
    }

    // Add city, state, zipcode if any are available
    final locationParts = <String>[];
    if (city != null) locationParts.add(city!);
    if (state != null) locationParts.add(state!);
    if (zipcode != null) locationParts.add(zipcode!);
    if (locationParts.isNotEmpty) {
      parts.add(locationParts.join(', '));
    }

    // Add country if available
    if (country != null) {
      parts.add(country!);
    }

    // Add contact info if available
    if (phone != null) {
      parts.add('Phone: $phone');
    }
    if (email != null) {
      parts.add('Email: $email');
    }

    return parts.join('\n');
  }
}
