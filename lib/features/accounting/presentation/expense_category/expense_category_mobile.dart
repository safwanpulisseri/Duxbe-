import 'package:duxbe/features/accounting/accounting.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ExpenseCategoryScreenMobile extends ConsumerStatefulWidget {
  const ExpenseCategoryScreenMobile({super.key});

  @override
  ConsumerState<ExpenseCategoryScreenMobile> createState() => _ExpenseCategoryScreenMobileState();
}

class _ExpenseCategoryScreenMobileState extends ConsumerState<ExpenseCategoryScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);

  void _showOptionsBottomModal(TransactionCategory itemCategory) {
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
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) => AddTransactionCategoryDialog(
                        type: TransactionCategoryType.expense,
                        category: itemCategory,
                      ),
                    );
                  },
                  label: Text(context.l10n.edit, style: AppText.smallSB.copyWith(color: AppColors.black)),
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
                          isLoading: ref.watch(expenseCategoryNotifierProvider).status == ExpenseCategoryStatus.loading,
                          title: AppRouter.l10n.deleteCategory,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          positiveText: AppRouter.l10n.delete,
                          children: [
                            Text(
                              AppRouter.l10n.deleteThisCategory,
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref
                                .read(expenseCategoryNotifierProvider.notifier)
                                .deleteExpenseCategory(itemCategory)
                                .then(AppRouter.pop);
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
    final expenseCategoryNotifier = ref.watch(expenseCategoryNotifierProvider.notifier);
    final expenseCategoryState = ref.watch(expenseCategoryNotifierProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.expenseCategory),
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
                        expenseCategoryNotifier.setFilter(query: value);
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
                child: PagedListView<int, TransactionCategory>.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  pagingController: expenseCategoryState.pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<TransactionCategory>(
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
                                  Row(
                                    children: [
                                      if (item.iconInfo != null)
                                        Icon(
                                          IconData(
                                            item.iconInfo!.code!,
                                            fontFamily: item.iconInfo?.family,
                                            fontPackage: item.iconInfo?.package,
                                          ),
                                          size: 24,
                                          color: AppColors.primaryColor,
                                        )
                                      else
                                        const Icon(Icons.category_outlined, size: 16, color: AppColors.greyish2),
                                      const SizedBox(width: 12),
                                      Text(item.name, style: AppText.mediumM.copyWith(color: AppColors.black)),
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
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: AppButton(
                  onPress: () {
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) => const AddTransactionCategoryDialog(
                        type: TransactionCategoryType.expense,
                      ),
                    );
                  },
                  label: Text(context.l10n.addCategory),
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
