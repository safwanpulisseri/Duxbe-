part of 'sales_payment_mobile.dart';

class SalesSuccessScreen extends ConsumerWidget {
  const SalesSuccessScreen({super.key});
  Row _dataRow({
    required String label,
    required Widget child,
    TextStyle? style,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: style ?? AppText.xLargeM.copyWith(color: AppColors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 28),
          child,
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleId = GoRouterState.of(context).pathParameters['id'];
    final currency = ref.watch(currencyProvider);
    return ref.watch(saleProvider(saleId)).when(
      data: (data) {
        return Scaffold(
          backgroundColor: AppColors.primaryColor,
          body: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: const ShapeDecoration(
                  shape: CustomSvgBorder(),
                  color: AppColors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.images.paymentSuccessfull.image(height: 100, width: 100),
                          const SizedBox(height: 18),
                          Text(
                            context.l10n.paymentSuccessfull,
                            style: AppText.heading5.copyWith(color: AppColors.green),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data!.payments.map((e) => e.paymentMethod.name.displayCase).join(', '),
                            style: AppText.mediumN.copyWith(color: AppColors.stormyBlue),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.saleInvoice,
                            style: AppText.largeM.copyWith(color: AppColors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.customer?.name ?? context.l10n.walkInCustomer,
                            style: AppText.heading4.copyWith(
                              color: AppColors.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CustomPaint(
                        painter: DashedLinePainter(),
                        size: const Size(double.infinity, 1),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _dataRow(
                              label: context.l10n.totalAmount,
                              child: Text(
                                currency + data.totalAmount.toStringAsFixed(2),
                                style: AppText.xLargeM,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _dataRow(
                              label: context.l10n.paidAmount,
                              child: Text(
                                currency + data.paidAmount.toStringAsFixed(2),
                                overflow: TextOverflow.ellipsis,
                                style: AppText.xLargeM,
                              ),
                            ),
                            _dataRow(
                                label: context.l10n.dueAmount,
                              child: Text(
                                currency + data.dueAmount.toStringAsFixed(2),
                                overflow: TextOverflow.ellipsis,
                                style: AppText.xLargeM,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              onPress: () {
                                context.goNamed(AppRouter.pos);
                              },
                              label: Text(context.l10n.nextSale),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              style: ButtonStyles.secondary,
                              onPress: () async {
                                await PdfService.printSaleInvoice(data);
                              },
                              label: Text(context.l10n.printReceipt),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Text(error.toString()),
          ),
        );
      },
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
