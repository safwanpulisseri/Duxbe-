import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_pemissions_model.freezed.dart';
part 'role_pemissions_model.g.dart';

@unfreezed
class Module with _$Module {
  factory Module({
    @JsonKey(name: 'id') required int id,
    required String url,
    required String name,
    @JsonKey(name: 'permissions') required Permissions permissions,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'description') String? description,
    @Default([]) @JsonKey(name: 'submenus') List<Submenu> submenus,
  }) = _Module;

  factory Module.fromJson(Map<String, Object?> json) => _$ModuleFromJson(json);
}

@unfreezed
class Permissions with _$Permissions {
  factory Permissions({
    @JsonKey(name: 'permission_id') String? permissionId,
    @Default(false) @JsonKey(name: 'add') bool add,
    @Default(false) @JsonKey(name: 'edit') bool edit,
    @Default(false) @JsonKey(name: 'view') bool view,
    @Default(false) @JsonKey(name: 'print') bool print,
    @Default(false) @JsonKey(name: 'delete') bool delete,
  }) = _Permissions;

  factory Permissions.fromJson(Map<String, Object?> json) => _$PermissionsFromJson(json);
}

@unfreezed
class Submenu with _$Submenu {
  factory Submenu({
    @JsonKey(name: 'id') required int id,
    required String url,
    @JsonKey(name: 'link_name') required String linkName,
    @JsonKey(name: 'permissions') required Permissions permissions,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @Default(true) bool visibility,
  }) = _Submenu;

  factory Submenu.fromJson(Map<String, Object?> json) => _$SubmenuFromJson(json);
}
