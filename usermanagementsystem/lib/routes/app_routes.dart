import 'package:get/get.dart';
import 'package:usermanagementsystem/pages/profilepage.dart';
import 'package:usermanagementsystem/pages/splash.dart';
import 'package:usermanagementsystem/pages/homepage.dart';
import 'package:usermanagementsystem/pages/login.dart';
import 'package:usermanagementsystem/pages/create_post.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/login', page: () => LoginPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/profile', page: () => ProfilePage()),
    GetPage(name: '/createpost', page: () => CreatePostPage()),
  ];
}