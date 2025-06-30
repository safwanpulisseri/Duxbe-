import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlineStoreDialog extends ConsumerStatefulWidget {
  const OnlineStoreDialog({super.key});

  @override
  ConsumerState<OnlineStoreDialog> createState() => _OnlineStoreDialogState();
}

class _OnlineStoreDialogState extends ConsumerState<OnlineStoreDialog> {
  final _customerAddFormKey = GlobalKey<FormBuilderState>();
  // Future<void> _createCustomer() async {
  //   try {
  //     if (_customerAddFormKey.currentState?.saveAndValidate() ?? false) {
  //       await ref
  //           .read(customerNotifierProvider.notifier)
  //           .upsertCustomer(
  //             Customer.fromJson(_customerAddFormKey.currentState!.value),
  //           )
  //           .then((value) {
  //         if (mounted) {
  //           context.pop(value);
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     Alert.showSnackBar(e.toString(), type: SnackBarType.error);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final storeUrl = 'connect.duxbe.com/${ref.watch(businessNotifierProvider)?.businessId}';
    return FormAddDialog(
      title: context.l10n.goToOnlineStore,
      formKey: _customerAddFormKey,
      positiveLabel: context.l10n.copyLink,
      negativeLabel: context.l10n.openLink,
      buttonColor: AppColors.darkBlue,
      negativeButtonColor: AppColors.darkBlue,
      onPositive: () {
        Clipboard.setData(ClipboardData(text: storeUrl));
        Alert.showSnackBar(context.l10n.linkCopiedToClipboard, type: SnackBarType.success);
      },
      onNegative: () async {
        final url = Uri.parse('https://$storeUrl');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hereIsYourStoreUrl,
                style: AppText.mediumB.copyWith(
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  storeUrl,
                  style: AppText.largeSB,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
