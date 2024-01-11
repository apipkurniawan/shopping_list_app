import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        "groceries-flutter-default-rtdb.firebaseio.com", "shopping-list.json");

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadItems = [];
    for (var item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }

    setState(() {
      _groceryItems = loadItems;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(null),
      ),
    );

    _loadItems();
  }

  void _editItem(GroceryItem grocery) async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(grocery),
      ),
    );

    print('opo $newItem');
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.firstWhere((obj) => obj.id == grocery.id,
          orElse: () => newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No item added yet."));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          background: Container(
            color: _groceryItems[index].category.color,
          ),
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (DismissDirection direction) {
            setState(() {
              _groceryItems.removeAt(index);
            });
          },
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            title: Text(_groceryItems[index].name),
            trailing: Text(_groceryItems[index].quantity.toString()),
            onTap: () {
              _editItem(_groceryItems[index]);
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
