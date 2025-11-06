// lib/models/item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String? id; // Set by Firestore
  final String name;
  final int quantity;
  final double price;
  final String category;
  final DateTime createdAt;

  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.createdAt,
  });

  // Converts Item object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
    };
  }

  // Factory constructor to create an Item object from a Firestore document
  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Uncategorized',
      createdAt: (map['createdAt'] as Timestamp).toDate(), // Convert Timestamp back to DateTime
    );
  }

  // Helper method for easy copying (useful for updates)
  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    double? price,
    String? category,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}