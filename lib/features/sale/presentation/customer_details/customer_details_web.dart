import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class CustomerDetailsScreenWeb extends ConsumerStatefulWidget {
  const CustomerDetailsScreenWeb({super.key, this.customer});
  final Customer? customer;
  @override
  ConsumerState<CustomerDetailsScreenWeb> createState() => _CustomerDetailsScreenWebState();
}

class _CustomerDetailsScreenWebState extends ConsumerState<CustomerDetailsScreenWeb> {
  final _formKey = GlobalKey<FormBuilderState>();
  dynamic _image;

  @override
  void initState() {
    super.initState();
    _image = widget.customer?.image;
  }

  void _removeImage() {
    try {
      setState(() {
        _image = null;
      });
    } catch (e) {
      debugPrint('Error removing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerNotifier = ref.watch(customerNotifierProvider.notifier);
    final customerState = ref.watch(customerNotifierProvider);

    return FormBuilder(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          decoration: AppStyles.boxDecoration,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextForm<String>(
                                      label: context.l10n.customerName,
                                      initialValue: widget.customer?.name,
                                      name: 'name',
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                          errorText: context.l10n.pleaseEnterTheCustomerName,
                                        ),
                                      ]),
                                    ),
                                  ),
                                  const SizedBox(height: 26, width: 26),
                                  Expanded(
                                    child: AppPhoneNumberForm(
                                      name: 'phone',
                                      label: '${context.l10n.phoneNo} *',
                                      initialValue: widget.customer?.phone == null
                                          ? ref.read(countryCodeProvider)
                                          : PhoneNumber.parse(widget.customer?.phone ?? ''),
                                      validator: FormBuilderValidators.required(),
                                      mobileValidator: PhoneValidator.compose(
                                        [
                                          PhoneValidator.required(context),
                                          PhoneValidator.validMobile(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26, width: 26),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextForm<String>(
                                      initialValue: widget.customer?.email,
                                      label: context.l10n.email,
                                      name: 'email',
                                      validator: FormBuilderValidators.email(checkNullOrEmpty: false),
                                      inputFormatters: [LowerCaseTextFormatter()],
                                    ),
                                  ),
                                  const SizedBox(height: 26, width: 26),
                                  Expanded(
                                    child: AppTextForm<String>(
                                      initialValue: widget.customer?.address,
                                      label: context.l10n.address,
                                      name: 'address',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26, width: 26),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextForm<double>(
                                      initialValue: widget.customer?.customerBalance,
                                      label: 'Customer Balance',
                                      name: 'customer_balance',
                                      enabled: widget.customer?.customerId == null,
                                    ),
                                  ),
                                  const SizedBox(height: 26, width: 26),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 26, width: 26),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      style: ButtonStyles.secondary,
                                      onPress: context.pop,
                                      label: Text(context.l10n.cancel),
                                    ),
                                  ),
                                  const SizedBox(height: 26, width: 26),
                                  Expanded(
                                    child: AppButton(
                                      isLoading: customerState.status == CustomerStatus.loading,
                                      onPress: () async {
                                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                                          await customerNotifier
                                              .upsertCustomer(
                                                Customer.fromJson(_formKey.currentState!.value).copyWith(
                                                  customerId: widget.customer?.customerId,
                                                ),
                                                image: _image,
                                              )
                                              .then(AppRouter.pop);
                                        }
                                      },
                                      label: Text(context.l10n.saveAndPublish),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_image != null)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: _image is Uint8List
                                ? Image.memory(
                                    _image as Uint8List,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _image as String,
                                    errorBuilder: (context, error, stackTrace) => Text('$error'),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: _removeImage,
                            child: const Icon(
                              CupertinoIcons.clear_circled_solid,
                              color: AppColors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: DropRegion(
                      // Formats this region can accept.
                      formats: const [Formats.png, Formats.jpeg],
                      hitTestBehavior: HitTestBehavior.opaque,
                      onDropOver: (event) {
                        // This drop region only supports copy operation.
                        if (event.session.allowedOperations.contains(DropOperation.copy)) {
                          return DropOperation.copy;
                        } else {
                          return DropOperation.none;
                        }
                      },
                      onDropEnter: (event) {
                        // This is called when region first accepts a drag. You can use this
                        // to display a visual indicator that the drop is allowed.
                      },
                      onDropLeave: (event) {
                        // Called when drag leaves the region. Will also be called after
                        // drag completion.
                        // This is a good place to remove any visual indicators.
                      },
                      onPerformDrop: (event) async {
                        // Called when user dropped the item. You can now request the data.
                        // Note that data must be requested before the performDrop callback
                        // is over.
                        final customerImage = event.session.items.first;
                        if (customerImage.canProvide(Formats.png) || customerImage.canProvide(Formats.jpeg)) {
                          try {
                            // Get the data as bytes
                            customerImage.dataReader?.getFile(
                              customerImage.canProvide(Formats.png) ? Formats.png : Formats.jpeg,
                              (value) async {
                                final bytes = await value.readAll();
                                final _ = await decodeImageFromList(bytes);
                                if (isValidFileSize(bytes, 10)) {
                                  setState(() {
                                    _image = bytes;
                                  });
                                } else {
                                  Alert.showSnackBar(AppRouter.l10n.imageSizeExceeds10mb);
                                }
                              },
                            );
                          } catch (e) {
                            debugPrint('Error processing dropped image: $e');
                          }
                        } else {
                          Alert.showSnackBar(context.l10n.invalidFileFormat, type: SnackBarType.error);
                        }
                      },
                      child: InkWell(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            withData: true,
                          );

                          if (result != null) {
                            for (final file in result.files) {
                              if (file.bytes != null) {
                                try {
                                  // Verify it's a valid image
                                  await decodeImageFromList(file.bytes!);
                                  setState(() {
                                    _image = file.bytes;
                                  });
                                } catch (e) {
                                  debugPrint('Error processing picked image: $e');
                                }
                              }
                            }
                          }
                        },
                        child: DottedBorder(
                          stackFit: StackFit.passthrough,
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          color: AppColors.borderColor,
                          strokeWidth: 2,
                          dashPattern: const [10],
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.icons.cloud.image(),
                              const SizedBox(height: 14),
                              Text(
                                context.l10n.selectAFileOrDragAndDropHere,
                                style: AppText.mediumN.copyWith(color: AppColors.title),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                context.l10n.jpgOrPngFileSizeNoMoreThan10mb,
                                style: AppText.mediumN.copyWith(color: AppColors.greyText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
