import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'create_invoice_mobile.dart';
export 'create_invoice_web.dart';

class CreateInvoiceScreen extends ConsumerWidget {
  const CreateInvoiceScreen({super.key, this.invoiceId});
  final String? invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return const Scaffold(
    //   body: ResponsiveWidget(
    //     smallScreen: CreateInvoiceScreenMobile(),
    //     largeScreen: CreateInvoiceScreenWeb(),
    //   ),
    // );
    return ref.watch(invoiceDataProvider(invoiceId)).when(
          data: (invoice) => ResponsiveWidget(
            smallScreen: const CreateInvoiceScreenMobile(),
            largeScreen: CreateInvoiceScreenWeb(invoice: invoice),
          ),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: Loader.new,
        );
  }
}
