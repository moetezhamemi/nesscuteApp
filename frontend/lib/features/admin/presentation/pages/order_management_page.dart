import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class OrderManagementPage extends ConsumerStatefulWidget {
  const OrderManagementPage({super.key});

  @override
  ConsumerState<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends ConsumerState<OrderManagementPage> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String? _errorMessage;

  final List<String> _orderStatuses = [
    'EN_ATTENTE',
    'ACCEPTEE',
    'EN_PREPARATION',
    'EN_LIVRAISON',
    'LIVREE',
    'REFUSEE',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final token = ref.read(authProvider).token;
      final user = ref.read(authProvider).user;
      
      print('Loading orders with token: ${token != null ? "present" : "missing"}');
      print('User role: ${user?.role}');
      
      _apiService.setToken(token);
      List<OrderModel> orders;
      if (_selectedStatus != null) {
        print('Fetching orders with status: $_selectedStatus');
        orders = await _apiService.getOrdersByStatus(_selectedStatus!);
      } else {
        print('Fetching all orders');
        orders = await _apiService.getOrders();
      }
      
      print('Received ${orders.length} orders');
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e'), duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      await _apiService.updateOrderStatus(order.id!, newStatus);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      await _apiService.deleteOrder(orderId);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande supprimée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text('Commande #${order.id}')),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer la commande'),
                    content: const Text('Êtes-vous sûr de vouloir supprimer cette commande ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && order.id != null) {
                  Navigator.pop(context); // Close details dialog
                  _deleteOrder(order.id!);
                }
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client: ${order.userName ?? "Inconnu"}'),
              Text('Date: ${order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : "-"}'),
              Text('Total: ${order.totalPrice.toStringAsFixed(2)}€'),
              Text('Type: ${order.type == 'LIVRAISON_DOMICILE' ? 'Livraison à domicile' : 'Retrait au restaurant'}'),
              if (order.deliveryAddress != null)
                Text('Adresse: ${order.deliveryAddress}'),
              const Divider(),
              const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item.quantity}x ${item.articleName ?? "Article"}')),
                        Text('${(item.unitPrice * item.quantity).toStringAsFixed(2)}€'),
                      ],
                    ),
                  )),
              const Divider(),
              // Quick action buttons for EN_ATTENTE status
              if (order.status == 'EN_ATTENTE') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateOrderStatus(order, 'ACCEPTEE');
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Accepter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateOrderStatus(order, 'REFUSEE');
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Refuser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              const Text('Changer le statut:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _orderStatuses.contains(order.status) ? order.status : null,
                isExpanded: true,
                items: _orderStatuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context);
                    _updateOrderStatus(order, value);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
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
        return Colors.indigo;
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
        title: const Text('Gestion des commandes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = null;
                    });
                    _loadOrders();
                  },
                ),
                const SizedBox(width: 8),
                ..._orderStatuses.map((status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : null;
                          });
                          _loadOrders();
                        },
                        backgroundColor: _getStatusColor(status).withOpacity(0.1),
                        selectedColor: _getStatusColor(status).withOpacity(0.3),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Erreur de chargement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Aucune commande', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadOrders,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualiser'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Commande #${order.id} - ${order.totalPrice.toStringAsFixed(2)}€'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Client: ${order.userName ?? "Inconnu"}'),
                            Text(
                              order.status,
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showOrderDetails(order),
                      ),
                    );
                  },
                ),
    );
  }
}
