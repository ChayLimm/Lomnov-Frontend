import 'package:app/presentation/provider/auth_viewmodel.dart';
import 'package:app/presentation/views/auth/login_view.dart';
import 'package:app/presentation/views/auth/signup_view.dart';
import 'package:app/presentation/views/home/home_view.dart';
import 'package:app/presentation/views/notifications/notifications_view.dart';
import 'package:app/presentation/widgets/app_background.dart';
import 'package:app/presentation/views/buildings/buildings_view.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:app/presentation/views/buildings/add_building_view.dart';
import 'package:app/presentation/views/buildings/building_detail_view.dart';
import 'package:app/presentation/views/settings/settings_view.dart';
import 'package:app/presentation/views/settings/edit_profile_view.dart';
import 'package:app/data/services/mobile_device_identifier.dart';

final DeviceIdService deviceIdService = DeviceIdService();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

// Fetch & log device id once.
  try {
    final id = await deviceIdService.getDeviceId(); // Service already logs.
    debugPrint('[DeviceID] main() received: $id');
  } catch (e) {
    debugPrint('[DeviceID] Error obtaining device id: $e');
  }

  // Decide start screen based on secure token
  final auth = AuthService();
  final loggedIn = await auth.isLoggedIn();
  final initial = loggedIn ? '/home' : '/';

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: MyApp(initialRoute: initial),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
  builder: (context, child) => AppBackground(addOverlay: false, child: child ?? const SizedBox()),
      getPages: [
        GetPage(name: '/', page: () => const LoginView()),
        GetPage(name: '/signup', page: () => const SignUpView()),
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/buildings', page: () => const BuildingsView()),
        GetPage(name: '/notifications', page: () => const NotificationsView()),
        GetPage(name: '/settings', page: () => const SettingsView()),
        GetPage(name: '/edit-profile', page: () => const EditProfileView()),
        GetPage(
          name: '/buildings/add',
          page: () {
            final args = Get.arguments;
            final landlordId = (args is Map && args['landlordId'] is int)
                ? args['landlordId'] as int
                : null;
            return AddBuildingView(initialLandlordId: landlordId);
          },
        ),
        GetPage(
          name: '/buildings/:id',
          page: () {
            final id = int.tryParse(Get.parameters['id'] ?? '');
            return BuildingDetailView(buildingId: id ?? 0);
          },
        ),
      ],
    );
  }
}
