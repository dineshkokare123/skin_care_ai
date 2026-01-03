class RoutineStep {
  final String stepName;
  final String productName;
  final String productCategory;
  final String? imageUrl;
  final String? affiliateUrl;

  RoutineStep({
    required this.stepName,
    required this.productName,
    required this.productCategory,
    this.imageUrl,
    this.affiliateUrl,
  });
}

class Routine {
  final List<RoutineStep> morningSteps;
  final List<RoutineStep> eveningSteps;

  Routine({required this.morningSteps, required this.eveningSteps});
}
