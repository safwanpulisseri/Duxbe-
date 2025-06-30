import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// Initialize Supabase client with service role key for admin access
const supabaseUrl = "https://awfbsiftpwpiczdxlmig.supabase.co";
const supabaseServiceKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3ZmJzaWZ0cHdwaWN6ZHhsbWlnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY5Njk2ODY3NiwiZXhwIjoyMDEyNTQ0Njc2fQ.cDrdza-bFxQ1lEB6p9-sTgqqVuFkw17lyPgjwWO3P-0";
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
        debug: true,
    },
});

async function sendAdminMagicLink(email: string) {
    try {
        const { data, error } = await supabase.auth.admin.generateLink({
            email: email,
            type: "recovery",
            options: {
                redirectTo: "https://dev.duxbe.com/set_new_user?org_id=1",
            },
        });

        if (error) {
            console.error("Error sending magic link:", error.message);
            return { success: false, error: error.message };
        }

        console.log("Magic link generated successfully:", data);
        return { success: true, data };
    } catch (error) {
        console.error("Unexpected error:", error);
        return { success: false, error: "An unexpected error occurred" };
    }
}

async function sendMagicLink(email: string) {
    try {
        const { data, error } = await supabase.auth.signInWithOtp({
            email: email,
            options: {
                emailRedirectTo: "https://dev.duxbe.com/set_new_user?org_id=1",
            },
        });

        if (error) {
            console.error("Error sending magic link:", error.message);
            return { success: false, error: error.message };
        }

        console.log("Magic link generated successfully:", data);
        return { success: true, data };
    } catch (error) {
        console.error("Unexpected error:", error);
        return { success: false, error: "An unexpected error occurred" };
    }
}

// Example usage
async function main() {
    const result = await sendAdminMagicLink("alfasmirbz@gmail.com");
    // const result = await sendMagicLink("alfasmirbz@gmail.com");
    console.log("Result:", result);
}

main();
