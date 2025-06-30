import 'package:duxbe/env.dart';
import 'package:duxbe/features/auth/auth.dart';
import 'package:duxbe/features/inventory/inventory.dart';
import 'package:duxbe/features/invoice/invoice.dart';
import 'package:duxbe/features/invoice/presentation/widgets/invoice_details_card.dart';
import 'package:duxbe/features/purchase/purchase.dart';
import 'package:duxbe/features/reservations/reservations.dart' as rs show Table;
import 'package:duxbe/features/sale/sale.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:flutter/services.dart';
import 'package:hancod_theme/hancod_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

enum PrintFormats {
  a4,
  roll80,
  roll57,
}

class PdfService {
  static const double inch = PdfPageFormat.inch;
  static const double mm = PdfPageFormat.mm;

  // Hancod UI Colors (matched with InvoiceDetailsCard)
  static final PdfColor _hancodPrimaryColor = PdfColor.fromHex('#0A003D'); // Example: Bootstrap Primary Blue
  static const PdfColor _hancodStormyBlue = PdfColor.fromInt(0xFF5A6B80); // Example: Cool Gray
  static const PdfColor _hancodColorE0E0E0 = PdfColor.fromInt(0xFFE0E0E0); // Example: Light Gray (for borders)
  static const PdfColor _hancodColorF5F5F5 = PdfColor.fromInt(
    0xFFF5F5F5,
  ); // Example: Very Light Gray (for table headers, backgrounds)
  static const PdfColor _hancodColorF9F9F9 = PdfColor.fromInt(
    0xFFF9F9F9,
  ); // Example: Off White (for section backgrounds)
  static const PdfColor _hancodBlack = PdfColor.fromInt(0xFF000000);

  // Hancod Text Style Helpers (to be matched with InvoiceDetailsCard)
  // Note: Font sizes are examples and should be adjusted for pixel-perfect matching.

  static TextStyle _appTextHeading4(
    Font boldFont, {
    PdfColor color = _hancodBlack,
  }) {
    return TextStyle(
      font: boldFont,
      fontSize: 22,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle _appTextHeading2(
    Font boldFont, {
    PdfColor color = _hancodBlack,
  }) {
    return TextStyle(
      font: boldFont,
      fontSize: 34,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle _appTextHeading5(
    Font boldFont, {
    PdfColor color = _hancodBlack,
  }) {
    return TextStyle(
      font: boldFont,
      fontSize: 20,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle _appTextMediumB(
    Font boldFont, {
    double fontSize = 14,
    PdfColor color = _hancodBlack,
  }) {
    return TextStyle(
      font: boldFont,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle _appTextMediumSB(
    Font semiBoldFont, {
    double fontSize = 13,
    PdfColor color = _hancodBlack,
    Font? boldFontForOverride,
  }) {
    // Default fontSize 13 for date values, customer name
    return TextStyle(
      font: boldFontForOverride ?? semiBoldFont,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle _appTextSmallN(
    Font regularFont, {
    double fontSize = 9,
    PdfColor color = _hancodStormyBlue,
  }) {
    // Matched to UI: address, date labels
    return TextStyle(font: regularFont, fontSize: fontSize, color: color);
  }

  static TextStyle _appTextSmallM(
    Font regularFont, {
    double fontSize = 10,
    PdfColor color = _hancodBlack,
    Font? semiBoldFont,
  }) {
    // Matched to UI: 'Bill To', table cell text
    return TextStyle(
      font: semiBoldFont ?? regularFont,
      fontSize: fontSize,
      color: color,
      fontWeight: semiBoldFont != null ? FontWeight.bold : FontWeight.normal,
    );
  }

  static TextStyle _appTextSmallB(
    Font boldFont, {
    double fontSize = 9,
    PdfColor color = _hancodBlack,
  }) {
    // Matched to UI: GSTIN, bold totals
    return TextStyle(
      font: boldFont,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle _appTextXSmallM(
    Font regularFont, {
    double fontSize = 8,
    PdfColor color = _hancodStormyBlue,
    Font? semiBoldFont,
  }) {
    // Matched to UI: table headers
    return TextStyle(
      font: semiBoldFont ?? regularFont,
      fontSize: fontSize,
      color: color,
      fontWeight: semiBoldFont != null ? FontWeight.bold : FontWeight.normal,
    );
  }

  static TextStyle _appTextXLargeSB(
    Font regularFont, {
    double fontSize = 18,
    PdfColor color = _hancodStormyBlue,
    Font? semiBoldFont,
  }) {
    // Matched to UI: table headers
    return TextStyle(
      font: semiBoldFont ?? regularFont,
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  // Helper for table cell padding
  static Widget _tableCellPadding(Widget child, {EdgeInsets? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: child,
    );
  }

  static Widget _dataRow({required Widget label, required Widget value}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: label,
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              value,
            ],
          ),
        ),
      ],
    );
  }

  // Helper for total rows, similar to InvoiceDetailsCard structure
  static Widget _buildTotalRow({
    required String label,
    required String value,
    required Font regularFont,
    required Font boldFont,
    bool isLabelBold = false,
    bool isValueBold = false,
    PdfColor labelColor = _hancodStormyBlue,
    PdfColor valueColor = _hancodBlack,
    TextStyle? labelStyle, // Allow overriding full style
    TextStyle? valueStyle, // Allow overriding full style
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2.5,
      ), // Reduced padding to match UI better
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ??
                (isLabelBold
                    ? _appTextSmallB(boldFont, color: labelColor, fontSize: 10)
                    : _appTextSmallN(
                        regularFont,
                        color: labelColor,
                        fontSize: 10,
                      )),
          ),
          Text(
            value,
            style: valueStyle ??
                (isValueBold
                    ? _appTextSmallB(boldFont, color: valueColor, fontSize: 10)
                    : _appTextSmallM(
                        regularFont,
                        color: valueColor,
                        semiBoldFont: boldFont,
                      )), // Use boldFont for semiBoldFont parameter if M implies slightly bolder
          ),
        ],
      ),
    );
  }

  // static Future<void> printTableBarcode(rs.Table table) async {
  //   final img = await rootBundle.loadString(Assets.icons.invoiceLogo.path);
  //   final pdf = Document()
  //     ..addPage(
  //       Page(
  //         pageFormat: const PdfPageFormat(200, 200, marginAll: 4),
  //         build: (context) {
  //           return Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               SizedBox(
  //                 height: 140,
  //                 child: BarcodeWidget(
  //                   color: PdfColor.fromHex('#000000'),
  //                   barcode: Barcode.qrCode(),
  //                   data: 'https://dubxe-admin-development.vercel.app/${table.businessId}?table_id=${table.tableId!}',
  //                 ),
  //               ),
  //               SizedBox(height: 6),
  //               Container(
  //                 decoration: BoxDecoration(color: PdfColor.fromHex('#0A003D')),
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 4,
  //                   vertical: 4,
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text('Powered by', style: TextStyle(color: PdfColor.fromHex('#ffffff'))),
  //                     SizedBox(width: 4),
  //                     SvgImage(svg: img, width: 30),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           AppRouter.l10n.duxbe.toUpperCase(),
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: PdfColor.fromHex('#ffffff'),
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ); // Page
  //   await _downloadPdf(pdf, print: true);
  // }

  static Future<void> printTableBarcode(rs.Table table, {required IEnvironment environment}) async {
    final barcode = environment is ProductionEnv
        ? 'https://business.duxbe.com/${table.businessId}?table_id=${table.tableId!}'
        : 'https://dubxe-admin-development.vercel.app/${table.businessId}?table_id=${table.tableId!}';
    // 1. Load all necessary assets
    final duxbeLogoSvg = await rootBundle.loadString(Assets.icons.invoiceLogo.path);
    // Make sure 'Assets.icons.tableBarcodBg.path' points to your new SVG background
    final bgSvg = await rootBundle.loadString(Assets.icons.tableBarcodBg.path);
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final regularFontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final regularTtf = Font.ttf(regularFontData.buffer.asByteData());

    final pdf = Document()
      ..addPage(
        Page(
          // Use a square format, with no margins as the background SVG handles the canvas.
          pageFormat: const PdfPageFormat(255, 255, marginAll: 0),
          build: (context) {
            // A Stack allows us to layer widgets on top of each other.
            return Stack(
              alignment: Alignment.center,
              children: [
                // Layer 1: The background SVG, covering the whole page.
                SvgImage(
                  svg: bgSvg,
                  fit: BoxFit.cover,
                ),

                // Layer 2: The "T02" bubble, positioned from the top.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    child: Container(
                      width: 60,
                      height: 30,
                      padding: const EdgeInsets.only(
                        bottom: 38,
                      ),
                      decoration: BoxDecoration(
                        color: _hancodPrimaryColor, // Dark blue background
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ), // Rounded rectangle
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          textAlign: TextAlign.center,
                          table.name.toUpperCase(),
                          style: TextStyle(
                            font: boldTtf,
                            fontSize: 18,
                            color: PdfColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 3: The QR Code, centered on the page.
                // Using Center widget for robust positioning.
                Positioned(
                  top: 40,
                  child: Container(
                    width: 155,
                    height: 155,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PdfColors.white, // White background for the QR code
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data: barcode,
                    ),
                  ),
                ),

                // Layer 4: The "Powered by" footer, positioned from the bottom.
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 2),
                      Text(
                        'Powered by',
                        style: TextStyle(
                          font: regularTtf,
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgImage(
                            svg: duxbeLogoSvg,
                            // height: 20,
                            width: 30,
                            // fit:BoxFit.fill
                          ),
                          SizedBox(width: 1),
                          Text(
                            'Duxbe',
                            style: TextStyle(
                              font: boldTtf,
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    await _downloadPdf(pdf, print: true);
  }

  static Future<void> _downloadPdf(Document pdf, {bool print = false}) async {
    try {
      final business = AppRouter.read(businessNotifierProvider)!;
      final format = business.format ?? PrintFormats.roll57;
      await IPdfPlatform().savePdf(
        pdf,
        print: print,
        format: format,
      );
    } catch (e) {
      Alert.showSnackBar(e.toString(), type: SnackBarType.error);
    }
  }

  static Future<void> printSaleInvoice(SaleView sale) async {
    final business = AppRouter.read(businessNotifierProvider)!;
    final format = business.format ?? PrintFormats.roll57;
    final currency = business.currency?.code ?? r'$';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());
    final img = await rootBundle.loadString(Assets.icons.invoiceLogo.path);
    const cellPadding = EdgeInsets.all(2);
    final cellStyle = TextStyle(fontSize: 6, font: ttf);

    //Load the Arabicfonts------

    final arabicFontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final arabicTtf = Font.ttf(arabicFontData.buffer.asByteData());

    // Load business logo for A4 format
    ImageProvider? logoBytes;
    if (business.logo != null) {
      try {
        logoBytes = await networkImage(business.logo!);
      } catch (e) {
        Alert.showSnackBar('Error loading logo: $e', type: SnackBarType.error);
        // Handle network image loading error silently
      }
    }

    final pdf = Document(
      theme: ThemeData(
        defaultTextStyle: TextStyle(fontSize: format == PrintFormats.a4 ? 10 : 6, font: ttf),
      ),
    );
    final isArabic = AppRouter.l10n.localeName == 'ar';
    if (format == PrintFormats.a4) {
      // A4 Format Layout with MultiPage
      pdf.addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(40),
          header: (Context context) {
            // Only show header on first page
            if (context.pageNumber == 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with Logo and Company Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (logoBytes != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image(
                                logoBytes,
                                height: 50,
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SvgImage(svg: img, width: 50, height: 60),
                            ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontBold: boldTtf,
                                ),
                              ),
                              Text(business.contactAddress ?? ''),
                              Text(business.contactEmail ?? ''),
                              Text(business.contactPhone ?? ''),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      // Right side - Address
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(business.state ?? ''),
                          Text(business.country ?? ''),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  // Invoice Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Invoice Number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppRouter.l10n.invoiceNumber,
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            sale.saleInvoice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Right side - Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${AppRouter.l10n.invoice} (in $currency)',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            '$currency ${sale.totalAmount}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Customer Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppRouter.l10n.customerName),
                          Text(
                            sale.customer?.name ?? AppRouter.l10n.walkInCustomer,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppRouter.l10n.invoiceDate),
                          Text(
                            sale.saleDate.toLocal().toPdfFullFormat,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
            // Return null for subsequent pages
            return SizedBox();
          },
          footer: (Context context) {
            // Only show footer on the last page
            if (context.pageNumber == context.pagesCount) {
              return Column(
                children: [
                  SizedBox(height: 20),
                  // Summary
                  Row(
                    children: [
                      Spacer(),
                      Container(
                        width: 200,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppRouter.l10n.subTotal),
                                Text('$currency ${sale.subTotal}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppRouter.l10n.discount),
                                Text('$currency ${sale.discountAmount}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppRouter.l10n.tax10),
                                Text('$currency ${sale.taxAmount}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppRouter.l10n.total,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontBold: boldTtf,
                                  ),
                                ),
                                Text(
                                  '$currency ${sale.totalAmount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontBold: boldTtf,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Thank you message and powered by
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppRouter.l10n.thankYouVisitAgain,
                            style: const TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                          SizedBox(width: 10),
                          //   Center(child: SvgImage(svg: smileyIconSvg)),
                        ],
                      ),
                      Text(
                        AppRouter.l10n.poweredByDuxbe,
                        style: const TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            // Return null for non-last pages
            return SizedBox();
          },
          build: (Context context) {
            return [
              // Items Table
              Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(width: 0.5, color: PdfColors.grey300),
                  bottom: BorderSide(width: 0.5, color: PdfColors.grey300),
                ),
                columnWidths: {
                  0: const FlexColumnWidth(3),
                  1: const FlexColumnWidth(),
                  2: const FlexColumnWidth(),
                  3: const FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: PdfColor.fromHex('#F8F9FA'),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.itemDetails.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.price.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.qty.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.amount.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...sale.saleItems.map(
                    (item) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontBold: boldTtf,
                                ),
                              ),
                              if (item.item.unit != null)
                                Text(
                                  item.item.unit!.name,
                                  style: const TextStyle(
                                    color: PdfColors.grey700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('$currency ${item.unitPrice}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(item.quantity.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('$currency ${item.totalPrice}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );
    } else {
      // Thermal Receipt Format Layout
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat(
            format == PrintFormats.roll57 ? 48.5 * mm : 71.5 * mm,
            double.infinity,
            marginAll: 8,
          ),
          margin: const EdgeInsets.all(8),
          build: (Context context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (logoBytes != null)
                      Image(
                        logoBytes,
                        height: 64,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(color: PdfColor.fromHex('#0A003D')),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgImage(svg: img, width: 30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppRouter.l10n.duxbe.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: PdfColor.fromHex('#ffffff'),
                                    fontWeight: FontWeight.bold,
                                    fontBold: semiBoldTtf,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              sale.saleInvoice,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontBold: boldTtf,
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                style: const BorderStyle(pattern: [4]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      left: 0,
                      top: -7,
                      child: Center(
                        child: Container(
                          width: 64,
                          decoration: const BoxDecoration(color: PdfColors.white),
                          child: Text(
                            AppRouter.l10n.invoiceNo,
                            textAlign: TextAlign.center,
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  sale.saleDate.toLocal().toPdfFullFormat,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.customerName),
                    Text(sale.customer?.name ?? AppRouter.l10n.walkInCustomer),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8),
                Table(
                  border: const TableBorder(),
                  columnWidths: {
                    0: const FlexColumnWidth(),
                    1: const IntrinsicColumnWidth(),
                    2: const IntrinsicColumnWidth(),
                    3: const IntrinsicColumnWidth(),
                  },
                  children: [
                    // Header row
                    TableRow(
                      children: [
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.itemName,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.price,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.qty,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.amount,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Order items and addons
                    ...sale.saleItems.expand(
                      (item) => [
                        // Item row
                        TableRow(
                          children: [
                            Padding(
                              padding: cellPadding,
                              child: Text(
                                item.item.name,
                                style: cellStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: cellPadding,
                              child: Text(
                                item.unitPrice.toString(),
                                style: cellStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: cellPadding,
                              child: Text(
                                item.quantity.toString(),
                                style: cellStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: cellPadding,
                              child: Text(
                                currency + item.totalPrice.toStringAsFixed(2),
                                style: cellStyle,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        // Addon rows
                        ...item.subServices.map(
                          (addon) => TableRow(
                            children: [
                              Padding(
                                padding: cellPadding,
                                child: Text(
                                  ' • ${addon.subServiceId}',
                                  style: cellStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: cellPadding,
                                child: Text(
                                  addon.additionalPrice.toString(),
                                  style: cellStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: cellPadding,
                                child: Text(
                                  addon.quantity.toString(),
                                  style: cellStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: cellPadding,
                                child: Text(
                                  currency + addon.totalAdditionalPrice.toStringAsFixed(2),
                                  style: cellStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.subTotal),
                    Text(currency + sale.subTotal.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.discount),
                    Text(currency + sale.discountAmount.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.shipping),
                    Text(currency + sale.shippingCharge.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.tax),
                    Text(currency + sale.taxAmount.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.total),
                    Text(currency + sale.totalAmount.toString()),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8),
                Text(
                  AppRouter.l10n.thankYouVisitAgain,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Center(
                  child: SvgImage(
                    svg: '''
                  <svg width="16" height="16" viewBox="0 0 29 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <g clip-path="url(#clip0_4392_4115)">
                      <path d="M14.5 0C22.5084 0 29 6.49165 29 14.5C29 22.5084 22.5084 29 14.5 29C6.49165 29 0 22.5084 0 14.5C0 6.49165 6.49165 0 14.5 0ZM14.5 2.02275C11.1908 2.02275 8.01719 3.33731 5.67725 5.67725C3.33731 8.01719 2.02275 11.1908 2.02275 14.5C2.02275 17.8092 3.33731 20.9828 5.67725 23.3227C8.01719 25.6627 11.1908 26.9773 14.5 26.9773C17.8092 26.9773 20.9828 25.6627 23.3227 23.3227C25.6627 20.9828 26.9773 17.8092 26.9773 14.5C26.9773 11.1908 25.6627 8.01719 23.3227 5.67725C20.9828 3.33731 17.8092 2.02275 14.5 2.02275ZM11.2288 17.4C11.3269 18.1964 11.7122 18.9297 12.3124 19.4623C12.9126 19.9949 13.6865 20.2902 14.489 20.2929C15.2914 20.2956 16.0673 20.0054 16.671 19.4768C17.2747 18.9482 17.6649 18.2175 17.7683 17.4218C17.7832 17.2917 17.8237 17.1658 17.8876 17.0515C17.9514 16.9372 18.0373 16.8368 18.1403 16.756C18.2433 16.6751 18.3614 16.6156 18.4876 16.5807C18.6138 16.5459 18.7456 16.5364 18.8755 16.5529C19.0054 16.5694 19.1307 16.6116 19.2442 16.6769C19.3577 16.7422 19.457 16.8294 19.5365 16.9334C19.616 17.0375 19.6741 17.1562 19.7073 17.2829C19.7406 17.4095 19.7483 17.5415 19.7302 17.6712C19.5655 18.9451 18.9415 20.1152 17.9752 20.9617C17.009 21.8082 15.7671 22.273 14.4825 22.2687C13.1979 22.2644 11.9591 21.7914 10.9985 20.9385C10.0379 20.0856 9.42171 18.9114 9.2655 17.6364C9.24744 17.5062 9.25548 17.3738 9.28917 17.2468C9.32285 17.1198 9.3815 17.0008 9.46169 16.8968C9.54187 16.7927 9.64199 16.7057 9.75619 16.6407C9.87039 16.5758 9.99638 16.5343 10.1268 16.5186C10.2572 16.5029 10.3895 16.5133 10.5158 16.5493C10.6422 16.5853 10.7601 16.6461 10.8627 16.7281C10.9653 16.8102 11.0505 16.9119 11.1134 17.0272C11.1762 17.1426 11.2155 17.2693 11.2288 17.4ZM8.4303 9.106C8.96677 9.106 9.48126 9.31911 9.8606 9.69845C10.2399 10.0778 10.4531 10.5923 10.4531 11.1288C10.4531 11.6652 10.2399 12.1797 9.8606 12.5591C9.48126 12.9384 8.96677 13.1515 8.4303 13.1515C7.89383 13.1515 7.37934 12.9384 7 12.5591C6.62066 12.1797 6.40755 11.6652 6.40755 11.1288C6.40755 10.5923 6.62066 10.0778 7 9.69845C7.37934 9.31911 7.89383 9.106 8.4303 9.106ZM20.5697 9.106C21.1062 9.106 21.6207 9.31911 22 9.69845C22.3793 10.0778 22.5925 10.5923 22.5925 11.1288C22.5925 11.6652 22.3793 12.1797 22 12.5591C21.6207 12.9384 21.1062 13.1515 20.5697 13.1515C20.0332 13.1515 19.5187 12.9384 19.1394 12.5591C18.7601 12.1797 18.547 11.6652 18.547 11.1288C18.547 10.5923 18.7601 10.0778 19.1394 9.69845C19.5187 9.31911 20.0332 9.106 20.5697 9.106Z" fill="black"/>
                    </g>
                    <defs>
                      <clipPath id="clip0_4392_4115">
                        <rect width="29" height="29" fill="white"/>
                      </clipPath>
                    </defs>
                  </svg>
              ''',
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await _downloadPdf(pdf, print: true);
  }

  static Future<void> printPurchaseInvoice(PurchaseView purchase) async {
    final business = AppRouter.read(businessNotifierProvider)!;
    final format = business.format ?? PrintFormats.roll57;
    final currency = business.currency?.code ?? r'$';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());
    final img = await rootBundle.loadString(Assets.icons.invoiceLogo.path);
    const cellPadding = EdgeInsets.all(2);
    final cellStyle = TextStyle(fontSize: 6, font: ttf);

    //Load the Arabicfonts------
    // final arabicFontData =
    //     await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    // final arabicTtf = Font.ttf(arabicFontData.buffer.asByteData());

    // Load business logo
    ImageProvider? logoBytes;
    if (business.logo != null) {
      try {
        logoBytes = await networkImage(business.logo!);
      } catch (e) {
        Alert.showSnackBar('Error loading logo: $e', type: SnackBarType.error);
        // Handle network image loading error silently
      }
    }

    final pdf = Document(
      theme: ThemeData(
        defaultTextStyle: TextStyle(fontSize: format == PrintFormats.a4 ? 10 : 6, font: ttf),
      ),
    );
    // final isArabic = AppRouter.l10n.localeName == 'ar';

    if (format == PrintFormats.a4) {
      // A4 Format Layout with MultiPage
      pdf.addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(40),
          header: (Context context) {
            // Only show header on first page
            if (context.pageNumber == 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with Logo and Company Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (logoBytes != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image(
                                logoBytes,
                                height: 50,
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SvgImage(svg: img, width: 50, height: 60),
                            ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontBold: boldTtf,
                                ),
                              ),
                              Text(business.contactAddress ?? ''),
                              Text(business.contactEmail ?? ''),
                              Text(business.contactPhone ?? ''),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      // Right side - Address
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(business.state ?? ''),
                          Text(business.country ?? ''),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  // Invoice Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Invoice Number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppRouter.l10n.invoiceNumber,
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            purchase.purchaseInvoice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Right side - Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${AppRouter.l10n.invoice} (in $currency)',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            '$currency ${purchase.totalAmount}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Supplier Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppRouter.l10n.supplierName),
                          Text(
                            purchase.supplier.name ?? 'Unknown Supplier',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppRouter.l10n.invoiceDate),
                          Text(
                            purchase.purchaseDate.toLocal().toPdfFullFormat,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontBold: boldTtf,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
            // Return null for subsequent pages
            return SizedBox();
          },
          footer: (Context context) {
            // Only show footer on the last page
            if (context.pageNumber == context.pagesCount) {
              return Column(
                children: [
                  SizedBox(height: 20),
                  // Summary
                  Row(
                    children: [
                      Spacer(),
                      Container(
                        width: 200,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppRouter.l10n.subTotal),
                                Text('$currency ${purchase.subTotal}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppRouter.l10n.discount),
                                Text('$currency ${purchase.discountAmount}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppRouter.l10n.tax10,
                                ), // Assuming tax is 10% like in sales
                                Text('$currency ${purchase.taxAmount}'),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppRouter.l10n.total,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontBold: boldTtf,
                                  ),
                                ),
                                Text(
                                  '$currency ${purchase.totalAmount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontBold: boldTtf,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Powered by
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppRouter.l10n.poweredByDuxbe,
                        style: const TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            // Return null for non-last pages
            return SizedBox();
          },
          build: (Context context) {
            return [
              // Items Table
              Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(width: 0.5, color: PdfColors.grey300),
                  bottom: BorderSide(width: 0.5, color: PdfColors.grey300),
                ),
                columnWidths: {
                  0: const FlexColumnWidth(3),
                  1: const FlexColumnWidth(),
                  2: const FlexColumnWidth(),
                  3: const FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: PdfColor.fromHex('#F8F9FA'),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.itemDetails.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.price.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.qty.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          AppRouter.l10n.amount.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontBold: boldTtf,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...purchase.purchaseItems.map(
                    (item) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontBold: boldTtf,
                                ),
                              ),
                              if (item.item.unit != null)
                                Text(
                                  item.item.unit!.name,
                                  style: const TextStyle(
                                    color: PdfColors.grey700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('$currency ${item.unitPrice}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(item.quantity.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('$currency ${item.totalPrice}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );
    } else {
      // Thermal Receipt Format Layout
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat(
            format == PrintFormats.roll57 ? 48.5 * mm : 71.5 * mm,
            double.infinity,
            marginAll: 8,
          ),
          margin: const EdgeInsets.all(8),
          build: (Context context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (logoBytes != null)
                      Image(
                        logoBytes,
                        height: 64,
                      )
                    else
                      Container(
                        decoration: BoxDecoration(color: PdfColor.fromHex('#0A003D')),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgImage(svg: img, width: 30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppRouter.l10n.duxbe.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: PdfColor.fromHex('#ffffff'),
                                    fontWeight: FontWeight.bold,
                                    fontBold: semiBoldTtf,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              purchase.purchaseInvoice,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontBold: boldTtf,
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                style: const BorderStyle(pattern: [4]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      left: 0,
                      top: -7,
                      child: Center(
                        child: Container(
                          width: 64,
                          decoration: const BoxDecoration(color: PdfColors.white),
                          child: Text(
                            AppRouter.l10n.invoiceNo,
                            textAlign: TextAlign.center,
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  purchase.purchaseDate.toLocal().toPdfFullFormat,
                  textAlign: TextAlign.center,
                ),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.supplierName),
                    Text(purchase.supplier.name ?? 'Unknown Supplier'),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8),
                Table(
                  border: const TableBorder(),
                  columnWidths: {
                    0: const FlexColumnWidth(),
                    1: const IntrinsicColumnWidth(),
                    2: const IntrinsicColumnWidth(),
                    3: const IntrinsicColumnWidth(),
                  },
                  children: [
                    // Header row
                    TableRow(
                      children: [
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.itemName,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.price,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.qty,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: cellPadding,
                          child: Text(
                            AppRouter.l10n.amount,
                            style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Purchase items
                    ...purchase.purchaseItems.map(
                      (item) => TableRow(
                        children: [
                          Padding(
                            padding: cellPadding,
                            child: Text(
                              item.item.name,
                              style: cellStyle,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: cellPadding,
                            child: Text(
                              item.unitPrice.toString(),
                              style: cellStyle,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: cellPadding,
                            child: Text(
                              item.quantity.toString(),
                              style: cellStyle,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: cellPadding,
                            child: Text(
                              currency + item.totalPrice.toStringAsFixed(2),
                              style: cellStyle,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.subTotal),
                    Text(currency + purchase.subTotal.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.discount),
                    Text(currency + purchase.discountAmount.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Assuming no shipping charge for purchase, can be added if needed
                    Text(AppRouter.l10n.shipping),
                    Text('$currency 0.00'), // Placeholder for shipping
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.tax),
                    Text(currency + purchase.taxAmount.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppRouter.l10n.total),
                    Text(currency + purchase.totalAmount.toString()),
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  borderStyle: BorderStyle.dotted,
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 8),
                // No "Thank you" message for purchase invoice, can be added if needed
                Center(
                  child: Text(
                    AppRouter.l10n.poweredByDuxbe,
                    style: const TextStyle(fontSize: 6, color: PdfColors.grey700),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  // Keep smiley face or remove as per preference
                  child: SvgImage(
                    svg: '''
                  <svg width="16" height="16" viewBox="0 0 29 29" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <g clip-path="url(#clip0_4392_4115)">
                      <path d="M14.5 0C22.5084 0 29 6.49165 29 14.5C29 22.5084 22.5084 29 14.5 29C6.49165 29 0 22.5084 0 14.5C0 6.49165 6.49165 0 14.5 0ZM14.5 2.02275C11.1908 2.02275 8.01719 3.33731 5.67725 5.67725C3.33731 8.01719 2.02275 11.1908 2.02275 14.5C2.02275 17.8092 3.33731 20.9828 5.67725 23.3227C8.01719 25.6627 11.1908 26.9773 14.5 26.9773C17.8092 26.9773 20.9828 25.6627 23.3227 23.3227C25.6627 20.9828 26.9773 17.8092 26.9773 14.5C26.9773 11.1908 25.6627 8.01719 23.3227 5.67725C20.9828 3.33731 17.8092 2.02275 14.5 2.02275ZM11.2288 17.4C11.3269 18.1964 11.7122 18.9297 12.3124 19.4623C12.9126 19.9949 13.6865 20.2902 14.489 20.2929C15.2914 20.2956 16.0673 20.0054 16.671 19.4768C17.2747 18.9482 17.6649 18.2175 17.7683 17.4218C17.7832 17.2917 17.8237 17.1658 17.8876 17.0515C17.9514 16.9372 18.0373 16.8368 18.1403 16.756C18.2433 16.6751 18.3614 16.6156 18.4876 16.5807C18.6138 16.5459 18.7456 16.5364 18.8755 16.5529C19.0054 16.5694 19.1307 16.6116 19.2442 16.6769C19.3577 16.7422 19.457 16.8294 19.5365 16.9334C19.616 17.0375 19.6741 17.1562 19.7073 17.2829C19.7406 17.4095 19.7483 17.5415 19.7302 17.6712C19.5655 18.9451 18.9415 20.1152 17.9752 20.9617C17.009 21.8082 15.7671 22.273 14.4825 22.2687C13.1979 22.2644 11.9591 21.7914 10.9985 20.9385C10.0379 20.0856 9.42171 18.9114 9.2655 17.6364C9.24744 17.5062 9.25548 17.3738 9.28917 17.2468C9.32285 17.1198 9.3815 17.0008 9.46169 16.8968C9.54187 16.7927 9.64199 16.7057 9.75619 16.6407C9.87039 16.5758 9.99638 16.5343 10.1268 16.5186C10.2572 16.5029 10.3895 16.5133 10.5158 16.5493C10.6422 16.5853 10.7601 16.6461 10.8627 16.7281C10.9653 16.8102 11.0505 16.9119 11.1134 17.0272C11.1762 17.1426 11.2155 17.2693 11.2288 17.4ZM8.4303 9.106C8.96677 9.106 9.48126 9.31911 9.8606 9.69845C10.2399 10.0778 10.4531 10.5923 10.4531 11.1288C10.4531 11.6652 10.2399 12.1797 9.8606 12.5591C9.48126 12.9384 8.96677 13.1515 8.4303 13.1515C7.89383 13.1515 7.37934 12.9384 7 12.5591C6.62066 12.1797 6.40755 11.6652 6.40755 11.1288C6.40755 10.5923 6.62066 10.0778 7 9.69845C7.37934 9.31911 7.89383 9.106 8.4303 9.106ZM20.5697 9.106C21.1062 9.106 21.6207 9.31911 22 9.69845C22.3793 10.0778 22.5925 10.5923 22.5925 11.1288C22.5925 11.6652 22.3793 12.1797 22 12.5591C21.6207 12.9384 21.1062 13.1515 20.5697 13.1515C20.0332 13.1515 19.5187 12.9384 19.1394 12.5591C18.7601 12.1797 18.547 11.6652 18.547 11.1288C18.547 10.5923 18.7601 10.0778 19.1394 9.69845C19.5187 9.31911 20.0332 9.106 20.5697 9.106Z" fill="black"/>
                    </g>
                    <defs>
                      <clipPath id="clip0_4392_4115">
                        <rect width="29" height="29" fill="white"/>
                      </clipPath>
                    </defs>
                  </svg>
              ''',
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await _downloadPdf(pdf, print: true);
  }

  static void printBarcode({
    required Item item,
    required int quantity,
    required bool withPrice,
    required String currency,
    required StickerProps dimensions,
  }) {
    final pdf = Document(
      theme: ThemeData(defaultTextStyle: const TextStyle(fontSize: 12)),
    )..addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: EdgeInsets.zero,
          build: (context) {
            return List.generate((quantity / dimensions.maxStickerCountPerPage).ceil(), (indexPage) {
              return TableHelper.fromTextArray(
                cellAlignment: Alignment.center,
                data: List.generate(
                  dimensions.maxStickerCountPerPage ~/ dimensions.crossAxisCount, // Calculate number of rows
                  (indexRow) => List.generate(
                    dimensions.crossAxisCount, // Number of columns per row
                    (indexColumn) {
                      final barcodeIndex = indexPage * dimensions.maxStickerCountPerPage +
                          indexRow * dimensions.crossAxisCount +
                          indexColumn;

                      if (barcodeIndex < quantity) {
                        return Container(
                          width: dimensions.width * PdfService.inch,
                          height: dimensions.height * PdfService.inch,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.name),
                              SizedBox(height: 6),
                              BarcodeWidget(
                                data: item.itemCode,
                                barcode: Barcode.code128(),
                                drawText: false,
                                height: dimensions.height * PdfService.inch - 60,
                              ),
                              SizedBox(height: 6),
                              Text(item.itemCode),
                              SizedBox(height: 6),
                              if (withPrice) Text('$currency ${item.salePrice}'),
                            ],
                          ),
                        );
                      } else {
                        // If no more barcodes to print, return an empty SizedBox
                        return SizedBox(
                          width: dimensions.width * PdfService.inch,
                          height: dimensions.height * PdfService.inch,
                        );
                      }
                    },
                  ),
                ),
              );
            });
          },
        ),
      );
    _downloadPdf(pdf, print: true);
  }

  static Future<void> printStockAdjustment(
    StockAdjustments stockAdjustment,
  ) async {
    ImageProvider? imageBytes;

    final business = AppRouter.read(businessNotifierProvider)!;
    final currency = business.currency?.code ?? r'$';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());
    final img = await rootBundle.loadString(Assets.icons.invoiceLogo.path);
    ImageProvider? logoBytes;
    if (business.logo != null) {
      try {
        logoBytes = await networkImage(business.logo!);
      } catch (e) {
        // Handle network image loading error silently
      }
    }

    final pdf = Document(
      theme: ThemeData(
        defaultTextStyle: TextStyle(font: ttf, fontBold: semiBoldTtf),
      ),
    )..addPage(
        Page(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(20),
          build: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (logoBytes != null)
                  Image(
                    logoBytes,
                    height: 64,
                  )
                else
                  SvgImage(svg: img, height: 64),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppRouter.l10n.inventoryAdjustment,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      stockAdjustment.performedAt.toLocal().toPdfFullFormat,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${AppRouter.l10n.reference}: ${stockAdjustment.reference}',
                      style: const TextStyle(fontSize: 14, color: PdfColors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${AppRouter.l10n.performedBy}: ${stockAdjustment.performedUser}',
                      style: const TextStyle(fontSize: 14, color: PdfColors.grey),
                    ),
                  ],
                ),
                Text(
                  '${AppRouter.l10n.reason}: ${stockAdjustment.reason}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: PdfColor.fromHex('#D7DAE0'),
                    ),
                    top: BorderSide(
                      color: PdfColor.fromHex('#D7DAE0'),
                    ),
                    bottom: BorderSide(
                      color: PdfColor.fromHex('#D7DAE0'),
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: PdfColor.fromHex('#F8F9FA'),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            AppRouter.l10n.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex('5E6470'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            AppRouter.l10n.quantityAdjusted,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex('5E6470'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            AppRouter.l10n.newQuantityOnHand,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PdfColor.fromHex('5E6470'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...stockAdjustment.adjustedItems.map(
                      (e) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(e.item!.name, textAlign: TextAlign.start),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              e.quantityAdjusted.toString(),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              e.newQuantity.toString(),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ); // Page
    await _downloadPdf(pdf, print: true);
  }

  // NEW FUNCTION 1: For Invoices
  /// Generates a PDF for a standard Invoice.
  /// This replaces the `InvoiceType.invoice` logic from the old function.
  static Future<void> printInvoicePdf({
    required String invoiceNumber,
    required String invoiceDate,
    required String dueDate,
    required InvoiceFormStatus status, // To handle "Paid" status correctly
    required String customerName,
    required String customerAddress,
    required List<InvoiceItem> items,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double total,
    required String totalInWords,
    required String note,
    required String termsAndConditions,
    required double balanceDue,
  }) async {
    final business = AppRouter.read(businessNotifierProvider)!;
    final currencySymbol = business.currency?.code ?? '₹';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());

    final pdf = Document()
      ..addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(32),
          build: (Context context) {
            return [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: _appTextHeading4(
                                boldTtf,
                                color: _hancodPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              business.storeName ?? '',
                              style: _appTextMediumB(boldTtf, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            if (business.contactAddress != null)
                              Text(
                                business.contactAddress!,
                                style: _appTextSmallN(ttf),
                              ),
                              if (business.state != null&&business.country !=null)
                              Text(
                                '${business.state ?? ''}, ${business.country ?? ''}',
                                style: _appTextSmallN(ttf),
                              ),
                            SizedBox(height: 2),
                            SizedBox(height: 2),
                            if (business.gstIn != null)
                              Text(
                                business.gstIn!,
                                style: _appTextSmallB(
                                  boldTtf,
                                  color: _hancodStormyBlue,
                                ),
                              ),
                            SizedBox(height: 2),
                            Text(
                              '${business.contactPhone ?? ''}  |  ${business.contactEmail ?? ''}',
                              style: _appTextSmallN(ttf),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _hancodColorF5F5F5,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                invoiceNumber,
                                style: _appTextMediumSB(
                                  semiBoldTtf,
                                  fontSize: 16,
                                  boldFontForOverride: boldTtf,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              AppRouter.l10n.balanceDue,
                              style: _appTextSmallM(
                                ttf,
                                color: _hancodStormyBlue,
                              ),
                            ),
                            Text(
                              status == InvoiceFormStatus.paid
                                  ? '$currencySymbol ${0.toStringAsFixed(2)}'
                                  : '$currencySymbol ${balanceDue.toStringAsFixed(2)}',
                              style: _appTextHeading5(boldTtf),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- DATE SECTION ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _hancodColorF9F9F9,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppRouter.l10n.invoiceDate,
                                style: _appTextSmallN(ttf),
                              ),
                              SizedBox(height: 4),
                              Text(
                                invoiceDate,
                                style: _appTextMediumSB(semiBoldTtf),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppRouter.l10n.dueDate,
                                style: _appTextSmallN(ttf),
                              ),
                              SizedBox(height: 4),
                              Text(
                                dueDate,
                                style: _appTextMediumSB(semiBoldTtf),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // --- CUSTOMER, ITEMS, and TOTALS SECTION ---
                  _buildItemsAndTotalsSection(
                    customerName: customerName,
                    customerAddress: customerAddress,
                    items: items,
                    currencySymbol: currencySymbol,
                    subtotal: subtotal,
                    cgst: cgst,
                    sgst: sgst,
                    total: total,
                    totalInWords: totalInWords,
                    ttf: ttf,
                    boldTtf: boldTtf,
                  ),
                  SizedBox(height: 18),

                  // --- NOTE AND TERMS SECTION ---
                  _buildNotesAndTermsSection(
                    note: note,
                    termsAndConditions: termsAndConditions,
                    ttf: ttf,
                  ),
                ],
              ),
            ];
          },
        ),
      );
    await _downloadPdf(pdf, print: true);
  }

// NEW FUNCTION 2: For Quotes
  /// Generates a PDF for a Quote.
  /// This replaces the `InvoiceType.quote` logic from the old function.
  static Future<void> printQuotePdf({
    required String quoteNumber,
    required String quoteDate,
    required String expiryDate,
    required String customerName,
    required String customerAddress,
    required List<InvoiceItem> items,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double total,
    required String totalInWords,
    required String note,
    required String termsAndConditions,
  }) async {
    final business = AppRouter.read(businessNotifierProvider)!;
    final currencySymbol = business.currency?.code ?? '₹';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());

    final pdf = Document()
      ..addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(32),
          build: (Context context) {
            return [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: _appTextHeading4(
                                boldTtf,
                                color: _hancodPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              business.storeName ?? '',
                              style: _appTextMediumB(boldTtf, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            if (business.contactAddress != null)
                              Text(
                                business.contactAddress!,
                                style: _appTextSmallN(ttf),
                              ),
                            SizedBox(height: 2),
                            if (business.state != null&&business.country !=null)
                              Text(
                                '${business.state ?? ''}, ${business.country ?? ''}',
                                style: _appTextSmallN(ttf),
                              ),
                            SizedBox(height: 2),
                            if (business.gstIn != null)
                              Text(
                                business.gstIn!,
                                style: _appTextSmallB(
                                  boldTtf,
                                  color: _hancodStormyBlue,
                                ),
                              ),
                            SizedBox(height: 2),
                            Text(
                              '${business.contactPhone ?? ''}  |  ${business.contactEmail ?? ''}',
                              style: _appTextSmallN(ttf),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _hancodColorF5F5F5,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quoteNumber,
                                style: _appTextMediumSB(
                                  semiBoldTtf,
                                  fontSize: 16,
                                  boldFontForOverride: boldTtf,
                                ),
                              ),
                            ),
                            // NO "Balance Due" for a quote
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- DATE SECTION ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _hancodColorF9F9F9,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppRouter.l10n.quoteDate,
                                style: _appTextSmallN(ttf),
                              ),
                              SizedBox(height: 4),
                              Text(
                                quoteDate,
                                style: _appTextMediumSB(semiBoldTtf),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppRouter.l10n.expiryDate,
                                style: _appTextSmallN(ttf),
                              ),
                              SizedBox(height: 4),
                              Text(
                                expiryDate,
                                style: _appTextMediumSB(semiBoldTtf),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // --- CUSTOMER, ITEMS, and TOTALS SECTION (REUSABLE) ---
                  _buildItemsAndTotalsSection(
                    customerName: customerName,
                    customerAddress: customerAddress,
                    items: items,
                    currencySymbol: currencySymbol,
                    subtotal: subtotal,
                    cgst: cgst,
                    sgst: sgst,
                    total: total,
                    totalInWords: totalInWords,
                    ttf: ttf,
                    boldTtf: boldTtf,
                  ),
                  SizedBox(height: 18),

                  // --- NOTE AND TERMS SECTION (REUSABLE) ---
                  _buildNotesAndTermsSection(
                    note: note,
                    termsAndConditions: termsAndConditions,
                    ttf: ttf,
                  ),
                ],
              ),
            ];
          },
        ),
      );
    await _downloadPdf(pdf, print: true);
  }

  // NEW FUNCTION 3: For Credit Notes
  /// Generates a PDF for a Credit Note.
  /// This replaces the `InvoiceType.credit` logic from the old function.
  static Future<void> printCreditNotePdf({
    required String creditNoteNumber,
    required String creditNoteDate,
    required String referenceInvoiceNumber,
    required String customerName,
    required String customerAddress,
    required List<InvoiceItem> items,
    required double subtotal,
    required double cgst,
    required double creditRemaining,
    required double sgst,
    required double total,
    required String totalInWords,
    required String note,
    required String termsAndConditions,
  }) async {
    final business = AppRouter.read(businessNotifierProvider)!;
    final currencySymbol = business.currency?.code ?? '₹';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());

    final pdf = Document()
      ..addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(32),
          build: (Context context) {
            return [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: _appTextHeading4(
                                boldTtf,
                                color: _hancodPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              business.storeName ?? '',
                              style: _appTextMediumB(boldTtf, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            if (business.contactAddress != null)
                              Text(
                                business.contactAddress!,
                                style: _appTextSmallN(ttf),
                              ),
                            SizedBox(height: 2),
                            if (business.state != null&&business.country !=null)
                              Text(
                                '${business.state ?? ''}, ${business.country ?? ''}',
                                style: _appTextSmallN(ttf),
                              ),
                            SizedBox(height: 2),
                            if (business.gstIn != null)
                              Text(
                                business.gstIn!,
                                style: _appTextSmallB(
                                  boldTtf,
                                  color: _hancodStormyBlue,
                                ),
                              ),
                            SizedBox(height: 2),
                            Text(
                              '${business.contactPhone ?? ''}  |  ${business.contactEmail ?? ''}',
                              style: _appTextSmallN(ttf),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _hancodColorF5F5F5,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                creditNoteNumber,
                                style: _appTextMediumSB(
                                  semiBoldTtf,
                                  fontSize: 16,
                                  boldFontForOverride: boldTtf,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              AppRouter.l10n.creditsRemaining,
                              style: _appTextSmallM(
                                ttf,
                                color: _hancodStormyBlue,
                              ),
                            ),
                            Text(
                              '$currencySymbol ${creditRemaining.toStringAsFixed(2)}',
                              style: _appTextHeading5(boldTtf),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- DATE SECTION ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _hancodColorF9F9F9,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppRouter.l10n.creditDate,
                                style: _appTextSmallN(ttf),
                              ),
                              SizedBox(height: 4),
                              Text(
                                creditNoteDate,
                                style: _appTextMediumSB(semiBoldTtf),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppRouter.l10n.invoiceNumber,
                                style: _appTextSmallN(ttf),
                              ),
                              SizedBox(height: 4),
                              Text(
                                referenceInvoiceNumber,
                                style: _appTextMediumSB(semiBoldTtf),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // --- CUSTOMER, ITEMS, and TOTALS SECTION (REUSABLE) ---
                  _buildItemsAndTotalsSection(
                    customerName: customerName,
                    customerAddress: customerAddress,
                    items: items,
                    currencySymbol: currencySymbol,
                    subtotal: subtotal,
                    cgst: cgst,
                    sgst: sgst,
                    total: total,
                    totalInWords: totalInWords,
                    ttf: ttf,
                    boldTtf: boldTtf,
                  ),
                  SizedBox(height: 18),

                  // --- NOTE AND TERMS SECTION (REUSABLE) ---
                  _buildNotesAndTermsSection(
                    note: note,
                    termsAndConditions: termsAndConditions,
                    ttf: ttf,
                  ),
                ],
              ),
            ];
          },
        ),
      );
    await _downloadPdf(pdf, print: true);
  }

  /// Generates a PDF for a Payment Receipt.
  /// This replaces the `InvoiceType.payment` logic from the old function.
// Add this updated function to your PdfService class.

  /// Generates a PDF for a Payment Receipt, matching the PaymentReceipt widget layout.
  static Future<void> printPaymentReceiptPdf({
    required String receiptNumber,
    required String paymentDate,
    required double amountReceived,
    required String amountInWords,
    required String receivedFrom, // Customer Name
    required String referenceNumber,
    required String paymentMode,
  }) async {
    final business = AppRouter.read(businessNotifierProvider)!;
    final currencySymbol = business.currency?.code ?? '₹';

    final fontData = await rootBundle.load(Assets.fonts.notoSansArabicRegular);
    final ttf = Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load(Assets.fonts.notoSansArabicBold);
    final boldTtf = Font.ttf(boldFontData.buffer.asByteData());
    final semiBoldfontData = await rootBundle.load(Assets.fonts.notoSansArabicSemiBold);
    final semiBoldTtf = Font.ttf(semiBoldfontData.buffer.asByteData());

    final pdf = Document()
      ..addPage(
        MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(32),
          build: (Context context) {
            return [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Use stretch for centered title
                children: [
                  // --- HEADER SECTION (Business Info and Receipt Number) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              style: _appTextHeading4(
                                boldTtf,
                                color: _hancodPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              business.storeName ?? '',
                              style: _appTextMediumB(boldTtf, fontSize: 15),
                            ),
                            SizedBox(height: 2),
                            if (business.contactAddress != null)
                              Text(
                                business.contactAddress!,
                                style: _appTextSmallN(ttf),
                              ),

                            SizedBox(height: 2),
                            if (business.state != null&&business.country !=null)
                              Text(
                                '${business.state ?? ''}, ${business.country ?? ''}',
                                style: _appTextSmallN(ttf),
                              ),

                            SizedBox(height: 2),
                            if (business.gstIn != null)
                              Text(
                                business.gstIn!,
                                style: _appTextSmallB(
                                  boldTtf,
                                  color: _hancodStormyBlue,
                                ),
                              ),
                            SizedBox(height: 2),
                            Text(
                              '${business.contactPhone ?? ''}  |  ${business.contactEmail ?? ''}',
                              style: _appTextSmallN(ttf),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _hancodColorF5F5F5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          receiptNumber,
                          style: _appTextMediumSB(
                            semiBoldTtf,
                            fontSize: 16,
                            boldFontForOverride: boldTtf,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // --- "PAYMENT RECEIPT" TITLE ---
                  Center(
                    child: Text(
                      AppRouter.l10n.paymentReceipt.toUpperCase(),
                      style: _appTextXLargeSB(
                        semiBoldTtf,
                        color: _hancodPrimaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // --- PAYMENT DETAILS CONTAINER ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _hancodColorE0E0E0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppRouter.l10n.amountReceived,
                          style: _appTextXLargeSB(semiBoldTtf),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$currencySymbol${amountReceived.toStringAsFixed(2)}',
                          style: _appTextHeading2(
                            boldTtf,
                          ), // Matches AppText.heading2
                        ),
                        SizedBox(height: 4),
                        Text(
                          amountInWords,
                          style: _appTextMediumSB(semiBoldTtf),
                        ),
                        SizedBox(height: 30),
                        _dataRow(
                          label: Text(
                            AppRouter.l10n.receivedFrom,
                            style: _appTextSmallN(ttf),
                          ),
                          value: Text(
                            receivedFrom,
                            style: _appTextSmallB(boldTtf),
                          ),
                        ),
                        SizedBox(height: 16),
                        _dataRow(
                          label: Text(
                            AppRouter.l10n.paymentDate,
                            style: _appTextSmallN(ttf),
                          ),

                          value:
                              Text(paymentDate, style: _appTextSmallB(boldTtf)),

                        ),
                        SizedBox(height: 16),
                        _dataRow(
                          label: Text(
                            AppRouter.l10n.referenceNumber,
                            style: _appTextSmallN(ttf),
                          ),
                          value: Text(
                            referenceNumber,
                            style: _appTextSmallB(boldTtf),
                          ),
                        ),
                        SizedBox(height: 16),
                        _dataRow(
                          label: Text(
                            AppRouter.l10n.paymentMode,
                            style: _appTextSmallN(ttf),
                          ),

                          value:
                              Text(paymentMode, style: _appTextSmallB(boldTtf)),

                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

    await _downloadPdf(pdf, print: true);
  }

  // PRIVATE HELPER WIDGETS TO AVOID CODE DUPLICATION BETWEEN THE 3 NEW FUNCTIONS

  /// Builds the common section for customer details, items table, and totals.
  static Widget _buildItemsAndTotalsSection({
    required String customerName,
    required String customerAddress,
    required List<InvoiceItem> items,
    required String currencySymbol,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double total,
    required String totalInWords,
    required Font ttf,
    required Font boldTtf,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _hancodColorE0E0E0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppRouter.l10n.billTo,
            style: _appTextSmallM(ttf, color: _hancodStormyBlue),
          ),
          SizedBox(height: 4),
          Text(customerName, style: _appTextMediumSB(boldTtf)),
          Text(customerAddress, style: _appTextSmallN(ttf)),
          SizedBox(height: 18),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
              2: IntrinsicColumnWidth(),
              3: IntrinsicColumnWidth(),
              4: IntrinsicColumnWidth(),
              5: IntrinsicColumnWidth(),
            },
            border: const TableBorder(
              horizontalInside: BorderSide(color: _hancodColorF5F5F5),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: _hancodColorF5F5F5),
                children: [
                  _tableCellPadding(
                    Text('Sl. no.', style: _appTextXSmallM(ttf)),
                  ),
                  _tableCellPadding(
                    Text(AppRouter.l10n.itemName, style: _appTextXSmallM(ttf)),
                  ),
                  _tableCellPadding(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppRouter.l10n.quantity,
                        style: _appTextXSmallM(ttf),
                      ),
                    ),
                  ),
                  _tableCellPadding(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppRouter.l10n.rate,
                        style: _appTextXSmallM(ttf),
                      ),
                    ),
                  ),
                  _tableCellPadding(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(AppRouter.l10n.tax, style: _appTextXSmallM(ttf)),
                    ),
                  ),
                  _tableCellPadding(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppRouter.l10n.amount,
                        style: _appTextXSmallM(ttf),
                      ),
                    ),
                  ),
                ],
              ),
              ...items.asMap().entries.map((entry) {
                final item = entry.value;
                return TableRow(
                  children: [
                    _tableCellPadding(
                      Text('${entry.key + 1}', style: _appTextSmallM(ttf)),
                    ),
                    _tableCellPadding(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description, style: _appTextSmallM(ttf)),
                          if (item.subDescription?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                item.subDescription!,
                                style: _appTextSmallN(ttf),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _tableCellPadding(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.quantity.toStringAsFixed(
                            item.quantity % 1 == 0 ? 0 : 2,
                          ),
                          style: _appTextSmallM(ttf),
                        ),
                      ),
                    ),
                    _tableCellPadding(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.rate.toStringAsFixed(2),
                          style: _appTextSmallM(ttf),
                        ),
                      ),
                    ),
                    _tableCellPadding(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.tax.toStringAsFixed(2),
                          style: _appTextSmallM(ttf),
                        ),
                      ),
                    ),
                    _tableCellPadding(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$currencySymbol ${item.amount.toStringAsFixed(2)}',
                          style: _appTextSmallM(ttf),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 18),
          Divider(color: _hancodColorE0E0E0, height: 1, thickness: 1),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTotalRow(
                      label: 'Sub Total',
                      value: '$currencySymbol ${subtotal.toStringAsFixed(2)}',
                      regularFont: ttf,
                      boldFont: boldTtf,
                    ),
                    _buildTotalRow(
                      label: 'CGST (9%)',
                      value: '$currencySymbol ${cgst.toStringAsFixed(2)}',
                      regularFont: ttf,
                      boldFont: boldTtf,
                    ),
                    _buildTotalRow(
                      label: 'SGST (9%)',
                      value: '$currencySymbol ${sgst.toStringAsFixed(2)}',
                      regularFont: ttf,
                      boldFont: boldTtf,
                    ),
                    SizedBox(height: 8),
                    _buildTotalRow(
                      label: AppRouter.l10n.total,
                      value: '$currencySymbol ${total.toStringAsFixed(2)}',
                      regularFont: ttf,
                      boldFont: boldTtf,
                      isLabelBold: true,
                      isValueBold: true,
                      labelStyle: _appTextSmallB(boldTtf, fontSize: 11),
                      valueStyle: _appTextSmallB(boldTtf, fontSize: 11),
                    ),
                    SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        totalInWords,
                        style: _appTextSmallN(ttf, fontSize: 8),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the common section for notes and terms & conditions.
  static Widget _buildNotesAndTermsSection({
    required String note,
    required String termsAndConditions,
    required Font ttf,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.isNotEmpty) ...[
          Text(AppRouter.l10n.note, style: _appTextSmallN(ttf)),
          SizedBox(height: 2),
          Text(note, style: _appTextSmallM(ttf)),
          SizedBox(height: 18),
        ],
        if (termsAndConditions.isNotEmpty) ...[
          Text(AppRouter.l10n.termsAndConditions, style: _appTextSmallN(ttf)),
          SizedBox(height: 2),
          Text(termsAndConditions, style: _appTextSmallM(ttf)),
        ],
      ],
    );
  }
}
