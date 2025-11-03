import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ✅ CORS Headers - CRÍTICO para Flutter Web
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // ✅ SIEMPRE responder a OPTIONS primero (preflight CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({
        error: "Method Not Allowed"
      }),
      {
        status: 405,
        headers: {
          ...corsHeaders, // ✅ CORS en error
          "Content-Type": "application/json"
        }
      }
    );
  }

  try {
    const { user_id, radius_meters } = await req.json();
    
    if (!user_id) {
      return new Response(
        JSON.stringify({
          error: "Bad request: Falta user_id"
        }),
        {
          status: 400,
          headers: {
            ...corsHeaders, // ✅ CORS en error
            "Content-Type": "application/json"
          }
        }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Llamamos a la función que ahora hace TODO
    const { data, error } = await supabase.rpc("disconnect_user_and_find_nearby_count", {
      p_user_id: user_id,
      p_radius_m: radius_meters || 50
    });

    if (error) {
      console.error("RPC error:", error);
      
      if (error.message.includes("User not found")) {
        return new Response(
          JSON.stringify({
            error: error.message
          }),
          {
            status: 404,
            headers: {
              ...corsHeaders, // ✅ CORS en error
              "Content-Type": "application/json"
            }
          }
        );
      }
      
      return new Response(
        JSON.stringify({
          error: "Database RPC error"
        }),
        {
          status: 500,
          headers: {
            ...corsHeaders, // ✅ CORS en error
            "Content-Type": "application/json"
          }
        }
      );
    }

    // ✅ Respuesta exitosa con CORS
    return new Response(
      JSON.stringify(data),
      {
        status: 200,
        headers: {
          ...corsHeaders, // ✅ CORS en éxito
          "Content-Type": "application/json"
        }
      }
    );
  } catch (e) {
    console.error("Internal server error:", e);
    return new Response(
      JSON.stringify({
        error: "Internal server error"
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders, // ✅ CORS en error
          "Content-Type": "application/json"
        }
      }
    );
  }
});
