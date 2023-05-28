import 'package:flutter/material.dart';
import 'package:merkado/screens/organization_screens/organization_chat_list.dart';

import 'organization_settings_screen.dart';
import '../../widgets/org_bottom_navigation_bar.dart';

//screens

class OrgScreenController extends StatefulWidget {
  static const routeName = '/org-home';

  const OrgScreenController({Key? key}) : super(key: key);

  @override
  OrgScreenControllerState createState() => OrgScreenControllerState();
}

class OrgScreenControllerState extends State<OrgScreenController> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const Center(child: Text('Home Page')),
      const Center(child: Text('Home Page')),
      const OrganizationListScreen(),
      const OrgSettingsScreen(),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: OrgCustomBottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
