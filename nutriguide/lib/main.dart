import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutriguide/app/app_widget.dart';
import 'package:nutriguide/core/services/logging_service.dart';

void main() async {
  // 1. Initialize Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock Orientation (Optional but good for MVP)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 3. Initialize Environment Variables
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    LoggingService.instance
        .warning('Could not load .env file. Using defaults.');
  }

  // 4. Initialize Local Storage (Hive)
  await Hive.initFlutter();

  // Open Boxes needed for offline features
  // We open them here so Providers can access them synchronously
  await Hive.openBox('chat_storage');
  await Hive.openBox('recipe_storage');

  // 5. Run App
  runApp(
    const ProviderScope(
      child: AppWidget(),
    ),
  );
}
