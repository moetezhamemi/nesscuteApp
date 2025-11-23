import 'package:flutter/material.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssistantOrdersPage extends ConsumerStatefulWidget {
  const AssistantOrdersPage({super.key});

  @override
  ConsumerState<AssistantOrdersPage> createState() => _AssistantOrdersPageState();
}

class _AssistantOrdersPageState extends ConsumerState<AssistantOrdersPage> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  String _selectedStatus = 'EN_ATTENTE';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _apiService.getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    try {
      await _apiService.updateOrderStatus(orderId, status);
      _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((o) => o.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
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
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusChip('EN_ATTENTE', 'En attente'),
                const SizedBox(width: 8),
                _buildStatusChip('ACCEPTEE', 'Acceptée'),
                const SizedBox(width: 8),
                _buildStatusChip('EN_PREPARATION', 'En préparation'),
                const SizedBox(width: 8),
                _buildStatusChip('EN_LIVRAISON', 'En livraison'),
                const SizedBox(width: 8),
                _buildStatusChip('LIVREE', 'Livrée'),
                const SizedBox(width: 8),
                _buildStatusChip('REFUSEE', 'Refusée'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? const Center(child: Text('Aucune commande'))
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text('Commande #${order.id}'),
                              subtitle: Text(
                                '${order.userName ?? 'Client'} - ${order.totalPrice}€',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (order.status == 'EN_ATTENTE')
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () {
                                            _updateOrderStatus(order.id!, 'ACCEPTEE');
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () {
                                            _updateOrderStatus(order.id!, 'REFUSEE');
                                          },
                                        ),
                                      ],
                                    ),
                                  if (order.status == 'ACCEPTEE')
                                    IconButton(
                                      icon: const Icon(Icons.restaurant),
                                      onPressed: () {
                                        _updateOrderStatus(order.id!, 'EN_PREPARATION');
                                      },
                                    ),
                                  if (order.status == 'EN_PREPARATION')
                                    IconButton(
                                      icon: const Icon(Icons.delivery_dining),
                                      onPressed: () {
                                        _updateOrderStatus(order.id!, 'EN_LIVRAISON');
                                      },
                                    ),
                                  if (order.status == 'EN_LIVRAISON')
                                    IconButton(
                                      icon: const Icon(Icons.check_circle),
                                      onPressed: () {
                                        _updateOrderStatus(order.id!, 'LIVREE');
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
    );
  }
}

