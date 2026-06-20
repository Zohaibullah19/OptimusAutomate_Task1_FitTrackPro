import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';


class WorkoutChartScreen extends StatelessWidget {
  const WorkoutChartScreen({super.key});

  // Queries historical entries sorted chronologically, limited to a readable dataset
  Future<List<Map<String, dynamic>>> getWorkoutAnalyticsData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
    .collection('workouts')
    .where(
      'userId',
      isEqualTo: user.uid,
    )
    .orderBy(
      'createdAt',
      descending: true,
    )
    .limit(7)
    .get();

    // Reverse the list so it displays from oldest to newest (left to right)
    final docs = snapshot.docs.toList();
    List<Map<String, dynamic>> analyticalPoints = [];

    for (var doc in docs.reversed) {
      final data = doc.data();
      analyticalPoints.add({
        'calories': (data['calories'] ?? 0).toDouble(),
        'exercise': data['exercise'] ?? 'Workout',
      });
    }

    return analyticalPoints;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium UI Theme Color Mapping
    final Color brandColor = const Color(0xFF10B981); // Emerald Green
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
     appBar: AppBar(
  elevation: 0,
  backgroundColor: cardColor,
  surfaceTintColor: Colors.transparent,
  title: Text(
    "Performance Insights",
    style: TextStyle(
      color: textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
  ),
  leading: IconButton(
  icon: Icon(
    Icons.arrow_back_ios_new_rounded,
    color: textPrimary,
    size: 18,
  ),
  onPressed: () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  },
),
),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getWorkoutAnalyticsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: brandColor, strokeWidth: 3));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Database Synchronization Error: ${snapshot.error}",
                style: TextStyle(color: textSecondary),
              ),
            );
          }

          final analyticsData = snapshot.data ?? [];
          
          // Calculate cumulative values
          double totalCalories = 0;
          for (var item in analyticsData) {
            totalCalories += item['calories'];
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800), // Perfect desktop layout constraint
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Metadata Blocks
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: "Energy Expended",
                            value: "${totalCalories.toInt()} kcal",
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.orangeAccent,
                            cardColor: cardColor,
                            titleStyle: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                            valueStyle: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard(
                            title: "Tracked Sessions",
                            value: "${analyticsData.length} entries",
                            icon: Icons.fitness_center_rounded,
                            iconColor: brandColor,
                            cardColor: cardColor,
                            titleStyle: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                            valueStyle: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Analytical Bar Chart Module
                    Text(
                      "Caloric Output Curve (Last 7 Sessions)",
                      style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 380,
                      padding: const EdgeInsets.only(top: 36, bottom: 16, right: 24, left: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withAlpha(5)),
                      ),
                      child: analyticsData.isEmpty
                          ? Center(child: Text("No tracking history found.", style: TextStyle(color: textSecondary)))
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: analyticsData.isEmpty 
                                    ? 100.0 
                                    : (analyticsData.map((e) => e['calories'] as double).reduce((a, b) => a > b ? a : b) * 1.25).clamp(100, double.infinity),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) => isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
                                    tooltipRoundedRadius: 8,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        "${analyticsData[groupIndex]['exercise']}\n${rod.toY.toInt()} kcal",
                                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          "${value.toInt()}",
                                          style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 && index < analyticsData.length) {
                                          String label = analyticsData[index]['exercise'];
                                          if (label.length > 6) label = "${label.substring(0, 5)}..";
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            key: ValueKey(index),
                                            child: Text(
                                              label,
                                              style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: isDark ? Colors.white10 : Colors.black.withAlpha(5),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: analyticsData.asMap().entries.map((entry) {
                                  return BarChartGroupData(
                                    x: entry.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value['calories'],
                                        width: 22,
                                        color: brandColor,
                                        gradient: LinearGradient(
                                          colors: [brandColor, brandColor.withAlpha(160)],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 4),
                Text(value, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}