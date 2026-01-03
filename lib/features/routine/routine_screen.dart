import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skin_care_ai/core/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers/routine_provider.dart';
import 'models/routine_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("My Routine"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.event),
                  tooltip: "Add to Calendar",
                  onPressed: () => _addToCalendar(context),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: "Regenerate Routine",
                  onPressed: routineState.isLoading
                      ? null
                      : () {
                          ref.read(routineProvider.notifier).generateRoutine("Oily", "Acne & Breakouts");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                  SizedBox(width: 12),
                                  Text("Generating personalized routine..."),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                )
              ],
            ),
            body: Column(
              children: [
                // Custom Tab Bar styling
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: AppTheme.primary,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textDark,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      tabs: const [
                        Tab(text: "Morning (AM)"),
                        Tab(text: "Evening (PM)"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildRoutineList(context, routineState.routine.morningSteps),
                      _buildRoutineList(context, routineState.routine.eveningSteps),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (routineState.isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          "Creating your custom routine...",
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Analyzing your skin needs",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addToCalendar(BuildContext context) async {
    // Generate a Google Calendar Template URL
    // Format: https://www.google.com/calendar/render?action=TEMPLATE&text=Your+Event+Name&details=Event+Details&dates=YYYYMMDDTHHMMSSZ/YYYYMMDDTHHMMSSZ
    
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 8, 0).toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';
    final endTime = DateTime(now.year, now.month, now.day, 8, 30).toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';

    final url = "https://www.google.com/calendar/render?action=TEMPLATE"
        "&text=Morning+Skincare+Routine"
        "&details=Time+to+glow!+Complete+your+personalized+morning+routine+from+SkinCare+AI."
        "&dates=$startTime/$endTime"
        "&recur=RRULE:FREQ=DAILY";

    _launchURL(url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google Calendar template opened!")),
    );
  }

  Widget _buildRoutineList(BuildContext context, List<RoutineStep> steps) {
    if (steps.isEmpty) return const Center(child: Text("No routine generated yet."));

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildStepCard(context, index + 1, steps[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, int stepNum, RoutineStep step) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.secondary,
              child: Text("$stepNum"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.stepName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Recommended: ${step.productName}", style: const TextStyle(color: Colors.grey)),
                  
                ],
              ),
            ),
            if (step.affiliateUrl != null)
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.accent),
                onPressed: () => _launchURL(step.affiliateUrl!),
              )
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
