import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.2";
import { SUPABASE_KEY, SUPABASE_URL } from "./constants.ts";

if (!SUPABASE_URL || !SUPABASE_KEY) {
    throw new Error(
        "Environment variables SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required.",
    );
}

// Initialize Supabase client with the environment variables
export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
