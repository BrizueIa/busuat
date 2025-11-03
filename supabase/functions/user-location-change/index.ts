import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ✅ CORS Headers - CRÍTICO para Flutter Web
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function isValidLatLng(lat: number, lng: number): boolean {
  return Number.isFinite(lat) && Number.isFinite(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

serve(async (req) => {
  // ✅ SIEMPRE responder a OPTIONS primero (preflight CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return new Response("Use POST", {
        status: 405,
        headers: corsHeaders, // ✅ CORS en error
      });
    }
    
    const { user_id, lat, lng } = await req.json();
    
    if (!user_id || !isValidLatLng(lat, lng)) {
      return new Response("Bad request: user_id/lat/lng inválidos", {
        status: 400,
        headers: corsHeaders, // ✅ CORS en error
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // 1) Upsert de la ubicación del usuario
    {
      const { error } = await supabase
        .from("user_locations")
        .upsert({
          user_id,
          lat,
          lng,
          is_active: true,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: "user_id",
        });

      if (error) {
        console.error("upsert error:", error);
        return new Response("DB upsert error", {
          status: 500,
          headers: corsHeaders, // ✅ CORS en error
        });
      }
    }

    // 2) Contar vecinos
    const { data: count, error: rpcError } = await supabase.rpc("nearby_count_for", {
      p_user_id: user_id,
      p_radius_m: 5,
    });

    if (rpcError) {
      console.error("rpc error:", rpcError);
      return new Response("DB rpc error", {
        status: 500,
        headers: corsHeaders, // ✅ CORS en error
      });
    }

    const nearbyCount = count ?? 0;

    // ✅ Si hay usuarios cercanos, crear/actualizar el bus
    if (nearbyCount >= 1) {
      const busData = {
        bus_number: 1,
        lat: lat,
        lng: lng,
        // ✅ No incluir user_count si la columna no existe
      };

      const { error: upsertError } = await supabase
        .from("buses")
        .upsert(busData, {
          onConflict: "bus_number",
        });

      if (upsertError) {
        console.error("Buses upsert error:", upsertError);
      } else {
        console.log(`Bus 1 updated at (${lat}, ${lng}) with ${nearbyCount} users`);
      }
    } else {
      // ✅ Si no hay usuarios cercanos, eliminar el bus
      const { error: deleteError } = await supabase
        .from("buses")
        .delete()
        .eq("bus_number", 1);
      
      if (deleteError) {
        console.error("Bus delete error:", deleteError);
      } else {
        console.log("Bus 1 removed (no nearby users)");
      }
    }

    // ✅ Respuesta simple - Realtime se encarga del resto
    return new Response(
      JSON.stringify({
        success: true,
        nearby_count: nearbyCount,
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "content-type": "application/json",
        },
      }
    );
  } catch (e) {
    console.error(e);
    return new Response("Internal error", {
      status: 500,
      headers: corsHeaders, // ✅ CORS en error
    });
  }
});
