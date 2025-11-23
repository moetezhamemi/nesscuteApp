import 'package:flutter/material.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientOrdersPage extends ConsumerStatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  ConsumerState<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends ConsumerState<ClientOrdersPage> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final orders = await _apiService.getOrdersByUserId(userId);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'EN_PREPARATION':
        return 'En préparation';
      case 'EN_LIVRAISON':
        return 'En livraison';
      case 'LIVREE':
        return 'Livrée';
      case 'REFUSEE':
        return 'Refusée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ACCEPTEE':
        return Colors.blue;
      case 'EN_PREPARATION':
        return Colors.purple;
      case 'EN_LIVRAISON':
        return Colors.teal;
      case 'LIVREE':
        return Colors.green;
      case 'REFUSEE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Aucune commande'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('Commande #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ${order.totalPrice}€'),
                            Text('Type: ${order.type}'),
                            if (order.createdAt != null)
                              Text(
                                'Date: ${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                              ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            _getStatusLabel(order.status),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatusColor(order.status),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

