import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SupplierListScreenMobile extends ConsumerStatefulWidget {
  const SupplierListScreenMobile({super.key});

  @override
  ConsumerState<SupplierListScreenMobile> createState() => _SupplierListScreenMobileState();
}

class _SupplierListScreenMobileState extends ConsumerState<SupplierListScreenMobile> {
  final debouncer = Debouncer(milliseconds: 500);

  void _showOptionsBottomModal(Supplier supplier) {
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
                  icon: Assets.icons.edit.svg(
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                  ),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    AppRouter.pushNamed(
                      AppRouter.supplierDetails,
                      pathParameters: {'id': supplier.supplierId!},
                    );
                  },
                  label: Text(
                    context.l10n.edit,
                    style: AppText.smallSB.copyWith(color: AppColors.black),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: Assets.icons.delete.svg(
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(AppColors.red, BlendMode.srcIn),
                  ),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    context.pop();
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) => Consumer(
                        builder: (context, ref, child) => ConfirmationDialog(
                          title: AppRouter.l10n.deleteSupplier,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          isLoading: ref.watch(supplierNotifierProvider).status == SupplierStatus.loading,
                          children: [
                            Text(
                              AppRouter.l10n.areYouSureWantToDeleteSupplierName(supplier.name),
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref.read(supplierNotifierProvider.notifier).deleteSupplier(supplier).then((value) {
                              if (context.mounted) {
                                context.pop();
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                  label: Text(
                    context.l10n.delete,
                    style: AppText.smallSB.copyWith(color: AppColors.red),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: Assets.icons.settlementsMobile.svg(
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                  ),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {},
                  label: Text(
                    context.l10n.settlements,
                    style: AppText.smallSB.copyWith(color: AppColors.black),
                  ),
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
    final supplierListNotifier = ref.watch(supplierNotifierProvider.notifier);
    final currency = ref.watch(currencyProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.supplier),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: AppButton(
              onPress: () {
                AppRouter.pushNamed(AppRouter.createSupplier);
              },
              label: Text(context.l10n.addSupplier),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppTextForm<String>(
                  controller: searchController,
                  name: 'search',
                  hintText: context.l10n.enterNameInvoiceNumber,
                  onChanged: (value) {
                    supplierListNotifier.setFilter(query: value);
                  },
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(9.25),
                    ),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PagedListView<int, Supplier>.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  pagingController: ref.watch(supplierNotifierProvider).pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<Supplier>(
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: AppStyles.boxDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      backgroundImage: item.image != null ? NetworkImage(item.image!) : null,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: NameAbbrWidget(
                                          name: item.name.substring(0, 1),
                                          textSize: 20,
                                          size: 45,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: AppText.mediumM.copyWith(color: AppColors.black),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.phone,
                                              style: AppText.smallSB.copyWith(color: AppColors.greyish2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (item.supplierBalance < 0)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if (item.supplierBalance < 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.red.withOpacity(.1),
                                                  borderRadius: const BorderRadius.horizontal(
                                                    left: Radius.circular(2),
                                                  ),
                                                ),
                                                child: Text(
                                                  context.l10n.due,
                                                  style: AppText.xSmallSB.copyWith(color: AppColors.red),
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '$currency${item.supplierBalance}  ',
                                              style: AppText.largeB.copyWith(color: AppColors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
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
