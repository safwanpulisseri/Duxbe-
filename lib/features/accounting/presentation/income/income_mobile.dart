import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class IncomeScreenMobile extends ConsumerStatefulWidget {
  const IncomeScreenMobile({super.key});

  @override
  ConsumerState<IncomeScreenMobile> createState() => _IncomeScreenMobileState();
}

class _IncomeScreenMobileState extends ConsumerState<IncomeScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);

  void _showOptionsBottomModal(Income income) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    AppRouter.pushNamed(AppRouter.incomeDetails, pathParameters: {'id': income.incomeId!});
                  },
                  label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: const Icon(Icons.delete_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) => Consumer(
                        builder: (context, ref, child) => ConfirmationDialog(
                          isLoading: ref.watch(incomeNotifierProvider).status == IncomeStatus.loading,
                          title: AppRouter.l10n.deleteIncome,
                          positiveText: AppRouter.l10n.delete,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppRouter.l10n.areYouSureYouWantToDeleteThisIncome,
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref.read(incomeNotifierProvider.notifier).deleteIncome(income).then(AppRouter.pop);
                          },
                        ),
                      ),
                    );
                  },
                  label: Text(context.l10n.delete, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomeListState = ref.watch(incomeNotifierProvider);
    final incomeListNotifier = ref.watch(incomeNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.income),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  onPress: () {
                    context.pushNamed(AppRouter.createIncome);
                  },
                  label: Text(context.l10n.addIncome),
                ),
                const SizedBox(height: 12),
                AppButton(
                  style: ButtonStyles.secondary,
                  onPress: () {
                    context.pushNamed(AppRouter.incomeCategory);
                  },
                  label: Text(context.l10n.incomeCategory),
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppTextForm<String>(
                  controller: searchController,
                  name: 'search',
                  hintText: context.l10n.search,
                  onChanged: (value) {
                    _debouncer.run(
                      () {
                        incomeListNotifier.setFilter(query: value ?? '');
                      },
                    );
                  },
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(9.25),
                    ),
                    child: const Icon(CupertinoIcons.search, color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PagedListView<int, Income>.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  pagingController: incomeListState.pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<Income>(
                    noItemsFoundIndicatorBuilder: (context) {
                      if (searchController.text.isNotEmpty) {
                        return const NoSearchItemWidget();
                      }
                      return const NoDataViewWidget();
                    },
                    itemBuilder: (context, item, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: InkWell(
                          borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                          splashColor: Colors.transparent,
                          onLongPress: () {
                            _showOptionsBottomModal(item);
                          },
                          child: Ink(
                            decoration: AppStyles.boxDecoration,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    item.date.toInvoiceFormat,
                                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xffF9F9F9),
                                        radius: 20,
                                        child: Assets.icons.incomeIcon.svg(),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.incomeFor,
                                              style: AppText.mediumM.copyWith(color: AppColors.black),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.paymentType.name.displayCase,
                                              style: AppText.smallN.copyWith(color: AppColors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        currency + item.amount.toString(),
                                        style: AppText.largeSB.copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      AuthStatus.loading => const Center(child: CircularProgressIndicator()),
      AuthStatus.error => const Center(child: Text('Error')),
    };
  }
}
