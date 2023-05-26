import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCartProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void add(DocumentSnapshot product, int quantity) {
    _items.add({
      'product': product,
      'quantity': quantity,
    });
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}
