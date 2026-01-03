import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../features/auth/models/user_model.dart';

/// Simulates a backend authentication service
class AuthService {
  // Simulate database
  final List<User> _users = [];

  Future<User> login({required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    // Mock validation: Accept ANY credentials for demo purposes
    // In a real app, this would verify against a backend.
    
    // Check if user exists in the volatile mock DB (from signups in this session)
    try {
      final user = _users.firstWhere((u) => u.email == email);
      return user;
    } catch (e) {
      // If not found in mock DB, just create a temporary session user
      // This solves the issue of "Invalid Credentials" when the user expects to just log in
      return User(
        id: const Uuid().v4(),
        name: email.split('@').first, 
        email: email,
      );
    }
  }

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }

    if (_users.any((u) => u.email == email)) {
      throw Exception('Email already exists');
    }

    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
    );
    _users.add(newUser);
    
    return newUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
