import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/views/auth_view.dart';
import 'package:app/Presentation/views/home_view.dart';
import 'package:app/Presentation/views/buildings/buildings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:app/domain/services/auth_service.dart';
import 'package:app/Presentation/views/buildings/add_building_view.dart';
import 'package:app/Presentation/views/buildings/building_detail_view.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Decide start screen based on secure token
  final auth = AuthService();
  final loggedIn = await auth.isLoggedIn();
  final initial = loggedIn ? '/home' : '/';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
      getPages: [
        GetPage(name: '/', page: () => const AuthView()),
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/buildings', page: () => const BuildingsView()),
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