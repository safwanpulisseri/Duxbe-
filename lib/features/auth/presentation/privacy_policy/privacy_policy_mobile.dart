import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyScreenMobile extends ConsumerStatefulWidget {
  const PrivacyPolicyScreenMobile({super.key});

  @override
  ConsumerState<PrivacyPolicyScreenMobile> createState() => _PrivacyPolicyScreenMobileState();
}

class _PrivacyPolicyScreenMobileState extends ConsumerState<PrivacyPolicyScreenMobile> {
  Future<String> get data => rootBundle.loadString('assets/markdowns/privacy_policy.md');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:  Text(context.l10n.privacyPolicy)),
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
