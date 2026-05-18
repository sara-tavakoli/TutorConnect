import 'package:flutter/foundation.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  UserModel?  _user;
  String?     _errorMessage;
  bool        _isLoading = false;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get isLoading    => _isLoading;
  bool       get isAuth       => _status == AuthStatus.authenticated;

  AuthProvider({AuthService? service}) {
    _authService = service ?? AuthService();
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user   = null;
      } else {
        final user = await _authService.fetchUser(firebaseUser.uid);
        if (user != null) {
          _user   = user;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
      notifyListeners();
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.register(
        name: name, email: email, password: password, role: role,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } on Exception catch (e) {
      _errorMessage = _friendlyError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } on Exception catch (e) {
      _errorMessage = _friendlyError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } on Exception catch (e) {
      _errorMessage = _friendlyError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) return 'This email is already registered.';
    if (raw.contains('user-not-found'))       return 'No account found with this email.';
    if (raw.contains('wrong-password'))       return 'Incorrect password. Please try again.';
    if (raw.contains('weak-password'))        return 'Password must be at least 6 characters.';
    if (raw.contains('invalid-email'))        return 'Please enter a valid email address.';
    if (raw.contains('network-request-failed')) return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }
}
