import 'package:flutter/material.dart';
import 'app/avid_app.dart';
import 'core/storage/storage_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service here
  await StorageService.initialize();

  runApp(const AvidApp());
}
