import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'create_quote_mobile.dart';
export 'create_quote_web.dart';

class CreateQuoteScreen extends ConsumerWidget {
  const CreateQuoteScreen({super.key, this.quoteId});
  final String? quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(quoteProvider(quoteId)).when(
          data: (quote) => ResponsiveWidget(
            smallScreen: const CreateQuoteScreenMobile(),
            largeScreen: CreateQuoteScreenWeb(quote: quote),
          ),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: Loader.new,
        );
  }
}
