// Setup type definitions for built-in Supabase Runtime APIs
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";
import { Hono } from "jsr:@hono/hono";
import { cors } from "jsr:@hono/hono/cors";
const supabaseClient = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);
const MSG91_API_KEY = Deno.env.get("MSG91_API_KEY");
const MSG91_TEMPLATE_ID = Deno.env.get("MSG91_TEMPLATE_ID");
const base64_secret = Deno.env.get("SEND_SMS_HOOK_SECRET")!;
const MSG91_URL = "https://control.msg91.com/api/v5/flow";
const functionName = "auth-hook";
const app = new Hono().basePath(`/${functionName}`);
app.use("*", cors());
// Endpoint to send OTP
app.post("/send-otp", async (c) => {
  console.log("[auth-hook] Received POST request");
  const body = await c.req.text();
  console.log("[auth-hook] Request body:", body);
  try {
    const headers = c.req.header();
    console.log("[auth-hook] Request headers:", headers);
    const wh = new Webhook(base64_secret);
    wh.verify(body, headers);
    console.log("[auth-hook] Request Verified");
    const { user, sms } = JSON.parse(body);
    console.log("[auth-hook] Parsed user data:", {
      user,
      sms,
    });
    const payload = {
      template_id: MSG91_TEMPLATE_ID,
      short_url: "0",
      recipients: [
        {
          mobiles: `${user.phone}`,
          var1: `${sms.otp}`,
        },
      ],
    };
    console.log("[auth-hook] Prepared MSG91 payload:", payload);
    const response = await fetch(MSG91_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "authkey": MSG91_API_KEY,
      },
      body: JSON.stringify(payload),
    });
    console.log("[auth-hook] MSG91 API response status:", response.status);
    const data = await response.json();
    console.log("[auth-hook] MSG91 API response data:", data);
    if (response.ok) {
      console.log("[auth-hook] Successfully sent OTP");
      return c.json({
        success: true,
        msg: "OTP sent successfully!",
        data,
      });
    } else {
      console.log("[auth-hook] Failed to send OTP:", response.status);
      return c.json({
        success: false,
        msg: "Failed to send OTP",
        data,
      }, {
        status: response.status,
      });
    }
  } catch (error) {
    console.error("[auth-hook] Error:", error);
    return c.json({
      success: false,
      msg: "Internal Server Error",
      error: error,
    }, {
      status: 500,
    });
  }
});
Deno.serve(app.fetch);
