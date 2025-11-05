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

    // 1) Llamar al RPC existente para desconectar al usuario
    const { data: rpcData, error: rpcError } = await supabase.rpc("disconnect_user_and_find_nearby_count", {
      p_user_id: user_id,
      p_radius_m: radius_meters || 50
    });

    if (rpcError) {
      console.error("RPC error:", rpcError);
      
      if (rpcError.message.includes("User not found")) {
        return new Response(
          JSON.stringify({
            error: rpcError.message
          }),
          {
            status: 404,
            headers: {
              ...corsHeaders,
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
            ...corsHeaders,
            "Content-Type": "application/json"
          }
        }
      );
    }

    // 2) Eliminar el bus de la tabla buses
    // ✅ SOLO eliminar el bus, NO recrearlo
    // La lógica de recrear/actualizar el bus está en user-location-change
    console.log(`🗑️ Eliminando bus después de desconectar usuario ${user_id}...`);
    
    const { error: deleteError } = await supabase
      .from("buses")
      .delete()
      .eq("bus_number", 1);

    if (deleteError) {
      console.error("Bus delete error:", deleteError);
    } else {
      console.log("✅ Bus eliminado correctamente (usuario desconectado)");
    }
    
    // Contar usuarios activos globalmente (solo para debug/respuesta)
    const { count: totalActiveCount, error: totalError } = await supabase
      .from("user_locations")
      .select("*", { count: "exact", head: true })
      .eq("is_active", true);
    
    console.log(`📊 Total de usuarios activos globalmente: ${totalActiveCount ?? 0}`);

    // ✅ Respuesta exitosa con datos del RPC + user_count = 0 (usuario desconectado)
    return new Response(
      JSON.stringify({
        ...rpcData,
        user_count: 0, // ✅ Usuario fue desconectado, ya no está activo
      }),
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
