import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ItemCategoryListScreenMobile extends ConsumerStatefulWidget {
  const ItemCategoryListScreenMobile({super.key});

  @override
  ConsumerState<ItemCategoryListScreenMobile> createState() => _ItemCategoryListScreenMobileState();
}

class _ItemCategoryListScreenMobileState extends ConsumerState<ItemCategoryListScreenMobile> {
  void _showOptionsBottomModal(ItemCategory itemCategory) {
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
                    context.pop();
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) => AddCategoryDialog(
                        category: itemCategory,
                      ),
                    );
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
                      builder: (context) => ConfirmationDialog(
                        title: AppRouter.l10n.deleteCategory,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppRouter.l10n.deleteThisCategory,
                            style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                          ),
                        ],
                        onPositive: (ref) {
                          ref
                              .read(itemCategoryNotifierProvider.notifier)
                              .deleteItemCategory(itemCategory)
                              .then(AppRouter.pop);
                        },
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
    final itemCategoryNotifier = ref.watch(itemCategoryNotifierProvider.notifier);
    final itemCategoryState = ref.watch(itemCategoryNotifierProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.category),
          ),
          body: SafeArea(
            child: Column(
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
                      itemCategoryNotifier.setFilter(query: value);
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
                  child: PagedListView<int, ItemCategory>.separated(
                    pagingController: itemCategoryState.pagingController!,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    builderDelegate: PagedChildBuilderDelegate<ItemCategory>(
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
                  padding: const EdgeInsets.all(24),
                  child: AppButton(
                    onPress: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const AddCategoryDialog(),
                      );
                    },
                    label: Text(context.l10n.addCategory),
                  ),
                ),
              ],
            ),
          ),
        ),
      AuthStatus.loading => const Center(child: CircularProgressIndicator()),
      AuthStatus.error => const Center(child: Text('Error')),
    };
  }
}
