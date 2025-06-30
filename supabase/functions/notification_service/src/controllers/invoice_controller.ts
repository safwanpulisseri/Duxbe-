import { logger } from "../../index.ts";
import { supabase } from "../config/supabase.ts";
import { generateInvoicePDF } from "../services/pdf_service.ts";
import { StorageService } from "../services/storage_service.ts";
import { WhatsAppService } from "../services/whatsapp_service.ts";
import { SaleView } from "../types/sales.d.ts";

/**
 * Process the invoice PDF generation and notification sending.
 */
export async function handleInvoiceProcessing(
    sale_id: string,
): Promise<string> {
    logger.info("Processing invoice for sale ID:", sale_id);

    try {
        const sale = await fetchSaleDetails(sale_id);
        logger.info(`Sale details fetched: ${sale}`);
        const fileName = generateFileName(sale);
        logger.info(`File name generated: ${fileName}`);

        // Generate and upload PDF
        const pdfBytes = await generateInvoicePDF(sale);
        logger.info(`PDF generated: ${pdfBytes}`);
        if (!pdfBytes) throw new Error("Failed to generate PDF");

        const publicUrl = await StorageService.uploadPDF(
            "business-assets",
            fileName,
            pdfBytes,
        );
        logger.info(`Uploaded new PDF to: ${publicUrl}`);

        // Send notification if customer phone exists
        if (sale.customer?.phone) {
            const whatsappIntegration = await getWhatsappIntegration(
                sale.business_id,
            );
            await WhatsAppService.sendWhatsAppInvoiceTemplateMessage(
                sale,
                publicUrl,
                fileName,
                whatsappIntegration.whatsapp_number_id,
                whatsappIntegration.whatsapp_token,
            );
        }

        return `Notification sent successfully for sale ID: ${sale_id}`;
    } catch (error) {
        const errorMessage = error instanceof Error
            ? error.message
            : String(error);
        logger.error("Error processing invoice:", errorMessage);
        throw new Error(`Error processing invoice: ${errorMessage}`);
    }
}

/**
 * Fetch sale details from the database
 */
async function fetchSaleDetails(sale_id: string): Promise<SaleView> {
    const { data: sale, error } = await supabase
        .from("sale_view")
        .select()
        .eq("sale_id", sale_id)
        .single<SaleView>();

    if (error || !sale) {
        logger.error("Error fetching sale details:", error);
        throw new Error(`Error fetching sale details: ${error?.message}`);
    }
    return sale;
}

async function getWhatsappIntegration(business_id: string): Promise<{
    whatsapp_number_id: string;
    whatsapp_token: string;
}> {
    const { data, error: whatsappIntegrationError } = await supabase
        .from("whatsapp_integration")
        .select("whatsapp_number_id, whatsapp_token")
        .eq("business_id", business_id)
        .single();

    if (whatsappIntegrationError || !data) {
        logger.error(
            "Error fetching whatsapp integration details:",
            whatsappIntegrationError,
        );
        throw new Error(
            `Error fetching whatsapp integration details: ${whatsappIntegrationError?.message}`,
        );
    }
    return data;
}

/**
 * Generate standardized filename for the invoice
 */
function generateFileName(sale: SaleView): string {
    return `${sale.business.business_id}/sale_invoice/${sale.sale_invoice}.pdf`;
}
