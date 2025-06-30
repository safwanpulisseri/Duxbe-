// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";
import { Hono } from "jsr:@hono/hono";
import { cors } from "jsr:@hono/hono/cors";
import { Database } from "../database.types.ts";

const supabaseClient = createClient<Database>(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  },
);

const ENV = Deno.env.get("ENV")!;
const ENV_URL = ENV === "development"
  ? "https://dev.duxbe.com"
  : "https://business.duxbe.com";
// --- Email Configuration - Set these in Supabase Environment Variables ---
const SENDER_EMAIL_ADDRESS = Deno.env.get("SENDER_EMAIL_ADDRESS")!;
const SENDER_EMAIL_NAME = Deno.env.get("SENDER_EMAIL_NAME") || "Team Duxbe"; // Optional: Name to display for sender
const SMTP_HOSTNAME = Deno.env.get("SMTP_HOSTNAME")!;
const SMTP_PORT = Deno.env.get("SMTP_PORT")!; // e.g., 587 or 465
const SMTP_USERNAME = Deno.env.get("SMTP_USERNAME")!;
const SMTP_PASSWORD = Deno.env.get("SMTP_PASSWORD")!;
const SMTP_TLS = Deno.env.get("SMTP_TLS")?.toLowerCase() === "true"; // Set to 'true' to enable TLS, false or undefined for no TLS/STARTTLS
const REPLY_TO_EMAIL = Deno.env.get("REPLY_TO_EMAIL");

// change this to your function name
const functionName = "employees";
const app = new Hono().basePath(`/${functionName}`);

app.use("*", cors());

app.post("/create-employee", async (c) => {
  try {
    console.log("Starting create-employee endpoint");
    // Extract the request body
    const { email, name, phone, org_id, business_id, roles } = await c
      .req
      .json();
    console.log("Request body extracted:", {
      email,
      name,
      phone,
      org_id,
      business_id,
      roles,
    });

    console.log("Checking if user exists...");
    const { data: userData, error: userError } = await supabaseClient.rpc(
      "check_user_exists",
      {
        p_email: email,
        p_phone: phone,
      },
    );
    if (userError) {
      console.error("Error checking user existence:", userError);
      return c.json({
        error: "Failed to check user existence",
        details: userError.message,
      }, 500);
    }
    console.log("User existence check result:", userData);

    if (userData.length > 0) {
      console.log("User already exists, checking organization status");
      // user already exists
      // now we need to check if the user is an employee
      const user_meta_data = userData[0].raw_user_meta_data as {
        org_id?: string;
      };
      if (user_meta_data.org_id) {
        console.log("User is already in organization:", user_meta_data.org_id);
        // user is an employee of an organization
        // then return error saying user is already in an organization
        return c.json({
          error: "User is already in an organization",
          details: user_meta_data.org_id,
        }, 400);
      } else {
        console.log(
          "User exists but not in organization, generating invite link",
        );
        // user is not an employee of an organization
        // invite user to the organization
        const { data: inviteData, error: inviteError } = await supabaseClient
          .auth.signInWithOtp({
            email: email,
            options: {
              emailRedirectTo: `${ENV_URL}/set_new_user?org_id=${org_id}`,
              shouldCreateUser: true,
            },
          });
        const { error: updateUserError } = await supabaseClient.auth.admin
          .updateUserById(userData[0].id, {
            phone: phone,
            email: email,
            user_metadata: {
              invited_org_id: org_id,
              is_employee: true,
              employee_role: "staff",
              user_name: name,
              phone_number: phone,
              business_id: business_id,
              roles: roles,
            },
          });

        if (updateUserError) {
          return c.json({
            error: "Failed to update user, Email or Phone already in use",
          }, 500);
        }
        if (inviteError) {
          console.error("Error generating invite link:", inviteError);
          return c.json({
            error: "Failed to invite user",
            details: inviteError.message,
          }, 500);
        }
        if (inviteData) {
          return c.json({
            message: "User invited successfully",
            details: inviteData.messageId,
          }, 200);
        }
      }
    } else {
      console.log("User does not exist, creating new invitation");
      // user does not exist
      // invite user to the organization
      const { data: inviteData, error: inviteError } = await supabaseClient.auth
        .admin.inviteUserByEmail(email, {
          data: {
            invited_org_id: org_id,
            is_employee: true,
            employee_role: "staff",
            user_name: name,
            phone_number: phone,
            business_id: business_id,
            roles: roles,
          },
          redirectTo: `${ENV_URL}/set_new_user?org_id=${org_id}`,
        });
      if (inviteError) {
        console.error("Error creating new invitation:", inviteError);
        return c.json({
          error: "Failed to invite user",
          details: inviteError.message,
        }, 500);
      }
      if (inviteData) {
        console.log("New user invitation created successfully");
        return c.json({
          message: "User invited successfully",
          details: inviteData.user.id,
        }, 200);
      }
    }
  } catch (error) {
    console.error("Unexpected error in create-employee:", error);
    return c.json({ error: `An error occurred: ${error}` }, 500);
  }
});

app.post("/create-customer", async (c) => {
  try {
    // Extract the request body
    const {
      email,
      name,
      phone,
      business_id,
      address,
      image,
      customer_balance,
      customer_id,
      org_id,
    } = await c.req
      .json<{
        email: string;
        name: string;
        phone: string;
        business_id: string;
        address: string;
        image: string;
        customer_balance?: number;
        customer_id?: string;
        org_id: string;
      }>();

    if (customer_id) {
      // upsert business customer

      const { error: updateUserError } = await supabaseClient.auth.admin
        .updateUserById(customer_id, {
          phone: phone,
          email: email,
          user_metadata: {
            user_name: name,
            phone_number: phone,
            email_address: email,
            image: image,
          },
        });

      if (updateUserError) {
        return c.json({
          error: "Failed to update user, Email or Phone already in use",
        }, 500);
      }

      const { error: businessCustomerError } = await supabaseClient.rpc(
        "upsert_business_customer",
        {
          p_customer_data: {
            customer_id,
            name,
            address,
            image,
            business_id,
          },
        },
      );

      if (businessCustomerError) {
        return c.json({ error: "Failed to upsert business customer" }, 500);
      }
      return c.json(
        {
          message: "Business customer upserted successfully",
          customer_id,
        },
        200,
      );
    }

    if (!email && !phone) {
      return c.json({ error: "Either email or phone is required" }, 400);
    }

    // Check if user exists in users table by email or phone
    const { data: userData, error: userError } = await supabaseClient.rpc(
      "check_user_exists",
      {
        p_email: email,
        p_phone: phone,
      },
    );
    if (userError) {
      return c.json({
        error: "Failed to check user existence",
        details: userError.message,
      }, 500);
    }

    let userId;

    if (!userData?.length) {
      // Create new user if doesn't exist
      const { data: authResp, error: authError } = await supabaseClient.auth
        .admin
        .createUser({
          email,
          phone,
          email_confirm: true,
          phone_confirm: true,
          user_metadata: {
            is_customer: true,
            user_name: name,
            phone_number: phone,
            email_address: email,
            image: image,
          },
        });

      if (authError) {
        return c.json({
          error: "Failed to create user",
          details: authError.message,
        }, 500);
      }

      userId = authResp.user.id;

      // Insert into business_customers table
      const { error: businessCustomerError } = await supabaseClient
        .rpc("upsert_business_customer", {
          p_customer_data: {
            customer_id: userId,
            name,
            address,
            image,
            customer_balance,
            business_id,
            org_id,
          },
        });

      if (businessCustomerError) {
        return c.json({
          error: "Failed to create business customer record",
          details: businessCustomerError.message,
        }, 500);
      }
      return c.json({
        message: "Customer created successfully",
        customer_id: userId,
      }, 200);
    } else {
      const userEmail = userData[0].email;
      const userPhone = userData[0].phone;

      if (userPhone && phone && userPhone !== phone.replaceAll("+", "")) {
        return c.json({
          error: "Phone number mismatch",
          details:
            "This provided number is already attached with another email",
        }, 400);
      }

      if (userEmail && email && userEmail !== email) {
        return c.json({
          error: "Email mismatch",
          details: "The provided email is already attached with another phone",
        }, 400);
      }

      // user already exists
      // then we need to check if the user is a customer
      const user_meta_data = userData[0].raw_user_meta_data as {
        is_customer?: boolean;
      };
      if (user_meta_data.is_customer) {
        // user is a customer
        // then we need to upsert the customer
        const { error: businessCustomerError } = await supabaseClient.rpc(
          "upsert_business_customer",
          {
            p_customer_data: {
              customer_id: userData[0].id,
              name,
              address,
              image,
              customer_balance,
              business_id,
              org_id,
            },
          },
        );
        if (businessCustomerError) {
          return c.json({ error: "Failed to upsert business customer" }, 500);
        }
        return c.json({
          message: "Customer upserted successfully",
          customer_id: userData[0].id,
        }, 200);
      } else {
        // user is not a customer
        // then we need to create a new customer
        const { error: updateUserError } = await supabaseClient.auth.admin
          .updateUserById(userData[0].id, {
            user_metadata: {
              is_customer: true,
              user_name: name,
              phone_number: phone,
              email_address: email,
              image: image,
            },
          });
        if (updateUserError) {
          return c.json({ error: "Failed to update user" }, 500);
        }

        const { error: businessCustomerError } = await supabaseClient.rpc(
          "upsert_business_customer",
          {
            p_customer_data: {
              customer_id: userData[0].id,
              name,
              address,
              image,
              customer_balance,
              business_id,
              org_id,
            },
          },
        );
        if (businessCustomerError) {
          return c.json({ error: "Failed to upsert business customer" }, 500);
        }
        return c.json({
          message: "Customer created successfully",
          customer_id: userId,
        }, 200);
      }
    }
  } catch (error) {
    return c.json({ error: `An error occurred: ${error}` }, 500);
  }
});

app.post("/reset-employee-password", async (c) => {
  try {
    // Extract the request body
    const { email } = await c.req
      .json();

    if (!email) {
      return c.json({ error: "Email is required" }, 400);
    }

    const { data: authResp, error: authError } = await supabaseClient.auth
      .resetPasswordForEmail(email, {
        redirectTo: `${ENV_URL}/set_new_password`,
      });

    if (authError) {
      return c.json({
        error: "Failed to send password reset",
        details: authError.message,
      }, 500);
    }
    if (authResp) {
      return c.json({
        error: "Password Reset sent successfully",
      }, 200);
    }
  } catch (error) {
    return c.json({ error: `An error occurred: ${error}` }, 500);
  }
});

app.post("/auth", async (c) => {
  try {
    const { platform, user_type, force_signup, auth, data } = await c.req.json<{
      platform: string;
      user_type: string;
      force_signup?: boolean;
      auth: {
        type: string;
        email?: string;
        password?: string;
        phone?: string;
      };
      data?: {
        [key: string]: string | number | boolean | object | undefined;
      };
    }>();

    if (platform === "duxbe") {
      if (user_type === "employee") {
        if (auth.type === "signup") {
          if (
            !data ||
            !data.user_type || !data.user_name ||
            !data.business_type || !data.currency ||
            !auth.email || !auth.password || !auth.phone
          ) {
            return c.json(
              {
                error: "Missing required fields",
                details:
                  "user_type, user_name, phone_number, business_type, currency are required",
              },
              400,
            );
          }
          // Check if user exists in auth.users table
          const { data: userData, error: userError } = await supabaseClient.rpc(
            "check_user_exists",
            {
              p_email: auth.email,
              p_phone: auth.phone,
            },
          );
          if (userError) {
            return c.json({
              error: "Failed to check user existence",
              details: userError.message,
            }, 500);
          }
          if (userData.length > 0) {
            // user already exists
            // now we need to check if the user is an employee
            const user_meta_data = userData[0].raw_user_meta_data as {
              org_id?: string;
              invited_org_id?: string;
            };
            if (user_meta_data.org_id) {
              // user is an employee of an organization
              // then return error saying user is already in an organization
              return c.json({
                error: "User is already in an organization",
                details: user_meta_data.org_id,
              }, 400);
            } else if (user_meta_data.invited_org_id && !force_signup) {
              // user is not an employee of an organization but is invited to one
              // then we need show a message to the user to accept the invitation or reject it

              // fetch the organization details
              const { data: organizationData, error: organizationError } =
                await supabaseClient
                  .from("organizations")
                  .select("*")
                  .eq("org_id", user_meta_data.invited_org_id)
                  .limit(1);

              if (organizationError || !organizationData?.length) {
                // if the organization is not found, then continue with the signup process
                console.error(organizationError);
                const { data: _, error: updatePasswordError } =
                  await supabaseClient.auth.admin.updateUserById(
                    userData[0].id,
                    {
                      password: auth.password,
                    },
                  );

                if (updatePasswordError) {
                  return c.json({
                    error: "Failed to signup",
                    details: updatePasswordError.message,
                  }, 500);
                }
                // MARK: continue with the signin process and update the user
                const { data: loginData, error: loginError } =
                  await supabaseClient.auth.signInWithPassword({
                    email: auth.email!,
                    password: auth.password,
                  });

                if (loginError) {
                  return c.json({
                    error: "Failed to login",
                    details: loginError.message,
                  }, 500);
                }
                const { data: updateData, error: updateError } =
                  await supabaseClient.auth.updateUser({
                    data: {
                      platform: "duxbe",
                      is_employee: true,
                      employee_role: "admin",
                      user_name: data?.user_name,
                      phone_number: auth.phone,
                      business_type: data?.business_type,
                      currency: data?.currency,
                    },
                  });

                if (updateError) {
                  return c.json({
                    error: "Failed to update user",
                    details: updateError.message,
                  }, 500);
                }
                if (updateData) {
                  return c.json({
                    message: "Employee created successfully",
                    token: loginData.session?.refresh_token,
                  }, 200);
                }
              }

              return c.json({
                message: "You have been invited to join an organization",
                // detailed message to the user to accept the invitation or reject it
                details: `You have been invited to join ${
                  organizationData![0].name
                }. Please accept the invitation to continue. Reject the invitation to continue with the signup process.`,
                code: 100,
              }, 200);
            } else if (user_meta_data.invited_org_id && force_signup) {
              // user is invited to an organization and force_signup is true then
              // it means user rejected the previous invitation
              // then we need to signup the user as an admin of the organization
              // we need to update the user's metadata
              const { data: updateData, error: updateError } =
                await supabaseClient.auth.admin.updateUserById(userData[0].id, {
                  password: auth.password,
                  email_confirm: true,
                  user_metadata: {
                    platform: "duxbe",
                    is_employee: true,
                    employee_role: "admin",
                    user_name: data?.user_name,
                    phone_number: auth.phone,
                    business_type: data?.business_type,
                    currency: data?.currency,
                  },
                });

              if (updateError) {
                return c.json({
                  error: "Failed to update user",
                  details: updateError.message,
                }, 500);
              }
              if (updateData) {
                return c.json({
                  message: "Organization created successfully",
                  code: 101,
                }, 200);
              }
            } else {
              // user is not an employee of an organization and is not invited to one, also means maybe a customer
              // then we need to login the user, but on trigger we need to add the employee record

              const { data: _, error: updatePasswordError } =
                await supabaseClient.auth.admin.updateUserById(userData[0].id, {
                  password: auth.password,
                });

              if (updatePasswordError) {
                return c.json({
                  error: "Failed to signup",
                  details: updatePasswordError.message,
                }, 500);
              }

              const { data: loginData, error: loginError } =
                await supabaseClient.auth.signInWithPassword({
                  email: auth.email!,
                  password: auth.password,
                });

              if (loginError) {
                return c.json({
                  error: "Failed to signup",
                  details: loginError.message,
                }, 500);
              }
              const { data: updateData, error: updateError } =
                await supabaseClient.auth.updateUser({
                  data: {
                    platform: "duxbe",
                    is_employee: true,
                    employee_role: "admin",
                    user_name: data?.user_name,
                    phone_number: auth.phone,
                    business_type: data?.business_type,
                    currency: data?.currency,
                  },
                });

              if (updateError) {
                return c.json({
                  error: "Failed to update user",
                  details: updateError.message,
                }, 500);
              }
              if (updateData) {
                return c.json({
                  message: "Employee created successfully",
                  token: loginData.session?.refresh_token,
                }, 200);
              }
            }
          } else {
            // user is not in the auth.users table then signup as an employee
            // we need to signup the user as an employee

            const { data: signUpData, error: signUpError } =
              await supabaseClient.auth.signUp({
                email: auth.email!,
                phone: auth.phone?.replaceAll("+", ""),
                password: auth.password,
                options: {
                  data: {
                    user_name: data?.user_name,
                    is_employee: true,
                    phone_number: auth.phone,
                    business_type: data?.business_type,
                    currency: data?.currency,
                    employee_role: "admin",
                    platform: "duxbe",
                  },
                },
              });
            if (signUpError) {
              return c.json({
                error: "Failed to signup",
                details: signUpError.message,
              }, 500);
            }
            if (signUpData) {
              return c.json({
                message: "Employee created successfully",
                token: signUpData.session?.refresh_token,
              }, 200);
            }
          }
        } else if (auth.type === "login") {
          if (
            !auth.email || !auth.password
          ) {
            return c.json(
              {
                error: "Missing required fields",
                details: "email and password are required",
              },
              400,
            );
          }
          // login employee
          const { data: loginData, error: loginError } = await supabaseClient
            .auth.signInWithPassword({
              email: auth.email!,
              password: auth.password!,
            });

          if (loginError) {
            return c.json({
              error: "Failed to login",
              details: loginError.message,
            }, 500);
          }
          if (loginData.user.app_metadata.org_id) {
            return c.json({
              message: "Employee logged in successfully",
              token: loginData.session?.refresh_token,
            }, 200);
          } else {
            // user is not an employee of an organization
            // so throw an error
            return c.json({
              error: "No user found",
            }, 400);
          }
        } else {
          return c.json({ error: "Invalid auth type" }, 400);
        }
      }
    }
  } catch (error) {
    return c.json({ error: `An error occurred: ${error}` }, 500);
  }
});

Deno.serve(app.fetch);
