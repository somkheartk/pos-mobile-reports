class SalesReport {
  final DateTime date;
  final double totalSales;
  final double totalRevenue;
  final int totalOrders;
  final int totalItems;
  final double averageOrderValue;
  final List<ProductSummary> topProducts;
  final Map<String, double> salesByCategory;
  final Map<String, int> ordersByHour;

  SalesReport({
    required this.date,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalItems,
    required this.averageOrderValue,
    required this.topProducts,
    required this.salesByCategory,
    required this.ordersByHour,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      date: DateTime.parse(json['date']),
      totalSales: (json['totalSales'] ?? 0.0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0.0).toDouble(),
      topProducts: (json['topProducts'] as List<dynamic>?)
          ?.map((item) => ProductSummary.fromJson(item))
          .toList() ?? [],
      salesByCategory: Map<String, double>.from(json['salesByCategory'] ?? {}),
      ordersByHour: Map<String, int>.from(json['ordersByHour'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'totalItems': totalItems,
      'averageOrderValue': averageOrderValue,
      'topProducts': topProducts.map((p) => p.toJson()).toList(),
      'salesByCategory': salesByCategory,
      'ordersByHour': ordersByHour,
    };
  }

  String get formattedDate {
    return '${date.day}//';
  }

  String get formattedRevenue {
    return 'ß${totalRevenue.toStringAsFixed(2)}';
  }
}

class ProductSummary {
  final String id;
  final String name;
  final int quantity;
  final double revenue;
  final String category;

  ProductSummary({
    required this.id,
    required this.name,
    required this.quantity,
    required this.revenue,
    required this.category,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'revenue': revenue,
      'category': category,
    };
  }

  String get formattedRevenue {
    return 'ß${revenue.toStringAsFixed(2)}';
  }
}
