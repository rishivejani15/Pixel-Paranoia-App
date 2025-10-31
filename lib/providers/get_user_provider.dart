import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class GetUserProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _userStreamSubscription;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed statistics
  int get totalUsers => _users.length;
  int get totalRegistered =>
      _users.where((u) => u.status == 'registered').length;
  int get totalHadFood => _users.where((u) => u.hadFood).length;
  int get pendingUsers => _users.where((u) => u.status == 'pending').length;

  GetUserProvider() {
    _initializeRealtimeStream();
  }

  // Initialize real-time stream from Supabase
  void _initializeRealtimeStream() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Subscribe to real-time updates
      _userStreamSubscription = _supabaseService.getUsersStream().listen(
        (data) {
          _users = data.map((json) => UserModel.fromSupabase(json)).toList();
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
          debugPrint('Error in user stream: $error');
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error initializing user stream: $e');
    }
  }

  // Manually refresh users (for pull-to-refresh)
  Future<void> refreshUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _supabaseService.getUsers();
      _users = data.map((json) => UserModel.fromSupabase(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error refreshing users: $e');
    }
  }

  // Get user by QR ID
  Future<UserModel?> getUserByQrId(String qrId) async {
    try {
      final data = await _supabaseService.getUserByQrId(qrId);
      if (data != null) {
        return UserModel.fromSupabase(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by QR ID: $e');
      return null;
    }
  }

  // Update user status
  Future<bool> updateUserStatus(String userId, String status) async {
    try {
      await _supabaseService.updateUserStatus(userId, status);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating user status: $e');
      return false;
    }
  }

  // Update user food status
  Future<bool> updateUserFoodStatus(String userId, bool hadFood) async {
    try {
      await _supabaseService.updateUserFoodStatus(userId, hadFood);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating user food status: $e');
      return false;
    }
  }

  // Get users by status
  List<UserModel> getUsersByStatus(String status) {
    return _users.where((u) => u.status == status).toList();
  }

  // Search users by name or email
  List<UserModel> searchUsers(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(lowercaseQuery) ||
          user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    super.dispose();
  }
}
