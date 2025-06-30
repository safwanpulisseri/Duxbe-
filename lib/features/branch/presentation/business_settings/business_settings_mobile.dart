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

class BusinessSettingsScreenMobile extends ConsumerStatefulWidget {
  const BusinessSettingsScreenMobile({super.key});

  @override
  ConsumerState<BusinessSettingsScreenMobile> createState() => _BusinessSettingsScreenMobileState();
}

class _BusinessSettingsScreenMobileState extends ConsumerState<BusinessSettingsScreenMobile> {
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
    final branch = ref.watch(branchProvider);
    final image = ref.watch(businessLogoProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title:  Text(context.l10n.businessSettings),
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
                  'business_id': branch?.businessId,
                  ...?formKey.currentState?.value,
                },
                image: ref.watch(businessLogoProvider),
              ).then((value) {
                ref.invalidate(businessProvider(branch?.businessId));
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
              initialValue: branch?.name,
              label: '${context.l10n.businessName} *',
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            AppDropDownForm<BusinessType>(
              name: 'business_type',
              enabled: branch == null,
              initialValue: branch?.businessType,
              label: '${context.l10n.businessType} *',
              valueTransformer: (e) => e?.name,
              validator: FormBuilderValidators.required(),
              items: BusinessType.values.map((e) => DropDownItems(value: e, child: Text(e.title))).toList(),
            ),
            const SizedBox(height: 16),
            AppTypeAheadForm<Currency>(
              name: 'currency',
              initialValue: branch?.currency,
              label: context.l10n.currency,
              enabled: branch == null,
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
            AppTypeAheadForm<String>(
              name: 'country',
              label: context.l10n.country,
              initialValue: branch?.country,
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
            const SizedBox(height: 16),
            AppTypeAheadForm<String>(
              name: 'state',
              label: context.l10n.state,
              initialValue: branch?.state,
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
              initialValue: branch?.timeZone,
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
                    initialValue: branch?.fiscalId,
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
          ],
        ),
      ),
    );
  }
}
