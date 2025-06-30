// Use Deno.env.get to access environment variables in Supabase Edge Functions
export const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
export const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
