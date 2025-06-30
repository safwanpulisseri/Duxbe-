import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_sales_model.freezed.dart';
part 'employee_sales_model.g.dart';

@freezed
class EmployeeSales with _$EmployeeSales {
  const factory EmployeeSales({
    @JsonKey(name: 'employee_name') required String employeeName,
    @JsonKey(name: 'employee_role') required String employeeRole,
    @JsonKey(name: 'employee_code') String? employeeCode,
    @JsonKey(name: 'total_items_sold') @Default(0) int totalItemsSold,
    @JsonKey(name: 'total_revenue_generated') @Default(0) double totalRevenueGenerated,
  }) = _EmployeeSales;

  factory EmployeeSales.fromJson(Map<String, dynamic> json) => _$EmployeeSalesFromJson(json);
}
