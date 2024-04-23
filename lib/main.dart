import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Item {
  final int id;
  String name;

  Item({required this.id, required this.name});
}

class ItemViewModel extends ChangeNotifier {
  List<Item> _items = [];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  void addItem(String name) {
    _items.add(Item(id: _items.length + 1, name: name));
    notifyListeners();
  }
  
  void deleteItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateItem(Item item, String newName) {
    item.name = newName;
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}