import { supabase } from "../config/supabase.ts";

export class StorageService {
    /**
     * Upload a new PDF to the specified Supabase storage bucket.
     */
    static async uploadPDF(
        bucket: string,
        fileName: string,
        pdfBytes: Uint8Array,
    ): Promise<string> {
        const { data, error } = await supabase.storage.from(bucket).upload(
            fileName,
            pdfBytes,
            {
                cacheControl: "3600",
                upsert: true,
                contentType: "application/pdf",
            },
        );

        if (error) {
            throw new Error(`Failed to upload PDF: ${error.message}`);
        }

        const { data: { publicUrl } } = supabase.storage.from(bucket)
            .getPublicUrl(data.path);
        return publicUrl;
    }
}
