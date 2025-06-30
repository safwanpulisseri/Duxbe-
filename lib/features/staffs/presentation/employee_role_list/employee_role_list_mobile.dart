import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class EmployeeRoleListScreenMobile extends ConsumerStatefulWidget {
  const EmployeeRoleListScreenMobile({super.key});

  @override
  ConsumerState<EmployeeRoleListScreenMobile> createState() => _EmployeeRoleListScreenMobileState();
}

class _EmployeeRoleListScreenMobileState extends ConsumerState<EmployeeRoleListScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);
  void _showOptionsBottomModal(StaffRole staffRole) {
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
                if (staffRole.editable) ...[
                  AppButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.black),
                    color: AppColors.black.withOpacity(0.05),
                    onPress: () {
                      AppRouter.pushNamed(
                        AppRouter.userRoleDetails,
                        pathParameters: {'id': staffRole.employeeRoleId!},
                      );
                    },
                    label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                  ),
                  const SizedBox(height: 12),
                ],
                AppButton.icon(
                  icon: const Icon(Icons.delete_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) {
                        return ConfirmationDialog(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          title: AppRouter.l10n.deleteUserRole,
                          children: [
                            Text(
                              context.l10n.areYouSureYouWantToDeleteThisUserRole,
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref.read(employeeRoleNotifierProvider.notifier).deleteStaffRole(staffRole.employeeRoleId!);
                          },
                        );
                      },
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
    final employeeListState = ref.watch(employeeRoleNotifierProvider);
    final employeeListNotifier = ref.watch(employeeRoleNotifierProvider.notifier);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                onPress: () {
                  AppRouter.pushNamed(AppRouter.createUserRole);
                },
                label: Text(context.l10n.addUserRole),
                isLoading: employeeListState.status == EmployeeRoleStatus.loading,
              ),
            ),
          ],
        ),
      ),
      appBar: CustomAppBar(
        title: Text(context.l10n.userRole),
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
                  _debouncer.run(() {
                    employeeListNotifier.setFilter(query: value ?? '');
                  });
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
              child: PagedListView<int, StaffRole>.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                pagingController: employeeListState.pagingController!,
                builderDelegate: PagedChildBuilderDelegate<StaffRole>(
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
                          if (item.editable) _showOptionsBottomModal(item);
                        },
                        child: Ink(
                          decoration: AppStyles.boxDecoration,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
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
                                          style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                                        ),
                                      ],
                                    ),
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
    );
  }
}
