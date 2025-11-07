// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // --- CORE CRUD OPERATIONS (UNCHANGED) ---

  // CREATE: Add a new item
  Future<void> addItem(Item item) async {
    await _itemsCollection.add(item.toMap());
  }

  // READ: Get a real-time stream of all items with search/filter logic
  Stream<List<Item>> getItemsStream({
    String? searchTerm,
    String? categoryFilter,
  }) {
    // Start with the base query
    Query query = _itemsCollection.orderBy('createdAt', descending: true);

    // 1. Apply Category Filter (Firestore query)
    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'All') {
      // Filter by category
      query = query.where('category', isEqualTo: categoryFilter);
    }

    return query.snapshots().map((snapshot) {
      // Convert documents to Item list
      final allItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item.fromMap(doc.id, data);
      }).toList();

      // 2. Apply Client-Side Search Term Filter (by item name)
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final lowerCaseSearch = searchTerm.toLowerCase();
        return allItems.where((item) {
          return item.name.toLowerCase().contains(lowerCaseSearch);
        }).toList();
      }

      // Return the full or category-filtered list
      return allItems;
    });
  }

  // UPDATE: Update an existing item
  Future<void> updateItem(Item item) async {
    if (item.id == null) {
      throw Exception("Item ID must not be null for update operation.");
    }
    await _itemsCollection.doc(item.id).update(item.toMap());
  }

  // DELETE: Delete an item by its ID
  Future<void> deleteItem(String itemId) async {
    await _itemsCollection.doc(itemId).delete();
  }

  // --- ENHANCED FEATURE 2: DATA INSIGHTS METHODS (NEW) ---

  // 1. Get total number of unique items
  Stream<int> getTotalItemsCount() {
    return _itemsCollection.snapshots().map((snapshot) {
      return snapshot.size; // Returns the count of documents in the collection
    });
  }

  // 2. Get counts for each category
  Stream<Map<String, int>> getCategoryCounts() {
    return _itemsCollection.snapshots().map((snapshot) {
      final Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String? ?? 'Uncategorized';
        counts.update(category, (value) => value + 1, ifAbsent: () => 1);
      }
      return counts;
    });
  }

  // 3. Get total count and list of items below a certain stock level
  Stream<List<Item>> getLowStockItems(int threshold) {
    // Query Firestore for items where quantity is less than or equal to the threshold
    return _itemsCollection
        .where('quantity', isLessThanOrEqualTo: threshold)
        .orderBy('quantity') // Order by quantity to show lowest first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item.fromMap(doc.id, data);
      }).toList();
    });
  }
}