import 'package:flutter/material.dart';

import '../../widgets/customer_bottom_navigation_bar.dart';
import '../../widgets/farmer_bottom_navigation_bar.dart';

//screens
import '../customer_screens/customer_home_screen.dart';

class CustomerScreenController extends StatefulWidget {
  static const routeName = '/customer-home';
  const CustomerScreenController({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomerScreenControllerState createState() =>
      _CustomerScreenControllerState();
}

class _CustomerScreenControllerState extends State<CustomerScreenController> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const CustomerHomePageScreen(),
      const Center(child: Text('Messaging Page')),
      const Center(child: Text('Settings Page')),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: CustomerCustomBottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
