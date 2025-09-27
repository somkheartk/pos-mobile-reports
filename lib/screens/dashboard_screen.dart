import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sales_report.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/reports_service.dart';
import '../widgets/sales_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_products_list.dart';
import '../widgets/category_pie_chart.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ReportsService _reportsService = ReportsService();
  
  TabController? _tabController;
  User? _currentUser;
  SalesReport? _todayReport;
  List<SalesReport> _weeklyReports = [];
  List<ProductSummary> _topProducts = [];
  Map<String, double> _salesByCategory = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load user profile
      _currentUser = await _reportsService.getCurrentUser();
      
      // Check if user can view reports
      if (!_currentUser!.canViewReports()) {
        setState(() {
          _error = 'คุณไม่มีสิทธิ์ในการดู reports';
          _isLoading = false;
        });
        return;
      }

      // Load today's report
      final today = DateTime.now();
      _todayReport = await _reportsService.getDailySalesReport(today);

      // Load weekly reports (last 7 days)
      final List<Future<SalesReport>> weeklyFutures = [];
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        weeklyFutures.add(_reportsService.getDailySalesReport(date));
      }
      _weeklyReports = await Future.wait(weeklyFutures);

      // Load top products
      _topProducts = await _reportsService.getTopProducts(
        startDate: today.subtract(Duration(days: 7)),
        endDate: today,
        limit: 10,
      );

      // Load sales by category
      _salesByCategory = await _reportsService.getSalesByCategory(
        startDate: today.subtract(Duration(days: 30)),
        endDate: today,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildOverviewTab() {
    if (_todayReport == null) return Center(child: Text('ไม่มีข้อมูล'));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'ยอดขายวันนี้',
                    value: _todayReport!.formattedRevenue,
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'จำนวนออเดอร์',
                    value: _todayReport!.totalOrders.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'สินค้าที่ขาย',
                    value: _todayReport!.totalItems.toString(),
                    icon: Icons.inventory,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'ค่าเฉลี่ย/ออเดอร์',
                    value: '฿${_todayReport!.averageOrderValue.toStringAsFixed(0)}',
                    icon: Icons.analytics,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Weekly Sales Chart
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ยอดขาย 7 วันล่าสุด',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: SalesChart(reports: _weeklyReports),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สินค้าขายดี (7 วันล่าสุด)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            TopProductsList(products: _topProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ยอดขายตามหมวดหมู่ (30 วันล่าสุด)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  height: 300,
                  child: CategoryPieChart(salesByCategory: _salesByCategory),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Category details
            ..._salesByCategory.entries.map((entry) => 
              ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.primaries[_salesByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(entry.key),
                trailing: Text(
                  '฿${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'การวิเคราะห์ขั้นสูง',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.trending_up, color: Colors.green),
                title: Text('แนวโน้มการขาย'),
                subtitle: Text('กำลังพัฒนา...'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.schedule, color: Colors.blue),
                title: Text('ช่วงเวลาขายดี'),
                subtitle: Text('กำลังพัฒนา...'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.compare_arrows, color: Colors.orange),
                title: Text('เปรียบเทียบรายเดือน'),
                subtitle: Text('กำลังพัฒนา...'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(_currentUser?.name ?? 'User'),
                  subtitle: Text(_currentUser?.role ?? ''),
                ),
              ),
              PopupMenuItemDivider(),
              PopupMenuItem(
                onTap: _logout,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('ออกจากระบบ'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'ภาพรวม'),
            Tab(icon: Icon(Icons.inventory), text: 'สินค้า'),
            Tab(icon: Icon(Icons.category), text: 'หมวดหมู่'),
            Tab(icon: Icon(Icons.analytics), text: 'วิเคราะห์'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_error!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildProductsTab(),
                    _buildCategoriesTab(),
                    _buildAnalyticsTab(),
                  ],
                ),
    );
  }
}
