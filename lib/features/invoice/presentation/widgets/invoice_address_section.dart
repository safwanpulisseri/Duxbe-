import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/create_quote/add_shipping_address.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:hancod_theme/hancod_theme.dart';

class InvoiceAddressSection extends StatelessWidget {
  const InvoiceAddressSection({
    required this.customer,
    required this.billingAddress,
    required this.shippingAddress,
    required this.onAddressSelected,
    super.key,
    this.spacing = 20,
    this.iconSize = 16,
  });
  final Customer? customer;
  final CustomerAddress? billingAddress;
  final CustomerAddress? shippingAddress;
  final Function(CustomerAddress, String) onAddressSelected;
  final double spacing;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Billing Address
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.billingAddress.toUpperCase(),
                    style: AppText.mediumN,
                  ),
                  IconButton(
                    onPressed: () async {
                      if (customer != null) {
                        final address = await showDialog<CustomerAddress>(
                          context: AppRouter.rootContext,
                          builder: (context) => AddShippingAddress(
                            customerId: customer?.customerId ?? '',
                            type: ShippingAddressType.billing,
                          ),
                        );
                        if (address != null) {
                          onAddressSelected(address, 'billing');
                        }
                      } else {
                        Alert.showSnackBar(
                          'Please select a customer first',
                          type: SnackBarType.warning,
                        );
                      }
                    },
                    icon: Assets.icons.edit.svg(
                      width: iconSize,
                      height: iconSize,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                billingAddress == null
                    ? customer?.address ?? 'No billing address available '
                    : '${billingAddress?.address}, \n${billingAddress?.city}, ${billingAddress?.state} \n${billingAddress?.zipcode}, ${billingAddress?.country}',
                style: AppText.mediumN.copyWith(
                  color: AppColors.black,
                  height: 1.8,
                ),
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),

        SizedBox(width: spacing),

        // Shipping Address
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.shippingAddress.toUpperCase(),
                style: AppText.mediumN,
              ),
              const SizedBox(height: 8),
              Text(
                shippingAddress == null
                    ? customer?.address ?? 'No shipping address available '
                    : '${shippingAddress?.address}, \n${shippingAddress?.city}, ${shippingAddress?.state} \n${shippingAddress?.zipcode}, ${shippingAddress?.country}',
                style: AppText.mediumN.copyWith(
                  color: AppColors.black,
                  height: 1.8,
                ),
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  if (customer != null) {
                    final address = await showDialog<CustomerAddress>(
                      context: AppRouter.rootContext,
                      builder: (context) => AddShippingAddress(
                        customerId: customer?.customerId ?? '',
                        type: ShippingAddressType.shipping,
                      ),
                    );
                    if (address != null) {
                      onAddressSelected(address, 'shipping');
                    }
                  } else {
                    Alert.showSnackBar(
                      'Please select a customer first',
                      type: SnackBarType.warning,
                    );
                  }
                },
                child: Text(context.l10n.newAddress),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
