import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'create_credit_mobile.dart';
export 'create_credit_web.dart';

class CreateCreditScreen extends ConsumerWidget {
  const CreateCreditScreen({super.key, this.creditNoteId});
  final String? creditNoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(
          creditNoteDataProvider(creditNoteId),
        )
        .when(
          data: (data) {
            return  Scaffold(
              body: ResponsiveWidget(
                smallScreen: const CreateCreditScreenMobile(),
                largeScreen: CreateCreditScreenWeb(
                  creditNote: data,
                ),
              ),
            );
          },
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: Loader.new,
        );
  }
}
