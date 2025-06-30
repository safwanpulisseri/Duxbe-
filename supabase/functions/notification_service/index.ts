import { Hono } from "jsr:@hono/hono";
import { cors } from "jsr:@hono/hono/cors";
import { Logger } from "jsr:@deno-library/logger";
import { Payload } from "./src/types/payload.d.ts";
import { Sale } from "./src/types/sales.d.ts";
import { handleInvoiceProcessing } from "./src/controllers/invoice_controller.ts";

// Initialize Hono app and logger
const functionName = "notification_service";
const app = new Hono().basePath(`/${functionName}`);
export const logger = new Logger();

// Valid operation types
const VALID_OPERATIONS = ["INSERT", "UPDATE", "DELETE"] as const;
type OperationType = typeof VALID_OPERATIONS[number];

app.use("*", cors());

app.get("/", (c) => {
  return c.json({ message: "Hello World" });
});

app.post("/send_invoice", async (c) => {
  try {
    const payload = await c.req.json() as Payload<Sale>;

    // Validate payload
    if (!isValidPayload(payload)) {
      return c.json({
        error: "Invalid payload structure. Required: sale_id and type",
      }, 400);
    }

    if ((payload.record?.due_amount ?? 0) > 0) {
      return c.json({
        error: "Invoice is not paid",
      }, 400);
    }

    // Skip if it's an update and previous due_amount was already 0
    if (
      payload.type === "UPDATE" && (payload.old_record?.due_amount ?? 1) === 0
    ) {
      return c.json({
        message: "Skipping - invoice was already paid",
      }, 200);
    }

    const sale_id = payload.record!.sale_id;
    const operationType = payload.type;

    logger.info({
      message: "Processing invoice request",
      sale_id,
      operationType,
    });

    // Check if operation type is supported
    if (!VALID_OPERATIONS.includes(operationType as OperationType)) {
      logger.error("Unsupported operation type:", operationType);
      return c.json({ error: "Unsupported operation type" }, 400);
    }

    const result = await handleInvoiceProcessing(sale_id);

    logger.info("Operation completed successfully", { result });
    return c.json({ message: result }, 200);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    logger.error("Error processing request:", errorMessage);
    return c.json({ error: errorMessage }, 500);
  }
});

/**
 * Validates the payload structure
 */
function isValidPayload(payload: unknown): payload is Payload<Sale> {
  return Boolean(
    payload &&
      typeof payload === "object" &&
      "record" in payload &&
      (payload.record === null ||
        (typeof payload.record === "object" &&
          payload.record !== null &&
          "sale_id" in payload.record)) &&
      "type" in payload,
  );
}

// Start the server
Deno.serve(app.fetch);
