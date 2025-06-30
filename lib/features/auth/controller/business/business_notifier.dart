import 'dart:async';
import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'business_notifier.g.dart';

@riverpod
Future<List<FiscalYear>> fiscalYears(
  FiscalYearsRef ref,
) async =>
    ref.watch(businessRepoProvider).getFiscalYears();

@riverpod
Future<Country> getCountryById(
  GetCountryByIdRef ref,
  String isoCode,
) async =>
    ref.watch(businessRepoProvider).getCountryByIso(id: isoCode);

@Riverpod(keepAlive: true)
class BusinessNotifier extends _$BusinessNotifier {
  late IAuthRepository _authRepository;
  late SharedPreferences _preferences;
  StreamSubscription<List<Map<String, dynamic>>>? _businessSubscription;

  @override
  Business? build() {
    _authRepository = ref.watch(authRepoProvider);
    final sharedPrefs = ref.watch(sharedPrefsProvider).value;
    if (sharedPrefs == null) return null;
    _preferences = sharedPrefs;

    ref
      ..onDispose(() async {
        await _businessSubscription?.cancel();
        debugPrint('BusinessNotifier disposed, cancelled subscription.');
      })

      // Listener setup reacting to state changes
      ..listenSelf((previous, next) {
        _subscribeToBusinessUpdates(next?.businessId);
      });

    // Load initial state from preferences
    final storedBusiness = _preferences.getString('business');
    Business? initialState;
    try {
      if (storedBusiness != null) {
        initialState = Business.fromJson(
          jsonDecode(storedBusiness) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      print('Error decoding stored business: $e');
      _preferences.remove('business');
      initialState = null;
    }

    // Initial subscription based on loaded state
    // Use Future.microtask to ensure it runs after the build completes
    // and state initialization is done.
    Future.microtask(() => _subscribeToBusinessUpdates(initialState?.businessId));

    return initialState;
  }

  Future<void> _subscribeToBusinessUpdates(String? businessId) async {
    // Cancel previous subscription first
    await _businessSubscription?.cancel();
    _businessSubscription = null;

    if (businessId == null) {
      debugPrint('No business ID to subscribe to. Current state ID: ${state?.businessId}');
      return;
    }

    debugPrint('Subscribing to business updates for ID: $businessId');
    final supabase = ref.read(supabaseProvider);

    _businessSubscription =
        supabase.from('businesses').stream(primaryKey: ['business_id']).eq('business_id', businessId).listen(
              (data) async {
                debugPrint('Business update received for $businessId: $data');
                if (data.isNotEmpty) {
                  final newRecord = data.first;
                  try {
                    final updatedBusiness = Business.fromJson(newRecord);
                    if (state != updatedBusiness) {
                      state = updatedBusiness;
                      await _preferences.setString('business', jsonEncode(updatedBusiness.toJson()));
                      debugPrint('Business state updated from stream listener for $businessId.');
                    } else {
                      debugPrint('No change in business data for $businessId, state not updated.');
                    }
                  } catch (e, s) {
                    debugPrint('Error processing business update payload for $businessId: $e\n$s');
                  }
                } else {
                  debugPrint('Received empty data list for business $businessId.');
                }
              },
              onError: (error, stackTrace) {
                debugPrint('Error in business stream for $businessId: $error\n$stackTrace');
              },
              onDone: () {
                debugPrint('Business stream for $businessId was closed.');
              },
            );
    debugPrint('Subscription status for $businessId: ${_businessSubscription != null ? "active" : "inactive"}');
  }

  Future<void> setBusiness(String? businessId) async {
    try {
      final business = await _authRepository.getBusinessFromId(businessId);
      // The state change below will trigger ref.listenSelf -> _subscribeToBusinessUpdates
      state = business;

      if (business == null) {
        await _preferences.remove('business');
        debugPrint('Business set to null, preferences cleared.');
        // Set business_id to null in user metadata
        await ref.read(supabaseProvider).auth.updateUser(
              UserAttributes(data: {ref.watch(deviceIdProvider): null}),
            );
      } else {
        await _preferences.setString('business', jsonEncode(business.toJson()));
        debugPrint('Business ${business.businessId} set, preferences updated.');
        await ref.read(supabaseProvider).auth.updateUser(
              UserAttributes(
                data: {
                  ref.watch(deviceIdProvider): business.businessId,
                },
              ),
            );
      }

      // Refresh session might be needed after updateUser
      await ref.read(supabaseProvider).auth.refreshSession();
      debugPrint('Session refreshed after setting business.');
    } catch (e, s) {
      debugPrint('Error setting business: $e\n$s');
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }
}

@Riverpod(keepAlive: true)
String currency(CurrencyRef ref) =>
    ref.watch(businessNotifierProvider.select((value) => value?.currency?.symbol)) ?? r'$';
