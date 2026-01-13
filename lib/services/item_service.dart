import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemModel {
  final String id;
  final String sku;
  final String name;
  final String unit;
  final String category;
  final String? imageUrl;

  ItemModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.unit,
    required this.category,
    this.imageUrl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class ItemService {
  static const String baseUrl = 'https://logi-core-backend.vercel.app';

  static Future<List<ItemModel>> searchItems(String token,
      {String query = '', int limit = 20}) async {
    try {
      final startTime = DateTime.now();
      print(
          '[ItemService] Searching items with query: "$query", limit: $limit');

      final response = await http.get(
        Uri.parse('$baseUrl/api/ui/items/search?q=$query&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 8), // Reduced from 15s
        onTimeout: () =>
            throw Exception('Connection timeout - Backend tidak accessible'),
      );

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('[ItemService] Items request completed in ${duration}ms');
      print('[ItemService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['data'] == null) {
          print('[ItemService] No data in response');
          return [];
        }

        final items = (body['data'] as List)
            .map((item) => ItemModel.fromJson(item))
            .toList();

        print('[ItemService] Found ${items.length} items');
        return items;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error'] ?? 'Failed to fetch items';
        throw Exception('API Error [${response.statusCode}]: $errorMsg');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  static Future<List<ItemModel>> getAllItems(String token) async {
    return searchItems(token, limit: 100);
  }
}
