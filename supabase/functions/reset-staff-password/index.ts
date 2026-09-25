// ============================================================
// Edge Function: reset-staff-password (កំណែកែលម្អ — ស៊ីសង្វាក់ជាមួយ Key ថ្មី/ចាស់)
// ============================================================
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

function getSecretKey(): string {
  // 1) New-style single secret key
  const secretKey = Deno.env.get('SUPABASE_SECRET_KEY')
  if (secretKey) {
    console.log('[reset-staff-password] Using SUPABASE_SECRET_KEY')
    return secretKey
  }
  // 2) New-style JSON dictionary of secret keys
  const secretKeysJson = Deno.env.get('SUPABASE_SECRET_KEYS')
  if (secretKeysJson) {
    try {
      const parsed = JSON.parse(secretKeysJson)
      const val = parsed.default || Object.values(parsed)[0]
      if (val) {
        console.log('[reset-staff-password] Using SUPABASE_SECRET_KEYS.default')
        return val as string
      }
    } catch (e) {
      console.log('[reset-staff-password] Failed to parse SUPABASE_SECRET_KEYS:', e.message)
    }
  }
  // 3) Legacy service role key
  const legacyKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (legacyKey) {
    console.log('[reset-staff-password] Using legacy SUPABASE_SERVICE_ROLE_KEY')
    return legacyKey
  }
  console.log('[reset-staff-password] WARNING: No admin/secret key found in environment!')
  return ''
}

function getPublicKey(): string {
  const pubKey = Deno.env.get('SUPABASE_ANON_KEY')
  if (pubKey) return pubKey
  const pubKeysJson = Deno.env.get('SUPABASE_PUBLISHABLE_KEYS')
  if (pubKeysJson) {
    try {
      const parsed = JSON.parse(pubKeysJson)
      return (parsed.default || Object.values(parsed)[0]) as string
    } catch (e) { /* ignore */ }
  }
  return ''
}

Deno.serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { targetUserId, newPassword } = await req.json()
    if (!targetUserId || !newPassword) {
      return new Response(JSON.stringify({ error: 'Missing targetUserId or newPassword' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized: no Authorization header' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const publicKey = getPublicKey()
    const secretKey = getSecretKey()

    console.log('[reset-staff-password] supabaseUrl set:', !!supabaseUrl, '| publicKey set:', !!publicKey, '| secretKey set:', !!secretKey)

    if (!secretKey) {
      return new Response(JSON.stringify({ error: 'Server misconfiguration: no admin/secret key available in this function environment' }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Step 1: verify the CALLER is logged in and is an Owner
    const supabaseClient = createClient(supabaseUrl, publicKey, {
      global: { headers: { Authorization: authHeader } }
    })
    const { data: userData, error: userErr } = await supabaseClient.auth.getUser()
    if (userErr || !userData?.user) {
      console.log('[reset-staff-password] auth.getUser failed:', userErr?.message)
      return new Response(JSON.stringify({ error: 'Unauthorized: ' + (userErr?.message || 'no user') }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    const { data: profile, error: profileErr } = await supabaseClient
      .from('profiles').select('role').eq('id', userData.user.id).single()
    if (profileErr || !profile || profile.role !== 'owner') {
      console.log('[reset-staff-password] caller is not owner:', profileErr?.message, profile)
      return new Response(JSON.stringify({ error: 'Forbidden — Owner only' }), {
        status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Step 2: use the admin/secret key to actually reset the target user's password.
    // Also force email_confirm:true — staff accounts use synthetic @kimsreang-app.com
    // emails that never receive a real confirmation email, so if the project has
    // "Confirm email" enabled, an unconfirmed account can silently fail to log in
    // ("Invalid login credentials") even with the correct new password. Resetting
    // the password is also our chance to guarantee the account is confirmed.
    const supabaseAdmin = createClient(supabaseUrl, secretKey)
    const { data: updateData, error: updateErr } = await supabaseAdmin.auth.admin.updateUserById(targetUserId, {
      password: newPassword,
      email_confirm: true
    })
    if (updateErr) {
      console.log('[reset-staff-password] updateUserById failed:', updateErr.message)
      return new Response(JSON.stringify({ error: updateErr.message }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    console.log('[reset-staff-password] SUCCESS for user:', targetUserId)
    return new Response(JSON.stringify({ success: true }), {
      status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  } catch (e) {
    console.log('[reset-staff-password] Unhandled exception:', e.message)
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
