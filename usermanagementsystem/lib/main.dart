import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

import 'package:usermanagementsystem/controllers/themecontroller.dart';
import 'package:usermanagementsystem/pages/splash.dart';
import 'package:usermanagementsystem/routes/app_routes.dart';
import 'package:usermanagementsystem/cubit/userdetails_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = Get.put(ThemeController());
  await themeController.initializeTheme();

  runApp(
    flutter_bloc.MultiBlocProvider(
      providers: [flutter_bloc.BlocProvider(create: (_) => UserDetailsCubit())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'User Management System',
      getPages: AppPages.routes,
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 27, 27, 27),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      themeMode: Get.find<ThemeController>().themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
