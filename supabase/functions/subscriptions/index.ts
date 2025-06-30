// deno-lint-ignore-file
// deno-deploy-subscriptions-function.ts

// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2.49.4";
import Razorpay from "npm:razorpay@2.9.6";

import { Hono } from "jsr:@hono/hono";
import { cors } from "jsr:@hono/hono/cors";
import { poweredBy } from "jsr:@hono/hono/powered-by";
import { Database } from "../database.types.ts";
import {
  RazorpaySubscriptionBaseRequestBody,
  RazorpayWebhookEvent,
} from "./razorpay.ts"; // Not used in this file directly, but good for context
const { createHmac } = await import("node:crypto");

// --- Configuration ---
const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID");
const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET");
const RAZORPAY_WEBHOOK_SECRET = Deno.env.get("RAZORPAY_WEBHOOK_SECRET");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

// Validate essential environment variables
if (
  !RAZORPAY_KEY_ID ||
  !RAZORPAY_KEY_SECRET ||
  !RAZORPAY_WEBHOOK_SECRET ||
  !SUPABASE_URL ||
  !SUPABASE_SERVICE_ROLE_KEY
) {
  console.error(
    "FATAL: Missing one or more critical environment variables (Razorpay or Supabase credentials).",
  );
  throw new Error("Missing critical environment variables.");
}

// --- Initialize Clients ---
const razorpayClient = new Razorpay({
  key_id: RAZORPAY_KEY_ID,
  key_secret: RAZORPAY_KEY_SECRET,
});

const supabaseClient: SupabaseClient<Database> = createClient<Database>(
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
);

// --- Hono App Setup ---
const functionName = "subscriptions";
const app = new Hono().basePath(`/${functionName}`);

// --- Middleware ---
app.use("*", cors());
app.use("*", poweredBy({ serverName: "Duxbe" }));

// --- Helper Functions ---
function logInfo(message: string, context?: Record<string, any>) {
  console.log(
    JSON.stringify({ level: "INFO", message, functionName, ...context }),
  );
}

function logError(message: string, error?: any, context?: Record<string, any>) {
  const errorDetails = error instanceof Error
    ? { errorMessage: error.message, stack: error.stack }
    : { errorInfo: error };
  console.error(
    JSON.stringify({
      level: "ERROR",
      message,
      functionName,
      ...errorDetails,
      ...context,
    }),
  );
}

// --- Routes ---
app.get("/", (c) => {
  logInfo("Root endpoint hit");
  return c.json({ message: "Subscription service is active." });
});

app.post("/create-subscription", async (c) => {
  const requestContext = { route: "/create-subscription", method: "POST" };
  logInfo("Received request to /create-subscription", requestContext);

  try {
    const {
      plan_id,
      addon_id,
      org_id,
      country_code,
      billing_cycle,
      quantity,
      item_type, // "plan" or "addon"
    } = await c.req.json();

    if (
      !org_id || !country_code || !billing_cycle || !item_type ||
      (item_type === "plan" && !plan_id) ||
      (item_type === "addon" && !addon_id)
    ) {
      logError("Missing required fields for create-subscription", null, {
        ...requestContext,
        body: {
          plan_id,
          addon_id,
          org_id,
          country_code,
          billing_cycle,
          item_type,
          quantity,
        },
      });
      return c.json(
        {
          message:
            "Missing required fields. Ensure org_id, country_code, billing_cycle, item_type, and either plan_id (for item_type 'plan') or addon_id (for item_type 'addon') are provided.",
        },
        400,
      );
    }

    if (item_type === "plan" && addon_id) {
      logError(
        "Ambiguous request: both plan_id and addon_id provided with item_type 'plan'",
        null,
        requestContext,
      );
      return c.json(
        { message: "Provide only plan_id for item_type 'plan'." },
        400,
      );
    }
    if (item_type === "addon" && plan_id) {
      logError(
        "Ambiguous request: both plan_id and addon_id provided with item_type 'addon'",
        null,
        requestContext,
      );
      return c.json(
        { message: "Provide only addon_id for item_type 'addon'." },
        400,
      );
    }

    switch (country_code) {
      case "IN": {
        let result: CreateSubscriptionResult;
        if (item_type === "plan") {
          if (!plan_id) { // Should be caught by earlier check, but good for safety
            return c.json({
              message: "plan_id is required for item_type 'plan'",
            }, 400);
          }
          result = await createSubscription_IN(
            plan_id,
            billing_cycle,
            org_id,
          );
        } else if (item_type === "addon") {
          if (!addon_id) { // Should be caught by earlier check
            return c.json({
              message: "addon_id is required for item_type 'addon'",
            }, 400);
          }
          result = await createAddonSubscription_IN(
            addon_id,
            billing_cycle,
            org_id,
            country_code, // Addons need country_code for pricing
            quantity,
          );
        } else {
          logError("Invalid item_type for subscription", null, {
            ...requestContext,
            item_type,
          });
          return c.json({
            message: "Invalid item_type. Must be 'plan' or 'addon'.",
          }, 400);
        }

        if (result.error) {
          logError(
            `Error creating IN ${item_type} subscription`,
            { message: result.error },
            {
              ...requestContext,
              org_id,
              plan_id: item_type === "plan" ? plan_id : undefined,
              addon_id: item_type === "addon" ? addon_id : undefined,
              status: result.status,
            },
          );
          return c.json(
            { message: result.error, status: result.status || 500 },
          );
        }
        logInfo(
          `Successfully initiated IN ${item_type} subscription creation`,
          {
            ...requestContext,
            org_id,
            plan_id: item_type === "plan" ? plan_id : undefined,
            addon_id: item_type === "addon" ? addon_id : undefined,
            paymentUrl: result.payment_url,
          },
        );
        return c.json({
          payment_url: result.payment_url,
          message: result.message,
        });
      }
      default:
        logError("Invalid country code for subscription", null, {
          ...requestContext,
          country_code,
        });
        return c.json({ message: "Invalid country code" }, 400);
    }
  } catch (error) {
    logError("Unhandled error in /create-subscription", error, requestContext);
    return c.json(
      {
        message:
          "An unexpected error occurred while creating the subscription.",
      },
      500,
    );
  }
});

interface CreateSubscriptionResult {
  payment_url?: string | null;
  message?: string;
  error?: string;
  status?: number;
}

async function createSubscription_IN(
  plan_id: number,
  billing_cycle: "monthly" | "annually",
  org_id: string,
): Promise<CreateSubscriptionResult> {
  const functionContext = {
    function: "createSubscription_IN",
    org_id,
    plan_id,
    billing_cycle,
  };
  logInfo("Attempting to initiate IN subscription", functionContext);

  try {
    // 1. Fetch Razorpay plan ID for the target plan
    const { data: targetPlanData, error: planError } = await supabaseClient
      .from("razorpay_plans")
      .select("razorpay_plan_id, plans(name)")
      .eq("plan_id", plan_id)
      .eq("billing_cycle", billing_cycle)
      .single();

    if (planError || !targetPlanData) {
      logError(
        "Error fetching Razorpay plan details for target plan",
        planError,
        functionContext,
      );
      return {
        error:
          `Razorpay plan not found for plan_id: ${plan_id} and billing_cycle: ${billing_cycle}`,
        status: 404,
      };
    }
    const newRazorpayPlanId = targetPlanData.razorpay_plan_id;
    const newInternalPlanName = targetPlanData.plans?.name ||
      `Plan ID ${plan_id}`;

    const { data: currentOrgPlanData, error: currentOrgPlanError } =
      await supabaseClient
        .from("org_details_view")
        .select("active_subscription_details")
        .eq("org_id", org_id)
        .maybeSingle();

    if (currentOrgPlanError) {
      logError(
        "DB error fetching current org details",
        currentOrgPlanError,
        functionContext,
      );
      return { error: "Could not verify current subscription.", status: 500 };
    }

    // 2. Handle Downgrade to Free Plan (special case, plan_id = 1)
    if (plan_id === 1) {
      logInfo("Processing request to switch to Free Plan.", functionContext);
      const currentSubDetails = currentOrgPlanData
        ?.active_subscription_details as {
          payment_provider_subscription_id?: string;
          plan_id: number;
        } | null;

      if (currentSubDetails && currentSubDetails.plan_id === 1) {
        return { message: "Already on the free plan.", status: 200 };
      }

      if (
        currentSubDetails && currentSubDetails.payment_provider_subscription_id
      ) {
        try {
          logInfo(
            `Cancelling existing Razorpay subscription ${currentSubDetails.payment_provider_subscription_id} for switch to free.`,
            functionContext,
          );
          await razorpayClient.subscriptions.cancel(
            currentSubDetails.payment_provider_subscription_id,
          );
        } catch (razorpayCancelError) {
          logError(
            "Failed to cancel existing Razorpay subscription for switch to free.",
            razorpayCancelError,
            functionContext,
          );
          return {
            error:
              "Failed to cancel previous paid subscription. Please contact support.",
            status: 500,
          };
        }
      }

      const { error: rpcFreePlanError } = await supabaseClient.rpc(
        "handle_free_plan_switch",
        {
          p_org_id: org_id,
          p_start_date: new Date().toISOString(),
        },
      );

      if (rpcFreePlanError) {
        logError(
          "Failed to record free plan in DB via RPC.",
          rpcFreePlanError,
          functionContext,
        );
        return {
          error:
            "Failed to activate free plan in our records after cancelling paid one. Please contact support.",
          status: 500,
        };
      }
      logInfo("Successfully switched to free plan.", functionContext);
      return {
        message: "Successfully switched to the free plan.",
        status: 200,
      };
    }

    // 3. For Paid Plans: Check if already on the same paid plan
    const { data: existingIdenticalPaidSub, error: checkError } =
      await supabaseClient
        .from("subscriptions")
        .select("subscription_id")
        .eq("org_id", org_id)
        .eq("plan_id", plan_id)
        .in("status", ["active", "trialing", "past_due"])
        .not("payment_provider_subscription_id", "is", null)
        .maybeSingle();

    if (checkError) {
      logError(
        "DB error checking for existing identical paid subscription.",
        checkError,
        functionContext,
      );
      return {
        error: "Failed to verify current subscription status.",
        status: 500,
      };
    }
    if (existingIdenticalPaidSub) {
      logInfo(
        "Org already has an active-like subscription to this exact paid plan.",
        functionContext,
      );
      return {
        error:
          `Organization ${org_id} is already subscribed to or trialing plan ${newInternalPlanName}.`,
        status: 409, // Conflict
      };
    }

    // If there is any other 'pending_activation' subscription, cancel it.
    const { data: pendingActivations, error: pendingActivationError } =
      await supabaseClient
        .from("subscriptions")
        .select("subscription_id, payment_provider_subscription_id")
        .eq("org_id", org_id)
        .eq("status", "pending_activation");

    if (pendingActivationError) {
      logError(
        "DB error fetching pending_activation subscriptions.",
        pendingActivationError,
        functionContext,
      );
    }
    if (pendingActivations && pendingActivations.length > 0) {
      for (const pendingSub of pendingActivations) {
        if (pendingSub.payment_provider_subscription_id) {
          try {
            logInfo(
              `Cancelling existing pending_activation Razorpay subscription ${pendingSub.payment_provider_subscription_id}.`,
              {
                ...functionContext,
                pending_sub_id: pendingSub.subscription_id,
              },
            );
            await razorpayClient.subscriptions.cancel(
              pendingSub.payment_provider_subscription_id,
            );
          } catch (cancelPendingError) {
            logError(
              `Failed to cancel a pending_activation Razorpay subscription ${pendingSub.payment_provider_subscription_id}. This might lead to multiple pending subs if not resolved.`,
              cancelPendingError,
              {
                ...functionContext,
                pending_sub_id: pendingSub.subscription_id,
              },
            );
            // Consider halting: return { error: "Failed to clean up old pending subscriptions.", status: 500 };
          }
        }
      }
    }

    // 4. Create NEW Razorpay subscription for the target paid plan
    logInfo(
      `Creating new Razorpay subscription for target paid plan ${newInternalPlanName}.`,
      functionContext,
    );

    const razorpaySubscriptionPayload: RazorpaySubscriptionBaseRequestBody = {
      plan_id: newRazorpayPlanId,
      customer_notify: 0,
      quantity: 1,
      total_count: billing_cycle === "monthly" ? 60 : 5, // 5 years
      notes: {
        org_id: org_id,
        internal_plan_id: plan_id.toString(),
        billing_cycle: billing_cycle,
        item_type: "plan",
      },
    };

    const newRazorpaySubscription = await razorpayClient.subscriptions.create(
      razorpaySubscriptionPayload,
    );

    const newRazorpaySubscriptionInvoices = await razorpayClient.invoices.all({
      subscription_id: newRazorpaySubscription.id,
      count: 10,
    });

    // 5. Atomically insert subscription, invoices, and update org via RPC
    const initialStatusForNewSub:
      Database["public"]["Enums"]["subscription_status_enum"] =
        "pending_activation";

    const dbTrialEndDate = new Date(
      Date.now(),
    ).toISOString();

    const rpcParams = {
      p_org_id: org_id,
      p_plan_id: plan_id,
      p_payment_provider_subscription_id: newRazorpaySubscription.id,
      p_initial_status: initialStatusForNewSub,
      p_start_date: new Date(newRazorpaySubscription.start_at! * 1000)
        .toISOString(),
      p_payment_provider: "razorpay",
      p_payment_provider_plan_id: newRazorpayPlanId,
      p_end_date: new Date(newRazorpaySubscription.end_at! * 1000)
        .toISOString(),
      p_trial_end_date: dbTrialEndDate,
      p_current_start: newRazorpaySubscription.current_start &&
          Number(newRazorpaySubscription.current_start) !== 0
        ? new Date(Number(newRazorpaySubscription.current_start) * 1000)
          .toISOString()
        : undefined,
      p_current_end: newRazorpaySubscription.current_end &&
          Number(newRazorpaySubscription.current_end) !== 0
        ? new Date(Number(newRazorpaySubscription.current_end) * 1000)
          .toISOString()
        : undefined,
      p_invoices: newRazorpaySubscriptionInvoices.items as any[] || [],
      p_payment_url: newRazorpaySubscription.short_url,
      p_billing_cycle: billing_cycle,
      p_metadata: newRazorpaySubscription as any,
    };

    const { data: newSubscriptionId, error: rpcPaidPlanError } =
      await supabaseClient
        .rpc("create_paid_subscription_package", rpcParams)
        .single();

    if (rpcPaidPlanError) {
      logError(
        "Database transaction failed for new paid subscription via RPC.",
        rpcPaidPlanError,
        {
          ...functionContext,
          razorpay_sub_id: newRazorpaySubscription.id,
          rpcParams, // Log the params for debugging
        },
      );

      try {
        logInfo(
          `Attempting to cancel Razorpay subscription ${newRazorpaySubscription.id} due to DB transaction failure.`,
          { ...functionContext, razorpay_sub_id: newRazorpaySubscription.id },
        );
        await razorpayClient.subscriptions.cancel(newRazorpaySubscription.id);
        logInfo(
          `Successfully cancelled Razorpay subscription ${newRazorpaySubscription.id} as compensation.`,
          { ...functionContext, razorpay_sub_id: newRazorpaySubscription.id },
        );
      } catch (cancelError) {
        logError(
          `CRITICAL: FAILED TO CANCEL Razorpay subscription ${newRazorpaySubscription.id} after DB error. MANUAL INTERVENTION REQUIRED.`,
          cancelError,
          { ...functionContext, razorpay_sub_id: newRazorpaySubscription.id },
        );
      }
      return {
        error:
          "Failed to save subscription details. The Razorpay transaction may have been auto-cancelled. Contact support.",
        status: 500,
      };
    }

    logInfo(
      "New Razorpay subscription initiated and DB records created successfully.",
      {
        ...functionContext,
        new_razorpay_sub_id: newRazorpaySubscription.id,
        db_subscription_id: newSubscriptionId,
        payment_url: newRazorpaySubscription.short_url,
      },
    );
    return {
      payment_url: newRazorpaySubscription.short_url,
      message: "Subscription initiated. Please complete payment.",
    };
  } catch (error) {
    logError(
      "Unhandled error in createSubscription_IN function",
      error,
      functionContext,
    );
    const errorMessage = error instanceof Error && error.message
      ? error.message
      : "An unknown error occurred during subscription initiation.";

    // Example check for Razorpay error structure (adapt if SDK provides specific error types)
    if (error && typeof error === "object" && "statusCode" in error) { // Basic check
      return {
        error: `Razorpay error: ${errorMessage}`, // error.description or similar might exist from Razorpay SDK
        status: (error as any).statusCode || 500,
      };
    }
    return {
      error: `Failed to initiate subscription: ${errorMessage}`,
      status: 500,
    };
  }
}

async function createAddonSubscription_IN(
  addon_id: number,
  billing_cycle: "monthly" | "annually",
  org_id: string,
  country_code: string, // For addon pricing
  quantity: number,
): Promise<CreateSubscriptionResult> {
  const functionContext = {
    function: "createAddonSubscription_IN",
    org_id,
    addon_id,
    billing_cycle,
    country_code,
    quantity,
  };
  logInfo("Attempting to initiate IN addon subscription", functionContext);

  try {
    // 1. Fetch Addon Price and details
    // Assuming addon prices are stored with currency, let's default to INR for IN.
    const currency_code = "INR"; // Or determine dynamically if needed

    const { data: addonPriceData, error: addonPriceError } =
      await supabaseClient
        .from("addon_prices")
        .select(
          "price_monthly, price_annual, currency_code, addons (name, slug, unit_name)",
        )
        .eq("addon_id", addon_id)
        .eq("country_code", country_code)
        .eq("currency_code", currency_code) // Ensure we fetch for the correct currency
        .eq("is_active", true)
        .single();

    if (addonPriceError || !addonPriceData) {
      logError(
        "Error fetching addon price details",
        addonPriceError,
        functionContext,
      );
      return {
        error:
          `Active addon price not found for addon_id: ${addon_id}, country: ${country_code}, currency: ${currency_code}, cycle: ${billing_cycle}`,
        status: 404,
      };
    }

    const addonName = addonPriceData.addons?.name || `Addon ID ${addon_id}`;
    let addonAmount: number | null = null;

    if (billing_cycle === "monthly") {
      addonAmount = addonPriceData.price_monthly as number | null;
    } else if (billing_cycle === "annually") {
      addonAmount = addonPriceData.price_annual as number | null;
    }

    if (addonAmount === null || addonAmount === undefined) {
      logError(
        `Addon price is null for addon_id: ${addon_id}, cycle: ${billing_cycle}`,
        null,
        functionContext,
      );
      return {
        error:
          `Price not available for addon ${addonName} for ${billing_cycle} cycle.`,
        status: 404,
      };
    }

    // Note: Razorpay needs plan_id for subscriptions. For addons, we might need a generic "addon plan"
    // on Razorpay or use a different Razorpay product if not using plans.
    // For this example, let's assume you have a mechanism to map addons to Razorpay plans
    // or a generic plan you use for ad-hoc items.
    // LETS SIMULATE THIS BY CREATING A DUMMY RAZORPAY PLAN ON THE FLY (NOT RECOMMENDED FOR PROD)
    // OR, better: use a pre-existing generic plan_id on Razorpay for all addons,
    // and the differentiation happens via `notes` and your internal DB.

    // For demonstration, let's assume we need a Razorpay Plan ID.
    // In a real scenario, you would either:
    // 1. Create a generic plan in Razorpay for addons of a certain price/currency.
    // 2. Or, your `addon_prices` table would also store a `razorpay_plan_id` for each price point.
    // Let's assume for now that all addons of the same price/currency/interval can share a Razorpay plan.
    // We'll need to fetch or define this. For simplicity, if your `razorpay_plans` table could also store
    // generic plans (e.g., plan_id from your DB is null, but razorpay_plan_id exists), that's an option.

    // Let's find or create a generic Razorpay plan ID for this addon's price.
    // This part is complex without knowing your exact Razorpay plan setup for addons.
    // TEMPORARY: Using a placeholder. Replace with actual Razorpay plan ID logic for addons.
    // Ideally, you'd have a razorpay_plan_id in your addon_prices or a mapping table.
    const { data: genericRazorpayPlan, error: genericPlanError } =
      await supabaseClient
        .from("razorpay_addons") // Assuming you might have generic plans here
        .select("razorpay_addon_id")
        .eq("addon_id", addon_id)
        .eq("billing_cycle", billing_cycle) // Razorpay interval
        .maybeSingle();

    let addonRazorpayPlanId: string;

    if (genericPlanError || !genericRazorpayPlan) {
      logError(
        "Generic Razorpay plan for addon not found, or error fetching.",
        genericPlanError,
        { ...functionContext, addonAmount, currency_code, billing_cycle },
      );
      // TODO: Optionally create a Razorpay plan dynamically if it doesn't exist.
      // This is risky and needs careful management.
      // For now, we'll error out if a suitable plan isn't pre-configured.
      return {
        error:
          "Internal configuration error: Razorpay plan for addon pricing not found.",
        status: 500,
      };
    }
    addonRazorpayPlanId = genericRazorpayPlan.razorpay_addon_id;

    // Consider if 'pending_activation' addons should be cancelled like plans.
    // For now, assuming similar logic to plans for cancelling pending ones.
    const {
      data: pendingAddonActivations,
      error: pendingAddonActivationError,
    } = await supabaseClient
      .from("subscriptions")
      .select("subscription_id, payment_provider_subscription_id")
      .eq("org_id", org_id)
      .eq("addon_id", addon_id) // Only cancel pending for the *same* addon
      .eq("status", "pending_activation");

    if (pendingAddonActivationError) {
      logError(
        "DB error fetching pending_activation addon subscriptions.",
        pendingAddonActivationError,
        functionContext,
      );
    }
    if (pendingAddonActivations && pendingAddonActivations.length > 0) {
      for (const pendingSub of pendingAddonActivations) {
        if (pendingSub.payment_provider_subscription_id) {
          try {
            logInfo(
              `Cancelling existing pending_activation Razorpay subscription ${pendingSub.payment_provider_subscription_id} for addon ${addon_id}.`,
              {
                ...functionContext,
                pending_sub_id: pendingSub.subscription_id,
              },
            );
            await razorpayClient.subscriptions.cancel(
              pendingSub.payment_provider_subscription_id,
            );
          } catch (cancelPendingError) {
            logError(
              `Failed to cancel a pending_activation Razorpay subscription for addon ${pendingSub.payment_provider_subscription_id}.`,
              cancelPendingError,
              {
                ...functionContext,
                pending_sub_id: pendingSub.subscription_id,
              },
            );
          }
        }
      }
    }

    // 3. Create NEW Razorpay subscription for the addon
    logInfo(
      `Creating new Razorpay subscription for addon ${addonName}.`,
      functionContext,
    );

    // Addons typically don't have trials in the same way plans do.
    // If an addon has a trial, this logic would need adjustment.
    // For now, assuming addons start immediately or at a specified `start_at` if provided.
    const razorpaySubscriptionPayload: RazorpaySubscriptionBaseRequestBody = {
      plan_id: addonRazorpayPlanId, // Use the fetched/derived Razorpay plan ID for the addon
      customer_notify: 0,
      quantity: quantity, // Assuming quantity is 1 for addons, adjust if needed
      total_count: billing_cycle === "monthly" ? 60 : 5, // Default 5 years, adjust as per addon lifecycle
      notes: {
        org_id: org_id,
        item_type: "addon", // CRUCIAL for webhook processing
        internal_addon_id: addon_id.toString(), // CRUCIAL
        billing_cycle: billing_cycle,
        country_code: country_code,
        // Add any other relevant notes for the addon
      },
    };

    // If addons can have scheduled start dates or trials, add logic here:
    // if (some_addon_trial_condition) {
    //   razorpaySubscriptionPayload.start_at = Math.floor(Date.now() / 1000) + (TRIAL_DAYS * 24 * 60 * 60);
    // }

    const newRazorpaySubscription = await razorpayClient.subscriptions.create(
      razorpaySubscriptionPayload,
    );

    const newRazorpaySubscriptionInvoices = await razorpayClient.invoices.all({
      subscription_id: newRazorpaySubscription.id,
      count: 10, // Fetch initial invoices
    });

    // 4. Atomically insert addon subscription, invoices via RPC
    const initialStatusForNewSub:
      Database["public"]["Enums"]["subscription_status_enum"] =
        "pending_activation";

    // Trial end date for addons - usually null unless addons have trials.
    const dbTrialEndDate = null; // Or some logic if addons have trials

    const rpcParams:
      Database["public"]["Functions"]["create_addon_subscription_package"][
        "Args"
      ] = {
        p_org_id: org_id,
        p_addon_id: addon_id, // Pass addon_id to the new RPC
        p_payment_provider_subscription_id: newRazorpaySubscription.id,
        p_initial_status: initialStatusForNewSub,
        p_start_date: new Date(newRazorpaySubscription.start_at! * 1000)
          .toISOString(),
        p_payment_provider: "razorpay",
        p_payment_provider_item_id: addonRazorpayPlanId, // Pass the Razorpay plan_id used for this addon
        p_end_date: new Date(newRazorpaySubscription.end_at! * 1000)
          .toISOString(),
        p_trial_end_date: dbTrialEndDate
          ? new Date(dbTrialEndDate).toISOString()
          : undefined,
        p_quantity: quantity,
        p_invoices: newRazorpaySubscriptionInvoices.items as any[] || [],
        p_payment_url: newRazorpaySubscription.short_url,
        p_metadata: newRazorpaySubscription as any,
        p_billing_cycle: billing_cycle,
        p_country_code: country_code, // Pass to RPC
        p_currency_code: currency_code, // Pass to RPC
        p_current_start: newRazorpaySubscription.current_start &&
            Number(newRazorpaySubscription.current_start) !== 0
          ? new Date(Number(newRazorpaySubscription.current_start) * 1000)
            .toISOString()
          : undefined,
        p_current_end: newRazorpaySubscription.current_end &&
            Number(newRazorpaySubscription.current_end) !== 0
          ? new Date(Number(newRazorpaySubscription.current_end) * 1000)
            .toISOString()
          : undefined,
        // p_plan_id: null // Explicitly null as this is for an addon
      };

    const { data: newSubscriptionId, error: rpcAddonPlanError } =
      await supabaseClient
        .rpc("create_addon_subscription_package", rpcParams) // CALL THE NEW RPC
        .single();

    if (rpcAddonPlanError) {
      logError(
        "Database transaction failed for new addon subscription via RPC.",
        rpcAddonPlanError,
        {
          ...functionContext,
          razorpay_sub_id: newRazorpaySubscription.id,
          rpcParams,
        },
      );

      try {
        logInfo(
          `Attempting to cancel Razorpay subscription ${newRazorpaySubscription.id} for addon due to DB transaction failure.`,
          { ...functionContext, razorpay_sub_id: newRazorpaySubscription.id },
        );
        await razorpayClient.subscriptions.cancel(newRazorpaySubscription.id);
        logInfo(
          `Successfully cancelled Razorpay subscription ${newRazorpaySubscription.id} for addon as compensation.`,
          { ...functionContext, razorpay_sub_id: newRazorpaySubscription.id },
        );
      } catch (cancelError) {
        logError(
          `CRITICAL: FAILED TO CANCEL Razorpay subscription ${newRazorpaySubscription.id} for addon after DB error. MANUAL INTERVENTION REQUIRED.`,
          cancelError,
          { ...functionContext, razorpay_sub_id: newRazorpaySubscription.id },
        );
      }
      return {
        error:
          "Failed to save addon subscription details. The Razorpay transaction may have been auto-cancelled. Contact support.",
        status: 500,
      };
    }

    logInfo(
      "New Razorpay addon subscription initiated and DB records created successfully.",
      {
        ...functionContext,
        new_razorpay_sub_id: newRazorpaySubscription.id,
        db_subscription_id: newSubscriptionId, // This comes from the RPC response
        payment_url: newRazorpaySubscription.short_url,
      },
    );
    return {
      payment_url: newRazorpaySubscription.short_url,
      message: "Addon subscription initiated. Please complete payment.",
    };
  } catch (error) {
    logError(
      "Unhandled error in createAddonSubscription_IN function",
      error,
      functionContext,
    );
    const errorMessage = error instanceof Error && error.message
      ? error.message
      : "An unknown error occurred during addon subscription initiation.";

    if (error && typeof error === "object" && "statusCode" in error) {
      return {
        error: `Razorpay error: ${errorMessage}`,
        status: (error as any).statusCode || 500,
      };
    }
    return {
      error: `Failed to initiate addon subscription: ${errorMessage}`,
      status: 500,
    };
  }
}

// --- Webhook Middleware for Idempotency ---
app.use("/razorpay-webhook", async (c, next) => {
  const eventId = c.req.header("x-razorpay-event-id");
  const webhookContext = { route: "/razorpay-webhook", eventId };

  if (!eventId) {
    logError(
      "Webhook received without x-razorpay-event-id header.",
      null,
      webhookContext,
    );
    return c.json({ error: "Missing x-razorpay-event-id header" }, 400);
  }

  try {
    const { error } = await supabaseClient
      .from("processed_webhook_events")
      .insert({ event_id: eventId });

    if (error) {
      if (error.code === "23505") { // Postgres unique violation
        logInfo(
          "Duplicate webhook event ID received, skipping.",
          webhookContext,
        );
        return c.text("Duplicate event, already processed.");
      } else {
        logError(
          "Database error checking webhook event ID",
          error,
          webhookContext,
        );
        return c.json(
          { error: "Internal server error during event ID check" },
          500,
        );
      }
    } else {
      logInfo("New webhook event ID, proceeding to handler.", webhookContext);
      await next();
    }
  } catch (dbError) {
    logError(
      "Exception during webhook event ID check in DB",
      dbError,
      webhookContext,
    );
    return c.json({ error: "Internal server error during event check" }, 500);
  }
});

app.post("/razorpay-webhook", async (c) => {
  const webhookContextBase = { route: "/razorpay-webhook", method: "POST" };
  logInfo("Received webhook POST request", webhookContextBase);

  try {
    const signature = c.req.header("x-razorpay-signature");
    const eventId = c.req.header("x-razorpay-event-id") || "unknown_event_id";
    const webhookContextWithEventId = { ...webhookContextBase, eventId };

    if (!signature) {
      logError("Webhook signature not found", null, webhookContextWithEventId);
      return c.json({ error: "Signature not found" }, 400);
    }
    const rawBody = await c.req.text();

    const isValid = validateWebhookSignature(
      rawBody,
      signature,
      RAZORPAY_WEBHOOK_SECRET!,
    );
    if (!isValid) {
      logError("Invalid webhook signature", null, webhookContextWithEventId);
      return c.json({ error: "Invalid signature" }, 400);
    }

    const webhookData = JSON.parse(rawBody) as RazorpayWebhookEvent;
    const { event } = webhookData;
    const eventProcessingContextBase = {
      ...webhookContextWithEventId,
      event,
      accountId: webhookData.account_id,
    };
    logInfo(`Processing webhook event: ${event}`, eventProcessingContextBase);

    // --- Handle INVOICE Events ---
    if (event.startsWith("invoice.")) {
      const invoiceEvent = webhookData as Extract<
        RazorpayWebhookEvent,
        {
          event:
            | "invoice.paid"
            | "invoice.partially_paid"
            | "invoice.expired";
        }
      >;
      const invoiceEntity = invoiceEvent.payload.invoice.entity;
      const paymentProviderInvoiceId = invoiceEntity.id;
      const eventProcessingContext = {
        ...eventProcessingContextBase,
        paymentProviderInvoiceId,
      };

      const razorpaySubscriptionIdFromInvoice = invoiceEntity.subscription_id;

      const { data: subscriptionData, error: subscriptionError } =
        await supabaseClient
          .from("subscriptions")
          .select("subscription_id, org_id")
          .eq(
            "payment_provider_subscription_id",
            razorpaySubscriptionIdFromInvoice!, // Assert not null, as it's essential for linking
          )
          .single();

      if (subscriptionError) {
        logError(
          "Error fetching subscription data for invoice",
          subscriptionError,
          eventProcessingContext,
        );
        // Consider if this is a fatal error for invoice processing
        // If org_id/subscription_id can't be found, invoice can't be linked.
      }

      type InvoiceUpsertData =
        & Database["public"]["Tables"]["subscription_invoices"]["Insert"]
        & Database["public"]["Tables"]["subscription_invoices"]["Update"];

      const invoiceDataToUpsert: Partial<InvoiceUpsertData> = {
        org_id: subscriptionData?.org_id, // Relies on successful fetch above
        subscription_id: subscriptionData?.subscription_id, // Relies on successful fetch above
        payment_provider_invoice_id: paymentProviderInvoiceId,
        payment_provider_subscription_id: razorpaySubscriptionIdFromInvoice,
        payment_provider_order_id: invoiceEntity.order_id,
        payment_provider: "razorpay",
        amount: invoiceEntity.amount / 100,
        currency: invoiceEntity.currency,
        issued_at: new Date(invoiceEntity.issued_at * 1000).toISOString(),
        due_date: invoiceEntity.expire_by
          ? new Date(invoiceEntity.expire_by * 1000).toISOString()
          : undefined,
        line_items: invoiceEntity.line_items as any,
        pdf_url: invoiceEntity.short_url, // This is payment link, actual PDF might need another API call
        metadata: invoiceEntity as any,
        notes: invoiceEntity.notes?.your_internal_note_key, // Use your specific note key if any
        payment_url: invoiceEntity.short_url,
      };

      switch (invoiceEvent.event) {
        case "invoice.paid":
        case "invoice.partially_paid": {
          // Type assertion for payload specific to these events
          const paidEventPayload = invoiceEvent.payload as Extract<
            RazorpayWebhookEvent,
            { event: "invoice.paid" | "invoice.partially_paid" }
          >["payload"];
          invoiceDataToUpsert.status = invoiceEvent.event === "invoice.paid"
            ? "paid"
            : "partially_paid";
          invoiceDataToUpsert.paid_at = invoiceEntity.paid_at
            ? new Date(invoiceEntity.paid_at * 1000).toISOString()
            : new Date().toISOString(); // Fallback to now if paid_at is missing
          invoiceDataToUpsert.amount_paid = (invoiceEntity.amount_paid ?? 0) /
            100;
          invoiceDataToUpsert.amount_due = (invoiceEntity.amount_due ?? 0) /
            100;
          invoiceDataToUpsert.payment_provider_payment_id = paidEventPayload
            .payment?.entity.id; // payment is present in invoice.paid
          break;
        }
        case "invoice.expired":
          invoiceDataToUpsert.status = "void"; // Or 'expired' if you have that status
          break;
        default:
          // This path should ideally not be hit due to the Extract utility type.
          logInfo(
            `Unhandled invoice event type: ${invoiceEvent}`,
            eventProcessingContext,
          );
          return c.json({
            message: "Invoice event type not explicitly handled.",
          });
      }

      logInfo(`Upserting invoice data for event ${invoiceEvent.event}`, {
        ...eventProcessingContext,
        dataToUpsert: invoiceDataToUpsert,
      });
      const { error: invoiceUpsertError } = await supabaseClient
        .from("subscription_invoices")
        .upsert(invoiceDataToUpsert as InvoiceUpsertData, { // Ensure this cast is safe
          onConflict: "payment_provider, payment_provider_invoice_id",
        });

      if (invoiceUpsertError) {
        logError(
          "Failed to upsert invoice data.",
          invoiceUpsertError,
          eventProcessingContext,
        );
        return c.json({ error: "Database error during invoice upsert." }, 500);
      }
      logInfo(
        `Successfully processed invoice event ${invoiceEvent.event}.`,
        eventProcessingContext,
      );
      return c.json({
        received: true,
        processed_invoice_event: invoiceEvent.event,
      });

      // --- Handle SUBSCRIPTION Events ---
    } else if (event.startsWith("subscription.")) {
      const subscriptionEvent = webhookData as Extract<
        RazorpayWebhookEvent,
        {
          event:
            | "subscription.authenticated"
            | "subscription.activated"
            | "subscription.charged"
            | "subscription.pending"
            | "subscription.halted"
            | "subscription.updated"
            | "subscription.cancelled"
            | "subscription.completed"
            | "subscription.paused"
            | "subscription.resumed";
        }
      >;
      const razorpaySubscriptionEntity =
        subscriptionEvent.payload.subscription.entity;
      const razorpaySubscriptionId = razorpaySubscriptionEntity.id;
      const notes = razorpaySubscriptionEntity.notes;
      const orgId = notes?.org_id;
      const internalPlanIdStr = notes?.internal_plan_id;
      const internalPlanId = internalPlanIdStr
        ? parseInt(internalPlanIdStr, 10)
        : undefined;

      const itemTypeFromNotes = notes?.item_type; // "plan" or "addon"
      const internalAddonIdStr = notes?.internal_addon_id;
      const internalAddonId = internalAddonIdStr
        ? parseInt(internalAddonIdStr, 10)
        : undefined;

      const eventProcessingContext = {
        ...eventProcessingContextBase,
        razorpaySubscriptionId,
        orgId,
        itemTypeFromNotes, // For logging and decisions
        internalPlanId: itemTypeFromNotes === "plan"
          ? internalPlanId
          : undefined,
        internalAddonId: itemTypeFromNotes === "addon"
          ? internalAddonId
          : undefined,
      };

      if (!orgId) {
        logError(
          "Subscription webhook missing org_id in notes.",
          null,
          { ...eventProcessingContext, notes },
        );
        return c.json({ error: "Missing org_id in subscription notes" }, 400);
      }

      if (
        itemTypeFromNotes === "plan" &&
        (internalPlanId === undefined || isNaN(internalPlanId))
      ) {
        logError(
          "Subscription (plan) webhook missing valid internal_plan_id in notes.",
          null,
          { ...eventProcessingContext, notes },
        );
        return c.json(
          { error: "Missing valid internal_plan_id for plan subscription" },
          400,
        );
      }

      if (
        itemTypeFromNotes === "addon" &&
        (internalAddonId === undefined || isNaN(internalAddonId))
      ) {
        logError(
          "Subscription (addon) webhook missing valid internal_addon_id in notes.",
          null,
          { ...eventProcessingContext, notes },
        );
        return c.json(
          { error: "Missing valid internal_addon_id for addon subscription" },
          400,
        );
      }

      if (
        !itemTypeFromNotes ||
        (itemTypeFromNotes !== "plan" && itemTypeFromNotes !== "addon")
      ) {
        logError(
          "Subscription webhook missing or invalid item_type in notes.",
          null,
          { ...eventProcessingContext, notes },
        );
        return c.json(
          {
            error:
              "Missing or invalid item_type in subscription notes. Must be 'plan' or 'addon'.",
          },
          400,
        );
      }

      type SubscriptionUpsertData =
        & Database["public"]["Tables"]["subscriptions"]["Insert"]
        & Database["public"]["Tables"]["subscriptions"]["Update"];

      // Base data for most subscription events
      const subscriptionData: Partial<SubscriptionUpsertData> = {
        org_id: orgId,
        // plan_id will be set based on itemTypeFromNotes
        // addon_id will be set based on itemTypeFromNotes
        payment_provider_subscription_id: razorpaySubscriptionId,
        payment_provider: "razorpay",
        cancel_at_period_end: razorpaySubscriptionEntity.cancel_at_period_end ??
          false,
        // metadata might be updated in specific cases
        metadata: razorpaySubscriptionEntity as any, // Store the latest Razorpay entity
        plan_id: internalPlanId,
        addon_id: internalAddonId,
      };

      switch (subscriptionEvent.event) {
        case "subscription.authenticated":
          logInfo(
            "Subscription authenticated event processed.",
            eventProcessingContext,
          );
          await supabaseClient
            .from("subscriptions")
            .update({
              updated_at: new Date().toISOString(), // Or "failed"
            })
            .eq("payment_provider_subscription_id", razorpaySubscriptionId);
          break;

        case "subscription.activated":
        case "subscription.charged": {
          subscriptionData.status = "active";
          if (itemTypeFromNotes === "plan") {
            subscriptionData.plan_id = internalPlanId;
            subscriptionData.addon_id = null;
          } else if (itemTypeFromNotes === "addon") {
            subscriptionData.addon_id = internalAddonId;
            subscriptionData.plan_id = null;
          }
          subscriptionData.start_date = new Date(
            razorpaySubscriptionEntity.start_at! * 1000,
          ).toISOString();
          subscriptionData.end_date = new Date( // This is the overall subscription end (e.g., after total_count cycles)
            razorpaySubscriptionEntity.end_at! * 1000,
          ).toISOString();
          subscriptionData.current_start = new Date( // Start of the current billing cycle
            razorpaySubscriptionEntity.current_start! * 1000,
          ).toISOString();
          subscriptionData.current_end = new Date( // End of the current billing cycle
            razorpaySubscriptionEntity.current_end! * 1000,
          ).toISOString();
          subscriptionData.trial_end_date = null; // Trial is over or wasn't applicable

          // Include payment details if available (especially for 'subscription.charged')
          if (subscriptionEvent.payload.payment) {
            subscriptionData.metadata = { // Merge subscription and payment entities
              ...razorpaySubscriptionEntity,
              ...subscriptionEvent.payload.payment.entity,
            } as any;
            subscriptionData.currency =
              subscriptionEvent.payload.payment.entity.currency;
            subscriptionData.tax_amount =
              (subscriptionEvent.payload.payment.entity.tax ?? 0) / 100;
            subscriptionData.total_invoice_amount = // Amount of this specific charge
              subscriptionEvent.payload.payment.entity.amount / 100;
          } else {
            subscriptionData.metadata = razorpaySubscriptionEntity as any;
          }

          if (razorpaySubscriptionEntity.customer_id) {
            subscriptionData.payment_provider_customer_id =
              razorpaySubscriptionEntity.customer_id;
          }

          logInfo(
            `Attempting to activate/update subscription: ${razorpaySubscriptionId}`,
            eventProcessingContext,
          );
          if (subscriptionData.plan_id !== null) {
            const { error: updateFreeError } = await supabaseClient
              .from("subscriptions")
              .update({
                status: "ended",
                end_date: new Date().toISOString(),
              })
              .not("plan_id", "is", null)
              .eq("org_id", subscriptionData.org_id!);
            if (updateFreeError) {
              logError(
                `Failed to mark old plan-based subscriptions as ended for org_id ${subscriptionData.org_id}.`,
                updateFreeError,
                {
                  org_id: subscriptionData.org_id,
                  while_processing_subscription_event: subscriptionEvent.event,
                  current_payment_provider_subscription_id:
                    razorpaySubscriptionId,
                  item_type_being_processed: itemTypeFromNotes,
                  failed_operation_detail:
                    "Attempting to set status to 'ended' for existing plan-based subscriptions for the organization.",
                },
              );
            }
          }
          // Upsert the new/updated subscription first to ensure it's active
          const { error: newSubUpsertError } = await supabaseClient
            .from("subscriptions")
            .upsert(subscriptionData as SubscriptionUpsertData, { // Cast carefully
              onConflict: "payment_provider_subscription_id",
            });

          if (newSubUpsertError) {
            logError(
              "CRITICAL: Failed to activate/update subscription in DB after payment/activation event.",
              newSubUpsertError,
              eventProcessingContext,
            );
            return c.json(
              {
                error:
                  "Failed to finalize subscription activation in our system.",
              },
              500,
            );
          }
          logInfo(
            `Successfully activated/updated subscription: ${razorpaySubscriptionId}`,
            eventProcessingContext,
          );

          // NOW, handle the OLD subscription(s)
          logInfo(
            "Checking for old subscriptions to clean up.",
            eventProcessingContext,
          );
          if (subscriptionData.plan_id !== null) {
            const { data: oldSubscriptions, error: fetchOldSubsError } =
              await supabaseClient
                .from("subscriptions")
                .select(
                  "subscription_id, plan_id, status, payment_provider_subscription_id",
                )
                .eq("org_id", orgId)
                .not("plan_id", "is", null)
                .neq("payment_provider_subscription_id", razorpaySubscriptionId) // Exclude the one just activated
                .in("status", [ // Target statuses that need cleanup
                  "active",
                  "trialing",
                  "past_due",
                  "pending_activation",
                  "free_limited", // If plan_id 1 is free
                  "paused",
                ]);

            if (fetchOldSubsError) {
              logError(
                "DB error fetching old subscriptions for cleanup.",
                fetchOldSubsError,
                eventProcessingContext,
              );
              // Proceed, as the new subscription is active. Log for manual check.
            } else if (oldSubscriptions && oldSubscriptions.length > 0) {
              for (const oldSub of oldSubscriptions) {
                const oldSubContext = {
                  ...eventProcessingContext,
                  old_sub_db_id: oldSub.subscription_id,
                  old_razorpay_id: oldSub.payment_provider_subscription_id,
                  old_plan_id: oldSub.plan_id,
                  old_status: oldSub.status,
                };
                if (
                  oldSub.payment_provider_subscription_id &&
                  oldSub.plan_id !== null
                ) { // It's an old Razorpay (paid) subscription
                  try {
                    logInfo(
                      `Attempting to cancel old Razorpay subscription: ${oldSub.payment_provider_subscription_id}`,
                      oldSubContext,
                    );
                    await razorpayClient.subscriptions.cancel(
                      oldSub.payment_provider_subscription_id,
                    );
                    // The webhook for *this* cancellation will eventually update its status to 'canceled'.
                  } catch (cancelError) {
                    logError(
                      `Failed to cancel old Razorpay subscription ${oldSub.payment_provider_subscription_id}. Requires manual check.`,
                      cancelError,
                      oldSubContext,
                    );
                  }
                } else if (
                  oldSub.plan_id === 1 &&
                  (oldSub.status === "active" ||
                    oldSub.status === "free_limited")
                ) { // It's an active internal Free Plan
                  logInfo(
                    `Marking old active internal free plan as ended: ${oldSub.subscription_id}`,
                    oldSubContext,
                  );
                  const { error: updateFreeError } = await supabaseClient
                    .from("subscriptions")
                    .update({
                      status: "ended",
                      end_date: new Date().toISOString(),
                    })
                    .eq("subscription_id", oldSub.subscription_id);
                  if (updateFreeError) {
                    logError(
                      `Failed to mark old free plan as ended: ${oldSub.subscription_id}`,
                      updateFreeError,
                      oldSubContext,
                    );
                  }
                } else if (
                  oldSub.status === "pending_activation" &&
                  !oldSub.payment_provider_subscription_id &&
                  oldSub.plan_id !== null
                ) {
                  // Old internal 'pending_activation' that never got a Razorpay ID, likely an abandoned attempt.
                  logInfo(
                    `Marking old internal 'pending_activation' subscription as canceled: ${oldSub.subscription_id}`,
                    oldSubContext,
                  );
                  const { error: updateInternalPendingError } =
                    await supabaseClient
                      .from("subscriptions")
                      .update({
                        status: "canceled", // Or "failed"
                        canceled_at: new Date().toISOString(),
                      })
                      .not("plan_id", "is", null)
                      .eq("subscription_id", oldSub.subscription_id);
                  if (updateInternalPendingError) {
                    logError(
                      `Failed to mark old internal pending_activation sub as canceled: ${oldSub.subscription_id}`,
                      updateInternalPendingError,
                      oldSubContext,
                    );
                  }
                }
                // Note: 'pending_activation' for a Razorpay sub would be handled by its own cancel if needed,
                // or by the logic in createSubscription_IN that cancels pending subs.
              }
            }
          }
          // No further upsert needed here for subscriptionData, as it was done at the start of this case.
          // Return success for the webhook processing.
          return c.json({
            received: true,
            processed_subscription_event: subscriptionEvent.event,
          });
        } // End of subscription.activated / subscription.charged block

        case "subscription.pending": // Payment failed, subscription moves to pending state (awaiting payment)
          subscriptionData.status = "past_due"; // Or a specific 'pending_payment' status
          break;
        case "subscription.halted": // Subscription halted due to multiple payment failures
          subscriptionData.status = "past_due"; // Or 'halted' if you have such a status
          break;
        case "subscription.cancelled":
          subscriptionData.status = "canceled";
          subscriptionData.canceled_at = razorpaySubscriptionEntity.ended_at // `ended_at` is when cancellation is effective
            ? new Date(
              razorpaySubscriptionEntity.ended_at * 1000,
            ).toISOString()
            : new Date().toISOString(); // Fallback to now
          // Ensure start/end dates reflect the subscription's lifecycle if available
          if (razorpaySubscriptionEntity.start_at) {
            subscriptionData.start_date = new Date(
              razorpaySubscriptionEntity.start_at * 1000,
            ).toISOString();
          }
          if (razorpaySubscriptionEntity.current_end) { // current_end before cancellation might be relevant
            subscriptionData.end_date = new Date(
              razorpaySubscriptionEntity.current_end * 1000,
            ).toISOString();
          }
          break;
        case "subscription.paused":
          subscriptionData.status = "paused";
          // Record current cycle details at time of pausing if relevant
          if (razorpaySubscriptionEntity.current_start) {
            subscriptionData.current_start = new Date(
              razorpaySubscriptionEntity.current_start * 1000,
            ).toISOString();
          }
          if (razorpaySubscriptionEntity.current_end) {
            subscriptionData.current_end = new Date(
              razorpaySubscriptionEntity.current_end * 1000,
            ).toISOString();
          }
          // You might add a `paused_at` field.
          break;
        case "subscription.resumed":
          subscriptionData.status = "active";
          // Resumed subscription gets new current_start and current_end for the active cycle
          subscriptionData.current_start = new Date(
            razorpaySubscriptionEntity.current_start! * 1000,
          ).toISOString();
          subscriptionData.current_end = new Date(
            razorpaySubscriptionEntity.current_end! * 1000,
          ).toISOString();
          subscriptionData.start_date = new Date( // original start_at or current_start
            razorpaySubscriptionEntity.start_at! * 1000,
          ).toISOString();
          subscriptionData.end_date = new Date( // original end_at
            razorpaySubscriptionEntity.end_at! * 1000,
          ).toISOString();
          subscriptionData.canceled_at = null; // Clear any previous cancellation/paused markers
          subscriptionData.trial_end_date = null; // Ensure trial is not active
          break;
        case "subscription.completed": // All cycles completed
          subscriptionData.status = "ended";
          if (razorpaySubscriptionEntity.ended_at) {
            subscriptionData.end_date = new Date(
              razorpaySubscriptionEntity.ended_at * 1000,
            ).toISOString();
          }
          break;
        case "subscription.updated":
          logInfo(
            "Processing subscription.updated event. Current data reflects payload.",
            eventProcessingContext,
          );
          // This event is generic. Update any relevant fields based on the payload.
          // For example, if quantity or schedule changes.
          // `subscriptionData` already has plan_id and cancel_at_period_end.
          // Add other relevant fields from `razorpaySubscriptionEntity` if needed.
          // subscriptionData.quantity = razorpaySubscriptionEntity.quantity;
          // subscriptionData.total_count = razorpaySubscriptionEntity.total_count;
          // The general upsert below will apply these changes.
          break;

        default:
          // This path should ideally not be hit due to the Extract utility type.
          logInfo(
            `Unhandled subscription event type: ${subscriptionEvent}. No DB update.`,
            eventProcessingContext,
          );
          return c.json({
            message:
              "Subscription event type received but no specific action taken.",
          });
      }

      // Perform Upsert for Subscription Events (if not already handled like in activated/charged)
      // The (Object.keys(subscriptionData).length > 3) check was a bit arbitrary.
      // A more robust check is if there are meaningful changes beyond the base identifiers.
      // For simplicity, we'll attempt upsert if not activated/charged as those have specific return paths.
      if (subscriptionEvent.event != "subscription.authenticated") {
        logInfo(
          `Upserting subscription data for event ${subscriptionEvent.event}`,
          { ...eventProcessingContext, dataToUpsert: subscriptionData },
        );
        const { error: upsertError } = await supabaseClient
          .from("subscriptions")
          .upsert(subscriptionData as SubscriptionUpsertData, { // Cast carefully
            onConflict: "payment_provider_subscription_id", // This ensures update if exists, insert if new
          });

        if (upsertError) {
          logError(
            "Failed to upsert subscription data.",
            upsertError,
            eventProcessingContext,
          );
          return c.json(
            {
              error:
                `Database error during subscription upsert: ${upsertError.message}`,
            },
            500,
          );
        }
        logInfo(
          `Successfully upserted subscription for event ${subscriptionEvent.event}.`,
          eventProcessingContext,
        );
      }

      return c.json({
        received: true,
        processed_subscription_event: subscriptionEvent.event,
      });

      // --- Handle OTHER Event Families (Order, Payment - if needed) ---
    } else if (event.startsWith("order.")) {
      // const orderEvent = webhookData as Extract<RazorpayWebhookEvent, { event: "order.paid" }>; // Example
      logInfo(
        "Order event received (handler logic TBD).",
        eventProcessingContextBase,
      );
      // Implement order processing logic here if necessary
      return c.json({ message: "Order event received, processing TBD." });
    } else if (event.startsWith("payment.")) {
      // const paymentEvent = webhookData as Extract<RazorpayWebhookEvent, { event: "payment.captured" | "payment.failed" }>; // Example
      logInfo(
        "Payment event received (handler logic TBD).",
        eventProcessingContextBase,
      );
      // Implement payment processing logic here if necessary
      return c.json({ message: "Payment event received, processing TBD." });
    } else {
      logInfo("Unhandled webhook event type family.", {
        ...eventProcessingContextBase,
        payload: webhookData.payload, // Log the payload for unrecognized events
      });
      return c.json({ message: "Event type family not handled." });
    }
  } catch (error) {
    logError("Unhandled error processing webhook", error, webhookContextBase);
    return c.json(
      { error: "An unexpected error occurred while processing the webhook." },
      500,
    );
  }
});

function validateWebhookSignature(
  body: string,
  signature: string,
  secret: string,
): boolean {
  const expectedSignature = createHmac("sha256", secret)
    .update(body)
    .digest("hex");
  // console.log("Calculated Signature:", expectedSignature); // For debugging only
  // console.log("Received Signature:", signature);
  return expectedSignature === signature;
}

// --- Start Server ---
logInfo(`Subscription service starting. Function name: ${functionName}`);
Deno.serve(app.fetch);
