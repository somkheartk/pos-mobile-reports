import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sales_report.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ReportsService {
  static const String baseUrl = 'http://localhost:7800';
  final AuthService _authService = AuthService();

  // Get daily sales report
  Future<SalesReport> getDailySalesReport(DateTime date) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$baseUrl/reports/sales/daily?date=$formattedDate'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SalesReport.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load sales report');
      }
    } catch (e) {
      throw Exception('Error fetching sales report: $e');
    }
  }

  // Get monthly sales report
  Future<List<SalesReport>> getMonthlySalesReport(int year, int month) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/reports/sales/monthly?year=$year&month=$month'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => SalesReport.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load monthly sales report');
      }
    } catch (e) {
      throw Exception('Error fetching monthly sales report: $e');
    }
  }

  // Get sales summary for date range
  Future<Map<String, dynamic>> getSalesSummary(DateTime startDate, DateTime endDate) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final start = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final end = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse('$baseUrl/reports/sales/summary?startDate=$start&endDate=$end'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load sales summary');
      }
    } catch (e) {
      throw Exception('Error fetching sales summary: $e');
    }
  }

  // Get top selling products
  Future<List<ProductSummary>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      String url = '$baseUrl/reports/products/top?limit=$limit';
      if (startDate != null && endDate != null) {
        final start = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        final end = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
        url += '&startDate=$start&endDate=$end';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ProductSummary.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load top products');
      }
    } catch (e) {
      throw Exception('Error fetching top products: $e');
    }
  }

  // Get sales by category
  Future<Map<String, double>> getSalesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      String url = '$baseUrl/reports/sales/category';
      if (startDate != null && endDate != null) {
        final start = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        final end = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
        url += '?startDate=$start&endDate=$end';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, double>.from(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load sales by category');
      }
    } catch (e) {
      throw Exception('Error fetching sales by category: $e');
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }
}
