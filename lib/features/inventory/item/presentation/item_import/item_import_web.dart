import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextSpan;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemImportScreenWeb extends ConsumerStatefulWidget {
  const ItemImportScreenWeb({super.key});

  @override
  ConsumerState<ItemImportScreenWeb> createState() =>
      _ItemImportScreenWebState();
}

class _ItemImportScreenWebState extends ConsumerState<ItemImportScreenWeb> {
  bool _skipDuplicates = true;
  final Map<int, bool> page = {1: true, 2: false, 3: false};
  String? _selectedFileName;
  late Excel? _selectedExcel;
  List<String> headers = [];
  Map<String, Map<String, Object>>? emptyData;
  final _importFormKey = GlobalKey<FormBuilderState>();
  final requiredColumns = [
    'Item Name',
    'Item Code/Barcode',
    'Purchase Enabled',
    'Sales Enabled',
  ];

  // Define DUXBE field names
  final List<String> duxbeFields = [
    'Item Name',
    'Category',
    'Brand',
    'Item Code/Barcode',
    'Item Quantity (per unit)',
    'Item Unit',
    'Retail Price',
    'Sale Price',
    'Purchase Price',
    'Returnable Item',
    'Sales Enabled',
    'Purchase Enabled',
  ];

  // Map to store initial field mappings: DUXBE field -> Excel header
  Map<String, String> initialFieldMappings = {};
  bool hasAutoMapped = false;

  // Define the _row method
  Widget _row({
    required Widget title,
    required Widget value,
  }) =>
      Row(children: [Expanded(child: title), Expanded(child: value)]);

  // Define the _buildMappedFieldDropdown method
  Widget _buildMappedFieldDropdown(String fieldName, String displayName) {
    return _row(
      title: Text(
        displayName,
        style: AppText.m20.copyWith(color: AppColors.title),
      ),
      value: AppDropDownForm<String>(
        name: fieldName,
        validator: duxbeFields.contains(fieldName)
            ? FormBuilderValidators.required()
            : null,
        label: null,
        items: headers
            .map(
              (e) => DropDownItems(value: e, child: Text(e)),
            )
            .toList(),
        initialValue: initialFieldMappings[fieldName],
      ),
    );
  }

  List<String> _getExcelHeaders(Excel excel) {
    final headers = <String>[];

    // Assuming we want headers from the first sheet
    if (excel.tables.isNotEmpty) {
      final sheet = excel.tables.values.first;

      if (sheet.rows.isNotEmpty) {
        final headerRow = sheet.rows.first;

        for (final cell in headerRow) {
          if (cell?.value != null) {
            switch (cell!.value.runtimeType) {
              case TextCellValue:
                headers.add((cell.value! as TextCellValue).value.text ?? '');
              case IntCellValue:
                headers.add((cell.value! as IntCellValue).value.toString());
              case DoubleCellValue:
                headers.add((cell.value! as DoubleCellValue).value.toString());
              default:
                headers.add(''); // Add empty string for other types or null
            }
          } else {
            headers.add(''); // Add empty string for null cells
          }
        }
      }
    }
    if (!hasNoDuplicates(headers)) {
      Alert.showSnackBar(
        'This file contains Duplicated Headers.',
        type: SnackBarType.error,
      );
      throw Exception('This file contains Duplicated Headers.');
    }
    return headers;
  }

  void _validateExcelDataToBeEntered(Excel excel) {
    final columnsToValidate = [
      'Item Name',
      'Category',
      'Brand',
      'Item Code/Barcode',
      'Item Quantity (per unit)',
      'Item Unit',
      'Retail Price',
      'Sale Price',
      'Purchase Price',
      'Returnable Item',
      'Sales Enabled',
      'Purchase Enabled',
    ];
    final requiredColumns = [
      'Item Name',
      'Item Code/Barcode',
      'Purchase Enabled',
      'Sales Enabled',
    ];
    final sheet = excel.tables.values.first;

    // Create a map of column names to their indices based on the header row
    final headerRow = sheet.rows[0];
    final columnIndices = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i]?.value;
      if (cellValue is TextCellValue) {
        final header = cellValue.value.text!.trim();
        columnIndices[header] = i;
      }
    }

    // Initialize emptyData only for requiredColumns
    emptyData = {
      for (final col in requiredColumns)
        col: {'emptyCount': 0, 'emptyRows': <int>[]},
    };

    // Validate only requiredColumns for row validity
    for (final columnName in requiredColumns) {
      final mappedColumn =
          _importFormKey.currentState!.value[columnName]?.toString();
      if (mappedColumn == null || !columnIndices.containsKey(mappedColumn)) {
        // Column not mapped; skip validation
        continue;
      }
      final columnIndex = columnIndices[mappedColumn]!;

      // Start from rowIndex = 1 (second row, as first is header)
      for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final cellValue = sheet.rows[rowIndex][columnIndex]?.value;
        var isEmpty = false;

        // Validate based on column type
        switch (columnName) {
          case 'Item Name':
          case 'Item Code/Barcode':
            isEmpty = !_isValidString(cellValue);
          case 'Purchase Enabled':
          case 'Sales Enabled':
            isEmpty = !_isValidBoolean(cellValue);
          default:
            // No validation rules for other columns
            break;
        }

        if (isEmpty) {
          emptyData![columnName]!['emptyCount'] =
              (emptyData![columnName]!['emptyCount']! as int) + 1;
          (emptyData![columnName]!['emptyRows']! as List<int>)
              .add(rowIndex + 1);
        }
      }
    }

    // Validate optional columns but do not mark rows as invalid based on them
    for (final columnName in columnsToValidate) {
      if (requiredColumns.contains(columnName)) continue; // Already validated

      final mappedColumn =
          _importFormKey.currentState!.value[columnName]?.toString();
      if (mappedColumn == null || !columnIndices.containsKey(mappedColumn)) {
        // Column not mapped; skip validation
        continue;
      }
      final columnIndex = columnIndices[mappedColumn]!;

      for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final cellValue = sheet.rows[rowIndex][columnIndex]?.value;
        var isEmpty = false;

        // Validate based on column type
        switch (columnName) {
          case 'Category':
          case 'Brand':
          case 'Item Unit':
            isEmpty = cellValue == null || !_isValidString(cellValue);
          case 'Item Quantity (per unit)':
          case 'Retail Price':
          case 'Sale Price':
          case 'Purchase Price':
            isEmpty = cellValue == null || !_isValidNumber(cellValue);
          case 'Returnable Item':
            isEmpty = cellValue == null || !_isValidBoolean(cellValue);
          default:
            // No validation rules for other columns
            break;
        }

        // Optional columns do not affect row validity
        // Optionally, log if needed
        if (isEmpty) {
          log(
            "Info: Row ${rowIndex + 1} has empty or invalid '$columnName' cell.",
          );
        }
      }
    }

    // Print warnings for required columns
    emptyData!.forEach((columnName, data) {
      final emptyCount = data['emptyCount']! as int;
      final emptyRows = data['emptyRows']! as List<int>;
      if (emptyCount > 0) {
        log(
          "Warning: Found $emptyCount empty or invalid '$columnName' cells.",
        );
        log("Affected rows: ${emptyRows.join(', ')}");
      }
    });
  }

  Future<void> downloadTemplate(String url) async {
    final exportUri = Uri.parse(url);

    if (!await launchUrl(exportUri, mode: LaunchMode.externalApplication)) {
      // ignore: only_throw_errors
      throw 'Could not launch $url';
    }
  }

  List<Map<String, dynamic>> _getValidRows(Excel excel) {
    final sheet = excel.tables.values.first;

    final columnsToValidate = [
      'Item Name',
      'Category',
      'Brand',
      'Item Quantity (per unit)',
      'Item Unit',
      'Item Code/Barcode',
      'Sale Price',
      'Retail Price',
      'Purchase Price',
    ];
    final requiredColumns = ['Item Name', 'Item Code/Barcode', 'Sale Price'];

    // Retrieve all empty row indices where all required columns are empty
    final invalidIndices = getAllEmptyRowIndices(emptyData!, requiredColumns);
    final validRows = <Map<String, dynamic>>[];

    // Create a map of column names to their indices based on the header row
    final headerRow = sheet.rows[0];
    final columnIndices = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i]?.value;
      if (cellValue is TextCellValue) {
        final header = cellValue.value.text!.trim();
        columnIndices[header] = i;
      }
    }

    // Iterate through each data row in the sheet
    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final rowNumber = rowIndex + 1; // Excel rows are 1-based
      final rowData = <String, dynamic>{};

      for (final columnName in columnsToValidate) {
        final mapped =
            _importFormKey.currentState!.value[columnName]?.toString().trim();
        final mappedColumn = columnIndices[mapped];

        if (mappedColumn != null &&
            mappedColumn < sheet.rows[rowIndex].length) {
          final cellValue = sheet.rows[rowIndex][mappedColumn]?.value;
          rowData[columnName] = _getCellValue(cellValue);
        }
      }

      // Add the row to validRows only if it's not in invalidIndices
      if (!invalidIndices.contains(rowNumber)) {
        validRows.add(rowData);
      }
    }

    return validRows;
  }

  // Helper function to get the appropriate value from a cell
  dynamic _getCellValue(dynamic cellValue) {
    if (cellValue is TextCellValue) {
      if (cellValue.value is String) {
        log('Extracted String: ${cellValue.value}');
        return cellValue.value;
      } else {
        final text = cellValue.value.toString();
        log('Extracted TextSpan as String: $text');
        return text;
      }
    } else if (cellValue is IntCellValue) {
      log('Extracted Int: ${cellValue.value}');
      return cellValue.value;
    } else if (cellValue is DoubleCellValue) {
      log('Extracted Double: ${cellValue.value}');
      return cellValue.value;
    }
    log('Extracted null or unknown type');
    return null;
  }

  List<int> getAllEmptyRowIndices(Map<String, Map<String, dynamic>> emptyData,
    List<String> requiredColumns,
  ) {
    final rowEmptyCounts = <int, int>{};

    // Count how many required columns are empty per row
    emptyData.forEach((columnName, data) {
      if (!requiredColumns.contains(columnName)) return;

      final emptyRows = data['emptyRows'] as List<int>;
      for (final row in emptyRows) {
        rowEmptyCounts[row] = (rowEmptyCounts[row] ?? 0) + 1;
      }
    });

    // Rows where emptyCount == requiredColumns.length (all required columns are empty)
    final allEmptyRowIndices = rowEmptyCounts.entries
        .where((entry) => entry.value == requiredColumns.length)
        .map((entry) => entry.key)
        .toList()
      ..sort();

    return allEmptyRowIndices;
  }

  // Helper function to convert Excel column letter to index
  int letterToIndex(String letter) {
    return letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
  }

  // Helper function to check if a value is a valid string
  bool _isValidString(dynamic value) {
    return value is TextCellValue && value.value.text!.trim().isNotEmpty;
  }

  // Helper function to check if a value is a valid number
  bool _isValidNumber(dynamic value) {
    if (value is IntCellValue) {
      return !value.value.isNaN;
    }
    if (value is DoubleCellValue) {
      return !value.value.isNaN;
    } else if (value is TextCellValue) {
      return double.tryParse(value.value.text!) != null;
    }
    return false;
  }

  // Helper function to check if a value is a valid boolean
  bool _isValidBoolean(dynamic value) {
    if (value is TextCellValue) {
      final text = value.value.text!.toLowerCase().trim();
      return text == 'true' || text == 'false';
    }
    return false;
  }

  bool hasNoDuplicates(List<String> list) {
    return list.length == list.toSet().toList().length;
  }

  void handlePageSwitch() {
    if (page[1]!) {
      if (_selectedFileName == null) {
        Alert.showSnackBar(
          'Select a file to import items',
          type: SnackBarType.warning,
        );
        return;
      }
      page[1] = false;
      page[2] = true;
    } else if (page[2]!) {
      if (!_importFormKey.currentState!.saveAndValidate()) {
        Alert.showSnackBar(
          'Please fill the mandatory fields',
          type: SnackBarType.warning,
        );
        return;
      }

      _validateExcelDataToBeEntered(_selectedExcel!);
      page[2] = false;
      page[3] = true;
    } else {
      final validRows = _getValidRows(_selectedExcel!);
      ref
          .read(bulkItemImportNotifierProvider.notifier)
          .createBulkItem(validRows, skipDuplicates: _skipDuplicates);
      context.goNamed(AppRouter.itemList);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _importFormKey,
      child: Column(
        children: [
          Text(
            context.l10n.importItemGoodsSelectFile,
            style: AppText.sb24.copyWith(color: AppColors.primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperHeader(
                isSelected: page[1]!,
                number: '1',
                title: context.l10n.configure,
                isDone: page[2]! || page[3]!,
              ),
              const SizedBox(width: 80),
              _StepperHeader(
                isSelected: page[2]!,
                number: '2',
                title: context.l10n.mapFields,
                isDone: page[3]!,
              ),
              const SizedBox(width: 80),
              _StepperHeader(
                isSelected: page[3]!,
                number: '3',
                title: context.l10n.preview,
              ),
            ],
          ),
          if (page[1]!)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: AppStyles.boxDecoration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          DropRegion(
                            // Formats this region can accept.
                            formats: Formats.standardFormats,
                            hitTestBehavior: HitTestBehavior.opaque,
                            onDropOver: (event) {
                              final item = event.session.items.first;
                              if (item.localData is Map) {
                                // Drag within the app with custom local data
                              }
                              if (item.canProvide(Formats.plainText)) {
                                // Item contains plain text
                              }
                              if (event.session.allowedOperations
                                  .contains(DropOperation.copy)) {
                                return DropOperation.copy;
                              } else {
                                return DropOperation.none;
                              }
                            },
                            onDropEnter: (event) {
                              // Display visual indicator for accepted drag
                            },
                            onDropLeave: (event) {
                              // Remove visual indicators
                            },
                            onPerformDrop: (event) async {
                              final item = event.session.items.first;
                              final reader = item.dataReader!;

                              if (reader.canProvide(Formats.xlsx)) {
                                reader.getFile(
                                  Formats.xlsx,
                                  (file) async {
                                    _selectedFileName =
                                        file.fileName ?? 'Unknown';
                                    _selectedExcel =
                                        Excel.decodeBytes(await file.readAll());
                                    headers = _getExcelHeaders(_selectedExcel!);

                                    // Initialize auto-mappings
                                    for (final field in duxbeFields) {
                                      if (headers.contains(field)) {
                                        initialFieldMappings[field] = field;
                                      }
                                    }

                                    hasAutoMapped = true; // Prevent re-mapping
                                    setState(() {});
                                  },
                                  onError: (error) {
                                    log('Error reading value $error');
                                  },
                                );
                              }
                            },
                            child: InkWell(
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
                                    if (_selectedFileName == null) ...[
                                      Assets.icons.cloud.image(),
                                      const SizedBox(height: 28),
                                      Text(
                                        context.l10n.dragAndDropFileToImport,
                                        style: AppText.n20.copyWith(
                                          color: AppColors.stormyBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        context.l10n.maximumFileSize25MbFileFormatXls,
                                        style: AppText.n20.copyWith(
                                          color: AppColors.title,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      AppButton(
                                        onPress: () async {
                                          try {
                                            final result = await FilePicker
                                                .platform
                                                .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['xlsx'],
                                            );

                                            if (result != null) {
                                              if (kIsWeb) {
                                                final fileBytes =
                                                    result.files.first.bytes;
                                                _selectedFileName =
                                                    result.files.first.name;
                                                _selectedExcel =
                                                    Excel.decodeBytes(
                                                  fileBytes!,
                                                );
                                              } else {
                                                final file = File(
                                                  result.files.single.path!,
                                                );
                                                _selectedFileName =
                                                    file.uri.pathSegments.last;
                                                _selectedExcel =
                                                    Excel.decodeBytes(
                                                  await file.readAsBytes(),
                                                );
                                              }

                                              headers = _getExcelHeaders(
                                                _selectedExcel!,
                                              );

                                              // Initialize auto-mappings
                                              for (final field in duxbeFields) {
                                                if (headers.contains(field)) {
                                                  initialFieldMappings[field] =
                                                      field;
                                                }
                                              }

                                              hasAutoMapped =
                                                  true; // Prevent re-mapping
                                              setState(() {});
                                            } else {
                                              // User canceled the picker
                                            }
                                          } on Exception catch (e) {
                                            Alert.showSnackBar(e.toString());
                                          }
                                        },
                                        label: Text(context.l10n.chooseFile),
                                        color: AppColors.primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 24,
                                        ),
                                      ),
                                    ] else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _selectedFileName!,
                                            style: AppText.n20.copyWith(
                                              color: AppColors.stormyBlue,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _selectedFileName = null;
                                                _selectedExcel = null;
                                                headers = [];
                                                initialFieldMappings.clear();
                                                hasAutoMapped = false;
                                              });
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            context.l10n.downloadASampleFileAndCompareItToYourImportFileToEnsureYouHaveTheFilePerfectForTheImport,
                            style: AppText.n20.copyWith(
                              color: AppColors.title,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: AppButton(
                              width: 100,
                              onPress: () async {
                                const templateUrl =
                                    'https://docs.google.com/spreadsheets/d/1GCcvvc3iIl7v8B7764aiCig4jIofl50qKl0_XdyY0co/edit?usp=sharing'; // Replace with actual URL
                                await downloadTemplate(templateUrl);
                              },
                              label: Text(context.l10n.downloadSampleFile),
                              color: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      decoration: AppStyles.boxDecoration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.duplicateHandling,
                            style: AppText.sb20.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          RadioListTile(
                            value: true,
                            groupValue: _skipDuplicates,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _skipDuplicates = value;
                                });
                              }
                            },
                            title: Text(
                              context.l10n.skipDuplicates,
                              style: AppText.m20,
                            ),
                            subtitle: Text(
                              context.l10n
                                  .retainsTheItemsAndDoesNotImportTheDuplicatesInTheImportFile,
                              style: AppText.mediumN
                                  .copyWith(color: AppColors.black),
                            ),
                          ),
                          RadioListTile(
                            value: false,
                            groupValue: _skipDuplicates,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _skipDuplicates = value;
                                });
                              }
                            },
                            title: Text(
                              context.l10n.overwriteItems,
                              style: AppText.m20,
                            ),
                            subtitle: Text(
                              context.l10n
                                  .importsTheDuplicatesInTheImportFileAndOverwritesTheExistingItems,
                              style: AppText.mediumN
                                  .copyWith(color: AppColors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (page[2]!)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: AppStyles.boxDecoration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${context.l10n.yourSelectedFile} ${_selectedFileName ?? ''}',
                            style: AppText.m20.copyWith(color: AppColors.black),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            context.l10n
                                .theBestMatchToEachFieldOnTheSelectedFileHaveBeenAutoSelected,
                            style: AppText.m20.copyWith(
                              color: AppColors.brandViolet,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _row(
                            title: Text(
                              context.l10n.duxbeField,
                              style: AppText.m20
                                  .copyWith(color: AppColors.stormyBlue),
                            ),
                            value: Text(
                              context.l10n.importedFileHeaders,
                              style: AppText.m20
                                  .copyWith(color: AppColors.stormyBlue),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.l10n.itemDetails,
                            style: AppText.sb24
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 20),

                          // Using the helper method to build mapped dropdowns
                          _buildMappedFieldDropdown(
                            context.l10n.itemName,
                            context.l10n.itemName,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.category,
                            context.l10n.category,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.brand,
                            context.l10n.brand,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.itemCodeBarcode,
                            context.l10n.itemCodeBarcode,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.l10n.quantity,
                            style: AppText.sb24
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.itemQuantityPerUnit,
                            context.l10n.itemQuantityPerUnit,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.itemUnit,
                            context.l10n.itemUnit,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.l10n.priceDetails,
                            style: AppText.sb24
                                .copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.retailPrice,
                            context.l10n.retailPrice,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.salePrice,
                            context.l10n.salePrice,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.purchasePrice,
                            context.l10n.purchasePrice,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.returnableItem,
                            context.l10n.returnableItem,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.salesEnabled,
                            context.l10n.salesEnabled,
                          ),
                          const SizedBox(height: 20),
                          _buildMappedFieldDropdown(
                            context.l10n.purchaseEnabled,
                            context.l10n.purchaseEnabled,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (page[3]!)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 18),
                      Text(
                        '${(_selectedExcel?.tables.values.first.rows.first.length ?? 0) - getAllEmptyRowIndices(emptyData!, requiredColumns).length} of ${_selectedExcel?.tables.values.first.rows.first.length ?? 0} items in your file are ready to be imported',
                        style:
                            AppText.m20.copyWith(color: AppColors.brandViolet),
                      ),
                      const SizedBox(height: 18),
                      ExpansionTile(
                        title: Text(
                          '${context.l10n.itemsThatAreReadyToBeImported} ${(_selectedExcel?.tables.values.first.rows.first.length ?? 0) - getAllEmptyRowIndices(emptyData!, requiredColumns).length}',
                          style: AppText.m20.copyWith(color: AppColors.title),
                        ),
                      ),
                      ExpansionTile(
                        title: Text(
                          '${context.l10n.noOfRecordsSkipped} ${getAllEmptyRowIndices(emptyData!, requiredColumns).length}',
                          style: AppText.m20.copyWith(color: AppColors.title),
                        ),
                        expandedAlignment: Alignment.centerLeft,
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...emptyData!.entries.where((e) {
                            final emptyCount = e.value['emptyCount']! as int;
                            return emptyCount > 0;
                          }).map((e) {
                            final emptyCount = e.value['emptyCount']! as int;
                            return Text(
                              '\u2022 ${e.key}   $emptyCount ${context.l10n.noOfRowsHaveInvalidValues}',
                              style: AppText.m20.copyWith(
                                color: AppColors.title,
                                height: 1.5,
                              ),
                            );
                          }),
                        ],
                      ),
                      ExpansionTile(
                        title: Text(
                          '${context.l10n.unmappedFields} ${_importFormKey.currentState?.value.entries.where((value) => value.value == null).length ?? 0}',
                          style: AppText.m20.copyWith(color: AppColors.title),
                        ),
                        expandedAlignment: Alignment.centerLeft,
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n
                                .theFollowingFieldsInYourImportFileHaveNotBeenMappedToAnyFieldTheDataInTheseFieldsWillBeIgnoredDuringTheImport,
                            style: AppText.m20
                                .copyWith(color: AppColors.stormyBlue),
                          ),
                          ..._importFormKey.currentState?.value.entries
                                  .where((value) => value.value == null)
                                  .map(
                                    (e) => Text(
                                      '\u2022 ${e.key}',
                                      style: AppText.m20.copyWith(
                                        color: AppColors.title,
                                        height: 1.5,
                                      ),
                                    ),
                                  ) ??
                              [],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                onPress: () {
                  if (page[1]!) {
                    context.pop();
                  } else if (page[2]!) {
                    page[1] = true;
                    page[2] = false;
                  } else if (page[3]!) {
                    page[2] = true;
                    page[3] = false;
                  }
                  setState(() {});
                },
                style: ButtonStyles.secondary,
                label: Text(
                  page[1]! ? context.l10n.cancel : context.l10n.previous,
                ),
              ),
              const SizedBox(width: 14),
              AppButton(
                isLoading: ref.watch(bulkItemImportNotifierProvider).maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 60,
                ),
                onPress: handlePageSwitch,
                label: Text(context.l10n.next),
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  const _StepperHeader({
    required this.number,
    required this.title,
    required this.isSelected,
    this.isDone = false,
  });
  final String number;
  final String title;
  final bool isSelected;
  final bool isDone;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: isDone
              ? AppColors.green
              : isSelected
                  ? AppColors.brandViolet
                  : const Color(0xffF7F6FF),
          radius: 26,
          child: isDone
              ? const Icon(Icons.check, color: AppColors.white, size: 30)
              : Text(
                  number,
                  style: AppText.n20.copyWith(
                    color:
                        isSelected ? AppColors.white : AppColors.primaryColor,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: AppText.m20.copyWith(
            color: isSelected ? AppColors.primaryColor : AppColors.stormyBlue,
          ),
        ),
      ],
    );
  }
}
