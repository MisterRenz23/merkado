import 'package:flutter/material.dart';

import '../../widgets/farmer_bottom_navigation_bar.dart';

//screens
import '../farmer_screens/farmer_home_screen.dart';
import '../farmer_screens/farmer_new_post.dart';

class FarmerScreenController extends StatefulWidget {
  static const routeName = '/farmer-home';
  const FarmerScreenController({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FarmerScreenControllerState createState() => _FarmerScreenControllerState();
}

class _FarmerScreenControllerState extends State<FarmerScreenController> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const FarmerHomePage(),
      const NewProductPost(),
      const Center(child: Text('Messaging Page')),
      const Center(child: Text('Settings Page')),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: FarmerCustomBottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
