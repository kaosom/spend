import 'package:get/get.dart';
import '../features/shell/main_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String home = '/';
  static const String accountDetails = '/account/:id';
  static const String transactionDetails = '/transaction/:id';
  static const String settings = '/settings';

  static final routes = [
    GetPage(name: home, page: () => const MainScreen()),
    // TODO: Add other routes as needed
  ];
}
