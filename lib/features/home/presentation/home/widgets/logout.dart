part of '../home.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveWidget.isSmallScreen(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffFFF3EC),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.logout,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.logout,
                  style: AppText.heading5.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(context.l10n.logOutFromDuxbe),
                const SizedBox(height: 12),
              ],
            ),
            if (!isSmallScreen)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPress: () {
                        context.pop(false);
                      },
                      label: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      style: ButtonStyles.secondary,
                      onPress: () {
                        context.pop(true);
                      },
                      label: Text(context.l10n.logout),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    onPress: () {
                      context.pop(false);
                    },
                    label: Text(context.l10n.cancel),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    style: ButtonStyles.secondary,
                    onPress: () {
                      context.pop(true);
                    },
                    label: Text(context.l10n.logout),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
