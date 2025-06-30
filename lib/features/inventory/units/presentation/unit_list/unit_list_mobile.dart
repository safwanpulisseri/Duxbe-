import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UnitListScreenMobile extends ConsumerStatefulWidget {
  const UnitListScreenMobile({super.key});

  @override
  ConsumerState<UnitListScreenMobile> createState() => _UnitListScreenMobileState();
}

class _UnitListScreenMobileState extends ConsumerState<UnitListScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);

  void _showOptionsBottomModal(Unit unit) {
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
                      builder: (context) => AddUnitDialog(
                        unit: unit,
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
                      builder: (context) => Consumer(
                        builder: (context, ref, child) => ConfirmationDialog(
                          isLoading: ref.watch(unitNotifierProvider).status == UnitStatus.loading,
                          title: AppRouter.l10n.deleteUnit,
                          positiveText: AppRouter.l10n.delete,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppRouter.l10n.deleteUnitSub,
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref.read(unitNotifierProvider.notifier).deleteUnit(unit).then(AppRouter.pop);
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
    final unitNotifier = ref.watch(unitNotifierProvider.notifier);
    final unitState = ref.watch(unitNotifierProvider);
    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.units),
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
                showDialog<void>(
                  context: context,
                  builder: (context) => const AddUnitDialog(),
                );
              },
              label: Text(context.l10n.addUnit),
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
                        unitNotifier.setFilter(query: value ?? '');
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
                child: PagedListView<int, Unit>.separated(
                  pagingController: unitState.pagingController!,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  builderDelegate: PagedChildBuilderDelegate<Unit>(
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
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: item.name,
                                          style: AppText.mediumM.copyWith(color: AppColors.black),
                                        ),
                                        if (item.shortName != null)
                                          TextSpan(
                                            text: ' (${item.shortName})',
                                            style: AppText.smallSB.copyWith(color: AppColors.greyish2),
                                          ),
                                      ],
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
