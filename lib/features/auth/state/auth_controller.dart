import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  User? _user;
  bool _initialized = false;
  bool _isBusy = false;
  String? _errorMessage;

  AuthController(this._repository) {
    _repository.authStateChanges.listen((user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  bool get isInitialized => _initialized;
  bool get isBusy => _isBusy;
  String? get uid => _user?.uid;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.login(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _repository.register(email, password);
      await user?.updateDisplayName(name);
      await _repository.logout();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _repository.logout();

  String _mapError(String code) {
    return switch (code) {
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'E-mail já cadastrado.',
      'weak-password' => 'Senha muito fraca (mínimo 6 caracteres).',
      'invalid-email' => 'E-mail inválido.',
      _ => 'Erro inesperado. Tente novamente.',
    };
  }
}
