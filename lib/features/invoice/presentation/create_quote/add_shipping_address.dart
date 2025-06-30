import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/forms.dart';
import 'package:hancod_theme/hancod_theme.dart';

enum ShippingAddressType {
  shipping,
  billing,
}

class AddShippingAddress extends ConsumerStatefulWidget {
  const AddShippingAddress({
    required this.type,
    required this.customerId,
    super.key,
  });
  final ShippingAddressType type;
  final String customerId;

  @override
  ConsumerState<AddShippingAddress> createState() => _AddShippingAddressState();
}

class _AddShippingAddressState extends ConsumerState<AddShippingAddress> {
  final addressFormKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final branch = ref.watch(branchProvider);
    final currentCountry = ref.watch(countryCodeProvider);
    return FormAddDialog(
      onPositive: () async {
        if (addressFormKey.currentState!.validate() == true) {
          final address = addressFormKey.currentState?.fields['address_line_1']?.value as String?;
          final address2 = addressFormKey.currentState?.fields['address_line_2']?.value as String?;
          final city = addressFormKey.currentState?.fields['city']?.value as String?;
          final state = addressFormKey.currentState?.fields['state']?.value as String?;
          final pinCode = addressFormKey.currentState?.fields['pin_code']?.value as String?;
          final country = addressFormKey.currentState?.fields['country']?.value as String?;
          final customerAddress = CustomerAddress(
            address: '${address!}, ${address2!}',
            city: city ?? '',
            state: state ?? '',
            zipcode: pinCode ?? '',
            country: country ?? '',
            createdAt: DateTime.now(),
            customerAddressesId: '',
          );

          await ref
              .read(createInvoiceNotifierProvider.notifier)
              .insertNewAddress(
                type: widget.type == ShippingAddressType.shipping ? 'shipping' : 'billing',
                address: customerAddress,
                customerId: widget.customerId,
              )
              .then((value) {
            addressFormKey.currentState?.reset();
            if (mounted) {
              context.pop(value);
            }
          });
        }
      },
      onNegative: () {},
      title: widget.type == ShippingAddressType.shipping ? context.l10n.shippingAddress : context.l10n.billingAddress,
      formKey: addressFormKey,
      children: [
        // Country/Region
        ref.watch(getCountryByIdProvider(currentCountry.isoCode.name)).when(
              data: (data) => AppTypeAheadForm<String>(
                name: 'country',
                label: context.l10n.country,
                initialValue: branch?.country ?? data.name,
                itemBuilder: (context, e) => ListTile(
                  title: Text(e),
                ),
                onSuggestionSelected: (suggestion) {
                  addressFormKey.currentState?.fields['country']?.didChange(suggestion);
                  addressFormKey.currentState?.fields['state']?.didChange(null);
                },
                onClear: () {
                  addressFormKey.currentState?.fields['state']?.didChange(null);
                },
                suggestionsCallback: (search) async {
                  return ref
                      .watch(businessRepoProvider)
                      .getCountries(query: search)
                      .then((value) => value.map((e) => e.name).toList());
                },
              ),
              error: (error, stackTrace) => Text(error.toString()),
              loading: () {
                return const SizedBox.shrink();
              },
            ),

        const SizedBox(height: 16),

        // Address line 1
        const AppTextForm<String>(
          label: 'Address',
          name: 'address_line_1',
          hintText: 'Address line 1',
        ),
        const SizedBox(height: 8),

        // Address line 2
        const AppTextForm<String>(
          // label: 'Address',
          name: 'address_line_2',
          hintText: 'Address line 2',
        ),
        const SizedBox(height: 16),

        // City
        const AppTextForm<String>(
          label: 'City',
          name: 'city',
        ),
        const SizedBox(height: 16),

        // State and Pin code in a row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTypeAheadForm<String>(
                name: 'state',
                label: context.l10n.state,
                initialValue: branch?.state,
                itemBuilder: (context, e) => ListTile(
                  title: Text(e),
                ),
                suggestionsCallback: (search) async {
                  return ref
                      .watch(businessRepoProvider)
                      .getStates(
                        query: search,
                        country: addressFormKey.currentState?.fields['country']?.value as String?,
                      )
                      .then((value) => value.map((e) => e.name).toList());
                },
                onSuggestionSelected: (suggestion) {
                  addressFormKey.currentState?.fields['state']?.didChange(suggestion);
                },
                onClear: () {
                  addressFormKey.currentState?.fields['state']?.didChange(null);
                },
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              flex: 2,
              child: AppTextForm<String>(
                label: 'Pin code',
                name: 'pin_code',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
