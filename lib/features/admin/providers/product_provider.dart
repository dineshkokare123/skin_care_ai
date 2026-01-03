import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skin_care_ai/features/admin/admin_mock.dart';

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super(AdminConfig.products);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void removeProduct(String name) {
    state = state.where((p) => p.name != name).toList();
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});
