import { serve } from "https://deno.land/std/http/server.ts";

const { BOT_TOKEN, USERNAME, FLY_API_TOKEN, FLY_MACHINE_ID, FLY_APP } = Deno.env.toObject();

const sendTelegramMessage = async (chat_id: string, message: string) => {
  await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      chat_id: chat_id,
      text: message,
    }),
  });
};

const performAction = async (user_id: string, action: string) => {
  const url = `https://api.machines.dev/v1/apps/${FLY_APP}/machines/${FLY_MACHINE_ID}/${action}`;
  const headers = {
    Authorization: `Bearer ${FLY_API_TOKEN}`,
    "Content-Type": "application/json",
  };

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: headers,
    });

    if (response.status !== 200) {
      await sendTelegramMessage(
        user_id,
        `Sorry, failed to ${action} the machine`
      );
      return;
    }

    const responseData = await response.json();
    await sendTelegramMessage(user_id, `Ok, the machine is now ${action}ed`);
    return responseData;
  } catch (error) {
    console.error("Error:", error);
    await sendTelegramMessage(
      user_id,
      `Sorry, an error occurred while trying to ${action} the machine`
    );
  }
};

serve(async (req: Request) => {
  if (req.url.endsWith("/favicon.ico") || req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  try {
    const body = await req.json();
    const from_id = body?.message?.from?.id.toString();
    const username = body?.message?.from?.username;
    if (username !== USERNAME) {
      await sendTelegramMessage(from_id, "You are unauthorized");
      return new Response("Unauthorized");
    } else {
      const text = body?.message?.text;
      if (text.startsWith("/start")) {
        await performAction(from_id, "start");
        return new Response("OK");
      } else if (text.startsWith("/stop")) {
        await performAction(from_id, "stop");
        return new Response("OK");
      }
      return new Response("No Action Found");
    }
  } catch (e) {
    console.log(e);
    return new Response("No Body as JSON");
  }
});
