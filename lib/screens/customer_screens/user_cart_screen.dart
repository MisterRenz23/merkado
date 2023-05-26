import 'package:flutter/material.dart';
import 'package:merkado/providers/user_cart_provider.dart';
import 'package:provider/provider.dart';

class UserCartScreen extends StatelessWidget {
  const UserCartScreen({Key? key}) : super(key: key);
  static const routeName = '/user-cart-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Cart'),
        actions: [
          Row(
            children: [
              const Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.white, // Change this color to suit your needs
                  fontSize: 16, // Change the size as per your need
                ),
              ),
              IconButton(
                onPressed: () {
                  // Your logic here
                },
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<UserCartProvider>(
        builder: (ctx, cart, _) => ListView.builder(
          itemCount: cart.items.length,
          itemBuilder: (ctx, i) {
            var item = cart.items[i];
            double price = item['product']['price'];
            int quantity = item['quantity'];
            String seller = item['product']['sellerName'];
            double totalProductPrice = price * quantity;

            return ListTile(
              leading: Image.network(item['product']['image']),
              title: Text(item['product']['productName']),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Quantity: $quantity x Php.$price \nTotal Price: Php.$totalProductPrice'),
                  Text('Seller: $seller'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  cart.removeItem(i);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
