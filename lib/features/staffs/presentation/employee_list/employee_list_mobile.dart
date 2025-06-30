import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class EmployeeListScreenMobile extends ConsumerStatefulWidget {
  const EmployeeListScreenMobile({super.key});

  @override
  ConsumerState<EmployeeListScreenMobile> createState() => _EmployeeListScreenMobileState();
}

class _EmployeeListScreenMobileState extends ConsumerState<EmployeeListScreenMobile> {
  final _debouncer = Debouncer(milliseconds: 500);
  void _showOptionsBottomModal(EmployeeModel employee) {
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
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) {
                        return AddEmployeeDialog(employee: employee);
                      },
                    );
                  },
                  label: Text(context.l10n.view, style: AppText.smallSB.copyWith(color: AppColors.black)),
                ),
                const SizedBox(height: 12),
                AppButton.icon(
                  icon: const Icon(Icons.delete_outlined, size: 16, color: AppColors.black),
                  color: AppColors.black.withOpacity(0.05),
                  onPress: () {
                    showDialog<void>(
                      context: AppRouter.rootContext,
                      builder: (context) {
                        return ConfirmationDialog(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          title: AppRouter.l10n.removeBranchAccess,
                          children: [
                            Text(
                              AppRouter.l10n.areYouSureYouWantToRemoveThisUserFromAccessingThisBranch,
                              style: AppText.mediumN.copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                          onPositive: (ref) {
                            ref
                                .read(employeeNotifierProvider.notifier)
                                .removeEmployeeBranchAccess(employee.employeeId)
                                .then((value) => AppRouter.pop());
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
    final employeeListState = ref.watch(employeeNotifierProvider);
    final employeeListNotifier = ref.watch(employeeNotifierProvider.notifier);
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
                  showDialog<void>(
                    context: AppRouter.rootContext,
                    builder: (context) {
                      return const AddEmployeeDialog();
                    },
                  );
                },
                label: Text(context.l10n.addUser),
                isLoading: employeeListState.status == EmployeeStatus.loading,
              ),
            ),
          ],
        ),
      ),
      appBar: CustomAppBar(
        title: Text(context.l10n.userList),
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
              child: PagedListView<int, EmployeeModel>.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                pagingController: employeeListState.pagingController!,
                builderDelegate: PagedChildBuilderDelegate<EmployeeModel>(
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
                            child: Row(
                              children: [
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
                                          style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                                        ),
                                        if (item.employeeRoles.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                                decoration: BoxDecoration(color: AppColors.blue.withOpacity(.06)),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  item.employeeRoles.map((e) => e.name).join(', '),
                                                  style: AppText.smallM.copyWith(color: AppColors.blue),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          item.phone != null ? '${item.phone} | ${item.email}' : item.email,
                                          style: AppText.smallSB.copyWith(color: AppColors.stormyBlue),
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
