import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:timezone/timezone.dart' as tz;

class AddBranchScreenMobile extends ConsumerStatefulWidget {
  const AddBranchScreenMobile({super.key});
  @override
  ConsumerState<AddBranchScreenMobile> createState() => _AddBranchScreenMobileState();
}

class _AddBranchScreenMobileState extends ConsumerState<AddBranchScreenMobile> {
  final formKey = GlobalKey<FormBuilderState>();
  List<Currency> currencyModels = [];

  @override
  void initState() {
    super.initState();
    currencyModels = currencies.map(Currency.fromJson).toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(businessLogoProvider.notifier).state = ref.read(branchProvider)?.logo;
      setState(() {});
    });
  }

  void _removeImage() {
    try {
      setState(() {
        ref.read(businessLogoProvider.notifier).state = null;
      });
    } catch (e) {
      debugPrint('Error removing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = ref.watch(businessLogoProvider);
    final currentCountry = ref.watch(countryCodeProvider);
    final currentTimezone = ref.watch(currentTimeZoneProvider).value;

    return Scaffold(
      appBar: CustomAppBar(
        title:  Text(context.l10n.addBranch),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewPaddingOf(context).bottom == 0 ? 0 : MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: AppButton(
          isLoading: ref.watch(branchNotifierProvider).status == BranchStatus.loading,
          onPress: () {
            if (formKey.currentState?.saveAndValidate() ?? false) {
              ref.read(branchNotifierProvider.notifier).upsertBusiness(
                {
                  ...?formKey.currentState?.value,
                },
                image: ref.watch(businessLogoProvider),
              ).then((value) {
                // ignore: use_build_context_synchronously
                if (context.canPop()) context.pop();
                if (!mounted) return;
              });
            }
          },
          label: Text(context.l10n.save, style: AppText.largeB),
        ),
      ),
      body: FormBuilder(
        key: formKey,
        child: ListView(
          cacheExtent: 1000,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text(
              context.l10n.businessDetails,
              style: AppText.mediumN.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 16),
            if (image != null)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: image is Uint8List
                                  ? Image.memory(
                                      image,
                                      fit: BoxFit.cover,
                                      height: 100,
                                    )
                                  : Image.network(
                                      image as String,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
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
                                    ref.read(businessLogoProvider.notifier).state = bytes;
                                  } else {
                                    Alert.showSnackBar(AppRouter.l10n.imageSizeExceeds10mb, type: SnackBarType.warning);
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
                                    ref.read(businessLogoProvider.notifier).state = file.bytes;
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
                                  context.l10n.uploadLogo,
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
                  ),
                ],
              ),
            AppTextForm<String>(
              name: 'name',
              label: '${context.l10n.businessName} *',
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            AppDropDownForm<BusinessType>(
              name: 'business_type',
              label: '${context.l10n.businessType} *',
              valueTransformer: (e) => e?.name,
              validator: FormBuilderValidators.required(),
              items: BusinessType.values.map((e) => DropDownItems(value: e, child: Text(e.title))).toList(),
            ),
            const SizedBox(height: 16),
            AppTypeAheadForm<Currency>(
              name: 'currency',
              initialValue: currencyModels.firstWhere(
                (element) => element.countryCode.contains(
                  currentCountry.isoCode.name,
                ),
              ),
              label: context.l10n.currency,
              selectionToTextTransformer: (e) => '${e.code}   ${e.symbol}',
              valueTransformer: (e) => e?.toJson(),
              validator: FormBuilderValidators.required(),
              itemBuilder: (context, e) => ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.name),
                    Text('${e.code}   ${e.symbol}'),
                  ],
                ),
              ),
              suggestionsCallback: (search) => currencyModels
                  .where(
                    (e) => e.name.toLowerCase().contains(search.toLowerCase()),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ref.watch(getCountryByIdProvider(currentCountry.isoCode.name)).when(
                  data: (data) => AppTypeAheadForm<String>(
                    name: 'country',
                    label: context.l10n.country,
                    initialValue: data.name,
                    itemBuilder: (context, e) => ListTile(
                      title: Text(e),
                    ),
                    onSuggestionSelected: (suggestion) {
                      formKey.currentState?.fields['state']?.didChange(null);
                    },
                    onClear: () {
                      formKey.currentState?.fields['state']?.didChange(null);
                    },
                    suggestionsCallback: (search) async {
                      return ref
                          .watch(businessRepoProvider)
                          .getCountries(query: search)
                          .then((value) => value.map((e) => e.name).toList());
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => Text(error.toString()),
                ),
            const SizedBox(height: 16),
            AppTypeAheadForm<String>(
              name: 'state',
              label: context.l10n.state,
              itemBuilder: (context, e) => ListTile(
                title: Text(e),
              ),
              suggestionsCallback: (search) async {
                return ref
                    .watch(businessRepoProvider)
                    .getStates(query: search)
                    .then((value) => value.map((e) => e.name).toList());
              },
            ),
            const SizedBox(height: 16),
            AppTypeAheadForm<String>(
              name: 'time_zone',
              validator: FormBuilderValidators.required(),
              initialValue: currentTimezone,
              label: context.l10n.timeZone,
              itemBuilder: (context, location) => ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(location),
                    Text(
                      formatMillisecondsToUTCOffset(
                        tz.getLocation(location).currentTimeZone.offset,
                      ),
                    ),
                  ],
                ),
              ),
              suggestionsCallback: (search) async {
                return getSortedTimeZones()
                    .where((location) => location.toLowerCase().contains(search.toLowerCase()))
                    .toList();
              },
            ),
            const SizedBox(height: 16),
            ref.watch(fiscalYearsProvider).when(
                  data: (value) => AppDropDownForm<String>(
                    label: context.l10n.fiscalYear,
                    validator: FormBuilderValidators.required(),
                    items: ref
                        .watch(fiscalYearsProvider)
                        .value
                        ?.map(
                          (e) => DropDownItems(
                            value: e.fiscalId,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    name: 'fiscal_year',
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => Text(error.toString()),
                ),
            const SizedBox(height: 16),
            Text(
              context.l10n.gstSettings,
              style: AppText.mediumN.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 16),
            AppToggleForm(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              name: 'gst_on',
              hint: context.l10n.isYourBusinessRegisteredFor,
              onChanged: (val) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            if (formKey.currentState?.fields['gst_on']?.value == true) ...[
              const AppTextForm<String>(
                name: 'gst_in',
                label: 'GSTIN',
              ),
              const SizedBox(height: 16),
            ],
            Text(
              context.l10n.taxpayerDetails,
              style: AppText.mediumN.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 16),
            AppTextForm<String>(
              name: 'legal_name',
              label: context.l10n.businessLegalName,
            ),
            const SizedBox(height: 16),
            AppDateTimeForm(
              inputType: InputType.date,
              label: context.l10n.gstRegisteredOn,
              name: 'register_on_date',
              valueTransformer: (date) => date?.toIso8601String(),
            ),
            const SizedBox(height: 16),
            AppTextForm<String>(
              name: 'trade_name',
              label: context.l10n.businessTradeName,
            ),
            const SizedBox(height: 16),
            ref.watch(printerProvider).maybeWhen(
                  data: (value) => AppDropDownForm<String>(
                    label: context.l10n.printer,
                    items: ref
                        .watch(printerProvider)
                        .value
                        ?.map(
                          (e) => DropDownItems(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    name: 'printer',
                    initialValue: ref.read(printerNameProvider),
                    onChanged: (value) {
                      ref.read(printerNameProvider.notifier).state = value ?? '';
                    },
                  ),
                  orElse: () => const SizedBox(),
                ),
            const SizedBox(height: 16),
            AppDropDownForm<PrintFormats>(
              name: 'format',
              label: context.l10n.formatPageSize,
              initialValue: PrintFormats.a4,
              valueTransformer: (value) => value?.name,
              items:
                  PrintFormats.values.map((e) => DropDownItems<PrintFormats>(value: e, child: Text(e.name))).toList(),
            ),
            const SizedBox(height: 16),
            AppToggleForm(
              name: 'on_sale',
              hint: context.l10n.printOnSale,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              initialValue: false,
            ),
            const SizedBox(height: 16),
            AppToggleForm(
              name: 'on_purchase',
              hint: context.l10n.printOnPurchase,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              initialValue: false,
            ),
            const SizedBox(height: 16),
            AppToggleForm(
              name: 'on_barcode',
              hint: context.l10n.printBarcodeOnPurchase,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              initialValue: false,
            ),
            Container(
              decoration: AppStyles.boxDecoration,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.customerSettings,
                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                  ),
                  const SizedBox(height: 16),
                  AppToggleForm(
                    name: 'allow_walk_in',
                    hint: context.l10n.allowWalkInCustomers,
                    initialValue: false,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: AppStyles.boxDecoration,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.inventorySettings,
                    style: AppText.smallN.copyWith(color: AppColors.stormyBlue),
                  ),
                  const SizedBox(height: 16),
                  AppToggleForm(
                    name: 'allow_out_of_stock',
                    hint: context.l10n.allowSalesWhenOutOfStock,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    initialValue: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
