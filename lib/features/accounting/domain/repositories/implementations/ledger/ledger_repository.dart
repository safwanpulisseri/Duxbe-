import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ledger_repository.g.dart';

@Riverpod(keepAlive: true)
ILedgerRepository ledgerRepo(LedgerRepoRef ref) => LedgerRepository(ref);

class LedgerRepository implements ILedgerRepository {
  LedgerRepository(this.ref) : _supabaseClient = ref.watch(supabaseProvider);
  final LedgerRepoRef ref;
  final SupabaseClient _supabaseClient;

  @override
  Future<PaginatedResponse<Party>> getParties({
    required int pageSize,
    required int pageNumber,
    String query = '',
    TransactionParty? party,
  }) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final offset = (pageNumber - 1) * pageSize;

      var queryBuilder = _supabaseClient
          .from(DbConstants.ledgerParties)
          .select()
          .eq('business_id', businessId)
          .ilike('name', '%$query%');

      if (party != null && party != TransactionParty.all) {
        queryBuilder = queryBuilder.eq('type', party.name);
      }

      final response = await queryBuilder.range(offset, pageSize + offset - 1).count(CountOption.exact);
      return PaginatedResponse(
        data: response.data.map(Party.fromJson).toList(),
        count: response.count,
      );
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<Ledger> getLedger() async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient
          .rpc<Map<String, dynamic>>(RPCConstants.getBusinessSummaries, params: {'p_business_id': businessId});
      return Ledger.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }

  @override
  Future<PartyDetails> getPartyDetails({required String partyId, required TransactionParty partyType}) async {
    try {
      final businessId = ref.read(businessNotifierProvider)!.businessId;
      final response = await _supabaseClient.rpc<Map<String, dynamic>>(
        RPCConstants.getPartyTransactionSummary,
        params: {
          'party_type': partyType.name,
          'party_id': partyId,
          'p_business_id': businessId,
        },
      );
      return PartyDetails.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(
        e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    }
  }
}
