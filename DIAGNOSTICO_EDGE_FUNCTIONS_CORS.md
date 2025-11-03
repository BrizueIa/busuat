# 🔧 Diagnóstico: Error "Failed to fetch" en Edge Functions

## ❌ Error Detectado

```
ClientException: Failed to fetch, uri=https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/user-location-change
```

Este error significa que **la petición a la Edge Function está siendo bloqueada o no existe**.

## 🔍 Posibles Causas

### 1. Edge Function No Desplegada ⚠️ (MÁS PROBABLE)

Las Edge Functions que proporcionaste (`user-location-change` y `disconnect-user`) **NO están desplegadas** en tu proyecto de Supabase.

**Cómo verificar:**
1. Ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto
3. Ve a **Edge Functions** en el menú lateral
4. Verifica si aparecen las funciones:
   - ✅ `user-location-change`
   - ✅ `disconnect-user`

**Si NO aparecen**, necesitas desplegarlas.

### 2. Problema de CORS (Cross-Origin)

Si estás ejecutando en **navegador web** (Flutter Web), el navegador bloquea peticiones por CORS.

**Solución:** Las Edge Functions deben incluir headers CORS:

```typescript
// En cada Edge Function, asegúrate de tener:
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Y retornar así:
return new Response(
  JSON.stringify(data),
  { 
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200 
  }
)
```

### 3. URL Incorrecta

Verifica que la URL sea correcta:
- ✅ Correcto: `https://tzvyirisalzyaapkbwyw.supabase.co/functions/v1/user-location-change`
- ❌ Incorrecto: URLs con typos o paths incorrectos

## ✅ Soluciones

### Solución 1: Desplegar Edge Functions (RECOMENDADO)

#### Opción A: Usando Supabase CLI

1. **Instala Supabase CLI:**
```bash
npm install -g supabase
```

2. **Login a Supabase:**
```bash
supabase login
```

3. **Crea el directorio de funciones:**
```bash
mkdir -p supabase/functions/user-location-change
mkdir -p supabase/functions/disconnect-user
```

4. **Crea el archivo `user-location-change/index.ts`:**
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { lat, lng, userId } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Actualizar o insertar ubicación del usuario
    const { data: userData, error: userError } = await supabase
      .from('user_locations')
      .upsert({
        user_id: userId,
        lat,
        lng,
        is_active: true,
        updated_at: new Date().toISOString(),
      })
      .select()

    if (userError) throw userError

    // Contar usuarios activos
    const { count } = await supabase
      .from('user_locations')
      .select('*', { count: 'exact', head: true })
      .eq('is_active', true)

    // Calcular posición promedio de todos los usuarios
    const { data: locations } = await supabase
      .from('user_locations')
      .select('lat, lng')
      .eq('is_active', true)

    const avgLat = locations.reduce((sum, loc) => sum + loc.lat, 0) / locations.length
    const avgLng = locations.reduce((sum, loc) => sum + loc.lng, 0) / locations.length

    // Actualizar tabla buses
    const { data: busData, error: busError } = await supabase
      .from('buses')
      .upsert({
        bus_number: 1,
        lat: avgLat,
        lng: avgLng,
        user_count: count || 0,
        updated_at: new Date().toISOString(),
      })
      .select()

    if (busError) throw busError

    return new Response(
      JSON.stringify({ success: true, user: userData, bus: busData }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
```

5. **Crea el archivo `disconnect-user/index.ts`:**
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { userId } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Marcar usuario como inactivo
    const { error } = await supabase
      .from('user_locations')
      .update({ is_active: false })
      .eq('user_id', userId)

    if (error) throw error

    // Recalcular bus con usuarios activos restantes
    const { count } = await supabase
      .from('user_locations')
      .select('*', { count: 'exact', head: true })
      .eq('is_active', true)

    if (count === 0) {
      // Si no hay usuarios, eliminar el bus
      await supabase
        .from('buses')
        .delete()
        .eq('bus_number', 1)
    } else {
      // Recalcular posición promedio
      const { data: locations } = await supabase
        .from('user_locations')
        .select('lat, lng')
        .eq('is_active', true)

      const avgLat = locations.reduce((sum, loc) => sum + loc.lat, 0) / locations.length
      const avgLng = locations.reduce((sum, loc) => sum + loc.lng, 0) / locations.length

      await supabase
        .from('buses')
        .update({
          lat: avgLat,
          lng: avgLng,
          user_count: count,
          updated_at: new Date().toISOString(),
        })
        .eq('bus_number', 1)
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
```

6. **Despliega las funciones:**
```bash
# Link a tu proyecto
supabase link --project-ref tzvyirisalzyaapkbwyw

# Despliega ambas funciones
supabase functions deploy user-location-change
supabase functions deploy disconnect-user
```

#### Opción B: Desde el Dashboard (Más Fácil)

1. Ve a **Edge Functions** en Supabase Dashboard
2. Haz clic en **"New Function"**
3. Nombre: `user-location-change`
4. Pega el código TypeScript de arriba
5. Haz clic en **"Deploy"**
6. Repite para `disconnect-user`

### Solución 2: Verificar CORS en Funciones Existentes

Si ya desplegaste las funciones, asegúrate de que incluyan:

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Handler para OPTIONS (preflight)
if (req.method === 'OPTIONS') {
  return new Response('ok', { headers: corsHeaders })
}

// En todas las respuestas
return new Response(
  JSON.stringify(data),
  { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
)
```

### Solución 3: Crear las Tablas Necesarias

Las Edge Functions requieren estas tablas:

```sql
-- Tabla user_locations
create table user_locations (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null,
  lat double precision not null,
  lng double precision not null,
  is_active boolean default true,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Índices
create index user_locations_user_id_idx on user_locations(user_id);
create index user_locations_is_active_idx on user_locations(is_active);

-- RLS (Row Level Security)
alter table user_locations enable row level security;

create policy "Allow all operations for authenticated users"
  on user_locations for all
  using (true)
  with check (true);

-- Tabla buses
create table buses (
  id uuid default gen_random_uuid() primary key,
  bus_number integer not null unique,
  lat double precision not null,
  lng double precision not null,
  user_count integer default 0,
  updated_at timestamp with time zone default now()
);

-- RLS
alter table buses enable row level security;

create policy "Allow read access to everyone"
  on buses for select
  using (true);

create policy "Allow service role to update"
  on buses for all
  using (true)
  with check (true);

-- Habilitar Realtime
alter publication supabase_realtime add table buses;
```

## 📋 Checklist de Verificación

- [ ] **Edge Functions desplegadas**
  - [ ] `user-location-change`
  - [ ] `disconnect-user`
- [ ] **CORS configurado** en ambas funciones
- [ ] **Tablas creadas**:
  - [ ] `user_locations`
  - [ ] `buses`
- [ ] **Realtime habilitado** en tabla `buses`
- [ ] **Anonymous Auth habilitado** (para usuarios no registrados)
- [ ] **RLS configurado** apropiadamente

## 🎯 Próximos Pasos

1. **Verifica que las Edge Functions existan** en el Dashboard
2. **Si NO existen**, despliégalas usando CLI o Dashboard
3. **Verifica las tablas** en el SQL Editor
4. **Prueba de nuevo** la app

Una vez desplegadas las funciones, deberías ver:
```
✅ Respuesta exitosa: {success: true, ...}
```

En lugar de:
```
❌ Failed to fetch
```
