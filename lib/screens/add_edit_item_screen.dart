// lib/screens/add_edit_item_screen.dart

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

final FirestoreService _firestoreService = FirestoreService();

class AddEditItemScreen extends StatefulWidget {
  final Item? item; // Optional item parameter for editing

  AddEditItemScreen({this.item});

  @override
  _AddEditItemScreenState createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data if editing
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final category = _categoryController.text;

      final newItem = Item(
        name: name,
        quantity: quantity,
        price: price,
        category: category,
        // Use existing creation date for updates, otherwise use now for new items
        createdAt: widget.item?.createdAt ?? DateTime.now(), 
        id: widget.item?.id, // Keep existing ID for update
      );

      try {
        if (widget.item == null) {
          // CREATE new item
          await _firestoreService.addItem(newItem);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item added!')));
        } else {
          // UPDATE existing item
          await _firestoreService.updateItem(newItem);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item updated!')));
        }
        Navigator.pop(context); // Go back to the home screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save item: $e')));
      }
    }
  }

  void _deleteItem() async {
    if (widget.item?.id != null) {
      await _firestoreService.deleteItem(widget.item!.id!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.item!.name} deleted!')));
      Navigator.pop(context); // Go back to the home screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Item' : 'Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: 'Item Name',
                validator: (value) => value!.isEmpty ? 'Enter item name' : null,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _quantityController,
                label: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty || int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _priceController,
                label: 'Price (\$)',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _categoryController,
                label: 'Category',
                validator: (value) => value!.isEmpty ? 'Enter a category' : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveItem,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(isEditing ? 'Update Item' : 'Add Item', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (isEditing) ...[
                SizedBox(height: 16),
                // Delete button (DELETE operation)
                TextButton(
                  onPressed: _deleteItem,
                  child: Text('Delete Item', style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper for consistent TextFormField styling
  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}