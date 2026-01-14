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

  /// Submit PR (change status from DRAFT to SUBMITTED)
  static Future<bool> submitPR(String token, String prId) async {
    try {
      print('[PurchaseRequestService] Submitting PR: $prId');

      // Use PATCH /api/pr/{id} with status: SUBMITTED
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/pr/$prId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'status': 'SUBMITTED'}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print(
          '[PurchaseRequestService] Submit response status: ${response.statusCode}');
      print('[PurchaseRequestService] Submit response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else if (response.statusCode == 404) {
        throw Exception('Purchase Request not found');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error'] ?? 'Cannot submit this PR';
        throw Exception(errorMsg);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
        throw Exception('API Error [${response.statusCode}]: $errorMsg');
      }
    } catch (e) {
      print('[PurchaseRequestService] Submit Exception: $e');
      rethrow;
    }
  }

  /// Update PR (only when status is DRAFT)
  static Future<bool> updatePR(
    String token,
    String prId, {
    int? quantity,
    double? estimatedUnitPrice,
    String? notes,
  }) async {
    try {
      print('[PurchaseRequestService] Updating PR: $prId');

      final Map<String, dynamic> body = {};
      if (quantity != null) body['quantity'] = quantity;
      if (estimatedUnitPrice != null)
        body['estimatedUnitPrice'] = estimatedUnitPrice;
      if (notes != null) body['notes'] = notes;

      print('[PurchaseRequestService] Update body: $body');

      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/pr/$prId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print(
          '[PurchaseRequestService] Update response status: ${response.statusCode}');
      print('[PurchaseRequestService] Update response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else if (response.statusCode == 404) {
        throw Exception('Purchase Request not found');
      } else if (response.statusCode == 405) {
        throw Exception('Update tidak didukung oleh server');
      } else if (response.statusCode == 400) {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          final errorMsg = errorBody['error'] ?? 'Cannot update this PR';
          throw Exception(errorMsg);
        }
        throw Exception('Cannot update this PR');
      } else {
        if (response.body.isNotEmpty) {
          final errorBody = jsonDecode(response.body);
          final errorMsg =
              errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
          throw Exception('API Error [${response.statusCode}]: $errorMsg');
        }
        throw Exception('API Error [${response.statusCode}]');
      }
    } catch (e) {
      print('[PurchaseRequestService] Update Exception: $e');
      rethrow;
    }
  }

  /// Delete PR (only when status is DRAFT)
  static Future<bool> deletePR(String token, String prId) async {
    try {
      print('[PurchaseRequestService] Deleting PR: $prId');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/pr/$prId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(
          '[PurchaseRequestService] Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else if (response.statusCode == 404) {
        throw Exception('Purchase Request not found');
      } else if (response.statusCode == 405) {
        throw Exception(
            'Delete tidak didukung oleh server - hubungi administrator');
      } else if (response.statusCode == 400) {
        if (response.body.isNotEmpty) {
          try {
            final errorBody = jsonDecode(response.body);
            final errorMsg = errorBody['error'] ?? 'Cannot delete this PR';
            throw Exception(errorMsg);
          } catch (_) {
            throw Exception('Cannot delete this PR');
          }
        }
        throw Exception('Cannot delete this PR');
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorBody = jsonDecode(response.body);
            final errorMsg =
                errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
            throw Exception('API Error [${response.statusCode}]: $errorMsg');
          } catch (_) {
            throw Exception('API Error [${response.statusCode}]');
          }
        }
        throw Exception('API Error [${response.statusCode}]');
      }
    } catch (e) {
      print('[PurchaseRequestService] Delete Exception: $e');
      rethrow;
    }
  }
}
