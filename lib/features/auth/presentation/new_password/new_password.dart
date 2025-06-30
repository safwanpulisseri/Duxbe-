import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'new_password_mobile.dart';
export 'new_password_web.dart';

class NewPasswordScreen extends ConsumerWidget {
  const NewPasswordScreen({super.key, this.refreshToken, this.orgId, this.type, this.accessToken});
  final String? refreshToken;
  final String? orgId;
  final String? type;
  final String? accessToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveWidget(
        smallScreen: NewPasswordScreenMobile(
          refreshToken: refreshToken,
          orgId: orgId,
          type: type,
          accessToken: accessToken,
        ),
        largeScreen: NewPasswordScreenWeb(
          refreshToken: refreshToken,
          orgId: orgId,
          type: type,
          accessToken: accessToken,
        ),
      ),
    );
  }
}
