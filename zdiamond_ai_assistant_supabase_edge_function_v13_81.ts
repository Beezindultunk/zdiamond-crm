// Supabase Edge Function example: zdiamond-ai-assistant
// Deploy with OPENAI_API_KEY stored as a Supabase secret.
// Never put OPENAI_API_KEY in index.html.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders() });
  }

  try {
    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) throw new Error("OPENAI_API_KEY missing");

    const body = await req.json();
    const input = [
      { role: "system", content: body.system || "You are a helpful CRM assistant." },
      { role: "user", content: JSON.stringify({
        intent: body.intent,
        userInput: body.userInput,
        context: body.context
      }) }
    ];

    const r = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: body.model || "gpt-4.1-mini",
        input,
        temperature: 0.3
      })
    });

    const data = await r.json();
    const text =
      data.output_text ||
      data.output?.flatMap((x) => x.content || []).map((c) => c.text || "").join("\n") ||
      "";

    return Response.json({ text, raw: data }, { headers: corsHeaders() });
  } catch (e) {
    return Response.json({ error: String(e?.message || e) }, { status: 500, headers: corsHeaders() });
  }
});

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "https://www.zdiamond.eu",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS"
  };
}
