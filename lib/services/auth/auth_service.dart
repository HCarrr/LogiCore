import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logicore/model/Login/login_model.dart';

class AuthService {
  // Backend: https://logi-core-backend.vercel.app (Vercel deployment)
  static const String baseUrl = 'https://logi-core-backend.vercel.app';
  static const bool useMockData = false;

  // Persistent HTTP client for connection reuse
  static final http.Client _client = http.Client();

  static Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    if (useMockData) {
      return _mockLogin(email, password);
    }

    try {
      final startTime = DateTime.now();
      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
                'Connection timeout - Backend tidak accessible'),
          );

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('[AuthService] Login request completed in ${duration}ms');
      print('[AuthService] STATUS CODE: ${response.statusCode}');

      final body = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final errorMsg =
            body['error'] ?? body['message'] ?? 'Email atau password salah';
        throw Exception(errorMsg);
      }

      if (body['success'] != true) {
        final errorMsg = body['error'] ?? 'Login failed';
        throw Exception(errorMsg);
      }

      return LoginModel.fromJson(body['data']);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Mock login untuk development/testing tanpa backend
  static Future<LoginModel> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password tidak boleh kosong');
    }

    const mockUsers = {
      'requestor@logicore.com': {
        'password': 'password123',
        'name': 'Requestor User',
        'role': 'REQUESTOR'
      },
      'procurement@logicore.com': {
        'password': 'password123',
        'name': 'Procurement User',
        'role': 'PROCUREMENT'
      },
      'admin@logicore.com': {
        'password': 'admin123',
        'name': 'Admin User',
        'role': 'ADMIN'
      },
    };

    final user = mockUsers[email];
    if (user == null || user['password'] != password) {
      throw Exception('Email atau password salah');
    }

    return LoginModel(
      token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      role: user['role'] as String,
      userId: 'mock_user_id_${email.split('@')[0]}',
      email: email,
      name: user['name'] as String,
    );
  }
}
