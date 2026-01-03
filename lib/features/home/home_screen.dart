import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import 'package:skin_care_ai/features/admin/admin_mock.dart';
import 'package:go_router/go_router.dart';
import 'package:skin_care_ai/features/auth/providers/auth_provider.dart';
import 'package:skin_care_ai/features/home/providers/blog_provider.dart';
import 'package:skin_care_ai/features/admin/providers/product_provider.dart';
import '../shop/widgets/payment_sheet.dart';
import '../routine/providers/routine_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogProvider);
    final routine = ref.watch(routineProvider).routine;

    return Scaffold(
      appBar: AppBar(
        title: Text("SkinCare AI", style: AppTheme.lightTheme.textTheme.displayMedium),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting / Quiz Prompt
          _buildQuizPrompt(context, ref),
          const SizedBox(height: 24),

          // NEW: Routine Preview
          _buildRoutinePreview(context, routine),
          const SizedBox(height: 32),

          // NEW: Specialist Booking
          _buildSpecialistSection(context),
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Member Products", style: AppTheme.lightTheme.textTheme.displayMedium),
              TextButton(onPressed: () => context.push('/shop'), child: const Text("View All")),
            ],
          ),
          const SizedBox(height: 12),
          _buildProductGrid(ref),
          
          const SizedBox(height: 32),
          Text("Latest Insights", style: AppTheme.lightTheme.textTheme.displayMedium),
          const SizedBox(height: 12),
          
          blogsAsync.when(
            data: (List<BlogPost> blogs) => Column(
              children: blogs.map((post) => _buildBlogCard(context, post)).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Fresh insights coming soon!"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinePreview(BuildContext context, dynamic routine) {
    final hour = DateTime.now().hour;
    final isMorning = hour < 17 && hour > 4;
    final steps = isMorning ? routine.morningSteps : routine.eveningSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Your ${isMorning ? 'AM' : 'PM'} Routine", style: AppTheme.lightTheme.textTheme.displayMedium),
            TextButton(
              onPressed: () => context.go('/routine'),
              child: const Text("Full Routine"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(step.stepName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                    const SizedBox(height: 4),
                    Text(step.productName, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialistSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Confused about your skin?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                const Text("Book a 1:1 consultation with our top dermatologists.", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                  ),
                  child: const Text("Book Appointment"),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.medical_services_outlined, color: Colors.white70, size: 60),
        ],
      ),
    );
  }

  Widget _buildProductGrid(WidgetRef ref) {
    final products = ref.watch(productProvider);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length > 4 ? 4 : products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
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

  Widget _buildQuizPrompt(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final name = user?.name.split(' ').first ?? 'Friend';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hi $name, Discover Your Skin Profile", style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          const Text("Get a personalized routine tailored to your skin type and concerns."),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/quiz'),
            child: const Text("Start Skin Quiz"),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, BlogPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/blog', extra: post),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.secondary.withOpacity(0.4), AppTheme.primary.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(Icons.article_outlined, size: 48, color: AppTheme.primary.withOpacity(0.5)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: AppTheme.lightTheme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(post.summary, style: AppTheme.lightTheme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
