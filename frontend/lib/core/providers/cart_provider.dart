import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article_model.dart';

class CartItem {
  final ArticleModel article;
  int quantity;

  CartItem({
    required this.article,
    this.quantity = 1,
  });

  double get totalPrice => article.price * quantity;
}

class CartState {
  final List<CartItem> items;

  CartState({this.items = const []});

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  double get totalAmount {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(ArticleModel article) {
    final existingIndex = state.items.indexWhere(
      (item) => item.article.id == article.id,
    );

    if (existingIndex >= 0) {
      final updatedItems = [...state.items];
      updatedItems[existingIndex].quantity++;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(article: article)],
      );
    }
  }

  void removeItem(int articleId) {
    state = state.copyWith(
      items: state.items.where((item) => item.article.id != articleId).toList(),
    );
  }

  void updateQuantity(int articleId, int quantity) {
    if (quantity <= 0) {
      removeItem(articleId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.article.id == articleId) {
        item.quantity = quantity;
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void clear() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
