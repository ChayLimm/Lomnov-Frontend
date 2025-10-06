import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Presentation/viewmodels/test/sample_viewmodel.dart';
import 'Presentation/views/Test/home_view.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'Presentation/themes/app_theme.dart';
import 'domain/cores/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _navigator = GlobalKey<NavigatorState>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SampleViewModel()),
        // Add more providers here as needed
      ],
      child: GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system, // Follows system theme
        navigatorKey: _navigator,
        home: const HomeView(),
        
        // Enhanced app configuration
        defaultTransition: Transition.cupertino,
        transitionDuration: AppConstants.shortAnimation,
        
        // Global error handling
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
