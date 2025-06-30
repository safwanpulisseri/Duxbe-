import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ManageStockScreenMobile extends ConsumerStatefulWidget {
  const ManageStockScreenMobile({super.key});

  @override
  ConsumerState<ManageStockScreenMobile> createState() => _ManageStockScreenMobileState();
}

class _ManageStockScreenMobileState extends ConsumerState<ManageStockScreenMobile> {
  final debouncer = Debouncer(milliseconds: 500);
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manageStockNotifier = ref.watch(manageStockNotifierProvider.notifier);
    final manageStockState = ref.watch(manageStockNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.manageStock),
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
                    manageStockNotifier.setFilter(query: value ?? '');
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
                child: PagedListView<int, Item>.separated(
                  pagingController: manageStockState.pagingController!,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  builderDelegate: PagedChildBuilderDelegate<Item>(
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
                          child: Ink(
                            decoration: AppStyles.boxDecoration,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              item.itemCode,
                                              style: AppText.mediumSB.copyWith(color: AppColors.primaryColor),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(item.name, style: AppText.mediumM.copyWith(color: AppColors.black)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${item.stockQuantity} ${item.unit?.name ?? ''}',
                                        style: AppText.largeB.copyWith(color: AppColors.black),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AppButton.icon(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 16,
                                      color: AppColors.primaryColor,
                                    ),
                                    color: const Color(0xffF5F3FF),
                                    iconLeading: false,
                                    onPress: () {
                                      AppRouter.pushNamed(
                                        AppRouter.singleStockAdjust,
                                        pathParameters: {'id': item.itemId!},
                                      );
                                    },
                                    label: Text(
                                      context.l10n.adjustStock,
                                      style: AppText.mediumM.copyWith(color: AppColors.primaryColor),
                                    ),
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
