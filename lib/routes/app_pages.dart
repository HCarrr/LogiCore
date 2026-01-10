import 'package:get/get.dart';
import 'package:logicore/routes/route_name.dart';

import '../pages/Home/HomeScreen.dart';

class AppPages {
  static final routes = [
    GetPage(name: RoutesName.homeScreen, page: () => HomeScreen()),
  ];
}
