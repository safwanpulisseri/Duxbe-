import 'package:duxbe/features/auth/auth.dart';

class RouteItem {
  RouteItem({
    required this.route,
    required this.label,
    required this.permissions,
    required this.visibility,
    required this.sortOrder,
    this.selectedIcon,
    this.unselectedIcon,
    this.subItems = const [],
  });
  final String route;
  final String label;
  final String? selectedIcon;
  final String? unselectedIcon;
  final List<RouteItem> subItems;
  Permissions permissions;
  final bool visibility;
  final int sortOrder;
}
