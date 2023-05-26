import 'package:flutter/material.dart';

import 'marketplace_screen.dart';
import 'user_location_screen.dart';

class HomePageScreen extends StatefulWidget {
  static const routeName = '/home-page';

  const HomePageScreen({Key? key}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Customer!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Put your customer screen content here',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, UserLocationScreen.routeName);
              },
              child: const Text('User\'s Location'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, MarketplaceScreen.routeName);
              },
              child: const Text('Market Place'),
            ),
          ],
        ),
      ),
    );
  }
}
