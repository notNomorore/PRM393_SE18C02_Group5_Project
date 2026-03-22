import 'package:flutter/material.dart';

import '../../../models/review_model.dart';
import '../../../repositories/admin_review_repository.dart';
import '../widgets/admin_guard.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final AdminReviewRepository _repo = AdminReviewRepository();

  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    setState(() => isLoading = true);
    try {
      final data = await _repo.getRecentReviews();
      setState(() => reviews = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reviews: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ratings'),
          actions: [
            IconButton(
              onPressed: loadReviews,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : reviews.isEmpty
                ? const Center(child: Text('No reviews yet'))
                : ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = reviews[index];
                      return ListTile(
                        leading: const Icon(Icons.star),
                        title: Text('Product: ${r.productId}'),
                        subtitle: Text(
                          'Rating: ${r.rating}  •  User: ${r.userId}\n${r.comment}',
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
