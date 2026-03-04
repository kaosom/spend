import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/accounts/accounts_controller.dart';
import '../features/transactions/transactions_controller.dart';
import '../features/tracking/tracking_controller.dart';
import '../features/settings/settings_controller.dart';
import '../features/prediction/prediction_controller.dart';
import '../features/categories/categories_controller.dart';
import 'routes.dart';
import 'theme/avid_theme.dart';

/// Main Avid Spend App widget
class AvidApp extends StatelessWidget {
  const AvidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Avid Spend',
      theme: AvidTheme.theme,
      darkTheme: AvidTheme.theme,
      themeMode: ThemeMode.light, // Change to light mode
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.routes,
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// App binding to initialize controllers
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize controllers
    Get.put(AccountsController(), permanent: true);
    Get.put(CategoriesController(), permanent: true);
    Get.put(TransactionsController(), permanent: true);
    Get.put(TrackingController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(PredictionController(), permanent: true);
  }
}
