import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  final ApiService _apiService = ApiService();
  int _articleCount = 0;
  int _assistantCount = 0;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      final articles = await _apiService.getArticles();
      final orders = await _apiService.getOrders();
      final assistants = await _apiService.getUsersByRole('ASSISTANT');
      setState(() {
        _articleCount = articles.length;
        _orderCount = orders.length;
        _assistantCount = assistants.length;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildStatCard(
            context,
            'Articles',
            _articleCount.toString(),
            Icons.restaurant_menu,
            Colors.orange,
            () async {
              await Navigator.pushNamed(context, AppRouter.articleManagement);
              _loadStats();
            },
          ),
          _buildStatCard(
            context,
            'Assistants',
            _assistantCount.toString(),
            Icons.people,
            Colors.blue,
            () async {
              await Navigator.pushNamed(context, AppRouter.assistantManagement);
              _loadStats();
            },
          ),
          _buildStatCard(
            context,
            'Commandes',
            _orderCount.toString(),
            Icons.shopping_cart,
            Colors.green,
            () async {
              await Navigator.pushNamed(context, AppRouter.orderManagement);
              _loadStats();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

