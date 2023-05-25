import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:merkado/providers/products_provider.dart';
import 'package:merkado/screens/farmer_screens/farmer_new_post.dart';
import 'package:merkado/screens/marketplace_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/farmers_provider.dart';
import 'providers/organization_provider.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/farmer_screens/farmer_location_screen.dart';
import 'screens/farmer_screens/farmer_drawer_screens/farmer_my_order.dart';
import 'screens/farmer_screens/farmer_drawer_screens/farmer_my_products.dart';
import 'screens/user_location_screen.dart';
import 'screens/organization_screens/organization_location_screen.dart';
import 'screens/farmer_screens/farmer_screen_controller.dart';
import 'screens/organization_screens/organization_homescreen.dart';
import 'screens/authentication/user/forgot_password.dart';
import 'screens/authentication/user/login_screen.dart';
import 'screens/authentication/user/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA_JVEXL6cLkdg8SHHeSv46MwfXygNluPY',
      appId: '1:386692353743:android:016a59a6abd4bdf204f1ba',
      messagingSenderId: '386692353743',
      projectId: 'merkado-cfaa7',
      storageBucket: 'merkado-cfaa7.appspot.com',
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(
      const Merkado(),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class Merkado extends StatefulWidget {
  const Merkado({Key? key}) : super(key: key);

  @override
  State<Merkado> createState() => _MerkadoState();
}

class _MerkadoState extends State<Merkado> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FarmersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrganizationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Merkado',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
        routes: {
          //User Side Routes
          SplashScreen.routeName: (ctx) => const SplashScreen(),
          RegisterScreen.routeName: (ctx) => const RegisterScreen(),
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          ForgotPasswordScreen.routeName: (ctx) => const ForgotPasswordScreen(),
          HomePageScreen.routeName: (ctx) => const HomePageScreen(),
          UserLocationScreen.routeName: (ctx) => const UserLocationScreen(),
          MarketplaceScreen.routeName: (ctx) => const MarketplaceScreen(),

          //Farmer Side Routes
          FarmerScreenController.routeName: (ctx) =>
              const FarmerScreenController(),
          FarmerLocationScreen.routeName: (ctx) => const FarmerLocationScreen(),
          FarmerMyOrder.routeName: (ctx) => const FarmerMyOrder(),
          FarmerMyProducts.routeName: (ctx) => const FarmerMyProducts(),
          FarmerNewProductPost.routeName: (ctx) => const FarmerNewProductPost(),

          //Organization Side Routes
          OrganizationHomeScreen.routeName: (ctx) =>
              const OrganizationHomeScreen(),
          OrganizationLocationScreen.routeName: (ctx) =>
              const OrganizationLocationScreen(),
        },
      ),
    );
  }
}
