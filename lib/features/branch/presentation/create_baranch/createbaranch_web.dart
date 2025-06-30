import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:timezone/timezone.dart' as tz;

class CreatebaranchScreenWeb extends ConsumerStatefulWidget {
  const CreatebaranchScreenWeb({super.key});

  @override
  ConsumerState<CreatebaranchScreenWeb> createState() =>
      _CreatebaranchScreenWebState();
}

class _CreatebaranchScreenWebState extends ConsumerState<CreatebaranchScreenWeb>
    with AutomaticKeepAliveClientMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  bool get wantKeepAlive => true;

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
  void initState() {
    super.initState();
    currencyModels = currencies.map(Currency.fromJson).toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(businessLogoProvider.notifier).state = null;
    });
  }

  List<Currency> currencyModels = [];
  @override
  Widget build(BuildContext context) {
    // final formKey = FormBuilder.of(context)!;
    super.build(context);
    final branch = ref.watch(branchProvider);
    final image = ref.watch(businessLogoProvider);
    final currentTimezone = ref.watch(currentTimeZoneProvider).value;
    final currentCountry = ref.watch(countryCodeProvider);
    final printerNotifier = ref.watch(printerServiceProvider);

    return FormBuilder(
      key: formKey,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: AppStyles.boxDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.branchDetails,
                            style: AppText.largeSB
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          if (image != null)
                            Row(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.borderColor),
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
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Text('$error'),
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
                              ],
                            )
                          else
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: DropRegion(
                                    // Formats this region can accept.
                                    formats: const [Formats.png, Formats.jpeg],
                                    hitTestBehavior: HitTestBehavior.opaque,
                                    onDropOver: (event) {
                                      // This drop region only supports copy operation.
                                      if (event.session.allowedOperations
                                          .contains(DropOperation.copy)) {
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
                                      final customerImage =
                                          event.session.items.first;
                                      if (customerImage
                                              .canProvide(Formats.png) ||
                                          customerImage
                                              .canProvide(Formats.jpeg)) {
                                        try {
                                          // Get the data as bytes
                                          customerImage.dataReader?.getFile(
                                            customerImage
                                                    .canProvide(Formats.png)
                                                ? Formats.png
                                                : Formats.jpeg,
                                            (value) async {
                                              final bytes =
                                                  await value.readAll();
                                              final _ =
                                                  await decodeImageFromList(
                                                      bytes);
                                              if (isValidFileSize(bytes, 10)) {
                                                ref
                                                    .read(businessLogoProvider
                                                        .notifier)
                                                    .state = bytes;
                                              } else {
                                                Alert.showSnackBar(
                                                  AppRouter.l10n
                                                      .imageSizeExceeds10mb,
                                                  type: SnackBarType.warning,
                                                );
                                              }
                                            },
                                          );
                                        } catch (e) {
                                          debugPrint(
                                              'Error processing dropped image: $e');
                                        }
                                      } else {
                                        Alert.showSnackBar(
                                            context.l10n.invalidFileFormat,
                                            type: SnackBarType.error);
                                      }
                                    },
                                    child: InkWell(
                                      onTap: () async {
                                        final result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                          withData: true,
                                        );

                                        if (result != null) {
                                          for (final file in result.files) {
                                            if (file.bytes != null) {
                                              try {
                                                // Verify it's a valid image
                                                await decodeImageFromList(
                                                    file.bytes!);
                                                ref
                                                    .read(businessLogoProvider
                                                        .notifier)
                                                    .state = file.bytes;
                                              } catch (e) {
                                                debugPrint(
                                                    'Error processing picked image: $e');
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Assets.icons.cloud.image(),
                                            const SizedBox(height: 14),
                                            Text(
                                              context.l10n
                                                  .selectAFileOrDragAndDropHere,
                                              style: AppText.mediumN.copyWith(
                                                  color: AppColors.title),
                                            ),
                                            const SizedBox(height: 14),
                                            Text(
                                              context.l10n
                                                  .jpgOrPngFileSizeNoMoreThan10mb,
                                              style: AppText.mediumN.copyWith(
                                                  color: AppColors.greyText),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextForm<String>(
                                  name: 'name',
                                  label: '${context.l10n.businessName} *',
                                  validator: FormBuilderValidators.required(),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: AppDropDownForm<BusinessType>(
                                  name: 'business_type',
                                  enabled: branch == null,
                                  label: '${context.l10n.businessType} *',
                                  valueTransformer: (e) => e?.name,
                                  validator: FormBuilderValidators.required(),
                                  items: BusinessType.values
                                      .map((e) => DropDownItems(
                                          value: e, child: Text(e.title)))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: AppTypeAheadForm<Currency>(
                                  name: 'currency',
                                  initialValue: currencyModels.firstWhereOrNull(
                                    (element) => element.countryCode.contains(
                                      currentCountry.isoCode.name,
                                    ),
                                  ),
                                  label: context.l10n.currency,
                                  enabled: branch == null,
                                  selectionToTextTransformer: (e) =>
                                      '${e.code}   ${e.symbol}',
                                  valueTransformer: (e) => e?.toJson(),
                                  validator: FormBuilderValidators.required(),
                                  itemBuilder: (context, e) => ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.name),
                                        Text('${e.code}   ${e.symbol}'),
                                      ],
                                    ),
                                  ),
                                  suggestionsCallback: (search) =>
                                      currencyModels
                                          .where(
                                            (e) => e.name
                                                .toLowerCase()
                                                .contains(search.toLowerCase()),
                                          )
                                          .toList(),
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ref
                                  .watch(getCountryByIdProvider(
                                      currentCountry.isoCode.name))
                                  .when(
                                    data: (data) => Expanded(
                                      child: AppTypeAheadForm<String>(
                                        name: 'country',
                                        label: context.l10n.country,
                                        initialValue: data.name,
                                        itemBuilder: (context, e) => ListTile(
                                          title: Text(e),
                                        ),
                                        onSuggestionSelected: (suggestion) {
                                          formKey.currentState?.fields['state']
                                              ?.didChange(null);
                                          setState(() {});
                                        },
                                        onClear: () {
                                          formKey.currentState?.fields['state']
                                              ?.didChange(null);
                                          formKey.currentState?.fields['gst_on']
                                              ?.didChange(false);
                                          setState(() {});
                                        },
                                        suggestionsCallback: (search) async {
                                          return ref
                                              .watch(businessRepoProvider)
                                              .getCountries(query: search)
                                              .then((value) => value
                                                  .map((e) => e.name)
                                                  .toList());
                                        },
                                      ),
                                    ),
                                    error: (error, stackTrace) =>
                                        Expanded(child: Text(error.toString())),
                                    loading: Spacer.new,
                                  ),
                              const SizedBox(height: 20, width: 20),
                              Expanded(
                                child: AppTypeAheadForm<String>(
                                  name: 'state',
                                  label: context.l10n.state,
                                  itemBuilder: (context, e) => ListTile(
                                    title: Text(e),
                                  ),
                                  suggestionsCallback: (search) async {
                                    return ref
                                        .watch(businessRepoProvider)
                                        .getStates(
                                          query: search,
                                          country: formKey
                                              .currentState
                                              ?.fields['country']
                                              ?.value as String?,
                                        )
                                        .then((value) =>
                                            value.map((e) => e.name).toList());
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const SizedBox(height: 20),
                              Expanded(
                                child: AppTextForm<String>(
                                  name: 'contact_email',
                                  // enabled: false,
                                  label:
                                      '${context.l10n.email} (${context.l10n.thisEmailWillBeUsedAsTheOfficialEmailOnInvoices})',
                                  initialValue: branch?.contactEmail ??
                                      ref
                                          .read(authNotifierProvider)
                                          .user
                                          ?.email,
                                  validator: FormBuilderValidators.compose(
                                    [FormBuilderValidators.required()],
                                  ),
                                  inputFormatters: [LowerCaseTextFormatter()],
                                ),
                              ),
                              const SizedBox(height: 20, width: 20),
                              Expanded(
                                child: AppPhoneNumberForm(
                                  name: 'contact_phone',
                                  label:
                                      '${context.l10n.phoneNumber} (${context.l10n.thisNumberWillBeUsedAsTheOfficialNumberOnInvoices}',
                                  // enabled: false,
                                  // required: true,
                                  initialValue: (branch
                                              ?.contactPhone?.isNotEmpty ??
                                          false)
                                      ? PhoneNumber.parse(branch!.contactPhone!)
                                      : ref
                                                  .read(authNotifierProvider)
                                                  .user
                                                  ?.phone ==
                                              null
                                          ? ref.read(countryCodeProvider)
                                          : PhoneNumber.parse(
                                              ref
                                                  .read(authNotifierProvider)
                                                  .user!
                                                  .phone!,
                                            ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20, width: 20),
                    Container(
                      decoration: AppStyles.boxDecoration,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.moreInfo,
                            style: AppText.largeSB
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            children: [
                              Expanded(
                                child: AppTypeAheadForm<String>(
                                  name: 'time_zone',
                                  initialValue: currentTimezone,
                                  validator: FormBuilderValidators.required(),
                                  label: context.l10n.timeZone,
                                  itemBuilder: (context, location) => ListTile(
                                    title: Text(location),
                                    trailing: Text(
                                      formatMillisecondsToUTCOffset(
                                        tz
                                            .getLocation(location)
                                            .currentTimeZone
                                            .offset,
                                      ),
                                    ),
                                  ),
                                  suggestionsCallback: (search) async {
                                    return getSortedTimeZones()
                                        .where((location) => location
                                            .toLowerCase()
                                            .contains(search.toLowerCase()))
                                        .toList();
                                  },
                                ),
                              ),
                              const SizedBox(height: 20, width: 20),
                              ref.watch(fiscalYearsProvider).when(
                                    data: (value) => Expanded(
                                      child: AppDropDownForm<String>(
                                        label: context.l10n.fiscalYear,
                                        validator:
                                            FormBuilderValidators.required(),
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
                                    ),
                                    loading: () => const SizedBox.shrink(),
                                    error: (error, stack) =>
                                        Text(error.toString()),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    ///MARK:Tax Settings
                    // Container(
                    //   margin: const EdgeInsets.symmetric(vertical: 20),
                    //   decoration: AppStyles.boxDecoration,
                    //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       if (formKey.currentState?.fields['country']?.value == 'India') ...[
                    //         Text(
                    //           context.l10n.gstSettings,
                    //           style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                    //         ),
                    //         const SizedBox(height: 26),
                    //         Row(
                    //           children: [
                    //             Expanded(
                    //               child: AppToggleForm(
                    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                 name: 'gst_on',
                    //                 hint: context.l10n.isYourBusinessRegisteredFor,
                    //                 onChanged: (val) {
                    //                   setState(() {});
                    //                 },
                    //               ),
                    //             ),
                    //             const SizedBox(height: 20, width: 20),
                    //             const Spacer(),
                    //           ],
                    //         ),
                    //         if (formKey.currentState?.fields['gst_on']?.value == true)
                    //           Row(
                    //             children: [
                    //               const Expanded(
                    //                 child: AppTextForm<String>(
                    //                   name: 'gst_in',
                    //                   label: 'GSTIN',
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 24, width: 20),
                    //               Expanded(
                    //                 child: AppDateTimeForm(
                    //                   inputType: InputType.date,
                    //                   label: context.l10n.gstRegisteredOn,
                    //                   name: 'register_on_date',
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         const SizedBox(height: 26),
                    //       ],
                    //       Text(
                    //         context.l10n.taxpayerDetails,
                    //         style: AppText.largeSB,
                    //       ),
                    //       const SizedBox(height: 26),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: AppTextForm<String>(
                    //               name: 'legal_name',
                    //               label: context.l10n.businessLegalName,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 20, width: 20),
                    //           const Spacer(),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 20, width: 20),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: AppTextForm<String>(
                    //               name: 'trade_name',
                    //               label: context.l10n.businessTradeName,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 20, width: 20),
                    //           const Spacer(),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 26),
                    // // Container(
                    // //   decoration: AppStyles.boxDecoration,
                    // //   padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 38),
                    // //   child: Column(
                    // //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    // //     children: [
                    // //       Row(
                    // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // //         children: [
                    // //           Text(
                    // //             context.l10n.taxRates,
                    // //             style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                    // //           ),
                    // //           TextButton.icon(
                    // //             icon: const Icon(Icons.add, color: AppColors.primaryColor),
                    // //             label: Text(
                    // //               context.l10n.addTax,
                    // //               style: AppText.mediumM.copyWith(color: AppColors.primaryColor),
                    // //             ),
                    // //             onPressed: () async {
                    // //               await showDialog<void>(
                    // //                 context: context,
                    // //                 builder: (context) {
                    // //                   return ProviderScope(
                    // //                     overrides: [branchProvider.overrideWith((ref) => branch)],
                    // //                     child: const AddTaxDialog(),
                    // //                   );
                    // //                 },
                    // //               );
                    // //             },
                    // //           ),
                    // //         ],
                    // //       ),
                    // //       const SizedBox(height: 26),
                    // //       Column(
                    // //         children: [
                    // //           Row(
                    // //             children: [
                    // //               SizedBox(width: 300, child: Text(context.l10n.taxName)),
                    // //               SizedBox(width: 300, child: Text(context.l10n.taxType)),
                    // //               SizedBox(width: 300, child: Text(context.l10n.taxRate)),
                    // //             ],
                    // //           ),
                    // //           const SizedBox(height: 10),
                    // //           ...ref.watch(taxNotifierProvider(branch?.businessId ?? '')).taxes.map(
                    // //                 (e) => Padding(
                    // //                   padding: const EdgeInsets.only(bottom: 12),
                    // //                   child: Row(
                    // //                     children: [
                    // //                       SizedBox(
                    // //                         width: 300,
                    // //                         child: Text(
                    // //                           e.name,
                    // //                           style: AppText.largeN.copyWith(color: AppColors.primaryColor),
                    // //                         ),
                    // //                       ),
                    // //                       SizedBox(
                    // //                         width: 300,
                    // //                         child: Text(
                    // //                           e.type ?? '',
                    // //                           style: AppText.largeN.copyWith(
                    // //                             color: AppColors.primaryColor,
                    // //                           ),
                    // //                         ),
                    // //                       ),
                    // //                       SizedBox(
                    // //                         width: 300,
                    // //                         child: Text(
                    // //                           e.rate.toString(),
                    // //                           style: AppText.largeN.copyWith(color: AppColors.primaryColor),
                    // //                         ),
                    // //                       ),
                    // //                     ],
                    // //                   ),
                    // //                 ),
                    // //               ),
                    // //         ],
                    // //       ),
                    // //     ],
                    // //   ),
                    // // ),
                    // // const SizedBox(height: 26),
                    // //Print Settings
                    // Container(
                    //   margin: const EdgeInsets.symmetric(vertical: 20),
                    //   decoration: AppStyles.boxDecoration,
                    //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       Text(
                    //         context.l10n.printSettings,
                    //         style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                    //       ),
                    //       const SizedBox(height: 26),
                    //       Row(
                    //         children: [
                    //           StreamBuilder<List<BluetoothDevice>>(
                    //             stream: ref.read(printerServiceProvider).scanResults,
                    //             builder: (context, snapshot) {
                    //               return Expanded(
                    //                 child: AppDropDownForm<BluetoothDevice>(
                    //                   label: context.l10n.printer,
                    //                   items: snapshot.data
                    //                           ?.map(
                    //                             (e) => DropDownItems<BluetoothDevice>(
                    //                               value: e,
                    //                               child: Text(
                    //                                 e.name ?? e.address ?? 'Unknown Printer',
                    //                               ),
                    //                             ),
                    //                           )
                    //                           .toList() ??
                    //                       [],
                    //                   name: 'printer',
                    //                   initialValue: ref.read(printerServiceProvider).selectedPrinter.value,
                    //                   onChanged: (value) {
                    //                     ref.read(printerServiceProvider).selectedPrinter.value = value;
                    //                   },
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //           const SizedBox(height: 20, width: 20),
                    //           const Spacer(),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 26),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: AppDropDownForm<PrintFormats>(
                    //               name: 'format',
                    //               label: context.l10n.formatPageSize,
                    //               valueTransformer: (value) => value?.name,
                    //               items: PrintFormats.values
                    //                   .map((e) => DropDownItems<PrintFormats>(value: e, child: Text(e.name)))
                    //                   .toList(),
                    //             ),
                    //           ),
                    //           const SizedBox(width: 20),
                    //           const Spacer(),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 26),
                    //       AppToggleForm(
                    //         name: 'on_sale',
                    //         hint: context.l10n.printOnSale,
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       ),
                    //       AppToggleForm(
                    //         name: 'on_purchase',
                    //         hint: context.l10n.printOnPurchase,
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       ),
                    //       AppToggleForm(
                    //         name: 'on_barcode',
                    //         hint: context.l10n.printBarcodeOnPurchase,
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Container(
                    //   decoration: AppStyles.boxDecoration,
                    //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       Text(
                    //         context.l10n.customerSettings,
                    //         style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                    //       ),
                    //       const SizedBox(height: 26),
                    //       AppToggleForm(
                    //         name: 'allow_walk_in',
                    //         hint: context.l10n.allowWalkInCustomers,
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 26),
                    // Container(
                    //   decoration: AppStyles.boxDecoration,
                    //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       Text(
                    //         context.l10n.inventorySettings,
                    //         style: AppText.largeSB.copyWith(color: AppColors.primaryColor),
                    //       ),
                    //       const SizedBox(height: 26),
                    //       AppToggleForm(
                    //         name: 'allow_out_of_stock',
                    //         hint: context.l10n.allowSalesWhenOutOfStock,
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (context.canPop())
                          SizedBox(
                            width: 100,
                            child: AppButton(
                              onPress: context.pop,
                              label: Text(context.l10n.cancel),
                              style: ButtonStyles.secondary,
                            ),
                          ),
                        const SizedBox(height: 20, width: 20),
                        SizedBox(
                          width: 200,
                          child: AppButton(
                            isLoading:
                                ref.watch(branchNotifierProvider).status ==
                                    BranchStatus.loading,
                            onPress: () {
                              if (formKey.currentState?.saveAndValidate() ??
                                  false) {
                                final formValue = formKey.currentState!.value;
                                if (formValue['printer'] != null) {
                                  printerNotifier.connect().then((value) {
                                    if (value == PosPrintResult.success) {
                                      printerNotifier.printTicket(latin1
                                          .encode('Hello world!\n\n\n')
                                          .toList());
                                    }
                                  });
                                }
                                ref
                                    .read(branchNotifierProvider.notifier)
                                    .upsertBusiness(
                                  {
                                    // Basic Business Information
                                    'name': formValue['name'] ?? branch?.name,
                                    'business_type':
                                        formValue['business_type'] ??
                                            branch?.businessType,
                                    'trade_name': formValue['trade_name'] ??
                                        branch?.tradeName,
                                    'legal_name': formValue['legal_name'] ??
                                        branch?.legalBusinessName,
                                    'currency': formValue['currency'] ??
                                        branch?.currency?.toJson(),
                                    'country':
                                        formValue['country'] ?? branch?.country,
                                    'state':
                                        formValue['state'] ?? branch?.state,
                                    'time_zone': formValue['time_zone'] ??
                                        branch?.timeZone,
                                    'fiscal_year': formValue['fiscal_year'] ??
                                        branch?.fiscalId,
                                    'gst_in':
                                        formValue['gst_in'] ?? branch?.gstIn,
                                    'gst_on': formValue['gst_on'] ??
                                        branch?.isGstRegistered,
                                    'legal_business_name':
                                        formValue['legal_name'] ??
                                            branch?.legalBusinessName,
                                    'register_on_date':
                                        formValue['register_on_date'] ??
                                            branch?.gstRegisteredDate,
                                    'allow_out_of_stock':
                                        formValue['allow_out_of_stock'] ??
                                            branch?.allowSalesWhenOutOfStock,
                                    'allow_walk_in':
                                        formValue['allow_walk_in'] ??
                                            branch?.allowWalkinCustomer,
                                    'format':
                                        formValue['format'] ?? branch?.format,
                                    'on_sale': formValue['on_sale'] ??
                                        branch?.printOnSale,
                                    'on_purchase': formValue['on_purchase'] ??
                                        branch?.printOnPurchase,
                                    'on_barcode': formValue['on_barcode'] ??
                                        branch?.printBarcodeOnPurchase,
                                        'contact_email': formValue['contact_email'] ??
                                        branch?.contactEmail,
                                        'contact_phone': formValue['contact_phone'] ??
                                        branch?.contactPhone,
                                  },
                                  image: ref.watch(businessLogoProvider),
                                ).then((value) {
                                  ref.read(branchProvider.notifier).state =
                                      value;
                                  if (context.canPop()) context.pop();
                                  if (!mounted) return;
                                  //   DefaultTabController.of(context).animateTo(0);
                                });
                              } else {
                                //    DefaultTabController.of(context).animateTo(0);
                              }
                            },
                            label: Text(context.l10n.save,
                                style: AppText.heading5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
