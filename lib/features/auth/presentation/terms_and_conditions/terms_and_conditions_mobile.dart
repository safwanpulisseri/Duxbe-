import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TermsAndConditionsScreenMobile extends ConsumerStatefulWidget {
  const TermsAndConditionsScreenMobile({super.key});

  @override
  ConsumerState<TermsAndConditionsScreenMobile> createState() => _TermsAndConditionsScreenMobileState();
}

class _TermsAndConditionsScreenMobileState extends ConsumerState<TermsAndConditionsScreenMobile> {
  Future<String> get data => rootBundle.loadString('assets/markdowns/terms_and_conditions.md');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:  Text(context.l10n.termsAndConditions)),
      body: FutureBuilder<String>(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Markdown(
              data: snapshot.data!,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
