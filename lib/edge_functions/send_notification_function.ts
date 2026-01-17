import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const FIREBASE_SERVER_KEY = Deno.env.get('FIREBASE_SERVER_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface NotificationPayload {
  notification_id: string
  user_id: string
  title: string
  body: string
  type: string
  post_id?: string
  comment_id?: string
}

serve(async (req) => {
  try {
    // Parse request body
    const payload: NotificationPayload = await req.json()
    console.log('📨 Received notification payload:', payload)

    // Initialize Supabase client with service role key
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Get user's FCM token from database
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', payload.user_id)
      .single()

    if (profileError) {
      console.error('❌ Error fetching profile:', profileError)
      return new Response(JSON.stringify({ error: 'Profile not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const fcmToken = profile?.fcm_token

    if (!fcmToken) {
      console.log('⚠️ No FCM token for user:', payload.user_id)
      return new Response(
        JSON.stringify({ message: 'No FCM token, skipping push' }),
        {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
        }
      )
    }

    console.log('🔑 FCM Token found, sending push notification...')

    // Prepare FCM message
    const fcmMessage = {
      to: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
        sound: 'default',
      },
      data: {
        notification_id: payload.notification_id,
        type: payload.type,
        post_id: payload.post_id || '',
        comment_id: payload.comment_id || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      priority: 'high',
    }

    // Send to FCM
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${FIREBASE_SERVER_KEY}`,
      },
      body: JSON.stringify(fcmMessage),
    })

    const fcmResult = await fcmResponse.json()

    if (!fcmResponse.ok) {
      console.error('❌ FCM Error:', fcmResult)
      return new Response(JSON.stringify({ error: 'FCM request failed', details: fcmResult }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    console.log('✅ Push notification sent successfully:', fcmResult)

    return new Response(
      JSON.stringify({ success: true, fcm_response: fcmResult }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    console.error('❌ Error in send-notification function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
