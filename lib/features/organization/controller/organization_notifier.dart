import 'dart:async';
import 'dart:convert';

import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/organization/models/organization.dart';
import 'package:duxbe/features/organization/repository/organization_repository.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'organization_notifier.g.dart';

@Riverpod(keepAlive: false)
Future<OrganizationDetails?> organization(
  OrganizationRef ref,
  String? organizationId,
) async =>
    organizationId == null ? null : ref.watch(orgRepoProvider).getOrganizationFromId(organizationId);

@Riverpod(keepAlive: true)
class OrganizationNotifier extends _$OrganizationNotifier {
  late IOrganizationRepository _organizationRepository;
  late SharedPreferences _preferences;

  @override
  OrganizationDetails? build() {
    _organizationRepository = ref.watch(orgRepoProvider);
    final sharedPrefs = ref.watch(sharedPrefsProvider).value;
    if (sharedPrefs == null) return null;
    _preferences = sharedPrefs;

    ref
      ..onDispose(() async {
        debugPrint('OrganizationNotifier disposed, cancelled subscription.');
      })

      // Listen to auth state changes to update organization
      ..listen(authNotifierProvider, (previous, next) {
        if (previous?.user?.orgId != next.user?.orgId) {
          Future.microtask(() => _loadOrganizationFromAuthState(next));
        }
      });

    // Load initial state from auth or preferences
    final storedOrganization = _preferences.getString('organization');
    OrganizationDetails? initialState;
    try {
      if (storedOrganization != null) {
        initialState = OrganizationDetails.fromJson(
          jsonDecode(storedOrganization) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      print('Error decoding stored organization: $e');
      _preferences.remove('organization');
      initialState = null;
    }

    // Check auth state for organization ID
    final authState = ref.read(authNotifierProvider);
    if (initialState == null && authState.user?.orgId != null) {
      // Use Future.microtask to ensure it runs after build
      Future.microtask(() => _loadOrganizationFromAuthState(authState));
    } else {
      // Subscribe to updates for initial state
      Future.microtask(() => _subscribeToOrganizationUpdates(initialState?.orgId));
    }

    return initialState;
  }

  Future<void> _loadOrganizationFromAuthState(AuthNotifierState authState) async {
    final orgId = authState.user?.orgId;
    if (orgId != null) {
      final organization = await _organizationRepository.getOrganizationFromId(orgId);
      if (organization != null) {
        state = organization;
        await _preferences.setString('organization', jsonEncode(organization.toJson()));
        _subscribeToOrganizationUpdates(orgId);
      }
    }
  }

  Future<void> _subscribeToOrganizationUpdates(String? organizationId) async {
    // Cancel previous subscription first

    if (organizationId == null) {
      debugPrint('No organization ID to subscribe to. Current state ID: ${state?.orgId}');
      return;
    }

    debugPrint('Subscribing to organization updates for ID: $organizationId');
    ref
        .watch(supabaseProvider)
        .realtime
        .channel('subscriptions')
        .onPostgresChanges(
          callback: (payload) async {
            debugPrint('Organization update received for $organizationId: $payload');
            try {
              final updatedOrganization =
                  await _organizationRepository.getOrganizationFromId(payload.newRecord['org_id'].toString());
              if (state != updatedOrganization) {
                state = updatedOrganization;
                await _preferences.setString('organization', jsonEncode(updatedOrganization!.toJson()));
                debugPrint('Organization state updated from stream listener for $organizationId.');
              } else {
                debugPrint('No change in organization data for $organizationId, state not updated.');
              }
            } catch (e, s) {
              debugPrint('Error processing organization update payload for $organizationId: $e\n$s');
            }
          },
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'subscriptions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'org_id',
            value: organizationId,
          ),
        )
        .subscribe(
      (status, data) {
        switch (status) {
          case RealtimeSubscribeStatus.subscribed:
            debugPrint('Organization stream for $organizationId connected.');
          case RealtimeSubscribeStatus.channelError:
            debugPrint('Organization stream for $organizationId disconnected.');
          case RealtimeSubscribeStatus.closed:
            debugPrint('Organization stream for $organizationId closed.');
          case RealtimeSubscribeStatus.timedOut:
            debugPrint('Organization stream for $organizationId timed out.');
        }
      },
    );

    ref
        .watch(supabaseProvider)
        .realtime
        .channel('organizations')
        .onPostgresChanges(
          callback: (payload) async {
            debugPrint('Organization update received for $organizationId: $payload');
            try {
              final updatedOrganization =
                  await _organizationRepository.getOrganizationFromId(payload.newRecord['org_id'].toString());
              if (state != updatedOrganization) {
                state = updatedOrganization;
                await _preferences.setString('organization', jsonEncode(updatedOrganization!.toJson()));
                debugPrint('Organization state updated from stream listener for $organizationId.');
              } else {
                debugPrint('No change in organization data for $organizationId, state not updated.');
              }
            } catch (e, s) {
              debugPrint('Error processing organization update payload for $organizationId: $e\n$s');
            }
          },
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'organizations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'org_id',
            value: organizationId,
          ),
        )
        .subscribe(
      (status, data) {
        switch (status) {
          case RealtimeSubscribeStatus.subscribed:
            debugPrint('Organization stream for $organizationId connected.');
          case RealtimeSubscribeStatus.channelError:
            debugPrint('Organization stream for $organizationId disconnected.');
          case RealtimeSubscribeStatus.closed:
            debugPrint('Organization stream for $organizationId closed.');
          case RealtimeSubscribeStatus.timedOut:
            debugPrint('Organization stream for $organizationId timed out.');
        }
      },
    );
  }
}
