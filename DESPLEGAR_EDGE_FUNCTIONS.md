# 🚀 Cómo Desplegar las Edge Functions con CORS

## 📋 Prerequisitos

1. **Instalar Supabase CLI:**
```bash
npm install -g supabase
```

2. **Login a Supabase:**
```bash
supabase login
```

3. **Vincular tu proyecto:**
```bash
supabase link --project-ref tzvyirisalzyaapkbwyw
```

## 🔧 Desplegar las Funciones

### Desplegar user-location-change:
```bash
cd /home/brizuela/development/flutterProjects/busuat
supabase functions deploy user-location-change
```

### Desplegar disconnect-user:
```bash
supabase functions deploy disconnect-user
```

### Desplegar ambas a la vez:
```bash
supabase functions deploy user-location-change disconnect-user
```

## ✅ Verificar Despliegue

1. Ve a tu Dashboard de Supabase: https://supabase.com/dashboard
2. Navega a **Edge Functions**
3. Deberías ver:
   - ✅ `user-location-change` - Deployed
   - ✅ `disconnect-user` - Deployed

## 🧪 Probar las Funciones

Una vez desplegadas, prueba desde tu app Flutter. Deberías ver en los logs:

```
✅ Usuario existente encontrado: [user-id]
📍 Ubicación obtenida: LatLng(...)
🔵 Llamando a Edge Function user-location-change...
✅ Respuesta exitosa: {nearby_count: 1}
```

En lugar del error anterior:
```
❌ ClientException: Failed to fetch
```

## 📊 Ver Logs en Tiempo Real

Para ver los logs de las funciones mientras las pruebas:

```bash
# Ver logs de user-location-change
supabase functions logs user-location-change --tail

# Ver logs de disconnect-user
supabase functions logs disconnect-user --tail
```

## 🔍 Troubleshooting

### Error: "No project linked"
```bash
supabase link --project-ref tzvyirisalzyaapkbwyw
```

### Error: "Not logged in"
```bash
supabase login
```

### Ver funciones desplegadas:
```bash
supabase functions list
```

## 📝 Cambios Realizados en las Funciones

✅ **CORS Headers agregados:**
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type`

✅ **Manejo de OPTIONS requests** (preflight)

✅ **CORS en todas las respuestas** (éxito y error)

## 🎯 Resultado Esperado

Después de desplegar, cuando presiones "Estoy en el bus":

1. ✅ Se crea/obtiene usuario anónimo
2. ✅ Se obtiene ubicación GPS
3. ✅ **Llamada exitosa a user-location-change** (sin error de CORS)
4. ✅ Respuesta: `{nearby_count: X}`
5. ✅ Bus aparece en el mapa si hay usuarios cercanos

¡Ya no deberías ver el error "Failed to fetch"! 🎉
