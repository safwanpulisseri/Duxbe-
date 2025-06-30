import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ProfileScreenWeb extends ConsumerStatefulWidget {
  const ProfileScreenWeb({super.key});

  @override
  ConsumerState<ProfileScreenWeb> createState() => _ProfileScreenWebState();
}

class _ProfileScreenWebState extends ConsumerState<ProfileScreenWeb> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          ColoredBox(
            color: AppColors.lightPurple,
            child: TabBar(
              tabAlignment: TabAlignment.fill,
              indicator: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
              labelStyle: AppText.largeSB.copyWith(color: AppColors.white),
              unselectedLabelStyle: AppText.largeSB.copyWith(color: AppColors.stormyBlue),
              tabs: [
                context.l10n.personalDetails,
                context.l10n.changePassword,
              ].map((e) => Tab(text: e)).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: TabBarView(
              children: [
                PersonalDetails(),
                PasswordDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonalDetails extends ConsumerStatefulWidget {
  const PersonalDetails({super.key});

  @override
  ConsumerState<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends ConsumerState<PersonalDetails> {
  final _formKey = GlobalKey<FormBuilderState>();

  /// [_pickedImage] is either Uint8List or String
  // ignore: inference_failure_on_uninitialized_variable, prefer_typing_uninitialized_variables
  var _pickedImage;

  void _removeImage() {
    try {
      setState(() {
        _pickedImage = null;
      });
    } catch (e) {
      debugPrint('Error removing image: $e');
    }
  }

  @override
  void initState() {
    Future(
      () {
        setState(() {
          _pickedImage = ref.read(authNotifierProvider).user?.image;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      smallScreen: Scaffold(
        appBar: CustomAppBar(
          title: Text(context.l10n.personalDetails),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderColor, width: 2),
                            ),
                            child: _pickedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(75),
                                    child: _pickedImage is Uint8List
                                        ? Image.memory(
                                            _pickedImage as Uint8List,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            _pickedImage as String,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Center(child: Text('$error')),
                                          ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: AppColors.greyText,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
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
                                        if (isValidFileSize(file.bytes!, 10)) {
                                          setState(() {
                                            _pickedImage = file.bytes;
                                          });
                                        } else {
                                          Alert.showSnackBar(AppRouter.l10n.imageSizeExceeds10mb);
                                        }
                                      } catch (e) {
                                        debugPrint('Error processing picked image: $e');
                                      }
                                    }
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          if (_pickedImage != null)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: InkWell(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: AppColors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                AppTextForm<String>(
                  name: 'name',
                  label: context.l10n.name,
                  initialValue: ref.read(authNotifierProvider).user?.name,
                  validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required()],
                  ),
                ),
                const SizedBox(height: 20),
                AppTextForm<String>(
                  name: 'email',
                  enabled: false,
                  label: context.l10n.email,
                  initialValue: ref.read(authNotifierProvider).user?.email,
                  validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required()],
                  ),
                  inputFormatters: [LowerCaseTextFormatter()],
                ),
                const SizedBox(height: 20),
                AppPhoneNumberForm(
                  name: 'phone_no',
                  label: context.l10n.phoneNumber,
                  enabled: false,
                  required: true,
                  initialValue: ref.read(authNotifierProvider).user?.phone == null
                      ? ref.read(countryCodeProvider)
                      : PhoneNumber.parse(ref.read(authNotifierProvider).user!.phone!),
                ),
                const SizedBox(height: 20),
                AppButton(
                  onPress: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      final name = _formKey.currentState!.value['name'] as String;
                      await ref.read(authNotifierProvider.notifier).updateUserDetails(
                            name,
                            _pickedImage,
                          );
                    }
                  },
                  isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                  label: Text(context.l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
      largeScreen: Container(
        decoration: AppStyles.boxDecoration,
        padding: const EdgeInsets.all(22),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_pickedImage != null)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Stack(
                              children: [
                                Align(
                                  child: SizedBox(
                                    height: 400,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: _pickedImage is Uint8List
                                            ? Image.memory(
                                                _pickedImage as Uint8List,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                _pickedImage as String,
                                                errorBuilder: (context, error, stackTrace) => Text('$error'),
                                              ),
                                      ),
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
                                            _pickedImage = bytes;
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
                                            _pickedImage = file.bytes;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextForm<String>(
                          name: 'name',
                          label: context.l10n.name,
                          initialValue: ref.read(authNotifierProvider).user?.name,
                          validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required()],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppTextForm<String>(
                          name: 'email',
                          enabled: false,
                          label: context.l10n.email,
                          initialValue: ref.read(authNotifierProvider).user?.email,
                          validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required()],
                          ),
                          inputFormatters: [LowerCaseTextFormatter()],
                        ),
                        const SizedBox(height: 20),
                        AppPhoneNumberForm(
                          name: 'phone_no',
                          label: context.l10n.phoneNumber,
                          enabled: false,
                          required: true,
                          initialValue: ref.read(authNotifierProvider).user?.phone == null
                              ? ref.read(countryCodeProvider)
                              : PhoneNumber.parse(ref.read(authNotifierProvider).user!.phone!),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          onPress: () async {
                            if (_formKey.currentState!.saveAndValidate()) {
                              final name = _formKey.currentState!.value['name'] as String;
                              await ref.read(authNotifierProvider.notifier).updateUserDetails(
                                    name,
                                    _pickedImage,
                                  );
                            }
                          },
                          isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                          label: Text(context.l10n.save),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordDetails extends ConsumerStatefulWidget {
  const PasswordDetails({super.key});

  @override
  ConsumerState<PasswordDetails> createState() => _PasswordDetailsState();
}

class _PasswordDetailsState extends ConsumerState<PasswordDetails> {
  Future<void> _changePassword() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final newPassword = _formKey.currentState!.value['new_password'] as String;
      final confirmPassword = _formKey.currentState!.value['confirm_password'] as String;
      final oldPassword = _formKey.currentState!.value['old_password'] as String;
      final isConfirmAndNewisSame = newPassword == confirmPassword;
      if (!isConfirmAndNewisSame) {
        Alert.showSnackBar(
          AppRouter.l10n.shouldBeSamePassword,
          type: SnackBarType.warning,
        );
        return;
      }
      await ref.read(authNotifierProvider.notifier).updateUserPassword(oldPassword, newPassword);
    }
  }

  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: Container(
        decoration: AppStyles.boxDecoration,
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextForm<String>(
                      name: 'old_password',
                      label: context.l10n.oldPassword,
                      validator: FormBuilderValidators.compose(
                        [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(6),
                        ],
                      ),
                      enableObscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AppTextForm<String>(
                      name: 'new_password',
                      label: context.l10n.newPassword,
                      enableObscureText: true,
                      validator: FormBuilderValidators.compose(
                        [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextForm<String>(
                      name: 'confirm_password',
                      label: context.l10n.confirmPassword,
                      enableObscureText: true,
                      validator: FormBuilderValidators.compose(
                        [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      onPress: _changePassword,
                      label: Text(context.l10n.save),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      smallScreen: Scaffold(
        appBar: CustomAppBar(
          title: Text(context.l10n.changePassword),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextForm<String>(
                  name: 'old_password',
                  label: context.l10n.oldPassword,
                  validator: FormBuilderValidators.compose(
                    [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(6),
                    ],
                  ),
                  enableObscureText: true,
                ),
                const SizedBox(height: 20),
                AppTextForm<String>(
                  name: 'new_password',
                  label: context.l10n.newPassword,
                  enableObscureText: true,
                  validator: FormBuilderValidators.compose(
                    [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(6),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppTextForm<String>(
                  name: 'confirm_password',
                  label: context.l10n.confirmPassword,
                  enableObscureText: true,
                  validator: FormBuilderValidators.compose(
                    [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(6),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  isLoading: ref.watch(authNotifierProvider).status == AuthStatus.loading,
                  onPress: _changePassword,
                  label: Text(context.l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
