import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/PurchaseRequest/pr_list_model.dart';

class PRListService {
  static const String baseUrl = 'https://logi-core-backend.vercel.app';
  static final http.Client _client = http.Client();

  /// Get all PRs for current user
  static Future<List<PRListItem>> getMyPRs(String token,
      {String? status}) async {
    try {
      String url = '$baseUrl/api/ui/pr?mine=true';
      if (status != null && status.isNotEmpty && status != 'ALL') {
        url += '&status=$status';
      }

      print('[PRListService] Fetching PRs from: $url');

      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('[PRListService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        List<PRListItem> items = [];

        if (body is Map) {
          final data = body['data'];
          print('[PRListService] data type: ${data.runtimeType}');

          if (data is List) {
            print('[PRListService] Parsing data as list');
            items = data
                .map(
                    (item) => PRListItem.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data is Map) {
            print('[PRListService] data keys: ${data.keys.toList()}');

            // Try different possible keys
            List? prList;
            if (data['data'] is List) {
              // Nested structure: { data: { data: [...], pagination: {...} } }
              prList = data['data'];
            } else if (data['items'] is List) {
              prList = data['items'];
            } else if (data['purchaseRequests'] is List) {
              prList = data['purchaseRequests'];
            } else if (data['prs'] is List) {
              prList = data['prs'];
            } else if (data['list'] is List) {
              prList = data['list'];
            } else if (data['records'] is List) {
              prList = data['records'];
            }

            if (prList != null) {
              print('[PRListService] Found list with ${prList.length} items');
              items = prList
                  .map((item) =>
                      PRListItem.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else {
              print(
                  '[PRListService] No list found in data, trying to parse data itself as single PR list');
              // Maybe data itself contains the PRs mixed with other fields - dump first item
              print('[PRListService] Full data: $data');
            }
          }
        }

        print('[PRListService] Loaded ${items.length} PRs');
        return items;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
        throw Exception('API Error [${response.statusCode}]: $errorMsg');
      }
    } catch (e) {
      print('[PRListService] Exception: $e');
      rethrow;
    }
  }

  /// Search PRs by PR number or notes
  static List<PRListItem> searchPRs(List<PRListItem> prs, String query) {
    if (query.isEmpty) return prs;

    final lowerQuery = query.toLowerCase();
    return prs.where((pr) {
      return pr.prNumber.toLowerCase().contains(lowerQuery) ||
          (pr.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter PRs by status
  static List<PRListItem> filterByStatus(List<PRListItem> prs, String status) {
    if (status.isEmpty || status == 'ALL') return prs;

    // PENDING filter should include SUBMITTED status
    if (status == 'PENDING') {
      return prs
          .where((pr) => pr.status == 'PENDING' || pr.status == 'SUBMITTED')
          .toList();
    }

    return prs.where((pr) => pr.status == status).toList();
  }
}
