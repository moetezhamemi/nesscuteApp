import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;

  AuthNotifier() : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    final token = _prefs!.getString('auth_token');
    if (token != null) {
      _apiService.setToken(token);
      // Load user data if needed
    }
  }

  Future<bool> login(String email, String password) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.login(email, password);
      final token = response['token'] as String;
      // Convert userId to id for UserModel
      final userData = Map<String, dynamic>.from(response);
      if (userData.containsKey('userId') && !userData.containsKey('id')) {
        userData['id'] = userData['userId'];
      }
      final user = UserModel.fromJson(userData);

      await _prefs!.setString('auth_token', token);
      _apiService.setToken(token);

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.register(data);
      final token = response['token'] as String;
      // Convert userId to id for UserModel
      final userData = Map<String, dynamic>.from(response);
      if (userData.containsKey('userId') && !userData.containsKey('id')) {
        userData['id'] = userData['userId'];
      }
      final user = UserModel.fromJson(userData);

      await _prefs!.setString('auth_token', token);
      _apiService.setToken(token);

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> googleLogin(String googleId, String email, String name, String profileImage) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.googleLogin({
        'googleId': googleId,
        'email': email,
        'name': name,
        'profileImage': profileImage,
      });
      final token = response['token'] as String;
      // Convert userId to id for UserModel
      final userData = Map<String, dynamic>.from(response);
      if (userData.containsKey('userId') && !userData.containsKey('id')) {
        userData['id'] = userData['userId'];
      }
      final user = UserModel.fromJson(userData);

      await _prefs!.setString('auth_token', token);
      _apiService.setToken(token);

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs!.remove('auth_token');
    _apiService.setToken(null);
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

