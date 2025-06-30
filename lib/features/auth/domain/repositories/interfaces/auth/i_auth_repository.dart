import 'package:duxbe/features/auth/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Future<EmployeeModel> signIn(String email, String password);
  Future<EmployeeModel> signUp(Map<String, dynamic> signUpDetails);
  Future<void> forgotPassword(String email);
  Future<AuthResponse> verifyResetPassword(String email, String token);
  Future<UserResponse> createPassword(
    String password, {
    String? refreshToken,
    String? orgId,
    String? type,
    String? accessToken,
  });
  Future<void> signOut();
  Future<EmployeeModel?> getUserDetails();
  Future<List<RouteItem>> getSidebar();
  Future<Business?> getBusinessFromId(String? businessId);
  Future<bool> updateUserPassword(String oldPassword, String newPassword);
  Future<bool> verifyUserPassword(String password);
  Future<void> editEmployee({String? name, String? email, String? phone, dynamic image});
  Future<bool> checkUserExists(String email, String phone);
}
