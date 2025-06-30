import 'dart:typed_data';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
IAuthRepository authRepo(AuthRepoRef ref) => AuthRepository(ref);

class AuthRepository implements IAuthRepository {
  AuthRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);

  final AuthRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<EmployeeModel> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'employees/auth',
        body: {
          'platform': 'duxbe',
          'user_type': 'employee',
          'auth': {'type': 'login', 'email': email, 'password': password},
        },
      ).then((value) {
        if (value.data == null) {
          throw AppException(AppRouter.l10n.userDoesNotExist);
        }
        final response = AuthApiResponse.fromJson(value.data as Map<String, dynamic>);
        if (response.token == null) {
          throw AppException(response.message, details: response.details?.toString(), code: response.code);
        }
        return response.token!;
      }).catchError((e) {
        if (e is AppException) {
          throw e;
        }
        final error = AuthApiErrorResponse.fromJson(e.details as Map<String, dynamic>);
        throw AppException('${error.error} ${error.details?.toString() ?? ''}');
      });

      final user = await _supabaseClient.auth.setSession(response);
      if (user.user == null) {
        throw AppException(AppRouter.l10n.userDoesNotExist);
      }

      final userList = await _supabaseClient
          .from(DbConstants.employeeView)
          .select(
            '*,organizations!employees_org_id_fkey(*),employee_branches_view(*)',
          )
          .eq('employee_id', user.user!.id);
      if (userList.isEmpty) {
        throw AppException(AppRouter.l10n.userDoesNotExist);
      } else {
        return EmployeeModel.fromJson(userList.single);
      }
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<EmployeeModel> signUp(Map<String, dynamic> signUpDetails) async {
    try {
      final deviceId = ref.read(deviceIdProvider);
      final response = await _supabaseClient.functions.invoke(
        'employees/auth',
        body: {
          'platform': 'duxbe',
          'user_type': 'employee',
          'force_signup': signUpDetails['force_signup'] ?? false,
          'auth': {
            'type': 'signup',
            'email': signUpDetails['email'].toString(),
            'password': signUpDetails['password'].toString(),
            'phone': signUpDetails['phone_number'].toString().replaceAll('+', ''),
          },
          'data': {
            'user_type': 'employee',
            'user_name': signUpDetails['name'],
            'business_type': signUpDetails['business_type'],
            'phone_number': signUpDetails['phone_number'],
            'currency': signUpDetails['currency']?.toJson(),
            'device_id': deviceId,
          },
        },
      ).then((value) {
        if (value.data == null) {
          throw AppException(AppRouter.l10n.userDoesNotExist);
        }
        final response = AuthApiResponse.fromJson(value.data as Map<String, dynamic>);
        if (response.token == null) {
          throw AppException(response.message, details: response.details?.toString(), code: response.code);
        }
        return response.token!;
      }).catchError((e) {
        if (e is AppException) {
          throw e;
        }
        final error = AuthApiErrorResponse.fromJson(e.details as Map<String, dynamic>);
        throw AppException('${error.error} ${error.details?.toString() ?? ''}');
      });

      final user = await _supabaseClient.auth.setSession(response);

      // This RPC adds the user and business to respective tables
      final userModel = await Supabase.instance.client
          .from(DbConstants.employeeView)
          .select(
            '*,organizations!employees_org_id_fkey(*),employee_branches_view(*)',
          )
          .eq('employee_id', user.user!.id)
          .single()
          .withConverter(EmployeeModel.fromJson);
      return userModel;
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<AuthResponse> verifyResetPassword(String email, String token) async {
    try {
      final resp = await _supabaseClient.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
        //  saveSession: false,
      );
      return resp;
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<EmployeeModel?> getUserDetails() async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        return null;
      }
      final userModel = await _supabaseClient
          .from(DbConstants.employeeView)
          .select(
            '*,organizations!employees_org_id_fkey(*),employee_branches_view(*)',
          )
          .eq('employee_id', _supabaseClient.auth.currentUser!.id)
          .single()
          .withConverter(EmployeeModel.fromJson);
      return userModel;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details.toString(),
      );
    }
  }

  @override
  Future<Business?> getBusinessFromId(String? businessId) async {
    try {
      if (_supabaseClient.auth.currentUser == null || businessId == null) {
        return null;
      }
      final business = await _supabaseClient
          .from(DbConstants.businesses)
          .select('*, whatsapp_integration(*)')
          .eq('business_id', businessId)
          .single()
          .withConverter(Business.fromJson);
      return business;
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<UserResponse> createPassword(
    String password, {
    String? refreshToken,
    String? orgId,
    String? type,
    String? accessToken,
  }) async {
    try {
      if (refreshToken != null) {
        await _supabaseClient.auth.setSession(refreshToken);
      }

      return await _supabaseClient.auth.updateUser(
        UserAttributes(
          password: password,
          data: {
            if (type == 'invite' || type == 'magiclink') ...{
              'org_id': orgId,
              'platform': 'duxbe',
              'is_employee': true,
              'employee_role': 'staff',
            },
          },
        ),
      );
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<List<RouteItem>> getSidebar() async {
    try {
      return await _supabaseClient
          .rpc<PostgrestList>(
            RPCConstants.getSidebar,
          )
          .withConverter(
            (data) => data
                .map(Module.fromJson)
                .toList()
                .map(
                  (e) => RouteItem(
                    route: e.url,
                    label: e.name,
                    selectedIcon: 'assets/icons/${e.url}_selected.svg',
                    unselectedIcon: 'assets/icons/${e.url}_unselected.svg',
                    permissions: e.permissions,
                    visibility: true,
                    sortOrder: e.sortOrder,
                    subItems: e.submenus
                        .map(
                          (e) => RouteItem(
                            route: e.url,
                            label: e.linkName,
                            permissions: e.permissions,
                            visibility: e.visibility,
                            sortOrder: e.sortOrder,
                          ),
                        )
                        .toList()
                      ..sort((sortA, sortB) => sortA.sortOrder.compareTo(sortB.sortOrder))
                      ..removeWhere((element) => !element.permissions.view),
                  ),
                )
                .toList()
              ..sort((sortA, sortB) => sortA.sortOrder.compareTo(sortB.sortOrder))
              ..removeWhere((element) => !element.permissions.view),
          );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details.toString(),
      );
    }
  }

  @override
  Future<bool> updateUserPassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      if (await verifyUserPassword(oldPassword)) {
        await ref.read(supabaseProvider).auth.updateUser(
              UserAttributes(password: newPassword),
            );
      } else {
        throw AppException(AppRouter.l10n.oldPasswordDoesnTMatch);
      }
      return true;
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode, details: e.toString());
    }
  }

  @override
  Future<bool> verifyUserPassword(String password) async {
    try {
      final response = await _supabaseClient.rpc<bool>(RPCConstants.verifyUserPassword, params: {'password': password});
      return response;
    } on FunctionException catch (e) {
      throw AppException(
        e.details?['error'].toString() ?? 'Something went wrong',
        code: e.status,
        details: e.reasonPhrase?.toString(),
      );
    }
  }

  @override
  Future<void> editEmployee({String? name, String? email, String? phone, dynamic image}) async {
    try {
      String? url;
      if (image is Uint8List) {
        final fileName = _supabaseClient.auth.currentUser!.id;
        url = await ref.read(supabaseStorageProvider).uploadOrgImage(
              fileName: fileName,
              filePath: 'employee',
              file: image,
            );
      }
      await ref.read(supabaseProvider).from(DbConstants.employees).update({
        if (name != null) 'name': name,
        'image': url,
      }).eq('employee_id', _supabaseClient.auth.currentUser!.id);
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode, details: e.toString());
    }
  }

  @override
  Future<bool> checkUserExists(String email, String phone) async {
    final response = await _supabaseClient.rpc<PostgrestList>(
      'check_user_exists',
      params: {
        'p_email': email,
        'p_phone': phone,
      },
    );

    if (response.isEmpty) {
      return false;
    }

    final userEmail = response[0]['email'];
    final userPhone = response[0]['phone'];

    if (userPhone != null && userPhone != phone.replaceAll('+', '')) {
      throw const AppException(
        'Phone number mismatch',
        details: 'This provided number is already attached with another email',
      );
    }

    if (userEmail != null && userEmail != email) {
      throw const AppException(
        'Email mismatch',
        details: 'The provided email is already attached with another phone',
      );
    }
    final user = await _supabaseClient
        .from(DbConstants.employeeView)
        .select('employee_id')
        .or('email.eq.$email,phone.eq.${phone.replaceAll('+', '')}');
    if (user.isEmpty) {
      return false;
    }
    return true;
  }
}
