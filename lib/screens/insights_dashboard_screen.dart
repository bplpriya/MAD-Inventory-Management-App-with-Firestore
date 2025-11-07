// lib/screens/insights_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

// Instantiate the service for use in this screen
final FirestoreService _firestoreService = FirestoreService();
const int lowStockThreshold = 10; // Define your low stock level

class InsightsDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Dashboard'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Total Unique Items Count ---
            _buildInsightCard(
              context,
              'Total Unique Products',
              // Use the custom builder extension for clean StreamBuilder usage
              _firestoreService.getTotalItemsCount().builder(
                (count) => Text(
                  '$count', 
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.indigo),
                ),
              ),
              Icons.inventory_2,
            ),
            SizedBox(height: 20),

            // --- 2. Breakdown by Category ---
            Text('📈 Products by Category', style: Theme.of(context).textTheme.titleLarge),
            Divider(),
            _buildCategoryBreakdown(context),
            SizedBox(height: 30),
            
            // --- 3. Low Stock Items ---
            Text('🚨 Low Stock Items (Qty <= $lowStockThreshold)', style: Theme.of(context).textTheme.titleLarge),
            Divider(),
            _buildLowStockList(),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent insight cards
  Widget _buildInsightCard(BuildContext context, String title, Widget dataWidget, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo, size: 30),
                SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 10),
            dataWidget,
          ],
        ),
      ),
    );
  }

  // Widget to display category counts in a wrap/list
  Widget _buildCategoryBreakdown(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: _firestoreService.getCategoryCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Text('Error loading categories: ${snapshot.error}');
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Text('No categories found.');
        
        final categoryCounts = snapshot.data!;
        
        // Display counts using Wrap for flexible layout
        return Wrap(
          spacing: 8.0, 
          runSpacing: 8.0, 
          children: categoryCounts.entries.map((entry) {
            return Chip(
              label: Text('${entry.key}: ${entry.value}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blueAccent.shade400,
            );
          }).toList(),
        );
      },
    );
  }

  // Widget to display low stock items
  Widget _buildLowStockList() {
    return StreamBuilder<List<Item>>(
      stream: _firestoreService.getLowStockItems(lowStockThreshold),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Text('Error loading low stock items.');
        
        final lowStockItems = snapshot.data ?? [];
        if (lowStockItems.isEmpty) return Text('All stock levels look good!');

        // Use a ListView within a SingleChildScrollView, wrapped in NeverScrollableScrollPhysics
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: lowStockItems.length,
          itemBuilder: (context, index) {
            final item = lowStockItems[index];
            return ListTile(
              leading: Icon(Icons.warning, color: Colors.redAccent),
              title: Text(item.name),
              subtitle: Text('Category: ${item.category}'),
              trailing: Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

// Extension to simplify StreamBuilder usage for single-data streams (used for Total Count)
extension StreamBuilderExtension<T> on Stream<T> {
  Widget builder(Widget Function(T data) successWidget, {Widget? loadingWidget, Widget? errorWidget}) {
    return StreamBuilder<T>(
      stream: this,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return errorWidget ?? Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          return successWidget(snapshot.data as T);
        }
        return const SizedBox.shrink();
      },
    );
  }
}