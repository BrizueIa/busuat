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

    // 2) Contar usuarios activos CERCANOS restantes (no globales)
    // ✅ FIX: Usar conteo de proximidad, no conteo global
    // El RPC ya nos dio el nearby_count, pero necesitamos recalcularlo
    // porque el usuario actual ya fue desconectado
    console.log(`🔍 Verificando usuarios cercanos al usuario ${user_id} después de desconectar...`);
    
    const { data: nearbyUsersData, error: nearbyError } = await supabase.rpc("nearby_count_for", {
      p_user_id: user_id,  // Aunque esté desconectado, usar su última posición
      p_radius_m: radius_meters || 50
    });

    if (nearbyError) {
      console.error("Nearby count error:", nearbyError);
    }

    // El conteo de usuarios cercanos (sin incluir al que se desconectó)
    const userCount = nearbyUsersData ?? 0;
    console.log(`📊 nearby_count_for retornó: ${userCount} usuarios cercanos activos`);
    
    // Debug: Verificar cuántos usuarios activos hay en total
    const { count: totalActiveCount, error: totalError } = await supabase
      .from("user_locations")
      .select("*", { count: "exact", head: true })
      .eq("is_active", true);
    
    console.log(`📊 Total de usuarios activos globalmente: ${totalActiveCount ?? 0}`);

    // 3) Actualizar user_count en la tabla buses o eliminar el bus
    if (userCount > 0) {
      // Obtener la última posición de un usuario activo
      const { data: activeUser, error: activeUserError } = await supabase
        .from("user_locations")
        .select("lat, lng")
        .eq("is_active", true)
        .limit(1)
        .single();

      if (!activeUserError && activeUser) {
        const { error: busUpdateError } = await supabase
          .from("buses")
          .upsert({
            bus_number: 1,
            lat: activeUser.lat,
            lng: activeUser.lng,
            user_count: userCount,
          }, {
            onConflict: "bus_number",
          });

        if (busUpdateError) {
          console.error("Bus update error:", busUpdateError);
        } else {
          console.log(`Bus 1 updated: ${userCount} active users after disconnect`);
        }
      }
    } else {
      // No quedan usuarios activos, eliminar el bus
      const { error: deleteError } = await supabase
        .from("buses")
        .delete()
        .eq("bus_number", 1);

      if (deleteError) {
        console.error("Bus delete error:", deleteError);
      } else {
        console.log("Bus 1 removed (no active users remaining)");
      }
    }

    // ✅ Respuesta exitosa con datos del RPC + user_count actualizado
    return new Response(
      JSON.stringify({
        ...rpcData,
        user_count: userCount,
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
