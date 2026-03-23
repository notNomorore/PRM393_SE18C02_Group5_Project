import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme_controller.dart';
import '../../../models/product_model.dart';
import '../../../repositories/product_repository.dart';
import '../widgets/admin_guard.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ProductRepository _repo = ProductRepository();
  final ImagePicker _picker = ImagePicker();

  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await _repo.getAllProducts();
      setState(() => products = data);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load products')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String?> uploadImage(BuildContext context) async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image selected or permission denied'),
            ),
          );
        }
        return null;
      }

      final bytes = await picked.readAsBytes();
      final contentType = picked.mimeType ?? 'image/jpeg';

      final ref = FirebaseStorage.instance.ref().child(
            'products/${DateTime.now().millisecondsSinceEpoch}_${picked.name}',
          );

      await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Upload failed')),
        );
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      return null;
    }
  }

  Future<void> showProductForm({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    final categoryController =
        TextEditingController(text: product?.category ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');

    String imageUrl = product?.image ?? '';
    bool isUploading = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(product == null ? 'Create Product' : 'Update Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        imageUrl.isEmpty ? 'No image' : 'Image selected',
                      ),
                    ),
                    if (isUploading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    TextButton(
                      onPressed: isUploading
                          ? null
                          : () async {
                              setLocalState(() => isUploading = true);
                              final url = await uploadImage(context);
                              if (!mounted) return;
                              setLocalState(() => isUploading = false);
                              if (url == null) return;
                              setLocalState(() => imageUrl = url);
                            },
                      child: const Text('Upload'),
                    ),
                  ],
                ),
                if (imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text) ?? 0;
    final category = categoryController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || category.isEmpty) return;
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload product image')),
      );
      return;
    }

    try {
      if (product == null) {
        await _repo.createProduct(
          name: name,
          price: price,
          category: category,
          image: imageUrl,
          description: description,
        );
      } else {
        await _repo.updateProduct(
          productId: product.id,
          name: name,
          price: price,
          category: category,
          image: imageUrl,
          description: description,
        );
      }

      await loadProducts();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save product')),
      );
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      await _repo.deleteProduct(product.id);
      await loadProducts();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              onPressed: loadProducts,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: ThemeController.toggle,
              tooltip: Theme.of(context).brightness == Brightness.dark
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showProductForm(),
          child: const Icon(Icons.add),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
                ? const Center(child: Text('No products'))
                : ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            p.image,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(p.name),
                        subtitle: Text('\$${p.price} - ${p.category}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: () => showProductForm(product: p),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => deleteProduct(p),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
