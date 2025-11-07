// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// THIS IS NOW UNCOMMENTED AND IN USE
import 'firebase_options.dart'; 
import 'screens/inventory_home_screen.dart';

void main() async {
  // Ensures Flutter is initialized before calling platform services like Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 THIS IS NOW UNCOMMENTED AND ACTIVE!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // DELETE any temporary placeholder lines (like await Future.value();)

  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InventoryHomePage(),
    );
  }
}