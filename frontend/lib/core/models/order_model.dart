class OrderModel {
  final int? id;
  final int? userId;
  final String? userName;
  final String status;
  final String type;
  final double totalPrice;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> items;

  OrderModel({
    this.id,
    this.userId,
    this.userName,
    required this.status,
    required this.type,
    required this.totalPrice,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      status: json['status'],
      type: json['type'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItemModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'status': status,
      'type': type,
      'totalPrice': totalPrice,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class OrderItemModel {
  final int? id;
  final int articleId;
  final String? articleName;
  final int quantity;
  final double unitPrice;

  OrderItemModel({
    this.id,
    required this.articleId,
    this.articleName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      articleId: json['articleId'],
      articleName: json['articleName'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'articleName': articleName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

