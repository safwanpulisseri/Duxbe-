import 'package:freezed_annotation/freezed_annotation.dart';

part 'icon_info_model.freezed.dart';
part 'icon_info_model.g.dart';

@freezed
class IconInfo with _$IconInfo {
  @JsonSerializable(explicitToJson: true) 
  const factory IconInfo({
    int? code,
    String? family,
    String? package,
  }) = _IconInfo;

  factory IconInfo.fromJson(Map<String, dynamic> json) => _$IconInfoFromJson(json);
}
