import 'package:flutter/material.dart';
import 'labor_cost_screen.dart';
import 'food_cost_screen.dart';
import 'scheduling_screen.dart';
import 'checklists_screen.dart';
import 'kpi_dashboard_screen.dart';
import 'profit_estimator_screen.dart';
import 'coach_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = <_Feature>[
      _Feature('Labor cost calculator', Icons.point_of_sale,
          (ctx) => const LaborCostScreen()),
      _Feature('Food cost calculator', Icons.restaurant_menu,
          (ctx) => const FoodCostScreen()),
      _Feature('Staff scheduling', Icons.calendar_month,
          (ctx) => const SchedulingScreen()),
      _Feature('Daily shift checklists', Icons.checklist,
          (ctx) => const ChecklistsScreen()),
      _Feature('KPI dashboard', Icons.bar_chart,
          (ctx) => const KpiDashboardScreen()),
      _Feature('Profit estimator', Icons.trending_up,
          (ctx) => const ProfitEstimatorScreen()),
      _Feature('AI coach', Icons.chat_bubble_outline,
          (ctx) => const CoachScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Manager Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          for (final f in features)
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: f.builder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f.icon, size: 32, color: const Color(0xFF152238)),
                      const SizedBox(height: 12),
                      Text(
                        f.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Feature {
  final String title;
  final IconData icon;
  final Widget Function(BuildContext) builder;

  _Feature(this.title, this.icon, this.builder);
}
