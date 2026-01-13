import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../model/Requestor/requestor_model.dart';
import '../model/Activity/activity_model.dart';

class DashboardData {
  final RequestorModel summary;
  final List<ActivityModel> activities;

  DashboardData({
    required this.summary,
    required this.activities,
  });

  Map<String, dynamic> toJson() => {
        'summary': {
          'activePR': summary.activePR,
          'received': summary.received,
          'pendingActions': summary.pendingActions,
        },
        'activities': activities
            .map((a) => {
                  'id': a.id,
                  'prNumber': a.prNumber,
                  'title': a.title,
                  'subtitle': a.subtitle,
                  'status': a.status,
                  'statusBadge': a.statusBadge,
                  'icon': a.icon,
                  'createdAt': a.createdAt.toIso8601String(),
                })
            .toList(),
      };

  static DashboardData fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>;
    final activitiesJson = json['activities'] as List;

    return DashboardData(
      summary: RequestorModel(
        activePR: summaryJson['activePR'] ?? 0,
        received: summaryJson['received'] ?? 0,
        pendingActions: summaryJson['pendingActions'] ?? 0,
      ),
      activities: activitiesJson
          .map((a) => ActivityModel(
                id: a['id'] ?? '',
                prNumber: a['prNumber'] ?? '',
                title: a['title'] ?? '',
                subtitle: a['subtitle'],
                status: a['status'] ?? '',
                statusBadge: a['statusBadge'] ?? '',
                icon: a['icon'] ?? 'description',
                createdAt:
                    DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now(),
              ))
          .toList(),
    );
  }
}

class DashboardService {
  static const String baseUrl = 'https://logi-core-backend.vercel.app';
  static const bool useMockData = false;
  static const String _cacheKey = 'dashboard_cache';
  static const String _cacheTimeKey = 'dashboard_cache_time';
  static const int _cacheValidityMinutes = 5;

  // Persistent HTTP client
  static final http.Client _client = http.Client();

  /// Get cached dashboard data if available and not expired
  static DashboardData? getCachedDashboard() {
    try {
      final box = GetStorage();
      final cachedJson = box.read(_cacheKey);
      final cacheTime = box.read(_cacheTimeKey);

      if (cachedJson != null && cacheTime != null) {
        final cacheDateTime = DateTime.parse(cacheTime);
        final now = DateTime.now();

        if (now.difference(cacheDateTime).inMinutes < _cacheValidityMinutes) {
          print(
              '[DashboardService] Using cached data (age: ${now.difference(cacheDateTime).inSeconds}s)');
          return DashboardData.fromJson(jsonDecode(cachedJson));
        } else {
          print('[DashboardService] Cache expired');
        }
      }
    } catch (e) {
      print('[DashboardService] Error reading cache: $e');
    }
    return null;
  }

  /// Save dashboard data to cache
  static void _cacheDashboard(DashboardData data) {
    try {
      final box = GetStorage();
      box.write(_cacheKey, jsonEncode(data.toJson()));
      box.write(_cacheTimeKey, DateTime.now().toIso8601String());
      print('[DashboardService] Dashboard cached successfully');
    } catch (e) {
      print('[DashboardService] Error caching dashboard: $e');
    }
  }

  /// Clear dashboard cache
  static void clearCache() {
    try {
      final box = GetStorage();
      box.remove(_cacheKey);
      box.remove(_cacheTimeKey);
      print('[DashboardService] Cache cleared');
    } catch (e) {
      print('[DashboardService] Error clearing cache: $e');
    }
  }

  /// Fetch both dashboard summary and recent activities in ONE API call
  static Future<DashboardData> getFullDashboard(String token,
      {bool forceRefresh = false}) async {
    if (useMockData) {
      final data = DashboardData(
        summary: await _mockGetRequestorDashboard(),
        activities: await _mockGetRecentActivities(),
      );
      _cacheDashboard(data);
      return data;
    }

    try {
      final startTime = DateTime.now();
      print(
          '[DashboardService] Fetching full dashboard from $baseUrl/api/ui/requestor/dashboard');

      final response = await _client.get(
        Uri.parse('$baseUrl/api/ui/requestor/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw Exception('Request timeout - Backend tidak responsive'),
      );

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      print('[DashboardService] Full dashboard received in ${duration}ms');
      print('[DashboardService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['data'] == null) {
          throw Exception('Response missing data field');
        }

        // Parse summary
        final summary = RequestorModel.fromJson(body['data']['summary'] ?? {});
        print(
            '[DashboardService] Summary: activePR=${summary.activePR}, received=${summary.received}, pending=${summary.pendingActions}');

        // Parse recent activities
        final activities = body['data']['recentPRs'] is List
            ? (body['data']['recentPRs'] as List)
                .map((pr) => ActivityModel.fromJson(pr))
                .toList()
            : <ActivityModel>[];
        print(
            '[DashboardService] Found ${activities.length} recent activities');

        final dashboardData =
            DashboardData(summary: summary, activities: activities);

        // Cache the result
        _cacheDashboard(dashboardData);

        return dashboardData;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token invalid atau expired');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['error'] ?? errorBody['message'] ?? 'Unknown error';
        throw Exception('API Error [${response.statusCode}]: $errorMsg');
      }
    } catch (e) {
      print('[DashboardService] Exception: $e');
      rethrow;
    }
  }

  /// Prefetch dashboard data in background (non-blocking)
  static Future<void> prefetchDashboard(String token) async {
    try {
      print('[DashboardService] Prefetching dashboard...');
      await getFullDashboard(token, forceRefresh: true);
      print('[DashboardService] Prefetch completed');
    } catch (e) {
      print('[DashboardService] Prefetch failed: $e');
    }
  }

  // Legacy methods - kept for backward compatibility
  static Future<RequestorModel> getRequestorDashboard(String token) async {
    final data = await getFullDashboard(token);
    return data.summary;
  }

  static Future<List<ActivityModel>> getRecentActivities(String token) async {
    final data = await getFullDashboard(token);
    return data.activities;
  }

  // Mock data methods
  static Future<RequestorModel> _mockGetRequestorDashboard() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return RequestorModel(
      activePR: 1,
      received: 2,
      pendingActions: 0,
    );
  }

  static Future<List<ActivityModel>> _mockGetRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      ActivityModel(
        id: '1',
        prNumber: 'PR-9042',
        title: 'PR-9042 • Heavy Duty Equipment',
        subtitle: 'Oct 24 • Site A',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'APPROVED',
        statusBadge: 'APPROVED',
        icon: 'build',
      ),
      ActivityModel(
        id: '2',
        prNumber: 'PR-9041',
        title: 'Jane Smith approved your PR',
        subtitle: '5 hours ago',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'DELIVERED',
        statusBadge: 'RECEIVED',
        icon: 'person',
      ),
    ];
  }
}
