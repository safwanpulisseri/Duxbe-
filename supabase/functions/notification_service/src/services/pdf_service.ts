import utcToZonedTime from "https://cdn.skypack.dev/date-fns-tz@1.3.7/utcToZonedTime";
import format from "https://cdn.skypack.dev/date-fns/format";
import {
  Color,
  PDFDocument,
  PDFFont,
  PDFName,
  PDFPage,
  rgb,
  StandardFonts,
} from "https://esm.sh/pdf-lib@1.17.1";
import { SaleView } from "../types/sales.d.ts";

function safeDrawText(
  page: PDFPage,
  text: string | number | undefined | null,
  x: number,
  y: number,
  options: { size: number; font: PDFFont; color: Color },
) {
  if (text !== null && text !== undefined) {
    page.drawText(String(text), { x, y, ...options });
  }
}

export async function generateInvoicePDF(sale: SaleView): Promise<Uint8Array> {
  const pdfDoc = await PDFDocument.create();
  const timesRomanFont = await pdfDoc.embedFont(StandardFonts.TimesRoman);
  const page = pdfDoc.addPage([595, 842]); // Standard A4 size
  const { width, height } = page.getSize();
  const fontSize = 12;

  // Use default logo URL if the business logo is missing
  const defaultLogoUrl =
    "https://awfbsiftpwpiczdxlmig.supabase.co/storage/v1/object/public/invoice%20assets/duxbe_white.png?t=2025-01-21T09%3A03%3A17.024Z";
  const logoUrl = sale.business.logo ?? defaultLogoUrl;
  let logoHeight = 0;

  try {
    const logoBytes = await fetch(logoUrl).then((res) => res.arrayBuffer());
    const logoImage = await pdfDoc.embedPng(logoBytes);

    const logoWidth = 170; // Setting a fixed width for the logo
    logoHeight = (logoWidth * 68) / 227; // Maintain the aspect ratio 227/68

    // Draw the image at the specified position
    page.drawImage(logoImage, {
      x: 50,
      y: height - 100,
      width: logoWidth,
      height: logoHeight,
    });
  } catch (err) {
    console.error("Failed to load logo image:", err);
  }

  // Convert invoice date to local time with default timezone 'Asia/Kolkata'
  const invoiceUTCDate = new Date(sale.sale_date);
  const timeZone = sale.business.time_zone || "Asia/Kolkata";
  const localTime = utcToZonedTime(invoiceUTCDate, timeZone);
  const formattedDate = format(localTime, "dd-MM-yyyy HH:mm:ss", { timeZone });

  // Business Information with padding
  const businessInfoY = height - 80 - logoHeight; // Adjusted to add padding below the logo
  safeDrawText(page, sale.business.name, 50, businessInfoY, {
    size: fontSize + 2,
    font: timesRomanFont,
    color: rgb(0.2, 0.2, 0.2),
  });
  safeDrawText(
    page,
    sale.business.contact_address ?? "",
    50,
    businessInfoY - 20,
    {
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0.2, 0.2, 0.2),
    },
  );
  safeDrawText(
    page,
    `Phone: ${sale.business.contact_phone ?? ""}`,
    50,
    businessInfoY - 40,
    { size: fontSize, font: timesRomanFont, color: rgb(0.2, 0.2, 0.2) },
  );

  // Invoice Title and Basic Info
  page.drawText("INVOICE", {
    x: width - 200,
    y: height - 100,
    size: 2 * fontSize,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });
  safeDrawText(
    page,
    `Invoice Number: ${sale.sale_invoice ?? ""}`,
    width - 200,
    height - 130,
    { size: fontSize, font: timesRomanFont, color: rgb(0, 0, 0) },
  );
  safeDrawText(page, `Date: ${formattedDate}`, width - 200, height - 150, {
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });

  // Customer Information
  const customerInfoY = businessInfoY - 80;
  page.drawText("Bill To:", {
    x: 50,
    y: customerInfoY,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0.4, 0.4, 0.4),
  });
  safeDrawText(
    page,
    sale.customer?.name ?? "Walk-in Customer",
    50,
    customerInfoY - 20,
    {
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 0, 0),
    },
  );
  safeDrawText(page, sale.customer?.phone ?? "", 50, customerInfoY - 40, {
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });

  // Table Header with Fixed Alignment
  let tableY = height - 300;
  const tableX = 50;
  const colWidths = [150, 200, 100, 70, 75];
  const rowHeight = fontSize + 10;
  const headers = [
    "Item/Service",
    "Unit Price",
    "Quantity",
    "Amount",
  ];

  headers.forEach((header, i) => {
    page.drawText(header, {
      x: tableX + colWidths.slice(0, i).reduce((acc, w) => acc + w, 0),
      y: tableY,
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0.4, 0.4, 0.4),
    });
  });

  tableY -= rowHeight;

  /// Draw Services with Correct Access to Service Name
  sale.sale_items.forEach((item) => {
    const row = [
      // add subservices here
      item.item.name,
      `${sale.business.currency.code} ${item.unit_price.toFixed(2)}`,
      item.quantity,
      `${sale.business.currency.code} ${item.total_price.toFixed(2)}`,
    ];
    row.forEach((cell, i) => {
      safeDrawText(
        page,
        cell,
        tableX + colWidths.slice(0, i).reduce((acc, w) => acc + w, 0),
        tableY,
        { size: fontSize, font: timesRomanFont, color: rgb(0, 0, 0) },
      );
    });
    tableY -= rowHeight;
  });

  // Summary Section with Fixed Columns
  const summaryX = width - 250;
  tableY -= 20;
  page.drawText("Subtotal:", {
    x: summaryX,
    y: tableY,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });
  safeDrawText(
    page,
    `${sale.business.currency.code} ${sale.subtotal.toFixed(2)}`,
    summaryX + 100,
    tableY,
    { size: fontSize, font: timesRomanFont, color: rgb(0, 0, 0) },
  );

  tableY -= 15;
  page.drawText("Tax:", {
    x: summaryX,
    y: tableY,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });
  safeDrawText(
    page,
    `${sale.business.currency.code} ${sale.tax_amount.toFixed(2)}`,
    summaryX + 100,
    tableY,
    { size: fontSize, font: timesRomanFont, color: rgb(0, 0, 0) },
  );

  tableY -= 15;
  page.drawText("Total:", {
    x: summaryX,
    y: tableY,
    size: fontSize + 2,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });
  safeDrawText(
    page,
    `${sale.business.currency.code} ${sale.total_amount.toFixed(2)}`,
    summaryX + 100,
    tableY,
    { size: fontSize + 2, font: timesRomanFont, color: rgb(0, 0, 0) },
  );

  // Paid and Due Amounts
  tableY -= 30;
  if (sale.paid_amount > 0) {
    page.drawText("Paid:", {
      x: summaryX,
      y: tableY,
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 0, 0),
    });
    safeDrawText(
      page,
      `${sale.business.currency.code} ${sale.paid_amount.toFixed(2)}`,
      summaryX + 100,
      tableY,
      { size: fontSize, font: timesRomanFont, color: rgb(0, 1, 0) },
    );
    tableY -= 15;
  }

  tableY -= 15;
  if (sale.due_amount > 0) {
    page.drawText("Due:", {
      x: summaryX,
      y: tableY,
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 0, 0),
    });
    safeDrawText(
      page,
      `${sale.business.currency.code} ${sale.due_amount.toFixed(2)}`,
      summaryX + 100,
      tableY,
      {
        size: fontSize,
        font: timesRomanFont,
        color: rgb(1, 0.5, 0), // Orange for due amount
      },
    );
  } else if (sale.due_amount === 0 && sale.paid_amount > 0) {
    page.drawText("Status:", {
      x: summaryX,
      y: tableY,
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 0, 0),
    });
    safeDrawText(page, "Paid in Full", summaryX + 100, tableY, {
      size: fontSize,
      font: timesRomanFont,
      color: rgb(0, 1, 0), // Green for fully paid
    });
  }
  if (sale.due_amount === 0 && sale.paid_amount > 0) {
    try {
      // Update the URL to a publicly accessible network URL
      const paidSealUrl =
        "https://awfbsiftpwpiczdxlmig.supabase.co/storage/v1/object/public/invoice%20assets/paid_seal.png"; // Replace with the actual network URL
      const paidSealBytes = await fetch(paidSealUrl).then((res) =>
        res.arrayBuffer()
      );
      const paidSealImage = await pdfDoc.embedPng(paidSealBytes);

      const sealWidth = 120;
      const sealHeight = (sealWidth * paidSealImage.height) /
        paidSealImage.width;

      page.drawImage(paidSealImage, {
        x: width / 2 - sealWidth / 2,
        y: tableY - 100,
        width: sealWidth,
        height: sealHeight,
      });
      tableY -= sealHeight + 20; // Adjust tableY to move the footer section down
    } catch (err) {
      console.error("Failed to load paid seal image:", err);
    }
  }
  // Footer Section
  tableY -= 50;
  page.drawText("Thank you for your business!", {
    x: 50,
    y: tableY,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0, 0, 0),
  });
  page.drawText("Terms & Conditions:", {
    x: 50,
    y: tableY - 20,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0.6, 0.6, 0.6),
  });
  page.drawText("Please make payment within 15 days.", {
    x: 50,
    y: tableY - 35,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(0.6, 0.6, 0.6),
  });

  // Adding the Powered By Duxbe Strip at the Bottom of the Page
  const stripHeight = 40;
  page.drawRectangle({
    x: 0,
    y: 0,
    width,
    height: stripHeight,
    color: rgb(10 / 255, 0 / 255, 61 / 255), // #0A003D color
  });
  // Adding "Powered by" Text in the Center of the Strip
  const poweredByText = "Powered by";
  const poweredByTextWidth = timesRomanFont.widthOfTextAtSize(
    poweredByText,
    fontSize,
  );
  const textX = (width / 2) - (poweredByTextWidth / 2);
  const textY = stripHeight / 2 - fontSize / 2;

  page.drawText(poweredByText, {
    x: textX,
    y: textY,
    size: fontSize,
    font: timesRomanFont,
    color: rgb(1, 1, 1),
  });

  // Adding Duxbe Logo on the Next Line, Centered
  try {
    // Update the URL to a publicly accessible network URL
    const duxbeLogoUrl =
      "https://awfbsiftpwpiczdxlmig.supabase.co/storage/v1/object/public/invoice%20assets/duxbe_white.png";
    const duxbeLogoBytes = await fetch(duxbeLogoUrl).then((res) =>
      res.arrayBuffer()
    );
    const duxbeLogoImage = await pdfDoc.embedPng(duxbeLogoBytes);

    const logoWidth = 40;
    const logoHeight = (logoWidth * duxbeLogoImage.height) /
      duxbeLogoImage.width;

    // Position the logo below the "Powered by" text, centered horizontally
    const logoX = (width / 2) - (logoWidth / 2); // Centered horizontally
    const logoY = textY - 30; // Adjust `-30` to move the logo below the text

    page.drawImage(duxbeLogoImage, {
      x: logoX, // Centered position for the logo
      y: logoY, // Position Y for the logo
      width: logoWidth,
      height: logoHeight,
    });

    // Create a clickable link annotation over the "Powered by Duxbe" section
    const linkAnnotation = pdfDoc.context.obj({
      Type: PDFName.of("Annot"),
      Subtype: PDFName.of("Link"),
      Rect: [
        logoX - 5,
        logoY - 5,
        logoX + logoWidth + 5,
        logoY + logoHeight + 5,
      ],
      Border: [0, 0, 0],
      A: pdfDoc.context.obj({
        Type: PDFName.of("Action"),
        S: PDFName.of("URI"),
        URI: pdfDoc.context.obj({
          value: "https://www.duxbe.com",
        }),
      }),
    });

    // Attach annotation to the page
    page.node.set(PDFName.of("Annots"), pdfDoc.context.obj([linkAnnotation]));
  } catch (err) {
    console.error("Failed to load Duxbe logo image:", err);
  }

  // Return the generated PDF as bytes
  const pdfBytes = await pdfDoc.save();
  return pdfBytes;
}
