import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine_model.dart';
import 'package:skin_care_ai/features/admin/providers/product_provider.dart';
import 'package:skin_care_ai/features/admin/admin_mock.dart';

class RoutineState {
  final Routine routine;
  final bool isLoading;

  RoutineState({required this.routine, this.isLoading = false});

  RoutineState copyWith({Routine? routine, bool? isLoading}) {
    return RoutineState(
      routine: routine ?? this.routine,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RoutineNotifier extends StateNotifier<RoutineState> {
  final List<Product> availableProducts;
  
  RoutineNotifier(this.availableProducts) : super(RoutineState(routine: _initialRoutine()));

  static Routine _initialRoutine() {
    // Default / "Static" looking routine initially
    return Routine(
      morningSteps: [
        RoutineStep(
            stepName: "Cleanser",
            productName: "Gentle Hydrating Cleanser",
            productCategory: "Cleanser"),
        RoutineStep(
            stepName: "Sunscreen",
            productName: "Daily SPF 50",
            productCategory: "Sunscreen"),
      ],
      eveningSteps: [
         RoutineStep(
            stepName: "Cleanser",
            productName: "Gentle Hydrating Cleanser",
            productCategory: "Cleanser"),
         RoutineStep(
            stepName: "Moisturizer",
            productName: "Hyaluronic Acid Moisturizer",
            productCategory: "Moisturizer"),
      ],
    );
  }

  Future<void> generateRoutine(String skinType, String concern) async {
    // Set loading state
    state = state.copyWith(isLoading: true);
    
    // Simulate AI thinking
    await Future.delayed(const Duration(seconds: 2));

    final am = <RoutineStep>[];
    final pm = <RoutineStep>[];

    // Base Steps
    am.add(_findProductForStep("Cleanser", "Cleanser"));
    pm.add(_findProductForStep("Cleanser", "Double Cleanse"));

    // Concern specific
    if (concern.contains("Acne")) {
      am.add(_findProductForStep("Treatment", "Vitamin C Serum"));
      pm.add(_findProductForStep("Treatment", "Retinol/Treatment")); 
    } else if (concern.contains("Aging")) {
      am.add(_findProductForStep("Antioxidant", "Vitamin C Serum"));
      pm.add(_findProductForStep("Retinol", "Night Repair Retinol"));
    }

    // Finishers
    am.add(_findProductForStep("Moisturizer", "Moisturizer"));
    am.add(_findProductForStep("Sunscreen", "Sunscreen"));
    
    pm.add(_findProductForStep("Moisturizer", "Moisturizer"));

    final newRoutine = Routine(morningSteps: am, eveningSteps: pm);
    
    // Update with new routine and clear loading
    state = RoutineState(routine: newRoutine, isLoading: false);
  }

  RoutineStep _findProductForStep(String stepName, String categoryOrName) {
    final product = availableProducts.firstWhere(
      (p) => p.category.contains(categoryOrName) || p.name.contains(categoryOrName),
      orElse: () => availableProducts.first,
    );
    return RoutineStep(
      stepName: stepName,
      productName: product.name,
      productCategory: product.category,
      imageUrl: product.imageUrl,
      affiliateUrl: product.affiliateUrl,
    );
  }
}

final routineProvider = StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
  final products = ref.watch(productProvider);
  return RoutineNotifier(products);
});
