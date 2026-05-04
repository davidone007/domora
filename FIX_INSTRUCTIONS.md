# Fix para Error "Database error saving new user"

## Problema
El error ocurre porque:
- Un correo anterior (ej: miguelangelmartines148@gmail.com) quedó registrado en `public.users`
- Al intentar registrarse nuevamente con el mismo correo, el trigger `handle_new_user()` intenta insertar pero choca con la restricción `UNIQUE` en el email
- Supabase retorna: "Database error saving new user"

## Solución
Cambiar el trigger `handle_new_user()` para ignorar CUALQUIER conflicto (no solo `ON CONFLICT (id)`):

```sql
ON CONFLICT DO NOTHING;  -- ignora conflictos de email o id
```

---

## OPCIÓN 1: Aplicar via Dashboard (Recomendado - Sin credenciales necesarias)

1. **Abre Supabase Dashboard**
   - Ve a: https://app.supabase.com/ → tu proyecto

2. **Abre SQL Editor**
   - Click en **SQL Editor** (lado izquierdo)
   - Click en **New Query**

3. **Copia y pega este SQL:**
   ```sql
   -- Drop existing trigger
   DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

   -- Recreate function with ON CONFLICT DO NOTHING (ignores ALL conflicts)
   CREATE OR REPLACE FUNCTION public.handle_new_user()
   RETURNS trigger
   LANGUAGE plpgsql
   SECURITY DEFINER SET search_path = public
   AS $$
   BEGIN
     INSERT INTO public.users (id, email)
     VALUES (new.id, new.email)
     ON CONFLICT DO NOTHING;
     RETURN new;
   END;
   $$;

   -- Recreate trigger
   CREATE TRIGGER on_auth_user_created
     AFTER INSERT ON auth.users
     FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

   -- Verify
   SELECT 'Fix applied successfully' as status;
   ```

4. **Click "Run"**
   - Si ves "Fix applied successfully" al final, ¡el fix está aplicado! ✅

5. **Prueba el signup**
   - Vuelve a intentar registrarte con el correo problemático
   - Ya debería funcionar

---

## OPCIÓN 2: Aplicar via Script Node.js (Automático)

Si tienes Node.js instalado y quieres que sea automático:

1. **Obtén tu service_role_key:**
   - Ve a Supabase Dashboard → Settings → API
   - Copia la **Service Role Key** (la que comienza con `eyJ...`)

2. **Ejecuta el script:**
   ```powershell
   cd C:\Users\Miguel Angel\Documents\Apps Móviles\domora
   node apply-fix.js
   ```

3. **Cuando se solicite, pega tu service_role_key**
   - El script ejecutará el SQL automáticamente
   - Verás el resultado en la terminal

---

## OPCIÓN 3: Aplicar via CLI de Supabase (Si lo tienes instalado)

```bash
supabase db query < APPLY_FIX.sql
```

---

## Verificación Posterior

Una vez aplicado el fix, verifica en el dashboard:

1. **SQL Editor → New Query**
2. **Ejecuta:**
   ```sql
   SELECT COUNT(*) as "Usuarios en auth.users", 
          (SELECT COUNT(*) FROM public.users) as "Usuarios en public.users";
   ```
3. Los conteos deberían ser similares (puede haber pequeñas diferencias)

---

## Archivos incluidos

- `APPLY_FIX.sql` - Script SQL listo para copiar-pegar
- `apply-fix.js` - Script Node.js automático
- `supabase_schema.sql` - Schema completo (ya contiene el fix)

---

**¿Cuál prefieres?** 
- **Opción 1** (Dashboard) es la más simple, sin dependencias
- **Opción 2** (Node.js) es completamente automático
