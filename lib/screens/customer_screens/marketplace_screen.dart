import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:merkado/providers/user_cart_provider.dart';
import 'package:provider/provider.dart';

import '../customer_screens/user_cart_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);
  static const routeName = '/marketplace-screen';

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showProductDetails(BuildContext context, DocumentSnapshot product) {
    int selectedQuantity = 1; // Default selected quantity

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // To make the dialog as small as possible
                  children: <Widget>[
                    Image.network(product['image'], height: 150, width: 150),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          product['productName'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(product['productDetails']),
                        Text('Seller: ${product['sellerName']}'),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Price: Php.${product['price']}'),
                            Text('Quantity: ${product['quantity']}')
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (selectedQuantity > 1) {
                                selectedQuantity--;
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: TextEditingController()
                              ..text = selectedQuantity.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              int? newValue = int.tryParse(value);
                              if (newValue != null &&
                                  newValue >= 1 &&
                                  newValue <= product['quantity']) {
                                setState(() {
                                  selectedQuantity = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              if (selectedQuantity < product['quantity']) {
                                selectedQuantity++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<UserCartProvider>(context, listen: false)
                            .add(product, selectedQuantity);

                        // Close the dialog
                        Navigator.pushNamed(context, UserCartScreen.routeName);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, UserCartScreen.routeName);
            },
            icon: const Icon(Icons.shopping_cart_rounded),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('AllProducts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot product = snapshot.data!.docs[index];
              return ListTile(
                leading:
                    Image.network(product['image'], height: 100, width: 50),
                title: Text(product['productName']),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['productDetails']),
                    Text('Seller: ${product['sellerName']}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showProductDetails(context, product);
                      },
                      child: SizedBox(
                        width: 120, // Give it a certain width.
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(
                              Icons
                                  .add_shopping_cart, // This is a built-in icon for a shopping cart.
                              color: Colors.red,
                              size: 17,
                            ),
                            Text(
                              ' Add to Cart',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text("Price: Php.${product['price']}"),
                    Text("Quantity: ${product['quantity']}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
