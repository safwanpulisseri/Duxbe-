// deno-lint-ignore-file no-explicit-any
import { Hono } from "jsr:@hono/hono";
import { cors } from "jsr:@hono/hono/cors";
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

// Assuming these are correctly defined for your project:
import { Payload } from "./payload.d.ts"; // Define this based on your webhook payload structure
import { Database } from "../database.types.ts"; // Supabase generated types

// --- Application Configuration ---
const config = {
  functionName: "duxbe-onboarding",
  serverPort: Deno.env.get("PORT") || "8000",

  zoho: {
    refreshToken: Deno.env.get("ZOHO_REFRESH_TOKEN"),
    clientId: Deno.env.get("ZOHO_CLIENT_ID"),
    clientSecret: Deno.env.get("ZOHO_CLIENT_SECRET"),
    pipelineIdDuxbeApp: Deno.env.get("ZOHO_PIPELINE_ID_DUXBE_APP"),
    subPipelineIdAppUsers: Deno.env.get("ZOHO_SUB_PIPELINE_ID_APP_USERS"),
    dataCenter: Deno.env.get("ZOHO_DATA_CENTER") || "com",
    get accountsUrl() {
      return `https://accounts.zoho.${this.dataCenter}`;
    },
    get biginApiUrl() {
      return `https://www.zohoapis.${this.dataCenter}/bigin/v2`;
    },
    isConfigured: function () {
      return !!(this.refreshToken && this.clientId && this.clientSecret &&
        this.pipelineIdDuxbeApp && this.subPipelineIdAppUsers);
    },
    getMissingConfig: function (): string[] {
      const missing: string[] = [];
      if (!this.refreshToken) missing.push("ZOHO_REFRESH_TOKEN");
      if (!this.clientId) missing.push("ZOHO_CLIENT_ID");
      if (!this.clientSecret) missing.push("ZOHO_CLIENT_SECRET");
      if (!this.pipelineIdDuxbeApp) missing.push("ZOHO_PIPELINE_ID_DUXBE_APP");
      if (!this.subPipelineIdAppUsers) {
        missing.push("ZOHO_SUB_PIPELINE_ID_APP_USERS");
      }
      return missing;
    },
  },

  wati: {
    apiToken: Deno.env.get("WATI_API_TOKEN"),
    apiEndpoint: Deno.env.get("WATI_API_ENDPOINT") ||
      "https://app.wati.io/api/v1/sendTemplateMessage",
    defaultTemplateName: Deno.env.get("WATI_DEFAULT_TEMPLATE_NAME"),
    isConfigured: function () { // Checks if WATI can be used by the /onboard-user endpoint
      return !!(this.apiToken && this.apiEndpoint && this.defaultTemplateName);
    },
    getMissingConfig: function (checkDefaultTemplate = true): string[] { // For more granular checks
      const missing: string[] = [];
      if (!this.apiToken) missing.push("WATI_API_TOKEN");
      // apiEndpoint has a default, so less likely to be "missing" for the default URL
      if (checkDefaultTemplate && !this.defaultTemplateName) {
        missing.push("WATI_DEFAULT_TEMPLATE_NAME");
      }
      return missing;
    },
  },

  email: {
    senderAddress: Deno.env.get("SENDER_EMAIL_ADDRESS"),
    senderName: Deno.env.get("SENDER_EMAIL_NAME") || "Team Duxbe",
    smtpHostname: Deno.env.get("SMTP_HOSTNAME"),
    smtpPort: Deno.env.get("SMTP_PORT"),
    smtpUsername: Deno.env.get("SMTP_USERNAME"),
    smtpPassword: Deno.env.get("SMTP_PASSWORD"),
    smtpTls: Deno.env.get("SMTP_TLS")?.toLowerCase() === "true",
    replyTo: Deno.env.get("REPLY_TO_EMAIL"),
    get fromAddressFormatted() {
      return this.senderName && this.senderAddress
        ? `"${this.senderName}" <${this.senderAddress}>`
        : this.senderAddress || "";
    },
    isConfigured: function () {
      return !!(this.senderAddress && this.smtpHostname && this.smtpPort &&
        this.smtpUsername && this.smtpPassword && this.replyTo);
    },
    getMissingConfig: function (): string[] {
      const missing: string[] = [];
      if (!this.senderAddress) missing.push("SENDER_EMAIL_ADDRESS");
      if (!this.smtpHostname) missing.push("SMTP_HOSTNAME");
      if (!this.smtpPort) missing.push("SMTP_PORT");
      if (!this.smtpUsername) missing.push("SMTP_USERNAME");
      if (!this.smtpPassword) missing.push("SMTP_PASSWORD");
      if (!this.replyTo) missing.push("REPLY_TO_EMAIL");
      return missing;
    },
  },

  supabase: {
    url: Deno.env.get("SUPABASE_URL"),
    serviceRoleKey: Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
    isConfigured: function () {
      return !!(this.url && this.serviceRoleKey);
    },
  },
};

// --- Hono App Initialization ---
const app = new Hono().basePath(`/${config.functionName}`);
app.use(cors());

// --- Supabase Client Initialization ---
if (!config.supabase.isConfigured()) {
  console.error(
    "FATAL: Supabase URL or Service Role Key is not configured. Functionality will be impaired.",
  );
  // For an edge function, it will likely fail on first use of supabaseClient
}
const supabaseClient = createClient<Database>(
  config.supabase.url!,
  config.supabase.serviceRoleKey!,
);

// --- Zoho Helper Functions ---
async function getZohoAccessToken(): Promise<string> {
  if (
    !config.zoho.refreshToken || !config.zoho.clientId ||
    !config.zoho.clientSecret
  ) {
    throw new Error("Missing Zoho OAuth credentials in environment variables.");
  }
  const tokenUrl = `${config.zoho.accountsUrl}/oauth/v2/token`;
  const params = new URLSearchParams({
    refresh_token: config.zoho.refreshToken,
    client_id: config.zoho.clientId,
    client_secret: config.zoho.clientSecret,
    grant_type: "refresh_token",
  });

  const response = await fetch(tokenUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: params,
  });

  if (!response.ok) {
    let errorDetails = "";
    try {
      const errorData = await response.json();
      errorDetails = errorData.error || JSON.stringify(errorData);
    } catch (e) {
      errorDetails = await response.text().catch(() =>
        "Could not parse error response body" + e
      );
    }
    console.error("Zoho Token Error Response:", errorDetails);
    throw new Error(
      `Failed to fetch Zoho access token: ${response.status} ${response.statusText} - ${errorDetails}`,
    );
  }
  const data = await response.json();
  if (!data.access_token) {
    console.error("Zoho Token No Access Token:", data);
    throw new Error("No access_token received from Zoho.");
  }
  return data.access_token;
}

async function createZohoContact(
  accessToken: string,
  email: string,
  firstName?: string,
  lastName?: string,
): Promise<string> {
  const contactPayload = {
    data: [{
      Email: email,
      First_Name: firstName || "",
      Last_Name: lastName || email.split("@")[0] || "User",
    }],
  };
  const response = await fetch(`${config.zoho.biginApiUrl}/Contacts`, {
    method: "POST",
    headers: {
      "Authorization": `Zoho-oauthtoken ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(contactPayload),
  });
  const responseData = await response.json();
  if (
    !response.ok || !responseData.data ||
    responseData.data[0].status !== "success"
  ) {
    console.error("Zoho Create Contact Error Response:", responseData);
    const message = responseData.data?.[0]?.message || responseData.message ||
      responseData.error || response.statusText;
    throw new Error(`Failed to create Zoho contact: ${message}`);
  }
  return responseData.data[0].details.id;
}

async function createZohoDeal(
  accessToken: string,
  contactId: string,
  dealName: string,
): Promise<any> { // Returns deal details object
  if (!config.zoho.pipelineIdDuxbeApp || !config.zoho.subPipelineIdAppUsers) {
    throw new Error(
      "Zoho Pipeline/Sub-pipeline IDs are not set in environment variables.",
    );
  }
  const dealPayload = {
    data: [{
      Deal_Name: dealName,
      Stage: "Sign Up", // Consider making this configurable if stages vary
      Contact_Name: { id: contactId }, // API v2 often requires related records as objects with id
      Pipeline: { id: config.zoho.pipelineIdDuxbeApp }, // Assuming this is the main pipeline ID
      // Sub_Pipeline: { id: config.zoho.subPipelineIdAppUsers }, // For Bigin v2, sub-pipelines are often tied to Stages within the main Pipeline.
      // Or this could be a custom field.
      // If original code worked with Sub_Pipeline as a direct string ID, it may be a custom field or specific setup.
      // Using string ID as per original for now:
      Sub_Pipeline: config.zoho.subPipelineIdAppUsers, // Verify this field name and if it accepts a direct ID in your Bigin setup.
    }],
  };

  // CRITICAL FIX: Endpoint for creating Deals is /Deals
  const response = await fetch(`${config.zoho.biginApiUrl}/Deals`, {
    method: "POST",
    headers: {
      "Authorization": `Zoho-oauthtoken ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(dealPayload),
  });
  const responseData = await response.json();
  if (
    !response.ok || !responseData.data ||
    responseData.data[0].status !== "success"
  ) {
    console.error("Zoho Create Deal Error Response:", responseData);
    const message = responseData.data?.[0]?.message || responseData.message ||
      responseData.error || response.statusText;
    throw new Error(`Failed to create Zoho deal: ${message}`);
  }
  return responseData.data[0].details;
}

// --- Standalone Hono Endpoints ---
app.post("/create-bigin-user-deal", async (c) => {
  try {
    const body = await c.req.json<
      {
        email: string;
        firstName?: string;
        lastName?: string;
        dealName?: string;
      }
    >();
    const { email, firstName, lastName } = body;
    const dealName = body.dealName || `New Sign Up - ${email}`;

    if (!email) {
      return c.json({ error: "Email is required" }, 400);
    }

    if (!config.zoho.isConfigured()) {
      const missingVars = config.zoho.getMissingConfig().join(", ");
      console.error(
        `Missing critical Zoho environment variables: ${missingVars}`,
      );
      return c.json({
        error:
          `Server configuration error for Zoho integration. Missing: ${missingVars}`,
      }, 500);
    }

    console.log(`Processing Zoho creation for email: ${email}`);
    const accessToken = await getZohoAccessToken();
    console.log("Successfully obtained Zoho access token.");

    const contactId = await createZohoContact(
      accessToken,
      email,
      firstName,
      lastName,
    );
    console.log(`Successfully created contact with ID: ${contactId}`);

    const dealDetails = await createZohoDeal(accessToken, contactId, dealName);
    console.log(`Successfully created deal with ID: ${dealDetails.id}`);

    return c.json({
      message: "Successfully created contact and deal in Zoho Bigin",
      contactId: contactId,
      dealId: dealDetails.id,
      dealDetails: dealDetails,
    });
  } catch (error) {
    console.error("Error in /create-bigin-user-deal endpoint:", error);
    const message = error instanceof Error
      ? error.message
      : "An internal server error occurred";
    return c.json({ error: message }, 500);
  }
});

app.post("/send-wati-message", async (c) => {
  try {
    const body = await c.req.json<
      { phone: string; name: string; product: string; templateName?: string }
    >();
    const { name, product } = body;
    const phone = body.phone?.replace(/\D/g, "");
    const templateName = body.templateName || config.wati.defaultTemplateName;

    if (!phone || !name || !product) {
      return c.json({
        error: "Missing required parameters: phone (cleaned), name, or product",
      }, 400);
    }
    if (!config.wati.apiToken) {
      console.error("Missing WATI_API_TOKEN in environment variables.");
      return c.json({
        error: "Server configuration error: WATI_API_TOKEN missing.",
      }, 500);
    }
    if (!templateName) {
      console.error(
        "Missing WATI template name (neither in request nor WATI_DEFAULT_TEMPLATE_NAME env).",
      );
      return c.json({
        error: "Server configuration error: WATI template name not specified.",
      }, 500);
    }

    const watiPayload = {
      template_name: templateName,
      broadcast_name: `lead_to_whatsapp_${
        name.replace(/\s+/g, "_")
      }_${Date.now()}`,
      parameters: [
        { name: "name", value: name },
        { name: "product", value: product },
      ],
    };

    console.log(
      `Sending WATI message to ${phone} with template ${templateName}`,
    );
    const response = await fetch(
      `${config.wati.apiEndpoint}?whatsappNumber=${phone}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${config.wati.apiToken}`,
        },
        body: JSON.stringify(watiPayload),
      },
    );
    const responseData = await response.json().catch(() => ({}));

    if (!response.ok) {
      console.error("WATI API Error Response:", responseData);
      const message = responseData.message || responseData.error ||
        "Unknown WATI API error";
      throw new Error(
        `Failed to send WATI message: ${response.status} ${response.statusText} - ${message}`,
      );
    }
    console.log("WATI API Success Response:", responseData);

    if (
      responseData.result === false ||
      (responseData.status && responseData.status.toLowerCase() !== "sent" &&
        responseData.status.toLowerCase() !== "queued")
    ) {
      console.warn("WATI message sending indicated failure:", responseData);
      return c.json({
        message: "Message sent to WATI, but WATI indicated an issue.",
        watiResponse: responseData,
      }, 207);
    }
    return c.json({
      message: "Successfully sent message via WATI",
      watiResponse: responseData,
    });
  } catch (error) {
    console.error("Error in /send-wati-message endpoint:", error);
    return c.json({
      error: error instanceof Error
        ? error.message
        : "An internal server error occurred",
    }, 500);
  }
});

const INVITATION_EMAIL_HTML_CONTENT = (firstName: string) => `
<p>Hey ${firstName},</p>
<p>Welcome aboard! 🎉 We're thrilled to have you join Duxbe.</p>
<p>You've just taken a fantastic step towards simplifying your shop management — whether you're selling offline, online, or directly through WhatsApp.</p>
<p><strong>Here's your immediate next step to get rolling:</strong></p>
<ol>
    <li>👉 <strong>Add your items to the app.</strong> This is key to unlocking Duxbe's power!</li>
    <li>📽️ <em>Need a hand?</em> <a href="https://www.youtube.com/watch?v=GVjeYItUTZs" target="_blank" rel="noopener noreferrer">Watch this quick video guide on how to add items.</a></li>
</ol>
<p>Once your items are in, you're ready to start selling like a pro!</p>
<p><strong>Got questions or need a bit of help?</strong> Our dedicated team is always here for you. Just reply to this email, and we'll be happy to assist.</p>
<p>Let's make your business smarter, together.</p>
<p>Cheers,<br>
<strong>The Duxbe Team</strong><br>
<em>Smarter Data. Stronger Business.</em></p>
    `;

const INVITATION_EMAIL_TEXT_CONTENT = (firstName: string) => `
Hey ${firstName},

Welcome aboard! 🎉 We're thrilled to have you join Duxbe.

You've just taken a fantastic step towards simplifying your shop management — whether you're selling offline, online, or directly through WhatsApp.

Here's your immediate next step to get rolling:
1. 👉 Add your items to the app. This is key to unlocking Duxbe's power!
2. 📽️ Need a hand? Watch this quick video guide on how to add items: https://www.youtube.com/watch?v=GVjeYItUTZs

Once your items are in, you're ready to start selling like a pro!

Got questions or need a bit of help? Our dedicated team is always here for you. Just reply to this email, and we'll be happy to assist.

Let's make your business smarter, together.

Cheers,
The Duxbe Team
Smarter Data. Stronger Business.
    `;

app.post("/send-invitation-email", async (c) => {
  try {
    const body = await c.req.json<{ email: string; firstName: string }>();
    const { email, firstName } = body;

    if (!email || !firstName) {
      return c.json({
        error: "Missing required parameters: email or firstName",
      }, 400);
    }
    if (!config.email.isConfigured()) {
      const missingVars = config.email.getMissingConfig().join(", ");
      console.error(`Missing SMTP configuration: ${missingVars}`);
      return c.json({
        error:
          `Server configuration error for email sending. Missing: ${missingVars}`,
      }, 500);
    }

    const subject = `🎉 Welcome to Duxbe, ${firstName}! Let's Get You Started.`;
    const smtpClient = new SMTPClient({
      connection: {
        hostname: config.email.smtpHostname!,
        port: parseInt(config.email.smtpPort!),
        tls: config.email.smtpTls,
        auth: {
          username: config.email.smtpUsername!,
          password: config.email.smtpPassword!,
        },
      },
    });
    await smtpClient.send({
      from: config.email.fromAddressFormatted,
      to: email,
      subject: subject,
      content: INVITATION_EMAIL_TEXT_CONTENT(firstName),
      html: INVITATION_EMAIL_HTML_CONTENT(firstName),
      replyTo: config.email.replyTo!,
      headers: {
        "X-Mailer": "Deno Mailer",
        "X-Priority": "1",
        "X-MSMail-Priority": "High",
        "Importance": "high",
      },
    });
    console.log(`Invitation email successfully sent to: ${email}`);
    return c.json({ message: "Invitation email sent successfully." });
  } catch (error) {
    console.error("Error in /send-invitation-email endpoint:", error);
    return c.json({
      error: error instanceof Error
        ? error.message
        : "An internal server error occurred while sending email.",
    }, 500);
  }
});

// --- All-in-One Onboarding Endpoint ---
app.post("/onboard-user", async (c) => {
  const results = {
    zoho: {
      success: false,
      data: null as any,
      error: null as string | null,
      skipped: false,
    },
    wati: {
      success: false,
      data: null as any,
      error: null as string | null,
      skipped: false,
    },
    email: {
      success: false,
      message: null as string | null,
      error: null as string | null,
      skipped: false,
    },
  };

  try {
    // Assuming Payload is for a DB trigger, `record` contains the new/updated row.
    // `organizations` is the table name. `created_by` is a UUID linking to auth.users.
    const payload = await c.req.json() as Payload<
      Database["public"]["Tables"]["organizations"]["Row"]
    >;

    if (!payload || !payload.record || !payload.record.created_by) {
      const detail = (!payload || !payload.record)
        ? "Invalid payload: 'record' missing."
        : "'record.created_by' (user ID) is required.";
      return c.json({ error: `Invalid request payload. ${detail}` }, 400);
    }
    const createdByUserId = payload.record.created_by;
    const organizationName = payload.record.name || "New Organization";

    if (!config.supabase.isConfigured()) {
      console.error("[Onboard-User] Supabase client not configured on server.");
      return c.json({
        error: "Server configuration error: Supabase client not available.",
      }, 500);
    }

    // Fetch user details from Supabase `users` table (public schema, not auth.users directly with service_role)
    // Adjust selected fields as per your 'users' table schema (e.g., first_name, last_name, phone_number)
    const { data: user, error: userError } = await supabaseClient
      .from("users") // Your public 'users' table that mirrors/extends auth.users
      .select("*") // Example: raw_user_meta_data might contain name
      .eq("user_id", createdByUserId) // Match against the user's UUID
      .single();

    if (userError) {
      console.error("[Onboard-User] Supabase user fetch error:", userError);
      return c.json({
        error: `Error fetching user details: ${userError.message}`,
      }, 500);
    }
    if (!user) {
      return c.json(
        { error: `User not found with ID: ${createdByUserId}` },
        404,
      );
    }

    const userEmail = user.email;
    // Determine firstName: try raw_user_meta_data, then split email, then default
    const userFirstName = user.name;
    const userPhoneRaw = user.phone;
    const userPhoneCleaned = userPhoneRaw?.replace(/\D/g, "");

    if (!userEmail || !userFirstName || !userPhoneCleaned) {
      return c.json({
        error:
          "Missing critical user information (email, name, or phone) after fetching from database.",
        details: {
          email: !!userEmail,
          firstName: !!userFirstName,
          phone: !!userPhoneCleaned,
        },
      }, 400);
    }

    const productName = "Duxbe"; // Product name for WATI
    const zohoDealName = `New Sign Up - ${userEmail} (${organizationName})`;
    const watiUserName = userFirstName; // Name for WATI template variable

    // --- 2. Zoho Bigin Integration ---
    if (config.zoho.isConfigured()) {
      try {
        console.log(`[Onboard-User] Processing Bigin for email: ${userEmail}`);
        const accessToken = await getZohoAccessToken();
        // For Zoho contact, user's first name, and organization name as last name/company context
        const contactId = await createZohoContact(
          accessToken,
          userEmail,
          userFirstName,
          organizationName,
        );
        results.zoho.data = { contactId };
        console.log(`[Onboard-User] Created Zoho contact ID: ${contactId}`);

        const dealDetails = await createZohoDeal(
          accessToken,
          contactId,
          zohoDealName,
        );
        results.zoho.success = true;
        results.zoho.data = {
          ...results.zoho.data,
          dealId: dealDetails.id,
          dealDetails,
        };
        console.log(`[Onboard-User] Created Zoho deal ID: ${dealDetails.id}`);
      } catch (error) {
        console.error("[Onboard-User] Error in Zoho Bigin integration:", error);
        results.zoho.error = error instanceof Error
          ? error.message
          : "Zoho Bigin integration failed.";
      }
    } else {
      const missing = config.zoho.getMissingConfig().join(", ");
      results.zoho.error = `Skipped: Missing Zoho configuration (${missing}).`;
      results.zoho.skipped = true;
      console.warn(`[Onboard-User] ${results.zoho.error}`);
    }

    // --- 3. WATI Message Sending ---
    const watiTemplateName = config.wati.defaultTemplateName;
    if (config.wati.apiToken && watiTemplateName) { // Check essential WATI config for this operation
      try {
        console.log(
          `[Onboard-User] Sending WATI to ${userPhoneCleaned} (template: ${watiTemplateName})`,
        );
        const watiApiPayload = {
          template_name: watiTemplateName,
          broadcast_name: `onboarding_${userPhoneCleaned}_${Date.now()}`,
          parameters: [{ name: "name", value: watiUserName }, {
            name: "product",
            value: productName,
          }],
        };
        const response = await fetch(
          `${config.wati.apiEndpoint}?whatsappNumber=${userPhoneCleaned}`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${config.wati.apiToken}`,
            },
            body: JSON.stringify(watiApiPayload),
          },
        );
        const responseData = await response.json().catch(() => ({}));
        if (!response.ok) {
          throw new Error(
            `WATI API Error: ${response.status} - ${
              responseData.message || responseData.error || "Unknown"
            }`,
          );
        }
        results.wati.data = responseData;
        if (
          responseData.result === false ||
          (responseData.status &&
            !["sent", "queued"].includes(responseData.status.toLowerCase()))
        ) {
          results.wati.error = `WATI reported issue: ${
            responseData.message || responseData.error || responseData.status ||
            "Details in data"
          }`;
          console.warn(`[Onboard-User] ${results.wati.error}`, responseData);
        }
        results.wati.success = true; // API call succeeded, even if WATI reported an issue with the message itself
      } catch (error) {
        console.error("[Onboard-User] Error sending WATI message:", error);
        results.wati.error = error instanceof Error
          ? error.message
          : "WATI message sending failed.";
      }
    } else {
      const missing = config.wati.getMissingConfig().join(", "); // Will show default template name if missing
      results.wati.error = `Skipped: Missing WATI configuration (${missing}).`;
      results.wati.skipped = true;
      console.warn(`[Onboard-User] ${results.wati.error}`);
    }

    // --- 4. Send Invitation Email ---
    if (config.email.isConfigured()) {
      try {
        console.log(`[Onboard-User] Sending invitation email to: ${userEmail}`);
        const emailSubject =
          `🎉 Welcome to Duxbe, ${userFirstName}! Let's Get You Started.`;
        const smtpClient = new SMTPClient({
          connection: {
            hostname: config.email.smtpHostname!,
            port: parseInt(config.email.smtpPort!),
            tls: config.email.smtpTls,
            auth: {
              username: config.email.smtpUsername!,
              password: config.email.smtpPassword!,
            },
          },
        });
        await smtpClient.send({
          from: config.email.fromAddressFormatted,
          to: userEmail,
          subject: emailSubject,
          content: INVITATION_EMAIL_TEXT_CONTENT(userFirstName),
          html: INVITATION_EMAIL_HTML_CONTENT(userFirstName),
          replyTo: config.email.replyTo!,
          headers: {
            "X-Mailer": "Deno Mailer",
            "X-Priority": "1",
            "X-MSMail-Priority": "High",
            "Importance": "high",
          },
        });
        results.email.success = true;
        results.email.message = "Invitation email sent successfully.";
        console.log(`[Onboard-User] Invitation email sent to: ${userEmail}`);
      } catch (error) {
        console.error("[Onboard-User] Error sending invitation email:", error);
        results.email.error = error instanceof Error
          ? error.message
          : "Email sending failed.";
      }
    } else {
      const missing = config.email.getMissingConfig().join(", ");
      results.email.error = `Skipped: Missing SMTP configuration (${missing}).`;
      results.email.skipped = true;
      console.warn(`[Onboard-User] ${results.email.error}`);
    }

    // --- 5. Return Combined Results ---
    let httpStatusCode = 200;
    if (
      (results.zoho.error && !results.zoho.skipped) ||
      (results.wati.error && !results.wati.skipped &&
        results.wati.data?.result !== false) || // Count actual WATI API call errors, not WATI's own rejections if API call was ok
      (results.email.error && !results.email.skipped)
    ) {
      httpStatusCode = 207; // Error in an attempted operation
    } else if (
      results.zoho.skipped || results.wati.skipped || results.email.skipped ||
      results.wati.data?.result === false
    ) {
      httpStatusCode = 207; // Some operations skipped or WATI rejected message
    }
    return c.json(results, { status: httpStatusCode });
  } catch (error) { // Catch critical errors like JSON parsing, initial DB call, etc.
    console.error("[Onboard-User] Critical error in endpoint:", error);
    // Populate results with the critical error if not already set by a specific service
    const errorMessage = error instanceof Error
      ? error.message
      : "Critical internal server error.";
    results.zoho.error = results.zoho.error ||
      (results.zoho.skipped ? results.zoho.error : errorMessage);
    results.wati.error = results.wati.error ||
      (results.wati.skipped ? results.wati.error : errorMessage);
    results.email.error = results.email.error ||
      (results.email.skipped ? results.email.error : errorMessage);

    return c.json({
      error: "An internal server error occurred during the onboarding flow.",
      detail: errorMessage,
      results,
    }, 500);
  }
});

// --- Health Check & Server Start ---
app.get(
  "/",
  (c) =>
    c.text(
      `${config.functionName} is running! (Zoho Deal v2, Onboarding Flow)`,
    ),
);

Deno.serve({ port: parseInt(config.serverPort) }, app.fetch);
console.log(`Hono server listening on http://localhost:${config.serverPort}`);
