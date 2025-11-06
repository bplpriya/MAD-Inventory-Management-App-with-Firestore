// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  // Collection reference for 'items'
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // CREATE: Add a new item
  Future<void> addItem(Item item) async {
    await _itemsCollection.add(item.toMap());
  }

  // READ: Get a real-time stream of all items
  Stream<List<Item>> getItemsStream() {
    return _itemsCollection
        .orderBy('createdAt', descending: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Use Item.fromMap to convert DocumentSnapshot to Item
        final data = doc.data() as Map<String, dynamic>;
        return Item.fromMap(doc.id, data);
      }).toList();
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
}