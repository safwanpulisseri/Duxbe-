import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_notifier.freezed.dart';
part 'auth_notifier.g.dart';
part 'auth_state.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late IAuthRepository _authRepository;
  late IAnalyticsRepository _analyticsRepository;

  @override
  AuthNotifierState build() {
    _authRepository = ref.watch(authRepoProvider);
    _analyticsRepository = ref.watch(analyticsRepoProvider);
    state = const AuthNotifierState();
    // Use Future.microtask to defer the execution until after initialization
    Future.microtask(getUserDetails);
    ref.listen(businessNotifierProvider, (previous, next) {
      // Use Future.microtask to avoid modifying providers during build
      if (previous != next) {
        Future.microtask(getUserDetails);
      }
    });
    return AuthNotifierState.initial();
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.signIn(email, password);
      state = state.copyWith(user: user);
      unawaited(getSidebar());

      // Track login success with GA4
      _analyticsRepository
        ..logEvent(
          AuthEvents.loginSuccess,
          {
            AnalyticsParams.userId: user.email,
            AnalyticsParams.eventCategory: 'auth',
            AnalyticsParams.eventAction: 'login',
            AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
            'email': email,
            'user_role': user.role.toString(),
          },
        )
        ..setUserId(user.email)
        ..trackSessionStart(user.email, user.role.toString());

      Alert.showSnackBar(
        AppRouter.l10n.loginSuccessfully,
        type: SnackBarType.success,
      );
      unawaited(
        ref.read(businessNotifierProvider.notifier).setBusiness(user.accessedBrances.firstOrNull?.businessId),
      );
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(error: e.toString());

      // Track login failure
      _analyticsRepository.logEvent(
        'login_failure',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'login_failure',
          AnalyticsParams.eventLabel: e.toString(),
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
          'email_provided': email,
        },
      );
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<void> signUp(Map<String, dynamic> signUpDetails) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.signUp(signUpDetails);
      state = state.copyWith(user: user);
      unawaited(getSidebar());

      // Track signup success with GA4
      _analyticsRepository
        ..logEvent(
          'signup',
          {
            AnalyticsParams.userId: user.email,
            AnalyticsParams.eventCategory: 'auth',
            AnalyticsParams.eventAction: 'signup',
            AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
            'email': signUpDetails['email'].toString(),
            'user_role': user.role.toString(),
            'signup_method': 'email',
          },
        )
        ..setUserId(user.email)
        ..trackSessionStart(user.email, user.role.toString());

      unawaited(
        ref.read(businessNotifierProvider.notifier).setBusiness(user.accessedBrances.firstOrNull?.businessId),
      );
    } on AppException catch (e) {
      if (e.code == 100) {
        // show a dialog to the user to accept the invitation
        AppRouter.showConfirmationDialog(
          icon: const Icon(Icons.person_add_alt_1_outlined),
          title: e.message,
          children: [
            Text(e.details ?? ''),
          ],
          positiveText: 'Accept',
          negativeText: 'Reject',
          onPositive: () {
            // accepted the invitation so send to login screen
            AppRouter.goNamed(AppRouter.login);
            // So message to the user that you have been invited to an organization, check your email for the invitation or reset your password
            Alert.showSnackBar(
              'You have been invited to an organization, check your email for the invitation or reset your password',
              type: SnackBarType.success,
            );
          },
          onNegative: () {
            // reject the invitation
            signUp(signUpDetails..['force_signup'] = true);
          },
        );
      } else if (e.code == 101) {
        // show a snackbar to the user to create an organization
        Alert.showSnackBar(e.message, type: SnackBarType.success);
        AppRouter.goNamed(AppRouter.login);
      } else {
        Alert.showSnackBar("${e.message} ${e.details ?? ''}", type: SnackBarType.error);
      }
    } catch (e) {
      log(e.toString());
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);

      // Track signup failure
      _analyticsRepository.logEvent(
        'signup_failure',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'signup_failure',
          AnalyticsParams.eventLabel: e.toString(),
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
          'email_provided': signUpDetails['email'].toString(),
        },
      );
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<void> getUserDetails() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.getUserDetails();
      state = state.copyWith(user: user);

      if (user != null) {
        // Set user ID for analytics
        _analyticsRepository.setUserId(user.email);

        // Set user properties
        _analyticsRepository.setUserProperties({
          'user_role': user.role.toString(),
          'user_name': user.name,
          'user_email': user.email,
        });

        unawaited(getSidebar());
      }
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(error: e.toString(), user: null);
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<void> getSidebar() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final sidebar = await _authRepository.getSidebar();
      state = state.copyWith(sidebar: sidebar);
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(user: null);
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<void> signOut() async {
    final user = state.user;

    if (user != null) {
      // Track session end
      _analyticsRepository.trackSessionEnd(user.email);

      // Track logout event
      _analyticsRepository.logEvent(
        AuthEvents.logout,
        {
          AnalyticsParams.userId: user.email,
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'logout',
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );
    }

    // First, clear shared preferences
    await ref.read(sharedPrefsProvider).value!.clear();

    // Then sign out from Supabase
    await _authRepository.signOut();

    // Finally invalidate providers using microtask to avoid circular dependency issues
    Future.microtask(() {
      // Invalidate business provider first, then self
      ref.invalidate(businessNotifierProvider);
      ref.invalidateSelf();
    });
  }

  Future<bool> verifyResetPassword(String email, String token) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final authResponse = await _authRepository.verifyResetPassword(email, token);
      state = state.copyWith(authResponse: authResponse);

      // Track password reset verification
      _analyticsRepository.logEvent(
        'password_reset_verify',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'password_reset_verify',
          'email': email,
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );

      return true;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);

      // Track verification failure
      _analyticsRepository.logEvent(
        'password_reset_verify_failure',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'password_reset_verify_failure',
          AnalyticsParams.eventLabel: e.toString(),
          'email': email,
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );

      return false;
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.forgotPassword(email);

      // Track password reset request
      _analyticsRepository.logEvent(
        AuthEvents.passwordReset,
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'password_reset_request',
          'email': email,
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );

      Alert.showSnackBar(
        AppRouter.l10n.passwordResetOtpSentSuccessfully,
        type: SnackBarType.success,
      );
      return true;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);

      // Track password reset failure
      _analyticsRepository.logEvent(
        'password_reset_request_failure',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'password_reset_request_failure',
          AnalyticsParams.eventLabel: e.toString(),
          'email': email,
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );

      return false;
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<bool> createPassword(
    String password, {
    String? refreshToken,
    String? orgId,
    String? type,
    String? accessToken,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.createPassword(
        password,
        refreshToken: refreshToken,
        orgId: orgId,
        type: type,
        accessToken: accessToken,
      );

      // Track password creation success
      _analyticsRepository.logEvent(
        'password_create_success',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'password_create',
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );
      unawaited(getUserDetails());
      return true;
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);

      // Track password creation failure
      _analyticsRepository.logEvent(
        'password_create_failure',
        {
          AnalyticsParams.eventCategory: 'auth',
          AnalyticsParams.eventAction: 'password_create_failure',
          AnalyticsParams.eventLabel: e.toString(),
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );

      return false;
    } finally {
      state = state.copyWith(status: AuthStatus.success);
    }
  }

  Future<void> updateUserPassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      final verified = await _authRepository.updateUserPassword(oldPassword, newPassword);

      if (verified) {
        Alert.showSnackBar(
          AppRouter.l10n.passwordChangedSuccessfully,
          type: SnackBarType.success,
        );

        // Track password update success
        _analyticsRepository.logEvent(
          'password_update_success',
          {
            AnalyticsParams.eventCategory: 'account',
            AnalyticsParams.eventAction: 'password_update',
            AnalyticsParams.userId: state.user?.email ?? '',
            AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
          },
        );
      } else {
        Alert.showSnackBar(
          AppRouter.l10n.passwordChangingFailed,
          type: SnackBarType.error,
        );

        // Track password update failure
        _analyticsRepository.logEvent(
          'password_update_failure',
          {
            AnalyticsParams.eventCategory: 'account',
            AnalyticsParams.eventAction: 'password_update_failure',
            AnalyticsParams.userId: state.user?.email ?? '',
            AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
          },
        );
      }
      state = state.copyWith(status: AuthStatus.success);
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(status: AuthStatus.error);

      // Track error
      _analyticsRepository.trackError(
        e.toString(),
        ModuleNames.settings,
        state.user?.email ?? '',
      );
    }
  }

  Future<void> updateUserDetails(
    String name,
    // ignore: type_annotate_public_apis, inference_failure_on_untyped_parameter
    var image,
  ) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authRepository.editEmployee(name: name, image: image);
      state = state.copyWith(status: AuthStatus.success);

      // Track profile update
      _analyticsRepository.logEvent(
        AccountEvents.profileUpdated,
        {
          AnalyticsParams.eventCategory: 'account',
          AnalyticsParams.eventAction: 'profile_update',
          AnalyticsParams.userId: state.user?.email ?? '',
          'updated_fields': 'name,image',
          AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
        },
      );

      Alert.showSnackBar(
        'Profile updated successfully',
        type: SnackBarType.success,
      );
      unawaited(getUserDetails());
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(status: AuthStatus.error);

      // Track error
      _analyticsRepository.trackError(
        e.toString(),
        ModuleNames.settings,
        state.user?.email ?? '',
      );
    }
  }

  // Go to enter business screen
  Future<void> goToEnterBusiness(Map<String, dynamic> signUpDetails) async {
    try {
      if (signUpDetails['email'] != null && signUpDetails['password'] != null) {
        state = state.copyWith(status: AuthStatus.loading);

        final userExists = await _authRepository.checkUserExists(
          signUpDetails['email'].toString(),
          signUpDetails['phone_number'].toString(),
        );
        state = state.copyWith(status: AuthStatus.success);

        if (!userExists) {
          // Track business registration start
          _analyticsRepository.logEvent(
            'business_registration_start',
            {
              AnalyticsParams.eventCategory: 'onboarding',
              AnalyticsParams.eventAction: 'start_business_registration',
              'email': signUpDetails['email'].toString(),
              AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
            },
          );

          await AppRouter.pushNamed(
            AppRouter.businessRegister,
            extra: signUpDetails,
          );
        } else {
          Alert.showSnackBar('Email or phone number is already registered', type: SnackBarType.error);

          // Track user exists error
          _analyticsRepository.logEvent(
            'user_exists_error',
            {
              AnalyticsParams.eventCategory: 'auth',
              AnalyticsParams.eventAction: 'signup_user_exists',
              'email': signUpDetails['email'].toString(),
              AnalyticsParams.platform: kIsWeb ? 'web' : Platform.operatingSystem,
            },
          );
        }
      }
      state = state.copyWith(status: AuthStatus.success);
    } on Exception catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
      state = state.copyWith(status: AuthStatus.error);
    }
  }
  
}
