# Supabase Integration - Quick Reference

## 📁 New Files Created

1. **`lib/services/supabase_service.dart`**
   - Handles Supabase initialization and connection
   - Provides methods for real-time user streams
   - Contains placeholder credentials (TODO: Add your credentials here)

2. **`lib/providers/get_user_provider.dart`**
   - Separate provider specifically for getting user data from Supabase
   - Manages real-time stream subscription
   - Provides computed statistics (totalUsers, totalRegistered, totalHadFood, pendingUsers)
   - Includes search and filter methods

3. **`SUPABASE_SETUP.md`**
   - Complete setup instructions for Supabase integration
   - Database schema requirements
   - Step-by-step credential configuration

## 📝 Modified Files

1. **`pubspec.yaml`**
   - Added `supabase_flutter: ^2.9.0` dependency

2. **`lib/main.dart`**
   - Added Supabase initialization on app startup
   - Added `GetUserProvider` to MultiProvider
   - Made main() async to support initialization

3. **`lib/models/user_model.dart`**
   - Added new fields: `id` and `status`
   - Added `fromSupabase()` factory constructor for Supabase data
   - Added `toSupabase()` method for writing to Supabase
   - Kept legacy `fromMap()` for backward compatibility

4. **`lib/screens/user.dart`**
   - Now uses `GetUserProvider` instead of old `UserProvider`
   - Displays user `name` and `email` from Supabase
   - Shows user `status` (registered/pending) from Supabase table
   - Added pull-to-refresh functionality
   - Added error state UI for connection issues
   - Real-time updates without manual refresh

## 🔧 How It Works

### Real-time Stream Flow:
```
Supabase Database → SupabaseService.getUsersStream() 
    → GetUserProvider (listens to stream)
    → notifyListeners() 
    → User Screen UI updates automatically
```

### Data Flow:
1. **App Startup**: Supabase initializes with credentials
2. **GetUserProvider Init**: Subscribes to real-time users stream
3. **Data Changes**: Any database change triggers stream update
4. **UI Update**: Provider notifies listeners, UI rebuilds automatically

## 🎯 Key Features

✅ **Real-time Updates**: No need to refresh - data updates live!
✅ **Pull to Refresh**: Swipe down to manually refresh if needed
✅ **Error Handling**: Shows friendly error message if Supabase not configured
✅ **Loading States**: Shows spinner while fetching data
✅ **Empty States**: Shows helpful message when no users exist
✅ **Statistics**: Auto-calculated totals for registered users and food status
✅ **Search Ready**: Built-in searchUsers() method for future search feature

## 📊 Database Schema Match

Your Supabase table columns map to UserModel fields:
- `id` (uuid) → `id` (String?)
- `qr_id` (text) → `qrId` (String)
- `name` (text) → `name` (String)
- `email` (text) → `email` (String)
- `status` (text) → `status` (String) - "registered" or "pending"
- `hadFood` (boolean) → `hadFood` (bool)

## 🚀 Next Steps

1. **Add Your Credentials** (REQUIRED):
   - Open `lib/services/supabase_service.dart`
   - Replace `YOUR_SUPABASE_URL_HERE` with your project URL
   - Replace `YOUR_SUPABASE_ANON_KEY_HERE` with your anon key

2. **Enable Realtime in Supabase** (REQUIRED):
   - Go to Supabase Dashboard → Database → Replication
   - Enable Realtime for the `users` table

3. **Test the App**:
   - Run the app
   - Open User screen
   - Should see users from your Supabase database
   - Make changes in Supabase dashboard - they'll appear instantly!

## 💡 Usage Examples

### In any widget, access user data:
```dart
final getUserProvider = Provider.of<GetUserProvider>(context);

// Get all users (live updates)
final users = getUserProvider.users;

// Get statistics
final total = getUserProvider.totalUsers;
final registered = getUserProvider.totalRegistered;
final hadFood = getUserProvider.totalHadFood;

// Manually refresh
await getUserProvider.refreshUsers();

// Search users
final results = getUserProvider.searchUsers('john');

// Get by status
final pending = getUserProvider.getUsersByStatus('pending');
```

## ⚠️ Important Notes

- The old `UserProvider` still exists for backward compatibility with registration/food scanning
- `GetUserProvider` is purely for reading/displaying user data from Supabase
- Stream automatically reconnects if connection drops
- Pull-to-refresh works even when stream is active
- Provider automatically disposes stream subscription on cleanup

## 🔍 Troubleshooting

**"Connection Error" appears:**
- Check if credentials are added in `supabase_service.dart`
- Verify Supabase project is running
- Check internet connection

**Users not updating in real-time:**
- Enable Realtime for users table in Supabase dashboard
- Check Supabase project logs for errors

**Build errors:**
- Run `flutter pub get` again
- Try `flutter clean` then `flutter pub get`
