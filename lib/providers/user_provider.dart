import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart'; // <-- import the model

const String scanApiUrl =
    'https://csi-pixel-paranoia-automation-api.vercel.app/scan';
const String hadFoodApiUrl =
    'https://csi-pixel-paranoia-automation-api.vercel.app/had_food';

class UserProvider with ChangeNotifier {
  // single scanned user (optional)
  String? email;
  String? qrId;
  bool registered = false;
  bool hadFood = false;

  // last server messages / errors (useful for dialogs or UI)
  String? lastMessage;
  String? lastError;

  // global loading flag for async operations
  bool loading = false;

  // list of users (for the full table)
  List<UserModel> usersList = [];

  // counters are now computed from usersList for consistency
  int get totalRegistered => usersList.where((u) => u.registered).length;
  int get totalHadFood => usersList.where((u) => u.hadFood).length;

  static const String _kEmailKey = 'user_email';
  static const String _kQrIdKey = 'user_qr_id';
  static const String _kRegisteredKey = 'user_registered';
  static const String _kHadFoodKey = 'user_had_food';

  // optional: persistence key for serialized users (only if you want to persist whole list)
  static const String _kUsersListKey = 'users_list_json';

  UserProvider() {
    _loadFromPrefs();
  }

  /// Clear only the per-scan single-user state. Call this when leaving a scanner screen.
  void clearSingleUser() {
    email = null;
    qrId = null;
    registered = false;
    hadFood = false;
    lastMessage = null;
    lastError = null;
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      email = prefs.getString(_kEmailKey);
      qrId = prefs.getString(_kQrIdKey);
      registered = prefs.getBool(_kRegisteredKey) ?? false;
      hadFood = prefs.getBool(_kHadFoodKey) ?? false;

      // load persisted list if present
      final usersJson = prefs.getString(_kUsersListKey);
      if (usersJson != null && usersJson.isNotEmpty) {
        final List decoded = jsonDecode(usersJson);
        usersList =
            decoded.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading prefs: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (email != null) {
        await prefs.setString(_kEmailKey, email!);
      } else {
        await prefs.remove(_kEmailKey);
      }

      if (qrId != null) {
        await prefs.setString(_kQrIdKey, qrId!);
      } else {
        await prefs.remove(_kQrIdKey);
      }

      await prefs.setBool(_kRegisteredKey, registered);
      await prefs.setBool(_kHadFoodKey, hadFood);

      // persist usersList as JSON (optional; remove if not needed)
      final usersJson = jsonEncode(usersList.map((u) => u.toMap()).toList());
      await prefs.setString(_kUsersListKey, usersJson);
    } catch (e) {
      debugPrint('Error saving prefs: $e');
    }
  }

  /// low-level POST that returns decoded JSON as Map (or { 'error': '...' } on failure)
  Future<Map<String, dynamic>> _post(String url, String qrId) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qr_id': qrId}),
      );

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {'message': decoded.toString()};
      }
    } catch (e) {
      return {'error': 'Network or parse error: $e'};
    }
  }

  Future<String?> _callApi(String url, String qrId) async {
    // kept for backward compatibility with older code using _callApi
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qr_id': qrId}),
      );

      final decoded = jsonDecode(response.body);
      return decoded['message']?.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Internal helpers to manage loading state cleanly
  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setLastMessage(String? msg) {
    lastMessage = msg;
    notifyListeners();
  }

  void _setLastError(String? err) {
    lastError = err;
    notifyListeners();
  }

  /// Helper to show SnackBar if context provided
  void _showSnackBarIfPossible(BuildContext? context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    if (context == null) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  /// If you want to register via API and also update/add the user in the list:
  /// returns a user-friendly message; never leaves loading == true.
  /// Optional: pass [context] if you want the provider to show a SnackBar for duplicate/success messages.
  Future<String> registerUser(String qrId, String email, {BuildContext? context, String? name}) async {
    // PRE-CHECK (fast, avoids unnecessary API calls)
    final preIndex = usersList.indexWhere((u) => u.qrId == qrId || u.email == email);
    if (preIndex >= 0 && usersList[preIndex].registered) {
      final msg = 'User already registered!';
      _setLastMessage(msg);
      _showSnackBarIfPossible(context, msg);
      return msg;
    }

    _setLoading(true);
    _setLastError(null);
    _setLastMessage(null);

    try {
      final response = await _post(scanApiUrl, qrId);

      if (response.containsKey('error')) {
        final err = response['error'].toString();
        _setLastError(err);
        _showSnackBarIfPossible(context, err);
        return err;
      }

      final msg = (response['message'] ?? '').toString();
      _setLastMessage(msg);

      // If server says already registered, show snackbar and return
      if (msg.toLowerCase().contains('already')) {
        final userMsg = 'User already registered!';
        _showSnackBarIfPossible(context, userMsg);
        return userMsg;
      }

      // Success — update single-user fields and usersList
      this.qrId = qrId;
      this.email = email;
      registered = true;

      final actualName = (name != null && name.trim().isNotEmpty) ? name.trim() : (email.isNotEmpty ? email : 'unknown');
      final existingIndex = usersList.indexWhere(
        (u) => u.qrId == qrId || u.email == email,
      );
      if (existingIndex >= 0) {
        usersList[existingIndex].registered = true;
        // always update email and name if freshly scanned
        usersList[existingIndex].email = email;
        usersList[existingIndex].name = actualName;
      } else {
        usersList.add(
          UserModel(qrId: qrId, name: actualName, email: email, registered: true, hadFood: false),
        );
      }

      await _saveToPrefs();

      final successMsg = 'Registration successful!';
      _showSnackBarIfPossible(context, successMsg);
      return successMsg;
    } catch (e) {
      final err = 'Unexpected error: $e';
      _setLastError(err);
      _showSnackBarIfPossible(context, err);
      return err;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Mark hadFood using the API. Returns a user-friendly message.
  /// Optional: pass [context] if you want the provider to show a SnackBar for duplicate/success messages.
  Future<String> markFood(String qrId, {BuildContext? context}) async {
    // PRE-CHECK (fast)
    final preIndex = usersList.indexWhere((u) => u.qrId == qrId);
    if (preIndex >= 0 && usersList[preIndex].hadFood) {
      final msg = 'Food already marked!';
      _setLastMessage(msg);
      _showSnackBarIfPossible(context, msg);
      return msg;
    }

    _setLoading(true);
    _setLastError(null);
    _setLastMessage(null);

    try {
      final response = await _post(hadFoodApiUrl, qrId);

      if (response.containsKey('error')) {
        final err = response['error'].toString();
        _setLastError(err);
        _showSnackBarIfPossible(context, err);
        return err;
      }

      final msg = (response['message'] ?? '').toString();
      _setLastMessage(msg);

      if (msg.toLowerCase().contains('already')) {
        final userMsg = 'Food already marked!';
        _showSnackBarIfPossible(context, userMsg);
        return userMsg;
      } else if (msg.toLowerCase().contains('marked') ||
          msg.toLowerCase().contains('hadfood') ||
          msg.toLowerCase().contains('true')) {
        hadFood = true;

        // update list user if present
        final existingIndex = usersList.indexWhere((u) => u.qrId == qrId);
        if (existingIndex >= 0) {
          usersList[existingIndex].hadFood = true;
        } else {
          // if unknown user, add a minimal entry
          usersList.add(
            UserModel(
              qrId: qrId,
              name: 'unknown',
              email: 'unknown',
              registered: false,
              hadFood: true,
            ),
          );
        }

        await _saveToPrefs();

        final successMsg = 'Food marked successfully!';
        _showSnackBarIfPossible(context, successMsg);
        return successMsg;
      }

      // otherwise return server message
      _showSnackBarIfPossible(context, msg);
      return msg.isNotEmpty ? msg : 'Unexpected response from server';
    } catch (e) {
      final err = 'Unexpected error: $e';
      _setLastError(err);
      _showSnackBarIfPossible(context, err);
      return err;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// This helper calls markFood and shows a dialog if the server indicates the user is not registered.
  /// Use this from UI when you want dialog behavior:
  /// await provider.markFoodWithDialog(context, qrId);
  Future<void> markFoodWithDialog(BuildContext context, String qrId) async {
    final result = await markFood(qrId);

    final lowered = result.toLowerCase();
    if (lowered.contains('not registered') ||
        lowered.contains('no user found') ||
        lowered.contains('cannot mark hadfood') ||
        lowered.contains('not found')) {
      // Show dialog informing the user they must be registered first.
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Not Registered'),
          content: Text(
            'This QR is not registered. You must register the user before marking food.\n\nServer message:\n$result',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Otherwise show a simple confirmation dialog for success or the returned message.
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Result'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Add/update user manually (useful if you fetch a list from server)
  void upsertUser(UserModel user) {
    final i = usersList.indexWhere(
      (u) => u.qrId == user.qrId || u.email == user.email,
    );
    if (i >= 0) {
      usersList[i].registered = user.registered;
      usersList[i].hadFood = user.hadFood;
      if (user.name.trim().isNotEmpty) {
        usersList[i].name = user.name;
      }
      if (user.email.trim().isNotEmpty) {
        usersList[i].email = user.email;
      }
    } else {
      usersList.add(user);
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearUser() async {
    email = null;
    qrId = null;
    registered = false;
    hadFood = false;
    await _saveToPrefs();
    notifyListeners();
  }

  // Clear the entire list (for testing)
  Future<void> clearAllUsers() async {
    usersList = [];
    await _saveToPrefs();
    notifyListeners();
  }
}
