import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/order_model.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Vider le panier'),
                    content: const Text('Voulez-vous vider tout le panier ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Vider'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Votre panier est vide',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.article.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: item.article.imageUrl!.startsWith('http')
                                            ? item.article.imageUrl!
                                            : '${AppConfig.baseUrlWithoutApi}${item.article.imageUrl}',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.restaurant_menu),
                                        ),
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.restaurant_menu),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.article.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.article.price}€',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () {
                                            ref.read(cartProvider.notifier).updateQuantity(
                                                  item.article.id!,
                                                  item.quantity - 1,
                                                );
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () {
                                            ref.read(cartProvider.notifier).updateQuantity(
                                                  item.article.id!,
                                                  item.quantity + 1,
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${item.totalPrice.toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).removeItem(item.article.id!);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartState.totalAmount.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (authState.user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vous devez être connecté pour commander')),
                              );
                              return;
                            }

                            // Show delivery type selection dialog
                            final deliveryType = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Type de livraison'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.delivery_dining),
                                      title: const Text('Livraison à domicile'),
                                      subtitle: const Text('Nous livrons chez vous'),
                                      onTap: () => Navigator.pop(context, 'LIVRAISON_DOMICILE'),
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.store),
                                      title: const Text('Retrait au restaurant'),
                                      subtitle: const Text('Venez chercher votre commande'),
                                      onTap: () => Navigator.pop(context, 'RETRAIT_RESTAURANT'),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (deliveryType == null) return;

                            String? deliveryAddress;
                            double? latitude;
                            double? longitude;

                            // If home delivery, ask for location
                            if (deliveryType == 'LIVRAISON_DOMICILE') {
                              final addressController = TextEditingController();
                              bool isLoadingLocation = false;
                              
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: const Text('Adresse de livraison'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: addressController,
                                          decoration: const InputDecoration(
                                            labelText: 'Adresse complète',
                                            hintText: 'Rue, ville, code postal',
                                          ),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: isLoadingLocation ? null : () async {
                                            setState(() => isLoadingLocation = true);
                                            try {
                                              // Check permissions
                                              LocationPermission permission = await Geolocator.checkPermission();
                                              if (permission == LocationPermission.denied) {
                                                permission = await Geolocator.requestPermission();
                                                if (permission == LocationPermission.denied) {
                                                  throw 'Permission de localisation refusée';
                                                }
                                              }
                                              
                                              if (permission == LocationPermission.deniedForever) {
                                                throw 'Permission de localisation refusée définitivement';
                                              }

                                              // Get current position
                                              Position position = await Geolocator.getCurrentPosition(
                                                desiredAccuracy: LocationAccuracy.high,
                                              );
                                              
                                              latitude = position.latitude;
                                              longitude = position.longitude;
                                              
                                              addressController.text = 'Position GPS: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
                                              
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Position GPS récupérée avec succès!')),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Erreur: $e')),
                                                );
                                              }
                                            } finally {
                                              setState(() => isLoadingLocation = false);
                                            }
                                          },
                                          icon: isLoadingLocation
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : const Icon(Icons.my_location),
                                          label: Text(isLoadingLocation ? 'Chargement...' : 'Utiliser ma position GPS'),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Partagez votre position pour une livraison précise',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Annuler'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Confirmer'),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (confirmed != true) return;
                              deliveryAddress = addressController.text;

                              if (deliveryAddress.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Veuillez entrer une adresse ou partager votre position')),
                                );
                                return;
                              }
                            }

                            // Create order
                            try {
                              final apiService = ApiService();
                              apiService.setToken(authState.token);

                              final orderItems = cartState.items.map((item) => OrderItemModel(
                                    articleId: item.article.id!,
                                    quantity: item.quantity,
                                    unitPrice: item.article.price,
                                  )).toList();

                              final order = OrderModel(
                                userId: authState.user!.id!,
                                items: orderItems,
                                totalPrice: cartState.totalAmount,
                                type: deliveryType,
                                status: 'EN_ATTENTE',
                                deliveryAddress: deliveryAddress,
                                latitude: latitude,
                                longitude: longitude,
                              );

                              await apiService.createOrder(order);
                              ref.read(cartProvider.notifier).clear();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      deliveryType == 'LIVRAISON_DOMICILE'
                                          ? 'Commande passée ! Livraison en cours de préparation'
                                          : 'Commande passée ! Vous pouvez venir la chercher bientôt',
                                    ),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Commander',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
