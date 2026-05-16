// supabase/functions/todo_reminder/index.ts
import { createClient } from "jsr:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

console.info("🚀 Todo Reminder Service Started");

interface Todo {
  id: string;
  local_id: string;
  user_id: string;
  title: string;
  description?: string;
  reminder_at: string;
  reminder_sent?: boolean;
  // reminder_sent_at?: string;
  push_token?: string;
  is_completed: boolean;
  created_at: string;
  updated_at: string;
}

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!supabaseUrl || !supabaseServiceRoleKey) {
  console.error("❌ Missing Supabase credentials");
  throw new Error("Missing Supabase credentials");
}

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

Deno.serve(async (req) => {
  try {
    // Optional: Handle webhook payload
    let payload = null;
    const contentType = req.headers.get("content-type");

    if (contentType?.includes("application/json")) {
      try {
        payload = await req.json();
        console.log("📨 Webhook received:", payload);
      } catch (e) {
        console.log("⚠️ Invalid JSON, continuing");
      }
    }

    const result = await sendReminders();
    return Response.json(result);
  } catch (error) {
    console.error("❌ Error:", error);
    return Response.json({ error: error.message }, { status: 500 });
  }
});

async function sendReminders() {
  const now = new Date();
  const oneMinuteFromNow = new Date(now.getTime() + 1 * 60 * 1000);

  console.log(`⏰ Current time: ${now.toISOString()}`);
  console.log(
    `⏰ Looking for reminders due by: ${oneMinuteFromNow.toISOString()}`,
  );

  try {
    const { data: todos, error } = await supabase
      .from("todos")
      .select("*")
      .eq("reminder_sent", false)
      .not("reminder_at", "is", null)
      .lte("reminder_at", oneMinuteFromNow.toISOString());

    if (error) {
      console.error("❌ Error fetching todos:", error);
      return { success: false, error: error.message };
    }

    if (!todos || todos.length === 0) {
      console.log("✅ No reminders to send");
      return {
        success: true,
        message: "No reminders to send",
        reminders_sent: 0,
      };
    }

    console.log(`📨 Found ${todos.length} reminder(s) to send`);

    const results = [];
    for (const todo of todos) {
      console.log(`📤 Processing: ${todo.title}`);

      const res = await sendPush(todo);
      if (!res.success) {
        console.error(`❌ Failed: ${res.message}`);
        results.push({
          id: todo.id,
          title: todo.title,
          success: false,
          error: res.message,
        });
        continue;
      }

      const { error: updateError } = await supabase
        .from("todos")
        .update({
          reminder_sent: true,
          reminder_at: new Date().toISOString(),
        })
        .eq("id", todo.id);

      if (updateError) {
        console.error(`Error updating todo ${todo.id}:`, updateError);
        results.push({
          id: todo.id,
          title: todo.title,
          success: false,
          error: updateError.message,
        });
      } else {
        results.push({
          id: todo.id,
          title: todo.title,
          reminder_at: todo.reminder_at,
          success: true,
        });
      }
    }

    return {
      success: true,
      reminders_sent: results.filter((r) => r.success).length,
      reminders_failed: results.filter((r) => !r.success).length,
      results,
    };
  } catch (error) {
    console.error("❌ Error in sendReminders:", error);
    return { success: false, error: error.message };
  }
}

async function loadServiceAccount() {
  const projectId = Deno.env.get("FCM_PROJECT_ID");
  const clientEmail = Deno.env.get("FCM_CLIENT_EMAIL");
  let privateKey = Deno.env.get("FCM_PRIVATE_KEY");

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error("Missing FCM service account credentials in environment");
  }

  // Important: Replace escaped newlines and ensure proper formatting
  privateKey = privateKey.replace(/\\n/g, "\n");

  // Validate that the private key has the correct format
  if (!privateKey.includes("-----BEGIN PRIVATE KEY-----")) {
    console.error(
      "❌ Invalid private key format. Key should start with -----BEGIN PRIVATE KEY-----",
    );
    throw new Error("Invalid private key format");
  }

  console.log("✅ Service account loaded successfully");

  return {
    projectId,
    clientEmail,
    privateKey,
  };
}

const getAccessToken = async ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}) => {
  try {
    console.log("🔑 Getting access token...");

    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });

    const tokens = await jwtClient.authorize();

    if (!tokens.access_token) {
      throw new Error("No access token received");
    }

    console.log("✅ Access token obtained successfully");
    return tokens.access_token;
  } catch (error) {
    console.error("❌ Error getting access token:", error.message);
    throw error;
  }
};

async function sendPush(todo: Todo) {
  if (!todo.push_token) {
    return { success: false, message: "No push token found" };
  }

  try {
    console.log(`📤 Sending push notification for: ${todo.title}`);

    const { projectId, clientEmail, privateKey } = await loadServiceAccount();
    const accessToken = await getAccessToken({ clientEmail, privateKey });

    const requestBody = {
      message: {
        token: todo.push_token,
        notification: {
          title: "🔔 Reminder",
          body: todo.title,
        },
        data: {
          todo_id: todo.id,
          user_id: todo.user_id,
          local_id: todo.local_id,
          type: "reminder",
          title: todo.title,
          description: todo.description || "",
          reminder_at: todo.reminder_at,
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channel_id: "reminders",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      },
    };

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(requestBody),
      },
    );

    const responseData = await response.json();

    if (!response.ok) {
      console.error("❌ FCM API error:", responseData);
      return {
        success: false,
        data: responseData,
        message: `Failed to send push notification: ${responseData.error?.message || response.statusText}`,
      };
    }

    console.log(`✅ Push notification sent successfully for: ${todo.title}`);
    return {
      success: true,
      data: responseData,
      message: "Reminder sent successfully",
    };
  } catch (error) {
    console.error("❌ Error in sendPush:", error);
    return { success: false, message: error.message };
  }
}
