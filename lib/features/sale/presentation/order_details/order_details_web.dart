// ignore_for_file: prefer_const_constructors

import 'package:collection/collection.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/sale/presentation/customer_list/customer_settlement.dart';
import 'package:duxbe/features/sale/presentation/sales/service_selection_dialog.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/features/staffs/staffs.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class OrderDetailsScreenWeb extends ConsumerStatefulWidget {
  const OrderDetailsScreenWeb({required this.sale, super.key});
  final SaleView sale;
  @override
  ConsumerState<OrderDetailsScreenWeb> createState() =>
      _OrderDetailsScreenWebState();
}

class _OrderDetailsScreenWebState extends ConsumerState<OrderDetailsScreenWeb> {
  static const Color tableBorder = Color(0xFFE2E3E7);
  final formKey = GlobalKey<FormBuilderState>();

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? trailingWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppText.heading4.copyWith(color: AppColors.primaryColor),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  final tableDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: tableBorder, width: 2),
  );

  Widget _buildRow(
    String key,
    String value, {
    Color? valueColor,
    BuildContext? context,
  }) {
    final isOrderSource = key == (context?.l10n.orderSource ?? 'Order Source');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              key,
              style: AppText.xLargeM.copyWith(color: AppColors.greyText),
            ),
          ),
          const Text(':  '),
          Expanded(
            child: isOrderSource
                ? Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF091E3A),
                              Color(0xFF2F80ED),
                              // Color(0xFF2D9EE0),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              // Color(0xFF091E3A),
                              Color(0xFF2F80ED),
                              Color(0xFF2D9EE0),
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          value,
                          style: AppText.xLargeN.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: AppText.xLargeSB.copyWith(
                      color: valueColor ?? AppColors.black,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  final border = const OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
    borderSide: BorderSide(color: AppColors.stormyBlue),
  );

  @override
  Widget build(BuildContext context) {
    print(widget.sale.status!.name);
    final currency = ref.read(businessNotifierProvider)?.currency?.code ?? r'$';
    return FormBuilder(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppStyles.boxDecoration,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: tableDecoration,
                child: _buildSection(
                  title: '${context.l10n.orderId}: ${widget.sale.saleInvoice}',
                  trailingWidget: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: FormBuilderField<EmployeeModel>(
                          name: 'employee',
                          initialValue: widget.sale.employee,
                          onChanged: (value) {
                            ref
                                .read(orderDetailsNotifierProvider.notifier)
                                .updateSaleEmployee(
                                  widget.sale.saleId,
                                  value!.employeeId,
                                );
                            ref
                              ..invalidate(
                                saleAuditsProvider(widget.sale.saleId),
                              )
                              ..invalidate(saleProvider(widget.sale.saleId))
                              ..invalidate(saleListNotifierProvider);
                          },
                          builder: (field) {
                            return DropdownSearch<EmployeeModel>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                itemBuilder:
                                    (context, item, isSelected, selected) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: item.image != null
                                          ? NetworkImage(item.image!)
                                          : null,
                                      backgroundColor: AppColors.primaryColor,
                                      child: Text(item.name.substring(0, 1)),
                                    ),
                                    title: Text(item.name),
                                    trailing: field.value?.employeeId ==
                                            item.employeeId
                                        ? const Icon(
                                            Icons.check_circle_outline_outlined,
                                            size: 20,
                                            color: AppColors.green,
                                          )
                                        : null,
                                  );
                                },
                              ),
                              selectedItem: field.value,
                              compareFn: (item, selectedItem) =>
                                  item.employeeId == selectedItem.employeeId,
                              dropdownBuilder: (context, selectedItem) => Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    CupertinoIcons.person_circle,
                                    size: 20,
                                    color: AppColors.brandViolet,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    context.l10n.assigned,
                                    style: AppText.largeM.copyWith(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CircleAvatar(
                                    backgroundImage: selectedItem?.image != null
                                        ? NetworkImage(selectedItem!.image!)
                                        : null,
                                    backgroundColor: AppColors.primaryColor,
                                    child: Text(
                                      selectedItem?.name.substring(0, 1) ?? '',
                                    ),
                                  ),
                                ],
                              ),
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              validator: FormBuilderValidators.required(),
                              items: (text, d) => ref
                                  .read(staffRepoProvider)
                                  .getEmployees(
                                    pageSize: 100,
                                    pageNumber: 1,
                                    query: text,
                                  )
                                  .then((value) => value.data),
                              onChanged: (value) {
                                field.didChange(value);
                              },
                              itemAsString: (item) => item.name,
                            );
                          },
                        ),
                      ),
                      if (widget.sale.status!.name != 'Completed' &&
                          widget.sale.status!.name != 'Cancelled')
                        ref.watch(saleStatusesProvider).maybeWhen(
                              data: (e) => MenuAnchor(
                                menuChildren: e
                                    .map(
                                      (e) => MenuItemButton(
                                        onPressed: () {
                                          ref
                                              .read(
                                                orderDetailsNotifierProvider
                                                    .notifier,
                                              )
                                              .updateSaleStatus(
                                                widget.sale.saleId,
                                                e.statusId,
                                              );
                                          ref
                                            ..invalidate(
                                              saleAuditsProvider(
                                                widget.sale.saleId,
                                              ),
                                            )
                                            ..invalidate(
                                              saleProvider(
                                                widget.sale.saleId,
                                              ),
                                            )
                                            ..invalidate(
                                              saleListNotifierProvider,
                                            );
                                        },
                                        child: Text(
                                          e.name,
                                          style: AppText.mediumN,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                builder: (context, controller, child) {
                                  return InkWell(
                                    onTap: controller.isOpen
                                        ? controller.close
                                        : controller.open,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.sale.status!.name,
                                              style: AppText.mediumM.copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_right_rounded,
                                              size: 22,
                                              color: AppColors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              orElse: () => const SizedBox.shrink(),
                            ),
                      const SizedBox(width: 10),
                      CustomOutlinedIconButton(
                        label: context.l10n.print,
                        icon: Assets.icons.print.svg(),
                        onPressed: () {
                          PdfService.printSaleInvoice(widget.sale);
                        },
                        borderColor: tableBorder,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                      ),
                      if (widget.sale.status!.name == 'Completed') ...[
                        const SizedBox(width: 10),
                        CustomOutlinedIconButton(
                          label: context.l10n.saleReturn,
                          icon: Assets.icons.saleReturn.svg(),
                          onPressed: () {
                            context.pushNamed(
                              AppRouter.createSaleReturn,
                              queryParameters: {'id': widget.sale.saleId},
                            );
                          },
                          borderColor: const Color(0xFFDE3BE2),
                          backgroundColor: const Color(0xFFFFEEFC),
                          textColor: const Color(0xFFDE3BE2),
                        ),
                      ],
                    ],
                  ),
                  children: [
                    Row(
                      children: [
                        StatusContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          label:
                              widget.sale.transaction.status.name.displayCase,
                          labelColor: switch (widget.sale.transaction.status) {
                            TransactionStatus.CANCELLED => AppColors.red,
                            TransactionStatus.PENDING => AppColors.orange,
                            TransactionStatus.PAID => AppColors.green,
                            TransactionStatus.PARTIALLY_PAID =>
                              AppColors.warning,
                            TransactionStatus.VOID => AppColors.grey,
                          },
                          backgroundColor: switch (
                              widget.sale.transaction.status) {
                            TransactionStatus.CANCELLED =>
                              AppColors.red.withOpacity(0.12),
                            TransactionStatus.PENDING =>
                              AppColors.orange.withOpacity(0.12),
                            TransactionStatus.PAID =>
                              AppColors.green.withOpacity(0.12),
                            TransactionStatus.PARTIALLY_PAID =>
                              AppColors.warning.withOpacity(0.12),
                            TransactionStatus.VOID =>
                              AppColors.grey.withOpacity(0.12),
                          },
                        ),
                        const SizedBox(width: 10),
                        StatusContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          label: widget.sale.status!.name,
                          labelColor: switch (widget.sale.status!.name) {
                            'Booked' => AppColors.blue,
                            'In Process' => AppColors.orange,
                            'Cancelled' => AppColors.grey,
                            'Completed' => AppColors.green,
                            _ => AppColors.grey,
                          },
                          backgroundColor: switch (widget.sale.status!.name) {
                            'Booked' => AppColors.blue.withOpacity(0.12),
                            'In Process' => AppColors.orange.withOpacity(0.12),
                            'Cancelled' => AppColors.grey.withOpacity(0.12),
                            'Completed' => AppColors.green.withOpacity(0.12),
                            _ => AppColors.grey.withOpacity(0.12),
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        StatusContainer(
                          label: '${context.l10n.placedOn}: ',
                          value: widget.sale.saleDate.toLocal().toFullFormat,
                          valueColor: const Color(0xFFF5F6F8),
                          backgroundColor: const Color(0xFFF5F6F8),
                          labelTextStyle: AppText.largeSB.copyWith(
                            color: AppColors.greyText,
                          ),
                          valueTextStyle: AppText.largeSB.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        StatusContainer(
                          label: '${context.l10n.updatedOn}: ',
                          value: widget.sale.updatedAt.toLocal().toFullFormat,
                          valueColor: const Color(0xFFF5F6F8),
                          backgroundColor: const Color(0xFFF5F6F8),
                          labelTextStyle: AppText.largeSB.copyWith(
                            color: AppColors.greyText,
                          ),
                          valueTextStyle: AppText.largeSB.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (widget.sale.table != null)
                          StatusContainer(
                            label: '${context.l10n.table}: ',
                            value: widget.sale.table!.name,
                            valueColor: const Color(0xFFF5F6F8),
                            backgroundColor: const Color(0xFFF5F6F8),
                            labelTextStyle: AppText.largeSB.copyWith(
                              color: AppColors.greyText,
                            ),
                            valueTextStyle: AppText.largeSB.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: tableDecoration,
                        child: _buildSection(
                          title: context.l10n.customerDetails,
                          children: [
                            _buildRow(
                              context.l10n.name,
                              widget.sale.customer?.name ?? '',
                            ),
                            _buildRow(
                              context.l10n.phoneNumber,
                              widget.sale.customer?.phone ?? '',
                            ),
                            _buildRow(
                              context.l10n.email,
                              widget.sale.customer?.email ?? '',
                            ),
                            if (widget.sale.billingAddress != null)
                              _buildRow(
                                'Billing Address',
                                widget.sale.billingAddress?.formattedAddress ??
                                    'N/A',
                              ),
                            if (widget.sale.shippingAddress != null)
                              _buildRow(
                                'Shipping Address',
                                widget.sale.shippingAddress?.formattedAddress ??
                                    'N/A',
                              ),
                            _buildRow(
                              context.l10n.orderSource,
                              widget.sale.orderSource ?? '',
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (widget.sale.employee != null) ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: tableDecoration,
                          child: _buildSection(
                            title: context.l10n.salespersonDetails,
                            children: [
                              _buildRow(
                                context.l10n.name,
                                widget.sale.employee!.name,
                              ),
                              _buildRow(
                                context.l10n.phoneNumber,
                                widget.sale.employee!.phone ?? '',
                              ),
                              _buildRow(
                                context.l10n.email,
                                widget.sale.employee!.email,
                              ),
                              _buildRow(
                                context.l10n.staffId,
                                widget.sale.employee!.code ?? '',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: tableDecoration,
                        child: _buildSection(
                          title: context.l10n.paymentDetails,
                          children: [
                            _buildRow(
                              context.l10n.totalAmount,
                              widget.sale.totalAmount.toString(),
                            ),
                            _buildRow(
                              context.l10n.dueAmount,
                              widget.sale.dueAmount.toString(),
                            ),
                            _buildRow(
                              context.l10n.paymentMode,
                              widget.sale.payments
                                  .map(
                                    (e) => e.paymentMethod.name.displayCase,
                                  )
                                  .toSet()
                                  .join(', '),
                            ),
                            if (widget.sale.customer != null &&
                                widget.sale.dueAmount > 0) ...[
                              const SizedBox(height: 8),
                              CustomOutlinedIconButton(
                                label: context.l10n.settle,
                                icon: Assets.icons.updatePayment.svg(
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.blue,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog<void>(
                                    context: AppRouter.rootContext,
                                    builder: (context) {
                                      return CustomerSettlementDialog(
                                        customerId:
                                            widget.sale.customer!.customerId!,
                                        invoice: widget.sale,
                                      );
                                    },
                                  ).then((value) {
                                    ref
                                      ..invalidate(
                                        saleAuditsProvider(
                                          widget.sale.saleId,
                                        ),
                                      )
                                      ..invalidate(
                                        saleProvider(widget.sale.saleId),
                                      )
                                      ..invalidate(saleListNotifierProvider);
                                  });
                                },
                                borderColor: AppColors.blue,
                                backgroundColor: AppColors.blue.withOpacity(.2),
                                textColor: AppColors.blue,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FormBuilderField<List<Item>>(
                name: 'items',
                onReset: () {
                  formKey.currentState?.fields['items']?.didChange(<Item>[]);
                },
                validator: FormBuilderValidators.notEqual(
                  [],
                  errorText: context.l10n.pleaseSelectAtLeastOneItem,
                ),
                // ignore: prefer_const_literals_to_create_immutables
                initialValue: [...widget.sale.saleItems.map((e) => e.item)],
                builder: (field) {
                  return Container(
                    decoration: tableDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '${context.l10n.itemsOrdered} (${field.value?.length ?? 0})',
                            style: AppText.largeSB
                                .copyWith(color: AppColors.black),
                          ),
                        ),
                        const Divider(
                          color: tableBorder,
                          thickness: 2,
                          height: 0,
                        ),
                        // Table with headers , SL No, Name, Price, Qty, Amount
                        Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(.5),
                            1: FlexColumnWidth(),
                            2: FlexColumnWidth(3),
                            3: FlexColumnWidth(),
                            4: FlexColumnWidth(),
                            5: FlexColumnWidth(),
                            6: FixedColumnWidth(72),
                          },
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: AppColors.offWhite,
                              ),
                              children: [
                                context.l10n.slNo,
                                context.l10n.image,
                                context.l10n.name,
                                context.l10n.unitPrice,
                                context.l10n.qty,
                                context.l10n.subTotal,
                                context.l10n.action,
                              ]
                                  .map(
                                    (header) => Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        header,
                                        style: AppText.mediumSB,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            if (widget.sale.status!.name == 'Completed' ||
                                widget.sale.status!.name == 'Cancelled')
                              ...widget.sale.saleItems.map(
                                (e) => TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: tableBorder,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        '${widget.sale.saleItems.indexOf(e) + 1}',
                                        style: const TextStyle(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: e.item.images.isNotEmpty
                                          ? Image.network(
                                              e.item.images
                                                      .firstWhereOrNull(
                                                        (e) => e.isThumbnail,
                                                      )
                                                      ?.url ??
                                                  e.item.images.firstOrNull
                                                      ?.url ??
                                                  '',
                                              height: 50,
                                              width: 50,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            e.item.name,
                                            style: const TextStyle(
                                              color: AppColors.stormyBlue,
                                            ),
                                          ),
                                          if (e.saleItemNote?.isNotEmpty ??
                                              false) ...[
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '${context.l10n.note}: ${e.saleItemNote}',
                                              style: const TextStyle(
                                                color: AppColors.stormyBlue,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        e.unitPrice.toString(),
                                        style: const TextStyle(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        e.quantity.toString(),
                                        style: const TextStyle(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        e.totalPrice.toString(),
                                        style: const TextStyle(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              )
                            else
                              ...List<TableRow>.generate(field.value!.length,
                                  (index) {
                                final saleItem = field.value![index];
                                final note = widget.sale.saleItems
                                        .firstWhereOrNull(
                                          (e) => e.itemId == saleItem.itemId,
                                        )
                                        ?.saleItemNote ??
                                    '';
                                return TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Color(0xffB1B8D0)),
                                    ),
                                  ),
                                  key: ObjectKey(saleItem),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: saleItem.images.isNotEmpty
                                          ? Image.network(
                                              saleItem.images
                                                      .firstWhereOrNull(
                                                        (e) => e.isThumbnail,
                                                      )
                                                      ?.url ??
                                                  saleItem.images.firstOrNull
                                                      ?.url ??
                                                  '',
                                              height: 50,
                                              width: 50,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            saleItem.name,
                                            style: AppText.largeB.copyWith(
                                              color: AppColors.stormyBlue,
                                            ),
                                          ),
                                          ...saleItem.selectedSubServices.map(
                                            (e) => Row(
                                              children: [
                                                Text(
                                                  e.name,
                                                  style:
                                                      AppText.mediumN.copyWith(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  currency +
                                                      e.additionalPrice
                                                          .toStringAsFixed(2),
                                                  style:
                                                      AppText.mediumN.copyWith(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (note.isNotEmpty) ...[
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: note,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.stormyBlue,
                                                    ),
                                                  ),
                                                ],
                                                text: '${context.l10n.note}: ',
                                                style: const TextStyle(
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: FormBuilderField<double>(
                                        name: 'unit-price-${saleItem.itemId}',
                                        initialValue: widget.sale.saleItems
                                                .firstWhereOrNull(
                                                  (e) =>
                                                      e.itemId ==
                                                      saleItem.itemId,
                                                )
                                                ?.unitPrice ??
                                            saleItem.salePrice,
                                        validator:
                                            FormBuilderValidators.required(
                                          errorText:
                                              context.l10n.pleaseEnterUnitPrice,
                                        ),
                                        builder: (unitPrice) {
                                          return DoubleSpinnerField(
                                            showButtons: false,
                                            value: unitPrice.value ?? 0,
                                            onChanged: (value) {
                                              if (value < 1) {
                                                unitPrice.didChange(1);
                                                return;
                                              }
                                              unitPrice.didChange(value);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: FormBuilderField<double>(
                                        name: 'quantity-${saleItem.itemId}',
                                        initialValue: widget.sale.saleItems
                                                .firstWhereOrNull(
                                                  (e) =>
                                                      e.itemId ==
                                                      saleItem.itemId,
                                                )
                                                ?.quantity ??
                                            1,
                                        validator:
                                            FormBuilderValidators.required(
                                          errorText:
                                              context.l10n.pleaseEnterQuantity,
                                        ),
                                        builder: (quantity) {
                                          return DoubleSpinnerField(
                                            value: quantity.value ?? 0,
                                            onChanged: (value) {
                                              if (value < 1) {
                                                quantity.didChange(1);
                                                return;
                                              }
                                              final allowSalesWhenOutOfStock = ref
                                                      .read(
                                                        businessNotifierProvider,
                                                      )
                                                      ?.allowSalesWhenOutOfStock ??
                                                  false;
                                              if (value >
                                                      saleItem.stockQuantity -
                                                          1 &&
                                                  !allowSalesWhenOutOfStock &&
                                                  saleItem.itemType ==
                                                      ItemType.goods) {
                                                Alert.showSnackBar(
                                                  '${saleItem.name} is ${context.l10n.outOfStock}',
                                                  type: SnackBarType.warning,
                                                );
                                                return;
                                              }
                                              quantity.didChange(value);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Builder(
                                        builder: (context) {
                                          final quantity = formKey
                                                  .currentState
                                                  ?.fields[
                                                      'quantity-${saleItem.itemId}']
                                                  ?.value as double? ??
                                              0;
                                          final unitPrice = formKey
                                                  .currentState
                                                  ?.fields[
                                                      'unit-price-${saleItem.itemId}']
                                                  ?.value as double? ??
                                              0;
                                          return Text(
                                            currency +
                                                ((quantity * unitPrice) +
                                                        saleItem
                                                            .selectedSubServices
                                                            .fold<double>(
                                                          0,
                                                          (sum, e) =>
                                                              sum +
                                                              e.additionalPrice,
                                                        ))
                                                    .toStringAsFixed(2),
                                            style: AppText.largeSB.copyWith(
                                              color: AppColors.stormyBlue,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        field.didChange([
                                          ...field.value!..remove(saleItem),
                                        ]);
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          ],
                        ),
                        const SizedBox(height: 7),
                        if (widget.sale.notes != null)
                          Container(
                            padding: EdgeInsets.all(10),
                            color: AppColors.offWhite,
                            child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: widget.sale.notes ?? '',
                                          style: const TextStyle(
                                            color: AppColors.stormyBlue,
                                          ),
                                        ),
                                      ],
                                      text: '${context.l10n.note}: ',
                                      style: const TextStyle(
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        // Add a row to add new item
                        if (widget.sale.status!.name != 'Completed' &&
                            widget.sale.status!.name != 'Cancelled') ...[
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  showDialog<Item>(
                                    context: AppRouter.rootContext,
                                    builder: (context) {
                                      return const AddNewItemDialog();
                                    },
                                  ).then((value) {
                                    if (value != null) {
                                      final existingItemIndex =
                                          field.value!.indexWhere(
                                        (item) => item.itemId == value.itemId,
                                      );

                                      if (existingItemIndex != -1) {
                                        // Item exists, increment quantity
                                        final quantityField =
                                            formKey.currentState?.fields[
                                                'quantity-${value.itemId}'];
                                        if (quantityField != null) {
                                          final currentQty =
                                              quantityField.value as double? ??
                                                  0;
                                          quantityField
                                              .didChange(currentQty + 1);
                                        }
                                      } else {
                                        // New item, add to list
                                        field.didChange(
                                          [...field.value!..add(value)],
                                        );
                                      }
                                      setState(() {});
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(context.l10n.addNewItem),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (widget.sale.status!.name == 'Completed' ||
                            widget.sale.status!.name == 'Cancelled') ...[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '${context.l10n.subTotal}      ${widget.sale.subTotal}',
                              style: AppText.largeSB
                                  .copyWith(color: AppColors.black),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '${context.l10n.discount}      ${widget.sale.discountAmount}',
                              style: AppText.mediumSB
                                  .copyWith(color: AppColors.stormyBlue),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '${context.l10n.taxAmount}      ${widget.sale.taxAmount}',
                              style: AppText.mediumSB
                                  .copyWith(color: AppColors.stormyBlue),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '${context.l10n.shipping}      ${widget.sale.shippingCharge}',
                              style: AppText.mediumSB
                                  .copyWith(color: AppColors.stormyBlue),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '${context.l10n.total}      ${widget.sale.totalAmount}',
                              style: AppText.largeSB
                                  .copyWith(color: AppColors.black),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ] else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Builder(
                                  builder: (context) {
                                    final quantityTotal = field.value
                                        ?.fold<double>(0, (sum, item) {
                                      final unitPrice = formKey
                                              .currentState
                                              ?.fields[
                                                  'unit-price-${item.itemId}']
                                              ?.value as double? ??
                                          0;
                                      final quantity = formKey
                                              .currentState
                                              ?.fields[
                                                  'quantity-${item.itemId}']
                                              ?.value as double? ??
                                          0;
                                      final subServices =
                                          item.selectedSubServices.fold<double>(
                                        0,
                                        (sum, e) => sum + e.additionalPrice,
                                      );
                                      return sum +
                                          (quantity * unitPrice) +
                                          subServices;
                                    });
                                    return Text(
                                      '${context.l10n.subTotal}      ${currency + (quantityTotal ?? 0).toStringAsFixed(2)}',
                                      style: AppText.largeSB
                                          .copyWith(color: AppColors.black),
                                      textAlign: TextAlign.end,
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      context.l10n.discount,
                                      style: AppText.mediumSB.copyWith(
                                        color: AppColors.stormyBlue,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    const SizedBox(width: 10),
                                    IntrinsicWidth(
                                      child: FormBuilderField<double>(
                                        name: 'discount-percent',
                                        initialValue:
                                            widget.sale.discountAmount != 0
                                                ? (widget.sale.discountAmount /
                                                        widget.sale.subTotal) *
                                                    100
                                                : 0,
                                        builder: (discountPercent) {
                                          return Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: AppColors.stormyBlue,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      8,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  border: Border.all(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '%',
                                                  style:
                                                      AppText.xLargeM.copyWith(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: DoubleSpinnerField(
                                                  style:
                                                      AppText.xLargeM.copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: border,
                                                    errorBorder: border,
                                                    focusedBorder: border,
                                                    enabledBorder: border,
                                                    disabledBorder: border,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                  onChanged: (value) {
                                                    discountPercent
                                                        .didChange(value);
                                                    final quantityTotal = field
                                                            .value
                                                            ?.fold<double>(0,
                                                                (sum, item) {
                                                          final unitPrice = formKey
                                                                  .currentState
                                                                  ?.fields[
                                                                      'unit-price-${item.itemId}']
                                                                  ?.value as double? ??
                                                              0;
                                                          final quantity = formKey
                                                                  .currentState
                                                                  ?.fields[
                                                                      'quantity-${item.itemId}']
                                                                  ?.value as double? ??
                                                              0;
                                                          final subServices = item
                                                              .selectedSubServices
                                                              .fold<double>(
                                                            0,
                                                            (sum, e) =>
                                                                sum +
                                                                e.additionalPrice,
                                                          );
                                                          return sum +
                                                              (quantity *
                                                                  unitPrice) +
                                                              subServices;
                                                        }) ??
                                                        0;
                                                    formKey
                                                        .currentState
                                                        ?.fields[
                                                            'discount-amount']
                                                        ?.didChange(
                                                      (quantityTotal *
                                                              (discountPercent
                                                                      .value ??
                                                                  0) /
                                                              100)
                                                          .toPrecision(2),
                                                    );
                                                  },
                                                  showButtons: false,
                                                  value:
                                                      discountPercent.value ??
                                                          0,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IntrinsicWidth(
                                      child: FormBuilderField<double>(
                                        name: 'discount-amount',
                                        initialValue:
                                            widget.sale.discountAmount,
                                        builder: (discountAmount) {
                                          return Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: AppColors.stormyBlue,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      8,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  border: Border.all(
                                                    color: AppColors.stormyBlue,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  currency,
                                                  style:
                                                      AppText.xLargeM.copyWith(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: DoubleSpinnerField(
                                                  style:
                                                      AppText.xLargeM.copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: border,
                                                    errorBorder: border,
                                                    focusedBorder: border,
                                                    enabledBorder: border,
                                                    disabledBorder: border,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                  onChanged: (value) {
                                                    discountAmount
                                                        .didChange(value);
                                                    final quantityTotal = field
                                                            .value
                                                            ?.fold<double>(0,
                                                                (sum, item) {
                                                          final unitPrice = formKey
                                                                  .currentState
                                                                  ?.fields[
                                                                      'unit-price-${item.itemId}']
                                                                  ?.value as double? ??
                                                              0;
                                                          final quantity = formKey
                                                                  .currentState
                                                                  ?.fields[
                                                                      'quantity-${item.itemId}']
                                                                  ?.value as double? ??
                                                              0;
                                                          final subServices = item
                                                              .selectedSubServices
                                                              .fold<double>(
                                                            0,
                                                            (sum, e) =>
                                                                sum +
                                                                e.additionalPrice,
                                                          );
                                                          return sum +
                                                              (quantity *
                                                                  unitPrice) +
                                                              subServices;
                                                        }) ??
                                                        0;
                                                    formKey
                                                        .currentState
                                                        ?.fields[
                                                            'discount-percent']
                                                        ?.didChange(
                                                      (quantityTotal != 0
                                                              ? (discountAmount
                                                                          .value! /
                                                                      quantityTotal) *
                                                                  100
                                                              : 0.0)
                                                          .toPrecision(2),
                                                    );
                                                  },
                                                  showButtons: false,
                                                  value:
                                                      discountAmount.value ?? 0,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Builder(
                                  builder: (context) {
                                    final taxTotal = field.value
                                            ?.fold<double>(0, (sum, item) {
                                          final unitPrice = formKey
                                                  .currentState
                                                  ?.fields[
                                                      'unit-price-${item.itemId}']
                                                  ?.value as double? ??
                                              0;
                                          final quantity = formKey
                                                  .currentState
                                                  ?.fields[
                                                      'quantity-${item.itemId}']
                                                  ?.value as double? ??
                                              0;
                                          final taxPercent =
                                              item.tax?.rate ?? 0;
                                          final subServices = item
                                              .selectedSubServices
                                              .fold<double>(
                                            0,
                                            (sum, e) => sum + e.additionalPrice,
                                          );
                                          if (taxPercent == 0) return sum;
                                          return sum +
                                              ((quantity * unitPrice) +
                                                      subServices) *
                                                  (taxPercent / 100);
                                        }) ??
                                        0;

                                    return Text(
                                      '${context.l10n.taxAmount} $currency $taxTotal',
                                      style: AppText.mediumSB.copyWith(
                                        color: AppColors.stormyBlue,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: IntrinsicWidth(
                                  child: FormBuilderField<double>(
                                    name: 'shipping',
                                    initialValue: widget.sale.shippingCharge,
                                    builder: (shipping) {
                                      return Row(
                                        children: [
                                          Text(
                                            context.l10n.shipping,
                                            style: AppText.mediumSB.copyWith(
                                              color: AppColors.stormyBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: AppColors.stormyBlue,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              border: Border.all(
                                                color: AppColors.stormyBlue,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              currency,
                                              style: AppText.xLargeM.copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: DoubleSpinnerField(
                                              style: AppText.xLargeM.copyWith(
                                                color: AppColors.primaryColor,
                                              ),
                                              decoration: InputDecoration(
                                                border: border,
                                                errorBorder: border,
                                                focusedBorder: border,
                                                enabledBorder: border,
                                                disabledBorder: border,
                                                contentPadding: EdgeInsets.zero,
                                                isDense: true,
                                              ),
                                              onChanged: shipping.didChange,
                                              showButtons: false,
                                              value: shipping.value ?? 0,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Builder(
                                  builder: (context) {
                                    final quantityTotal = field.value
                                            ?.fold<double>(0, (sum, item) {
                                          final unitPrice = formKey
                                                  .currentState
                                                  ?.fields[
                                                      'unit-price-${item.itemId}']
                                                  ?.value as double? ??
                                              0;
                                          final quantity = formKey
                                                  .currentState
                                                  ?.fields[
                                                      'quantity-${item.itemId}']
                                                  ?.value as double? ??
                                              0;
                                          final subServices = item
                                              .selectedSubServices
                                              .fold<double>(
                                            0,
                                            (sum, e) => sum + e.additionalPrice,
                                          );
                                          return sum +
                                              (quantity * unitPrice) +
                                              subServices;
                                        }) ??
                                        0;
                                    final shipping = formKey
                                            .currentState
                                            ?.fields['shipping']
                                            ?.value as double? ??
                                        0;
                                    final discountAmount = formKey
                                            .currentState
                                            ?.fields['discount-amount']
                                            ?.value as double? ??
                                        0;
                                    final grandTotal = quantityTotal +
                                        shipping -
                                        discountAmount;

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          context.l10n.grandTotal,
                                          style: AppText.heading4.copyWith(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$currency ${grandTotal.toStringAsFixed(2)}',
                                          style: AppText.heading4.copyWith(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: AppButton(
                                  onPress: () {
                                    if (formKey.currentState
                                            ?.saveAndValidate() ??
                                        false) {
                                      final taxTotal = field.value
                                          ?.fold<double>(0, (sum, item) {
                                        final unitPrice = formKey
                                                .currentState
                                                ?.fields[
                                                    'unit-price-${item.itemId}']
                                                ?.value as double? ??
                                            0;
                                        final quantity = formKey
                                                .currentState
                                                ?.fields[
                                                    'quantity-${item.itemId}']
                                                ?.value as double? ??
                                            0;
                                        final taxPercent = item.tax?.rate ?? 0;
                                        if (taxPercent == 0) return sum;
                                        final subServices = item
                                            .selectedSubServices
                                            .fold<double>(
                                          0,
                                          (sum, e) => sum + e.additionalPrice,
                                        );
                                        return sum +
                                            ((quantity * unitPrice) +
                                                    subServices) *
                                                (taxPercent / 100);
                                      });
                                      final subTotal = field.value
                                              ?.fold<double>(0, (sum, item) {
                                            final unitPrice = formKey
                                                    .currentState
                                                    ?.fields[
                                                        'unit-price-${item.itemId}']
                                                    ?.value as double? ??
                                                0;
                                            final quantity = formKey
                                                    .currentState
                                                    ?.fields[
                                                        'quantity-${item.itemId}']
                                                    ?.value as double? ??
                                                0;
                                            final subServices = item
                                                .selectedSubServices
                                                .fold<double>(
                                              0,
                                              (sum, e) =>
                                                  sum + e.additionalPrice,
                                            );
                                            return sum +
                                                (quantity * unitPrice) +
                                                subServices;
                                          }) ??
                                          0;
                                      final shipping = formKey
                                              .currentState
                                              ?.fields['shipping']
                                              ?.value as double? ??
                                          0;
                                      final discountAmount = formKey
                                              .currentState
                                              ?.fields['discount-amount']
                                              ?.value as double? ??
                                          0;
                                      final grandTotal =
                                          subTotal + shipping - discountAmount;
                                      ref
                                          .read(
                                        orderDetailsNotifierProvider.notifier,
                                      )
                                          .updateSale(widget.sale, {
                                        ...?formKey.currentState?.value,
                                        'tax_total': taxTotal,
                                        'subtotal': subTotal,
                                        'grand_total': grandTotal,
                                      }).then(
                                        (value) {
                                          ref
                                            ..invalidate(
                                              saleAuditsProvider(
                                                widget.sale.saleId,
                                              ),
                                            )
                                            ..invalidate(
                                              saleProvider(
                                                widget.sale.saleId,
                                              ),
                                            )
                                            ..invalidate(
                                              saleListNotifierProvider,
                                            );
                                        },
                                      );
                                    }
                                  },
                                  label: Text(context.l10n.submit),
                                  width: 120,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              ref.watch(saleAuditsProvider(widget.sale.saleId)).when(
                    data: (data) => data.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${context.l10n.auditHistory} (${data.length})',
                                style: AppText.largeSB
                                    .copyWith(color: AppColors.stormyBlue),
                              ),
                              ...data.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    '${ widget.sale.employee!.name} - ${e.changeDetails ?? '-'} On ${e.actionTimestamp.toLocal().toTime12WithDayWithMonthFormat}',
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    error: (error, stackTrace) => Text(error.toString()),
                    loading: () => Text(context.l10n.loading),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusContainer extends StatelessWidget {
  const StatusContainer({
    required this.label,
    super.key,
    this.value,
    this.backgroundColor,
    this.labelColor,
    this.valueColor,
    this.padding,
    this.borderRadius,
    this.valueTextStyle,
    this.labelTextStyle,
  });

  final String label;
  final String? value;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? valueColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? valueTextStyle;
  final TextStyle? labelTextStyle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 7),
        color: backgroundColor ??
            const Color.fromARGB(255, 44, 197, 111).withOpacity(0.12),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: labelTextStyle ??
                  AppText.largeSB.copyWith(
                    color: labelColor ?? AppColors.greyText,
                  ),
            ),
            if (value != null)
              TextSpan(
                text: value,
                style: valueTextStyle ??
                    AppText.largeSB.copyWith(
                      color: valueColor ?? AppColors.green,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class DetailsContainer extends StatelessWidget {
  const DetailsContainer({
    required this.tableDecoration,
    required this.child,
    super.key,
    this.margin,
    this.padding,
  });

  final BoxDecoration tableDecoration;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: tableDecoration,
      child: child,
    );
  }
}

class AddNewItemDialog extends ConsumerStatefulWidget {
  const AddNewItemDialog({super.key});

  @override
  ConsumerState<AddNewItemDialog> createState() => _AddNewItemDialogState();
}

class _AddNewItemDialogState extends ConsumerState<AddNewItemDialog> {
  final formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return FormAddDialog(
      title: context.l10n.addItemToOrder,
      formKey: formKey,
      onPositive: () {
        final item = formKey.currentState?.fields['item']?.value as Item?;
        if (item == null) return;
        final allowSalesWhenOutOfStock =
            ref.read(businessNotifierProvider)?.allowSalesWhenOutOfStock ??
                false;
        if (item.stockQuantity < 1 &&
            !allowSalesWhenOutOfStock &&
            item.itemType == ItemType.goods) {
          Alert.showSnackBar(
            '${item.name} is ${context.l10n.outOfStock}',
            type: SnackBarType.warning,
          );
          return;
        }
        context.pop(item);
      },
      children: [
        AppTypeAheadForm<Item>(
          name: 'item',
          validator: FormBuilderValidators.required(),
          onSuggestionSelected: (suggestion) async {
            List<SubService>? selectedServices;
            if (suggestion.itemType == ItemType.services) {
              if (suggestion.subServices.isNotEmpty) {
                selectedServices = await showDialog<List<SubService>>(
                  context: context,
                  useRootNavigator: false,
                  builder: (BuildContext dialogContext) =>
                      ServiceSelectionDialog(item: suggestion),
                );
              }
            }
            formKey.currentState?.fields['item']?.didChange(
              suggestion.copyWith(
                selectedSubServices: selectedServices ?? [],
              ),
            );

            setState(() {});
          },
          suggestionsCallback: (search) => ref
              .read(itemRepoProvider)
              .getItems(
                pageSize: 20,
                pageNumber: 1,
                query: search,
                salesEnabled: true,
              )
              .then(
                (value) => value.data,
              ),
          itemBuilder: (context, suggestion) => ListTile(
            title: Text(suggestion.name),
          ),
          selectionToTextTransformer: (suggestion) => suggestion.name,
        ),
        const SizedBox(height: 14),
        if (formKey.currentState?.fields['item']?.value != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.itemDetails,
                style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Builder(
                  builder: (context) {
                    final item =
                        formKey.currentState?.fields['item']?.value as Item?;
                    return Text(
                      '${item?.name} \n${item?.selectedSubServices.map((e) => '${e.name} - ${e.additionalPrice}').join('\n')}',
                      style: AppText.mediumN
                          .copyWith(color: AppColors.primaryColor, height: 1.5),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
