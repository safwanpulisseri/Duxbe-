import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'enter_otp_mobile.dart';
export 'enter_otp_web.dart';

class EnterOtpScreen extends ConsumerWidget {
  const EnterOtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: EnterOtpScreenMobile(),
        largeScreen: EnterOtpScreenWeb(),
      ),
    );
  }
}
