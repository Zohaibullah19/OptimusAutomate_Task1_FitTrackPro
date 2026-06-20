import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalTrackerScreen extends StatelessWidget {
  const GoalTrackerScreen({super.key});

  // Premium Theme Specs
  static const Color _brandColor = Color(0xFF10B981);      // Emerald Green
  static const Color _brandGradientEnd = Color(0xFF059669); 
  static const Color _bgColor = Color(0xFFF8FAFC);          // Cool Slate White
  static const Color _textPrimary = Color(0xFF0F172A);      // Slate 900
  static const Color _textSecondary = Color(0xFF64748B);    // Slate 500
  static const Color _orangeAccent = Color(0xFFF97316);     // Premium Goal Orange

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Premium Empty / Unauthenticated View
    if (user == null) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Text(
            "Please sign in to view tracking parameters.",
            style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Performance Goals",
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Real-time reactive mapping updates for tracking
        stream: FirebaseFirestore.instance
            .collection('workouts')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error fetching metrics collection profile data."),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(_brandColor),
              ),
            );
          }

          int calories = 0;
          int duration = 0;

          // Process underlying aggregates safely
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              calories += (data['calories'] ?? 0) as int;
              duration += (data['duration'] ?? 0) as int;
            }
          }

          // Compute targets mapping ratio parameters
          double calorieProgress = calories / 1000;
          double durationProgress = duration / 60;

          // Clamp values safely inside mathematical domain guidelines [0.0, 1.0]
          if (calorieProgress > 1.0) calorieProgress = 1.0;
          if (durationProgress > 1.0) durationProgress = 1.0;

          // Overall metric calculation
          int overallCompletion = ((calorieProgress + durationProgress) / 2 * 100).toInt();

          return SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 650),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Progress Header Summary Card
                      _buildSummaryHeaderCard(overallCompletion),
                      const SizedBox(height: 32),

                      const Text(
                        "METRICS TRACKING ENGINE",
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Calories Progress Structure Block
                      _buildMetricCard(
                        title: "Daily Calories Target",
                        currentValue: calories,
                        targetValue: 1000,
                        unit: "kcal",
                        progress: calorieProgress,
                        progressColor: _orangeAccent,
                        icon: Icons.local_fire_department_rounded,
                      ),
                      const SizedBox(height: 18),

                      // Duration Progress Structure Block
                      _buildMetricCard(
                        title: "Workout Duration Target",
                        currentValue: duration,
                        targetValue: 60,
                        unit: "min",
                        progress: durationProgress,
                        progressColor: _brandColor,
                        icon: Icons.timer_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeaderCard(int overallCompletion) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_brandColor, _brandGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _brandColor.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Great progress!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  overallCompletion >= 100 
                      ? "All performance metrics achieved today." 
                      : "Keep pushing to complete your parameters.",
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 74,
                width: 74,
                child: CircularProgressIndicator(
                  value: overallCompletion / 100,
                  strokeWidth: 7,
                  backgroundColor: Colors.white.withAlpha(40),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                "$overallCompletion%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int currentValue,
    required int targetValue,
    required String unit,
    required double progress,
    required Color progressColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: progressColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: progressColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  text: "$currentValue ",
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: "/ $targetValue $unit",
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Color(0xFFF1F5F9), // Slate 100 track fill
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}