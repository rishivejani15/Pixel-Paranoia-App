# Supabase Configuration

This file contains instructions for setting up Supabase credentials for the Pixel Paranoia App.

## Setup Instructions

1. **Get Your Supabase Credentials:**
   - Go to your Supabase project dashboard: https://app.supabase.com
   - Navigate to: Settings > API
   - Copy the following values:
     - Project URL (e.g., `https://xxxxxxxxxxxxx.supabase.co`)
     - Anon/Public Key (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

2. **Add Credentials to the App:**
   - Open `lib/services/supabase_service.dart`
   - Replace the placeholder values:
     ```dart
     const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
     const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
     ```
   - With your actual credentials:
     ```dart
     const String supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co';
     const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
     ```

3. **Database Schema:**
   Your Supabase `users` table should have the following columns:
   - `id` (uuid, primary key)
   - `name` (text)
   - `email` (text)
   - `status` (text)
   - `hadFood` (boolean) or `hadfood` (boolean)
   - `qr_id` (text)
   - `created_at` (timestamp with time zone)

4. **Enable Realtime:**
   - Go to your Supabase project
   - Navigate to: Database > Replication
   - Find the `users` table and toggle "Enable Realtime"
   - This allows the app to receive live updates without refreshing

5. **Row Level Security (Optional but Recommended):**
   - Navigate to: Authentication > Policies
   - Add policies for the `users` table if needed
   - For development, you can temporarily disable RLS:
     ```sql
     ALTER TABLE users DISABLE ROW LEVEL SECURITY;
     ```

## Testing

After adding credentials:
1. Run `flutter pub get` to install dependencies
2. Run the app
3. The User screen will automatically fetch data from Supabase
4. Any changes in the database will appear in real-time!

## Features

✅ **Real-time Updates:** Users are fetched via Supabase stream
✅ **Pull to Refresh:** Swipe down on the user list to manually refresh
✅ **Error Handling:** Displays helpful error messages if connection fails
✅ **Auto-reconnect:** Stream automatically reconnects if connection drops
✅ **Statistics:** Shows total registered users and food count
✅ **Search & Filter:** Built-in methods to search users by name/email

## Need Help?

- Supabase Docs: https://supabase.com/docs
- Flutter Supabase Docs: https://supabase.com/docs/reference/dart/introduction
