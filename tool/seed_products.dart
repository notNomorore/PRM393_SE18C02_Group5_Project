import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'package:project_prm/firebase_options.dart';

class SeedProduct {
  final String name;
  final double price;
  final String category;
  final String image;
  final String description;
  final double ratingAvg;
  final int ratingCount;

  const SeedProduct({
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.description,
    required this.ratingAvg,
    required this.ratingCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final products = <SeedProduct>[
    SeedProduct(
      name: 'Apex Laptop 14 Pro',
      price: 1299.0,
      category: 'Laptop',
      image: 'https://picsum.photos/seed/laptop-01/800/600',
      description: 'Slim 14-inch laptop with high performance and long battery.',
      ratingAvg: 4.6,
      ratingCount: 128,
    ),
    SeedProduct(
      name: 'Apex Laptop 16 Studio',
      price: 1799.0,
      category: 'Laptop',
      image: 'https://picsum.photos/seed/laptop-02/800/600',
      description: '16-inch creator laptop with color-accurate display.',
      ratingAvg: 4.7,
      ratingCount: 86,
    ),
    SeedProduct(
      name: 'Nova Phone X',
      price: 899.0,
      category: 'Phone',
      image: 'https://picsum.photos/seed/phone-01/800/600',
      description: 'Flagship phone with premium camera and fast charging.',
      ratingAvg: 4.5,
      ratingCount: 260,
    ),
    SeedProduct(
      name: 'Nova Phone SE',
      price: 499.0,
      category: 'Phone',
      image: 'https://picsum.photos/seed/phone-02/800/600',
      description: 'Compact phone with great performance for daily use.',
      ratingAvg: 4.3,
      ratingCount: 310,
    ),
    SeedProduct(
      name: 'Orbit Wireless Earbuds',
      price: 149.0,
      category: 'Audio',
      image: 'https://picsum.photos/seed/audio-01/800/600',
      description: 'Noise-cancelling earbuds with rich sound.',
      ratingAvg: 4.4,
      ratingCount: 520,
    ),
    SeedProduct(
      name: 'Orbit Over-Ear Max',
      price: 259.0,
      category: 'Audio',
      image: 'https://picsum.photos/seed/audio-02/800/600',
      description: 'Over-ear headphones with deep bass and comfort.',
      ratingAvg: 4.6,
      ratingCount: 210,
    ),
    SeedProduct(
      name: 'Pulse Smartwatch 3',
      price: 249.0,
      category: 'Wearable',
      image: 'https://picsum.photos/seed/wearable-01/800/600',
      description: 'Fitness tracking, sleep monitoring, and GPS.',
      ratingAvg: 4.2,
      ratingCount: 180,
    ),
    SeedProduct(
      name: 'Pulse Band Lite',
      price: 79.0,
      category: 'Wearable',
      image: 'https://picsum.photos/seed/wearable-02/800/600',
      description: 'Affordable band with step and heart tracking.',
      ratingAvg: 4.1,
      ratingCount: 340,
    ),
    SeedProduct(
      name: 'Vision Tablet 11',
      price: 549.0,
      category: 'Tablet',
      image: 'https://picsum.photos/seed/tablet-01/800/600',
      description: '11-inch tablet with stylus support.',
      ratingAvg: 4.4,
      ratingCount: 150,
    ),
    SeedProduct(
      name: 'Vision Tablet Mini',
      price: 399.0,
      category: 'Tablet',
      image: 'https://picsum.photos/seed/tablet-02/800/600',
      description: 'Compact tablet for reading and travel.',
      ratingAvg: 4.2,
      ratingCount: 120,
    ),
    SeedProduct(
      name: 'Zen Mechanical Keyboard',
      price: 129.0,
      category: 'Accessory',
      image: 'https://picsum.photos/seed/accessory-01/800/600',
      description: 'Mechanical keyboard with tactile switches.',
      ratingAvg: 4.7,
      ratingCount: 410,
    ),
    SeedProduct(
      name: 'Zen Wireless Mouse',
      price: 59.0,
      category: 'Accessory',
      image: 'https://picsum.photos/seed/accessory-02/800/600',
      description: 'Ergonomic mouse with long battery life.',
      ratingAvg: 4.3,
      ratingCount: 380,
    ),
    SeedProduct(
      name: 'Aurora 4K Monitor',
      price: 429.0,
      category: 'Monitor',
      image: 'https://picsum.photos/seed/monitor-01/800/600',
      description: '27-inch 4K monitor with HDR support.',
      ratingAvg: 4.5,
      ratingCount: 95,
    ),
    SeedProduct(
      name: 'Aurora UltraWide',
      price: 699.0,
      category: 'Monitor',
      image: 'https://picsum.photos/seed/monitor-02/800/600',
      description: '34-inch ultrawide for multitasking.',
      ratingAvg: 4.6,
      ratingCount: 60,
    ),
    SeedProduct(
      name: 'Photon Mirrorless Camera',
      price: 1099.0,
      category: 'Camera',
      image: 'https://picsum.photos/seed/camera-01/800/600',
      description: 'Mirrorless camera for high-quality photos.',
      ratingAvg: 4.5,
      ratingCount: 70,
    ),
    SeedProduct(
      name: 'Photon Action Cam',
      price: 299.0,
      category: 'Camera',
      image: 'https://picsum.photos/seed/camera-02/800/600',
      description: 'Waterproof action camera with stabilization.',
      ratingAvg: 4.3,
      ratingCount: 140,
    ),
    SeedProduct(
      name: 'Glide Gaming Chair',
      price: 219.0,
      category: 'Gaming',
      image: 'https://picsum.photos/seed/gaming-01/800/600',
      description: 'Comfortable chair with lumbar support.',
      ratingAvg: 4.2,
      ratingCount: 110,
    ),
    SeedProduct(
      name: 'Glide Controller Pro',
      price: 79.0,
      category: 'Gaming',
      image: 'https://picsum.photos/seed/gaming-02/800/600',
      description: 'Wireless controller with customizable buttons.',
      ratingAvg: 4.4,
      ratingCount: 230,
    ),
    SeedProduct(
      name: 'Spark Power Bank 20000',
      price: 49.0,
      category: 'Accessory',
      image: 'https://picsum.photos/seed/accessory-03/800/600',
      description: 'Fast-charging power bank with USB-C.',
      ratingAvg: 4.6,
      ratingCount: 520,
    ),
    SeedProduct(
      name: 'Spark Charger 65W',
      price: 39.0,
      category: 'Accessory',
      image: 'https://picsum.photos/seed/accessory-04/800/600',
      description: 'Compact GaN charger for laptops and phones.',
      ratingAvg: 4.5,
      ratingCount: 300,
    ),
  ];

  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  for (final product in products) {
    final doc = db.collection('products').doc();
    batch.set(doc, product.toMap());
  }

  await batch.commit();
  // ignore: avoid_print
  print('Seeded ${products.length} products');
}
