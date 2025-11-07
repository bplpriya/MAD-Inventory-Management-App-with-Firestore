// lib/screens/inventory_home_screen.dart

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import 'add_edit_item_screen.dart';

final FirestoreService _firestoreService = FirestoreService();

class InventoryHomePage extends StatefulWidget {
  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  String? _searchTerm;
  String? _categoryFilter = 'All'; // Default filter value
  final TextEditingController _searchController = TextEditingController();

  // Hardcoded categories for filter chips (you can fetch these dynamically later)
  final List<String> _categories = ['All', 'Electronics', 'Apparel', 'Food', 'Misc'];

  @override
  void initState() {
    super.initState();
    // Listen to search field changes to trigger stream rebuild
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Home Page'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items by name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              ),
              // Filter Chips
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: _categoryFilter == category,
                        onSelected: (bool selected) {
                          setState(() {
                            _categoryFilter = selected ? category : 'All';
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Item>>(
        // PASS THE SEARCH TERM AND FILTER TO THE SERVICE
        stream: _firestoreService.getItemsStream(
          searchTerm: _searchTerm,
          categoryFilter: _categoryFilter,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(child: Text('No matching items found.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              
              // (Keep the existing Dismissible/ListTile code for display/edit/delete)
              return Dismissible(
                key: Key(item.id!),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _firestoreService.deleteItem(item.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Category: ${item.category}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.blueGrey)),
                      Text('\$${item.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditItemScreen(item: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditItemScreen()),
          );
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}