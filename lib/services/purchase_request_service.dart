import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/PurchaseRequest/purchase_request_model.dart';
import '../model/PurchaseRequest/pr_detail_model.dart';

class PurchaseRequestService {
  static const String baseUrl = 'https://logi-core-backend.vercel.app';
  static const bool useMockData = false; // Backend Vercel sudah active

  static Future<PurchaseRequestResponse> createPurchaseRequest(
    String token,
    CreatePRRequest request,
  ) async {
    if (useMockData) {
      return _mockCreatePurchaseRequest();
    }

    try {
      print(
          '[PurchaseRequestService] Creating PR with ${request.items.length} items...');
      print('[PurchaseRequestService] Token: ${token.substring(0, 20)}...');
      print('[PurchaseRequestService] Endpoint: $baseUrl/api/pr');
      print(
          '[PurchaseRequestService] Request body: ${jsonEncode(request.toJson())}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/api/pr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[PurchaseRequestService] Request timeout after 15 seconds');
          throw Exception('Request timeout - Backend tidak responsive');
        },
      );

      print('[PurchaseRequestService] Response status: ${response.statusCode}');
      print('[PurchaseRequestService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['data'] == null) {
          throw Exception('Response missing data field: $body');
        }

        return PurchaseRequestResponse.fromJson(body['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Forbidden - User tidak memiliki role REQUESTOR untuk create PR');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
        throw Exception('API Error [${response.statusCode}]: $errorMsg');
      }
    } catch (e) {
      print('[PurchaseRequestService] Exception type: ${e.runtimeType}');
      print('[PurchaseRequestService] Exception: $e');
      print('[PurchaseRequestService] Stack trace: $e');
      rethrow;
    }
  }

  static Future<PurchaseRequestResponse> _mockCreatePurchaseRequest() async {
    print('[PurchaseRequestService] Using mock create PR data');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return PurchaseRequestResponse(
      id: 'pr-${DateTime.now().millisecondsSinceEpoch}',
      prNumber: 'PR-2024001',
      status: 'DRAFT',
      createdAt: DateTime.now(),
    );
  }

  /// Get PR detail by ID
  static Future<PRDetailModel> getPRDetail(String token, String prId) async {
    try {
      print('[PurchaseRequestService] Fetching PR detail for ID: $prId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/pr/$prId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('[PurchaseRequestService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['data'] == null) {
          throw Exception('Response missing data field');
        }

        return PRDetailModel.fromJson(body['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else if (response.statusCode == 404) {
        throw Exception('Purchase Request not found');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
        throw Exception('API Error [${response.statusCode}]: $errorMsg');
      }
    } catch (e) {
      print('[PurchaseRequestService] Exception: $e');
      rethrow;
    }
  }
}
