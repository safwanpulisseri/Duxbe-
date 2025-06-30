import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'createbaranch_mobile.dart';
export 'createbaranch_web.dart';

class CreatebaranchScreen extends ConsumerWidget {
  const CreatebaranchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: ResponsiveWidget(
        smallScreen: CreatebaranchScreenMobile(),
        largeScreen: CreatebaranchScreenWeb(),
      ),
    );
  }
}
