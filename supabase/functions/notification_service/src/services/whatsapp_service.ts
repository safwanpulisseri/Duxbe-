import { logger } from "../../index.ts";
import { SaleView } from "../types/sales.d.ts";

interface WhatsAppDocumentMessage {
    messaging_product: string;
    to: string;
    type: "document";
    document: {
        link: string;
        filename: string;
        caption: string;
    };
}

export class WhatsAppService {
    /**
     * Send WhatsApp notification with the invoice
     */
    static async sendWhatsAppNotification(
        sale: SaleView,
        publicUrl: string,
        fileName: string,
        whatsappNumberId: string,
        whatsappToken: string,
    ): Promise<void> {
        const whatsappApiUrl =
            `https://graph.facebook.com/v17.0/${whatsappNumberId}/messages`;
        const phoneNumber = sale.customer!.phone!.replace(/^\+/, "");

        const message: WhatsAppDocumentMessage = {
            messaging_product: "whatsapp",
            to: phoneNumber,
            type: "document",
            document: {
                link: publicUrl,
                filename: fileName.split("/").pop() ?? fileName,
                caption:
                    `Your invoice from ${sale.business.name} is ready: ${sale.sale_invoice}`,
            },
        };

        const response = await fetch(whatsappApiUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${whatsappToken}`,
            },
            body: JSON.stringify(message),
        });

        if (!response.ok) {
            const errorResponse = await response.text();
            throw new Error(
                `Failed to send WhatsApp message: ${errorResponse}`,
            );
        }
        logger.info(
            `WhatsApp document message sent successfully to ${phoneNumber}`,
        );
    }

    static async sendWhatsAppInvoiceTemplateMessage(
        sale: SaleView,
        publicUrl: string,
        fileName: string,
        whatsappNumberId: string,
        whatsappToken: string,
    ) {
        const whatsappApiUrl =
            `https://graph.facebook.com/v17.0/${whatsappNumberId}/messages`;
        const accessToken = whatsappToken;

        const body = {
            messaging_product: "whatsapp",
            to: sale.customer!.phone!.replace(/^\+/, ""),
            type: "template",
            template: {
                name: "invoice_receipt", // Replace with the approved template name
                language: {
                    code: "en_US", // Set the language for the template
                },
                components: [
                    // Add header with document information
                    {
                        type: "header",
                        parameters: [
                            {
                                type: "document",
                                document: {
                                    link: publicUrl, // Public URL to the document
                                    filename: fileName, // Document filename
                                },
                            },
                        ],
                    },
                    // Body component for personalized content
                    {
                        type: "body",
                        parameters: [
                            {
                                type: "text",
                                text: sale.business.name, // Replace with actual business name
                            },
                            {
                                type: "text",
                                text: sale.sale_invoice, // Replace with actual invoice number
                            },
                        ],
                    },
                ],
            },
        };

        const response = await fetch(whatsappApiUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${accessToken}`,
            },
            body: JSON.stringify(body),
        });

        if (!response.ok) {
            const errorResponse = await response.text();
            throw new Error(
                `Failed to send WhatsApp template message: ${errorResponse}`,
            );
        }

        logger.info(
            `WhatsApp document message sent successfully to ${
                sale.customer!.phone
            }`,
        );
    }
}
