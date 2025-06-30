import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BranchScreenMobile extends ConsumerStatefulWidget {
  const BranchScreenMobile({super.key});

  @override
  ConsumerState<BranchScreenMobile> createState() => _BranchScreenMobileState();
}

class _BranchScreenMobileState extends ConsumerState<BranchScreenMobile> {
  void _showOptionsBottomModal(Business business) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.black),
                color: AppColors.black.withOpacity(0.05),
                onPress: () {
                  AppRouter.pushNamed(AppRouter.branchDetails, pathParameters: {'id': business.businessId});
                },
                label: Text(context.l10n.edit, style: AppText.smallSB.copyWith(color: AppColors.black)),
              ),
              const SizedBox(height: 12),
              AppButton.icon(
                icon: const Icon(Icons.delete_outlined, size: 16, color: AppColors.black),
                color: AppColors.black.withOpacity(0.05),
                onPress: () {
                  showDialog<void>(
                    context: AppRouter.rootContext,
                    builder: (context) => ConfirmationDialog(
                      title: AppRouter.l10n.deleteBusiness,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppRouter.l10n.areYouSureYouWantToDeleteBusiness(business.name),
                          style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                      onPositive: (ref) {
                        ref.read(branchNotifierProvider.notifier).deleteBusiness(business).then(AppRouter.pop);
                      },
                    ),
                  );
                },
                label: Text(context.l10n.delete, style: AppText.smallSB.copyWith(color: AppColors.black)),
              ),
            ],
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
    final branchNotifier = ref.watch(branchNotifierProvider.notifier);
    final branchState = ref.watch(branchNotifierProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.branch),
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
                    branchNotifier.setFilter(query: value ?? '');
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
                child: PagedListView<int, Business>(
                  pagingController: branchState.pagingController!,
                  builderDelegate: PagedChildBuilderDelegate<Business>(
                    noItemsFoundIndicatorBuilder: (context) {
                      if (searchController.text.isNotEmpty) {
                        return const NoSearchItemWidget();
                      }
                      return const NoDataViewWidget();
                    },
                    itemBuilder: (context, item, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: InkWell(
                          borderRadius: AppStyles.boxDecoration.borderRadius!.resolve(TextDirection.ltr),
                          splashColor: Colors.transparent,
                          onLongPress: () {
                            _showOptionsBottomModal(item);
                          },
                          onTap: () {
                            AppRouter.pushNamed(AppRouter.branchDetails, pathParameters: {'id': item.businessId});
                          },
                          child: Ink(
                            decoration: AppStyles.boxDecoration,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(item.name, style: AppText.mediumM.copyWith(color: AppColors.black)),
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
                    AppRouter.pushNamed(AppRouter.createBranch);
                  },
                  label: Text(context.l10n.addBranch),
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
