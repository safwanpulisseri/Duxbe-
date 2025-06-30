import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/shared/shared.dart';

abstract class ILedgerRepository {
  Future<PaginatedResponse<Party>> getParties({
    required int pageSize,
    required int pageNumber,
    String query = '',
    TransactionParty? party,
  });
  Future<Ledger> getLedger();
  Future<PartyDetails> getPartyDetails({required String partyId, required TransactionParty partyType});
}
