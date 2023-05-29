import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'customer_selected_order.dart';

class CustomerMyOrders extends StatefulWidget {
  const CustomerMyOrders({super.key});
  static const routeName = '/customer-my-orders';

  @override
  // ignore: library_private_types_in_public_api
  _CustomerMyOrdersState createState() => _CustomerMyOrdersState();
}

class _CustomerMyOrdersState extends State<CustomerMyOrders> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customersOrders')
            .doc(userId)
            .collection('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var items = order['items'];
              var deliveryFee = 50.0; // Assuming a fixed delivery fee

              return InkWell(
                onTap: () {
                  if (order.data() is Map) {
                    var sellerId = order['sellerId'];
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CustomerSelectedOrder(
                            order: order.data() as Map,
                            items: items,
                            deliveryFee: deliveryFee,
                            sellerId: sellerId,
                            orderId: order.id)));
                  }
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${order.id}'),
                        Text('Seller: ${order['sellerName']}'),
                        ...items.map<Widget>((item) => ListTile(
                              leading: Image.network(item['productImage']),
                              title: Text(item['productName']),
                              subtitle: Text('Price: ${item['productPrice']}'),
                              trailing:
                                  Text('Quantity: ${item['productQuantity']}'),
                            )),
                        Text('Delivery Fee: $deliveryFee'),
                        Text(
                            'Total Payment: ${items.fold(0.0, (total, item) => total + item['productPrice'] * item['productQuantity']) + deliveryFee}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
