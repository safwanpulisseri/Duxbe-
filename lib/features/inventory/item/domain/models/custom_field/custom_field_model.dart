import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_field_model.freezed.dart';
part 'custom_field_model.g.dart';

enum FieldType { text, number, boolean, date, url }

@freezed
class CustomField with _$CustomField {
  @JsonSerializable(explicitToJson: true) 
  const factory CustomField({
    @JsonKey(name: 'field_name') required String fieldName,
    @JsonKey(name: 'field_id', includeIfNull: false) String? fieldId,
    @JsonKey(name: 'business_id', includeIfNull: false) String? businessId,
    @JsonKey(name: 'field_type') FieldType? fieldType,
    @Default(false) @JsonKey(name: 'is_required') bool isRequired,
    @JsonKey(name: 'default_value') String? defaultValue,
  }) = _CustomField;

  factory CustomField.fromJson(Map<String, dynamic> json) => _$CustomFieldFromJson(json);
}
