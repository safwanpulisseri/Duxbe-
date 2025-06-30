part of 'sales_payment_mobile.dart';

class MobileHoldBillDialog extends ConsumerWidget {
  const MobileHoldBillDialog({
    this.onDelete,
    this.onRecall,
    super.key,
  });
  final void Function(Map<String, dynamic> cartData)? onDelete;
  final void Function(Map<String, dynamic> cartData)? onRecall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesNotifier = ref.watch(salesNotifierProvider.notifier);
    final salesState = ref.watch(salesNotifierProvider);
    final currency = ref.watch(currencyProvider);
    final heldCarts = salesState.heldCarts;
    final l10n = AppLocalizations.of(context);

    // Localization fallbacks
    final customerLabel = l10n.customer;
    final recallBillTitle = l10n.recallBill;
    final noHeldBillsMsg = l10n.noHeldBillsAvailable;
    final okText = l10n.ok;
    final walkInCustomerText = l10n.walkInCustomer;
    final heldOnText = l10n.heldOn;
    final itemsLabel = l10n.items;
    final totalAmountLabel = l10n.totalAmount;
    final recallActionText = l10n.recall;
    final deleteActionText = l10n.delete;
    final cancelText = l10n.cancel;

    if (heldCarts.isEmpty) {
      return AlertDialog(
        title: Text(recallBillTitle),
        content: Text(noHeldBillsMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okText),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(recallBillTitle, style: AppText.xLargeB),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: heldCarts.length,
          itemBuilder: (context, index) {
            final cart = heldCarts[index];
            final heldTime = DateTime.tryParse(cart['held_time'] as String? ?? '')?.toLocal() ?? DateTime.now();
            final formattedHeldTime = DateFormat('MMM d, yyyy HH:mm').format(heldTime);

            var customerNameDisplay = walkInCustomerText;
            final customerData = cart['customer'] as Map<String, dynamic>?;
            if (customerData != null) {
              customerNameDisplay = customerData['name'] as String? ?? walkInCustomerText;
            }

            final itemsList = cart['saleItems'] as List<dynamic>? ?? [];
            final itemCount = itemsList.length;

            var calculatedTotalForDisplay = cart['grandTotal'] as double? ?? 0.0;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: AppStyles.boxDecoration,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$heldOnText: $formattedHeldTime', style: AppText.smallN.copyWith(color: AppColors.grey)),
                    const SizedBox(height: 4),
                    Text('$customerLabel: $customerNameDisplay', style: AppText.mediumM),
                    Text('$itemsLabel: $itemCount', style: AppText.mediumN),
                    Text(
                      '$totalAmountLabel: $currency ${calculatedTotalForDisplay.toStringAsFixed(2)}',
                      style: AppText.mediumB.copyWith(color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.restore, color: AppColors.green, size: 20),
                          label: Text(recallActionText, style: AppText.mediumM.copyWith(color: AppColors.green)),
                          onPressed: () {
                            salesNotifier.recallCart(cart);
                            onRecall?.call(cart);
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                          label: Text(deleteActionText, style: AppText.mediumM.copyWith(color: AppColors.red)),
                          onPressed: () {
                            salesNotifier.deleteCart(cart);
                            onDelete?.call(cart);
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText, style: AppText.mediumB.copyWith(color: AppColors.primaryColor)),
        ),
      ],
    );
  }
}
