import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/article_management_page.dart';
import '../../features/admin/presentation/pages/assistant_management_page.dart';
import '../../features/admin/presentation/pages/order_management_page.dart';
import '../../features/assistant/presentation/pages/assistant_orders_page.dart';
import '../../features/client/presentation/pages/client_home_page.dart';
import '../../features/client/presentation/pages/article_detail_page.dart';
import '../../features/client/presentation/pages/cart_page.dart';
import '../../features/client/presentation/pages/orders_page.dart';
import '../../features/client/presentation/pages/profile_page.dart';
import '../../features/client/presentation/pages/edit_profile_page.dart';
import '../../features/ai/presentation/pages/ai_chat_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminDashboard = '/admin/dashboard';
  static const String articleManagement = '/admin/articles';
  static const String assistantManagement = '/admin/assistants';
  static const String orderManagement = '/admin/orders';
  static const String assistantOrders = '/assistant/orders';
  static const String clientHome = '/client/home';
  static const String articleDetail = '/client/article';
  static const String cart = '/client/cart';
  static const String clientOrders = '/client/orders';
  static const String profile = '/client/profile';
  static const String editProfile = '/client/edit-profile';
  static const String aiChat = '/client/ai-chat';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case articleManagement:
        return MaterialPageRoute(builder: (_) => const ArticleManagementPage());
      case assistantManagement:
        return MaterialPageRoute(builder: (_) => const AssistantManagementPage());
      case orderManagement:
        return MaterialPageRoute(builder: (_) => const OrderManagementPage());
      case assistantOrders:
        return MaterialPageRoute(builder: (_) => const AssistantOrdersPage());
      case clientHome:
        return MaterialPageRoute(builder: (_) => const ClientHomePage());
      case articleDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ArticleDetailPage(articleId: args?['articleId']),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartPage());
      case clientOrders:
        return MaterialPageRoute(builder: (_) => const ClientOrdersPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case aiChat:
        return MaterialPageRoute(builder: (_) => const AiChatPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}

