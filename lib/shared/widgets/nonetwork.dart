import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class InternetAlert extends StatefulWidget {
  const InternetAlert({
    super.key,
    this.child,
    this.onRetry,
  });
  final Widget? child;
  final void Function()? onRetry;

  @override
  InternetAlertState createState() => InternetAlertState();
}

class InternetAlertState extends State<InternetAlert> {
  bool isChecking = false;

  Future<bool> checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Widget buildNoInternetScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom egg illustration
              Text(
                context.l10n.ooops,
                style: AppText.heading3,
              ),
              const SizedBox(height: 8),
              Assets.icons.noInternet.svg(
                  height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
              ),
              const SizedBox(height: 28),
              Text(
                context.l10n.youReOffline,
                style: AppText.heading5,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.somethingWentWrongTryRefreshingThePageOrCheckingYourInternetConnectionWeLlSeeYouInAMoment,
                style: AppText.largeM.copyWith(
                  height: 1.5,
                  letterSpacing: 0.1,
                  wordSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: isChecking
                      ? null
                      : () async {
                          setState(() => isChecking = true);
                          final hasInternet = await checkInternet();
                          setState(() => isChecking = false);

                          if (hasInternet) {
                            widget.onRetry?.call();
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.ledgerTotalPurchases,
                    side:
                        const BorderSide(color: AppColors.ledgerTotalPurchases),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(
                         context.l10n.retry,
                          style:
                              AppText.mediumSB.copyWith(color: AppColors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, AsyncSnapshot<List<ConnectivityResult>> snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.contains(ConnectivityResult.none)) {
          return buildNoInternetScreen(context);
        }
        return widget.child ?? const SizedBox.shrink();
      },
    );
  }
}
