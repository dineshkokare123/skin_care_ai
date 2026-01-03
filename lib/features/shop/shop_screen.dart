import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import 'package:skin_care_ai/features/admin/admin_mock.dart';
import 'package:skin_care_ai/features/admin/providers/product_provider.dart';
import 'widgets/payment_sheet.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Products"),
      ),
      body: products.isEmpty
          ? const Center(child: Text("No products available."))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: AppTheme.secondary.withOpacity(0.3),
                  child: Icon(
                    _getCategoryIcon(product.category), 
                    color: AppTheme.primary, 
                    size: 40
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showQuickPayment(context, product),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    category = category.toLowerCase();
    if (category.contains('serum')) return Icons.water_drop_outlined;
    if (category.contains('cleanser')) return Icons.face_outlined;
    if (category.contains('oil')) return Icons.opacity_outlined;
    return Icons.shopping_bag_outlined;
  }

  void _showQuickPayment(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentSheet(
        productName: product.name,
        price: product.price,
        onPaymentSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Order confirmed! ${product.name} will be delivered soon."),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
