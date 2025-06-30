
import 'package:duxbe/features/reservations/reservations.dart';
import 'package:duxbe/features/sale/domain/models/customer/customer_model.dart';
import 'package:duxbe/features/sale/domain/repositories/implementations/customer/customer_repository.dart';
import 'package:duxbe/features/sale/presentation/add_customer_dialog.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';

class AddReservationCustomer extends ConsumerStatefulWidget {
  const AddReservationCustomer({required this.partySize, required this.date, required this.selectedSpot, super.key});
  final int partySize;
  final DateTime date;
  final Slot selectedSpot;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddReservationCustomerState();
}

class _AddReservationCustomerState extends ConsumerState<AddReservationCustomer> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _customerController = TextEditingController();
  final Set<String> tags = {};
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.guest, style: AppText.b28.copyWith(color: AppColors.black)),
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              const Divider(color: AppColors.outlineGrey),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTypeAheadForm<Customer>(
                      name: 'customer',
                      validator: FormBuilderValidators.required(),
                      decoration: InputDecoration(
                        hintText: context.l10n.walkInCustomer,
                        suffixIcon: _formKey.currentState?.fields['customer']!.value != null
                            ? null
                            : InkWell(
                                onTap: () async {
                                  final customer = await showDialog<Customer>(
                                    context: context,
                                    builder: (context) {
                                      return AddCustomerDialog(
                                        customerName: _customerController.text,
                                      );
                                    },
                                  );
                                  if (customer != null) {
                                    _formKey.currentState!.fields['customer']!.didChange(customer);
                                  }
                                },
                                child: Container(
                                  height: 32,
                                  width: 42,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                      ),
                      selectionToTextTransformer: (e) => '${e.name}${', ${e.phone ?? ''}'}',
                      controller: _customerController,
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          subtitle: suggestion.phone == null ? null : Text(suggestion.phone ?? ''),
                        );
                      },
                      suggestionsCallback: (String search) async {
                        return ref
                            .read(customerRepoProvider)
                            .getCustomers(
                              pageSize: 12,
                              pageNumber: 1,
                              query: search,
                            )
                            .then((value) => value.data);
                      },
                      noItemsFoundBuilder: (context) {
                        return ListTile(
                          onTap: () async {
                            final customer = await showDialog<Customer>(
                              context: context,
                              builder: (context) {
                                return AddCustomerDialog(
                                  customerName: _customerController.text,
                                );
                              },
                            );
                            if (customer != null) {
                              _formKey.currentState!.fields['customer']!.didChange(customer);
                            }
                          },
                          leading: const Icon(Icons.add_box_outlined),
                          title: Text(context.l10n.addCustomer),
                        );
                      },
                      // onChanged: (p0) {
                      //   setState(() {});
                      // },
                    ),
                    const SizedBox(height: 12),
                    Text('Tag', style: AppText.b28.copyWith(color: AppColors.black)),
                    const SizedBox(height: 12),
                    Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      children: [
                        for (final tag in ['VIP', 'Birthday', 'Anniversary', 'Private Dining', 'First time'])
                          FilterChip(
                            side: BorderSide(
                              color: tags.contains(tag) ? AppColors.primaryColor : AppColors.outlineGrey,
                            ),
                            backgroundColor: AppColors.white,
                            selectedColor: const Color(0xffFFF5EE),
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            label: Text(tag),
                            selected: tags.contains(tag),
                            onSelected: (selected) {
                              if (selected) {
                                tags.add(tag);
                              } else {
                                tags.remove(tag);
                              }
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(AppRouter.l10n.notes, style: AppText.b28.copyWith(color: AppColors.black)),
                    const SizedBox(height: 12),
                    AppTextForm<String>(
                      name: 'notes',
                      hintText: AppRouter.l10n.writeReserveationNotesHere,
                      minLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.outlineGrey),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppButton(
                        style: ButtonStyles.cancel,
                        label: Text(context.l10n.cancel),
                        onPress: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: Text(AppRouter.l10n.continu),
                        onPress: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            final customer = _formKey.currentState!.fields['customer']!.value as Customer;
                            final notes = _formKey.currentState!.fields['notes']!.value as String? ?? '';
                            context.pushNamed(
                              AppRouter.chooseReservationTable,
                              extra: ReservationPageData(
                                customer: customer,
                                notes: notes,
                                tags: tags.toList(),
                                partySize: widget.partySize,
                                date: widget.date,
                                selectedSpot: widget.selectedSpot,
                              ),
                              queryParameters: {
                                'view_only': 'false',
                              },
                            ).then((value) {
                              if (context.mounted && value == true) {
                                context.pop(true);
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
