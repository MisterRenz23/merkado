import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  const CartScreen({super.key});

  void placeOrder(BuildContext context) async {
    var cartProvider = Provider.of<CartProvider>(context, listen: false);
    var itemsBySeller = cartProvider.itemsBySeller;

    // Get the logged-in user's ID
    var userId = FirebaseAuth.instance.currentUser?.uid;

    for (var seller in itemsBySeller.keys) {
      var items = itemsBySeller[seller]!;
      var orderItems = items
          .map((item) => {
                'productId': item.id,
                'productName': item.productName,
                'productPrice': item.price,
                'productQuantity': item.quantity,
                'productDetails': item
                    .productDetails, // Assuming the item has a 'details' field
                'productImage':
                    item.image, // Assuming the item has an 'image' field
              })
          .toList();

      // Generate a unique order ID
      var orderId = FirebaseFirestore.instance.collection('dummy').doc().id;

      var docRef = FirebaseFirestore.instance
          .collection('customersOrders')
          .doc(userId)
          .collection('orders')
          .doc(orderId);

      await docRef.set({
        'sellerName': seller,
        'items': orderItems,
      });

      // Decrease the stock of each product
      for (var item in items) {
        var productRef = FirebaseFirestore.instance
            .collection('FarmerProducts')
            .doc(item.sellerId)
            .collection(item.sellerName)
            .doc(item.id);
        await productRef.update({
          'quantity': FieldValue.increment(-item.quantity),
        });
      }

      // Decrease the stock of each product
      for (var item in items) {
        var productRef =
            FirebaseFirestore.instance.collection('AllProducts').doc(item.id);
        await productRef.update({
          'quantity': FieldValue.increment(-item.quantity),
        });
      }
    }

    // Clear the cart after placing the order
    cartProvider.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                        'Do you want to clear the items in your cart?'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false)
                              .clearCart();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cartProvider, _) {
          if (cartProvider.itemCount == 0) {
            return const Center(
              child: Text(
                "No added products, Choose a product in the marketplace",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          var cartItems = cartProvider.cartItems;
          var itemsBySeller = cartProvider.itemsBySeller;

          // Calculate the total for all sellers
          double grandTotal = itemsBySeller.values.fold(0.0, (total, items) {
            var subtotal = items.fold(0.0,
                (itemTotal, item) => itemTotal + item.price * item.quantity);
            var deliveryFee = 50.0; // PHP 50 delivery fee per seller
            return total + subtotal + deliveryFee;
          });

          return Column(
            children: [
              // List of cart items
              Expanded(
                flex: 6,
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, i) {
                    var cartItem = cartItems.values.toList()[i];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(cartItem.image),
                          backgroundColor: Colors.transparent,
                        ),
                        title: Text(cartItem.productName),
                        subtitle: Text(
                            'Total: Php.${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (cartItem.quantity == 1) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Remove Item'),
                                        content: const Text(
                                            'Do you want to remove this item from the cart?'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              cartProvider.removeItemQuantity(
                                                  cartItem.id);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  cartProvider.removeItemQuantity(cartItem.id);
                                }
                              },
                            ),
                            Text('${cartItem.quantity} x'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.addItemQuantity(
                                    cartItem.id, context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Cart Summary
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Cart Summary',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemsBySeller.keys.length,
                        itemBuilder: (ctx, i) {
                          var seller = itemsBySeller.keys.toList()[i];
                          var items = itemsBySeller[seller]!;
                          var subtotal = items.fold(
                              0.0,
                              (total, item) =>
                                  total + item.price * item.quantity);
                          var deliveryFee =
                              50.0; // PHP 50 delivery fee per seller

                          return Card(
                            margin: const EdgeInsets.all(5),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Seller Name: $seller',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  // Your item list here
                                  const Divider(),
                                  Text(
                                    'Subtotal: Php.${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    'Delivery Fee: Php.$deliveryFee',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const Divider(),
                                  Text(
                                    'Total: Php.${(subtotal + deliveryFee).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(
                        'Grand Total: Php.${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              placeOrder(context);
                            },
                            child: const Text('Place Order'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
