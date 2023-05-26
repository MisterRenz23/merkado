import 'package:flutter/material.dart';

import '../../widgets/user_bottom_navigation_bar.dart';

//screens
import 'user_chat_list.dart';
import 'marketplace_screen.dart';
import 'user_settings_screen.dart';

class UserScreenController extends StatefulWidget {
  static const routeName = '/home-page';
  const UserScreenController({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UserScreenControllerState createState() => _UserScreenControllerState();
}

class _UserScreenControllerState extends State<UserScreenController> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const MarketplaceScreen(),
      const UserListScreen(),
      const UserSettingsScreen(),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: UserCustomBottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
