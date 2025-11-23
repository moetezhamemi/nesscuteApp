import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/order_model.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
    ));
  }

  void setToken(String? token) {
    _token = token;
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/register', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> googleLogin(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/google', data: data);
    return response.data;
  }

  // Articles
  Future<List<ArticleModel>> getArticles() async {
    final response = await _dio.get('/articles');
    return (response.data as List)
        .map((json) => ArticleModel.fromJson(json))
        .toList();
  }

  Future<ArticleModel> getArticleById(int id) async {
    final response = await _dio.get('/articles/$id');
    return ArticleModel.fromJson(response.data);
  }

  Future<List<ArticleModel>> getArticlesByType(String type) async {
    final response = await _dio.get('/articles/type/$type');
    return (response.data as List)
        .map((json) => ArticleModel.fromJson(json))
        .toList();
  }

  Future<List<ArticleModel>> searchArticles(String keyword) async {
    final response = await _dio.get('/articles/search', queryParameters: {'keyword': keyword});
    return (response.data as List)
        .map((json) => ArticleModel.fromJson(json))
        .toList();
  }

  // Orders
  Future<List<OrderModel>> getOrders() async {
    final response = await _dio.get('/orders');
    return (response.data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  Future<List<OrderModel>> getOrdersByUserId(int userId) async {
    final response = await _dio.get('/orders/user/$userId');
    return (response.data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final response = await _dio.post('/orders', data: order.toJson());
    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    final response = await _dio.put('/orders/$orderId/status', queryParameters: {'status': status});
    return OrderModel.fromJson(response.data);
  }

  // Rating
  Future<void> addRating(int articleId, int userId, int rating) async {
    await _dio.post('/articles/$articleId/rating', queryParameters: {
      'userId': userId,
      'rating': rating,
    });
  }

  // Comments
  Future<List<CommentModel>> getComments(int articleId) async {
    final response = await _dio.get('/articles/$articleId/comments');
    return (response.data as List)
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  Future<CommentModel> addComment(int articleId, int userId, String content) async {
    final response = await _dio.post('/articles/$articleId/comments',
        queryParameters: {'userId': userId},
        data: {'content': content});
    return CommentModel.fromJson(response.data);
  }

  // AI
  Future<Map<String, dynamic>> queryAI(String question, String userRole) async {
    final response = await _dio.post('/ai/query', data: {
      'question': question,
      'userRole': userRole,
    });
    return response.data;
  }

  // Users
  Future<UserModel> getUserById(int id) async {
    final response = await _dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateUser(int id, UserModel user) async {
    final response = await _dio.put('/users/$id', data: user.toJson());
    return UserModel.fromJson(response.data);
  }

  Future<void> changePassword(int id, String oldPassword, String newPassword) async {
    await _dio.put('/users/$id/password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  // File Upload
  Future<Map<String, dynamic>> uploadImage(FormData formData) async {
    final response = await _dio.post('/files/upload', data: formData);
    return response.data;
  }
}

