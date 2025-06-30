import 'package:duxbe/features/home/home.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'profile_mobile.dart';
export 'profile_web.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: ProfileScreenMobile(),
        largeScreen: ProfileScreenWeb(),
      ),
    );
  }
}
