import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/views/rooms/room_detail_view.dart';
import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/views/auth/login_view.dart';
import 'package:app/Presentation/views/auth/signup_view.dart';
import 'package:app/Presentation/views/home/home_view.dart';
import 'package:app/Presentation/views/notifications/notifications_view.dart';
import 'package:app/Presentation/widgets/app_background.dart';
import 'package:app/Presentation/views/buildings/buildings_view.dart';
import 'package:app/data/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/views/buildings/add_building_view.dart';
import 'package:app/Presentation/views/rooms/add_room_view.dart';
import 'package:app/Presentation/views/buildings/building_detail_view.dart';
import 'package:app/Presentation/views/settings/settings_view.dart';
import 'package:app/Presentation/views/settings/profile/edit_profile_view.dart';
import 'package:app/Presentation/views/settings/services/service_view.dart';
import 'package:app/Presentation/views/settings/roles/role_view.dart';
import 'package:app/Presentation/views/settings/contact/contact_us_view.dart';
import 'package:app/data/services/mobile_device_identifier.dart';

import 'package:app/Presentation/views/auth/bakong_setup_view.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentViewModel())

        ],
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
        GetPage(name: ServiceView.routeName, page: () => const ServiceView()),
        GetPage(name: RoleView.routeName, page: () => const RoleView()),
        GetPage(name: '/contact-us', page: () => const ContactUsView()),
        GetPage(name: '/edit-profile', page: () => const EditProfileView()),
        GetPage(name: '/bakong-setup', page: () => const BakongSetupView()),
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
          name: '/rooms/add',
          page: () {
            final args = Get.arguments;
            final buildingId = (args is Map && args['buildingId'] is int) ? args['buildingId'] as int : 0;
            return AddRoomView(buildingId: buildingId);
          },
        ),
        GetPage(
          name: '/buildings/:id',
          page: () {
            final id = int.tryParse(Get.parameters['id'] ?? '');
            return BuildingDetailView(buildingId: id ?? 0);
          },
        ),
        GetPage(
          name: '/rooms/:id',
          page: () {
            final id = int.tryParse(Get.parameters['id'] ?? '');
            return RoomDetailView(roomId: id ?? 0);
          },
        ),

      ],
    );
  }
}
