#!/usr/bin/env node

/**
 * Script para aplicar el fix del trigger a Supabase directamente
 * Requiere: service_role_key (obtén de Supabase Dashboard → Settings → API)
 * 
 * Uso:
 *   node apply-fix.js
 * 
 * Te pedirá que pegues la service_role_key interactivamente
 */

const https = require('https');
const readline = require('readline');

// Read from .env if available, or ask user
function getEnvVar(key) {
  const fs = require('fs');
  try {
    const envContent = fs.readFileSync('.env', 'utf-8');
    const match = envContent.match(new RegExp(`^${key}=(.+)$`, 'm'));
    return match ? match[1].trim() : null;
  } catch {
    return null;
  }
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

async function main() {
  const supabaseUrl = getEnvVar('SUPABASE_URL') || 'https://rffagjnaxchwaggcsvep.supabase.co';
  
  console.log('🔧 Supabase Trigger Fix Aplicator\n');
  console.log(`URL detectada: ${supabaseUrl}\n`);
  console.log('Para continuar, necesito tu service_role_key');
  console.log('Obtén la clave de: Supabase Dashboard → Settings → API → Service Role Key\n');

  return new Promise((resolve) => {
    rl.question('Pega tu service_role_key: ', async (serviceRoleKey) => {
      rl.close();
      
      if (!serviceRoleKey || serviceRoleKey.trim().length === 0) {
        console.error('\n❌ Error: service_role_key es requerida');
        process.exit(1);
      }

      try {
        await applyFix(supabaseUrl, serviceRoleKey.trim());
        console.log('\n✅ ¡Fix aplicado exitosamente!');
        resolve();
      } catch (error) {
        console.error('\n❌ Error:', error.message);
        process.exit(1);
      }
    });
  });
}

function applyFix(supabaseUrl, serviceRoleKey) {
  return new Promise((resolve, reject) => {
    const sql = `
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

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

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

SELECT 'Fix applied successfully' as status;
    `.trim();

    const url = new URL(supabaseUrl);
    const hostname = url.hostname;
    
    const payload = JSON.stringify({
      query: sql,
    });

    const options = {
      hostname: hostname,
      port: 443,
      path: '/rest/v1/rpc/exec_sql',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
        'Authorization': `Bearer ${serviceRoleKey}`,
        'apikey': serviceRoleKey,
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log('📝 Respuesta del servidor:');
          console.log(data);
          resolve();
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

main().catch(console.error);
