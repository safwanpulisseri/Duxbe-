import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/purchase/purchase.dart';
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

class SupplierDetailsScreenMobile extends ConsumerStatefulWidget {
  const SupplierDetailsScreenMobile({super.key, this.supplier});
  final Supplier? supplier;
  @override
  ConsumerState<SupplierDetailsScreenMobile> createState() => _SupplierDetailsScreenMobileState();
}

class _SupplierDetailsScreenMobileState extends ConsumerState<SupplierDetailsScreenMobile> {
  final _formKey = GlobalKey<FormBuilderState>();
  dynamic _image;

  @override
  void initState() {
    super.initState();
    _image = widget.supplier?.image;
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
    final supplierNotifier = ref.watch(supplierNotifierProvider.notifier);
    final supplierState = ref.watch(supplierNotifierProvider);

    return switch (ref.watch(authNotifierProvider).status) {
      AuthStatus.initial => const SizedBox.shrink(),
      AuthStatus.success => Scaffold(
          appBar: CustomAppBar(
            title: Text(context.l10n.addSupplier),
          ),
          body: SafeArea(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      children: [
                        if (_image != null)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.borderColor),
                                  ),
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
                                                  height: 100,
                                                )
                                              : Image.network(
                                                  _image as String,
                                                  height: 100,
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
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
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
                                    if (customerImage.canProvide(Formats.png) ||
                                        customerImage.canProvide(Formats.jpeg)) {
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
                                              Alert.showSnackBar(
                                                AppRouter.l10n.imageSizeExceeds10mb,
                                                type: SnackBarType.warning,
                                              );
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
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.offWhite,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            context.l10n.uploadImage,
                                            style: AppText.mediumSB.copyWith(color: AppColors.stormyBlue),
                                          ),
                                          const SizedBox(height: 14),
                                          DottedBorder(
                                            stackFit: StackFit.passthrough,
                                            borderType: BorderType.RRect,
                                            radius: const Radius.circular(12),
                                            color: AppColors.borderColor,
                                            strokeWidth: 2,
                                            dashPattern: const [3],
                                            padding: const EdgeInsets.all(10),
                                            child: Assets.icons.cloud.image(width: 24, height: 24),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        AppTextForm<String>(
                          label: context.l10n.supplierName,
                          initialValue: widget.supplier?.name,
                          name: 'name',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: context.l10n.pleaseEnterTheSupplierName,
                            ),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        AppPhoneNumberForm(
                          name: 'phone',
                          label: context.l10n.phoneNo,
                          initialValue: widget.supplier?.phone == null
                              ? ref.read(countryCodeProvider)
                              : PhoneNumber.parse(widget.supplier?.phone ?? ''),
                          validator: FormBuilderValidators.required(),
                          mobileValidator: PhoneValidator.compose(
                            [
                              PhoneValidator.required(context),
                              PhoneValidator.validMobile(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppTextForm<String>(
                          initialValue: widget.supplier?.email,
                          label: context.l10n.email,
                          name: 'email',
                          validator: FormBuilderValidators.email(),
                          inputFormatters: [LowerCaseTextFormatter()],
                        ),
                        const SizedBox(height: 12),
                        AppTextForm<String>(
                          initialValue: widget.supplier?.address,
                          label: context.l10n.address,
                          name: 'address',
                        ),
                        const SizedBox(height: 12),
                        AppTextForm<double>(
                          label: context.l10n.supplierBalance,
                          name: 'supplier_balance',
                          initialValue: widget.supplier?.supplierBalance,
                          enabled: widget.supplier?.supplierId == null,
                        ),
                        const SizedBox(height: 12),
                        AppTextForm<String>(
                          label: context.l10n.gstNumber,
                          name: 'gst_number',
                          initialValue: widget.supplier?.gstNumber,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 24 : MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  isLoading: supplierState.status == SupplierStatus.loading,
                  onPress: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      await supplierNotifier
                          .upsertSupplier(
                            Supplier.fromJson(_formKey.currentState!.value).copyWith(
                              supplierId: widget.supplier?.supplierId,
                            ),
                            image: _image,
                          )
                          .then(AppRouter.pop);
                    }
                  },
                  label: Text(context.l10n.saveAndPublish),
                ),
                const SizedBox(height: 12),
                AppButton(
                  style: ButtonStyles.secondary,
                  onPress: context.pop,
                  label: Text(context.l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      AuthStatus.loading => const Center(child: CircularProgressIndicator()),
      AuthStatus.error => const Center(child: Text('Error')),
    };
  }
}
