import 'package:duxbe/features/organization/models/organization.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'organization_repository.g.dart';

abstract class IOrganizationRepository {
  Future<OrganizationDetails?> getOrganizationFromId(String? organizationId);
}

class OrganizationRepository implements IOrganizationRepository {
  OrganizationRepository(this.ref) : _supabase = ref.watch(supabaseProvider);
  final SupabaseClient _supabase;
  final OrgRepoRef ref;

  @override
  Future<OrganizationDetails?> getOrganizationFromId(String? organizationId) async {
    if (organizationId == null) return null;

    try {
      final response = await _supabase.from(DbConstants.orgDetailsView).select().eq('org_id', organizationId).single();

      return OrganizationDetails.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
IOrganizationRepository orgRepo(OrgRepoRef ref) => OrganizationRepository(ref);
