import 'package:get/get.dart';
import 'package:logicore/pages/login/LoginPage.dart';
import 'package:logicore/pages/mainPage.dart';
import 'package:logicore/pages/PurchaseRequest/PRDetailScreen.dart';
import 'package:logicore/routes/route_name.dart';

import '../pages/Home/HomeScreen.dart';
import '../pages/Po/CreatePurchaseRequest.dart';

class AppPages {
  static final routes = [
    GetPage(name: RoutesName.mainPage, page: () => MainPage()),
    GetPage(name: RoutesName.homeScreen, page: () => HomeScreen()),
    GetPage(name: RoutesName.loginPage, page: () => Loginpage()),
    GetPage(
        name: RoutesName.createPurchaseRequest,
        page: () => CreatePurchaseRequest()),
    GetPage(name: RoutesName.prDetail, page: () => const PRDetailScreen()),
  ];
}
