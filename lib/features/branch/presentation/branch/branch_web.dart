import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/features/organization/organization.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class BranchScreenWeb extends ConsumerStatefulWidget {
  const BranchScreenWeb({super.key});

  @override
  ConsumerState<BranchScreenWeb> createState() => _BranchScreenWebState();
}

class _BranchScreenWebState extends ConsumerState<BranchScreenWeb> {
  final debouncer = Debouncer(milliseconds: 500);
  @override
  Widget build(BuildContext context) {
    final branchNotifier = ref.watch(branchNotifierProvider.notifier);
    final branchState = ref.watch(branchNotifierProvider);
    final organizationState = ref.watch(organizationNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.success => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: AppStyles.boxDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextForm<String>(
                      name: 'business_search',
                      hintText: context.l10n.search,
                      onChanged: (val) {
                        debouncer.run(() {
                          branchNotifier.setFilter(query: val ?? '');
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppButton.icon(
                    padding: const EdgeInsets.all(16),
                    onPress: () {
                      final branchesCountThreshold =
                          organizationState?.activeAddonsList?.fold(0, (previousValue, element) {
                                final branchUserAddonCount = element.addonId == 2 ? 1 : 0;
                                return previousValue + branchUserAddonCount;
                              }) ??
                              0;
                      if (branchesCountThreshold <= branchState.count) {
                        context.goNamed(AppRouter.createBranch);
                      } else {
                        Alert.showSnackBar(context.l10n.youHaveReachedTheMaximumNumberOfBranches);
                      }
                    },
                    label: Text(context.l10n.addBranch),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PlutoGrid(
                        mode: PlutoGridMode.readOnly,
                        columns: branchNotifier.businessColumns,
                        // ignore: prefer_const_literals_to_create_immutables
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          branchNotifier.setStateManager(
                            stateManager: event.stateManager,
                          );
                        },
                        configuration: AppStylesX.dataTableConfig,
                        noRowsWidget: const NoDataViewWidget(),
                      ),
                    ),
                    PaginationFooter(
                      onPageChanged: (value) {
                        branchNotifier.setFilter(pageNumber: value);
                      },
                      totalPages: (branchState.count / branchState.pageSize).ceil(),
                      currentPage: branchState.pageNumber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox(),
    };
  }
}
