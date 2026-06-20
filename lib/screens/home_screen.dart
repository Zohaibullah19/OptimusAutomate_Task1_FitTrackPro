import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 

import '../services/auth_service.dart';
import '../services/dashboard_service.dart';

import 'login_screen.dart';
import 'add_workout_screen.dart';
import 'workout_history_screen.dart';
import 'workout_chart_screen.dart';
import 'goal_tracker_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final DashboardService _dashboardService = DashboardService();

  // BMI Controller Fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _calculatedBmi;
  String _bmiResultCategory = "";
  Color _bmiCategoryColor = _textSecondary;

  // Clean, Minimal Premium UI Colors
  static const Color _brandColor = Color(0xFF10B981); // Emerald Green
  static const Color _brandGradientEnd = Color(0xFF059669); 
  static const Color _bgColor = Color(0xFFF8FAFC);    // Cool Light Gray
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color _textSecondary = Color(0xFF64748B); // Slate 500

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String _getMotivationalMessage(double percent) {
    if (percent <= 0.0) return "Ready to start your day? 💪";
    if (percent <= 0.25) return "Let's get started!";
    if (percent <= 0.50) return "Keep moving!";
    if (percent <= 0.75) return "Great progress!";
    if (percent < 1.0) return "Goal almost achieved!";
    return "Goal completed! 🎉";
  }

  String _formatWorkoutDate(dynamic createdAt) {
    if (createdAt == null) return "Today";
    
    DateTime dateTime;
    if (createdAt is Timestamp) {
      dateTime = createdAt.toDate();
    } else if (createdAt is String) {
      dateTime = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else {
      return "Today";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (itemDate == today) {
      return "Today • ${DateFormat('hh:mm a').format(dateTime)}";
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday • ${DateFormat('hh:mm a').format(dateTime)}";
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  void _calculateBMIValue() {
    final double? weight = double.tryParse(_weightController.text);
    final double? heightInCm = double.tryParse(_heightController.text);

    if (weight == null || heightInCm == null || heightInCm <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please inputs valid metric parameters."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final double heightInMeters = heightInCm / 100;
    final double bmiValue = weight / (heightInMeters * heightInMeters);

    setState(() {
      _calculatedBmi = bmiValue;
      if (_calculatedBmi! < 18.5) {
        _bmiResultCategory = "Underweight";
        _bmiCategoryColor = Colors.orange;
      } else if (_calculatedBmi! >= 18.5 && _calculatedBmi! < 25.0) {
        _bmiResultCategory = "Normal Weight (Healthy)";
        _bmiCategoryColor = _brandColor;
      } else if (_calculatedBmi! >= 25.0 && _calculatedBmi! < 30.0) {
        _bmiResultCategory = "Overweight";
        _bmiCategoryColor = Colors.deepOrangeAccent;
      } else {
        _bmiResultCategory = "Obese Class Variant";
        _bmiCategoryColor = Colors.redAccent;
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget nextScreen;
    switch (index) {
      case 1:
        nextScreen = const WorkoutHistoryScreen();
        break;
      case 2:
        nextScreen = const WorkoutChartScreen();
        break;
      case 3:
        nextScreen = const GoalTrackerScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 768;

    final String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final String formattedDay = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_brandColor, _brandGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$formattedDate • $formattedDay', 
                  style: const TextStyle(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'FitTrack Pro',
                  style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.6),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(15), 
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await AuthService().logout();
                if (!navigator.mounted) return;
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dashboardService.getUserWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _brandColor));
          }

          int totalCalories = 0;
          int totalDuration = 0;
          int totalWorkouts = 0;
          List<Map<String, dynamic>> recentWorkouts = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              totalCalories += (data['calories'] ?? 0) as int;
              totalDuration += (data['duration'] ?? 0) as int;
              totalWorkouts++;
              recentWorkouts.add(data);
            }
          }

          double dailyGoalMinutes = 60.0; 
          double progressMultiplier = totalDuration / dailyGoalMinutes;
          double goalPercent = progressMultiplier > 1.0 ? 1.0 : progressMultiplier;

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDynamicProgressBanner(goalPercent, totalDuration, dailyGoalMinutes.toInt()),
                    const SizedBox(height: 30),
                    
                    const Text(
                      "Today's Performance Metrics",
                      style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 16),

                    if (totalWorkouts == 0) ...[
                      _buildEmptyState(context),
                      const SizedBox(height: 30),
                      _buildBMICalculatorCard(),
                    ] else ...[
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isWideScreen ? 4 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isWideScreen ? 1.2 : 1.35,
                        children: [
                          _buildMetricCard("Workouts Logged", "$totalWorkouts", Icons.bolt_rounded, Colors.amber),
                          _buildMetricCard("Energy Burned", "$totalCalories / 1000 kcal", Icons.local_fire_department_rounded, Colors.orange),
                          _buildMetricCard("Active Time", "$totalDuration min", Icons.timer_rounded, Colors.lightBlue),
                          _buildMetricCard("Estimated Steps", "${totalWorkouts * 1500} Steps", Icons.directions_run_rounded, Colors.indigo),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildBMICalculatorCard(),
                      const SizedBox(height: 32),
                      _buildRecentActivitySection(recentWorkouts),
                    ],
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _brandColor,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text("Log Workout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 15, offset: const Offset(0, -4)),
          ],
        ),
        child: Center(
          heightFactor: 1.0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: _brandColor,
              unselectedItemColor: _textSecondary.withAlpha(150),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              elevation: 0,
              onTap: _onTabTapped, 
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_rounded), label: "Dashboard"),
                BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: "History"),
                BottomNavigationBarItem(icon: Icon(Icons.insert_chart_rounded), label: "Analytics"),
                BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: "Goals"),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicProgressBanner(double percent, int minutes, int target) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_brandColor, _brandGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _brandColor.withAlpha(64), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DAILY GOAL PROGRESS",
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 6),
                Text(
                  _getMotivationalMessage(percent),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "$minutes / $target min tracked today",
                  style: TextStyle(color: Colors.white.withAlpha(215), fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 7,
                  backgroundColor: Colors.white.withAlpha(50),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(percent * 100).toInt()}%",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    percent >= 1.0 ? "Done" : "Achieved",
                    style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBMICalculatorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withAlpha(6), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.scale_rounded, color: Colors.blueAccent, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Body Mass Index (BMI) Calculator",
                style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Weight (kg)",
                    labelStyle: const TextStyle(fontSize: 13, color: _textSecondary),
                    filled: true,
                    fillColor: _bgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Height (cm)",
                    labelStyle: const TextStyle(fontSize: 13, color: _textSecondary),
                    filled: true,
                    fillColor: _bgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _calculateBMIValue,
                child: const Text("Calc", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_calculatedBmi != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bmiCategoryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _bmiCategoryColor.withAlpha(30), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Calculated Result Index", style: TextStyle(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(_bmiResultCategory, style: TextStyle(color: _bmiCategoryColor, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    _calculatedBmi!.toStringAsFixed(1),
                    style: TextStyle(color: _bmiCategoryColor, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(6), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(List<Map<String, dynamic>> workouts) {
    final recent = workouts.take(3).toList(); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.4),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withAlpha(6), width: 1.5),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
            itemBuilder: (context, index) {
              final item = recent[index];
              final exerciseName = item['exerciseName'] ?? item['name'] ?? item['type'] ?? 'Workout';
              final duration = item['duration'] ?? 0;
              final calories = item['calories'] ?? 0;
              final timestampString = _formatWorkoutDate(item['createdAt']);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _brandColor.withAlpha(20), shape: BoxShape.circle),
                  child: const Icon(Icons.fitness_center_rounded, color: _brandColor, size: 20),
                ),
                title: Text(exerciseName, style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("⏱️ $duration min  •  🔥 $calories kcal", style: const TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 2),
                      Text(timestampString, style: TextStyle(color: _textSecondary.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withAlpha(5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
            child: Icon(Icons.emoji_events_outlined, color: Colors.blueGrey.shade200, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            "No workouts yet",
            style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Start your fitness journey today!",
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text("Log First Workout", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
              );
            },
          )
        ],
      ),
    );
  }
}