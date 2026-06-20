import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, int>> getUserStats() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        'workouts': 0,
        'calories': 0,
        'duration': 0,
      };
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    int workouts = 0;
    int calories = 0;
    int duration = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      workouts++;
      calories += (data['calories'] ?? 0) as int;
      duration += (data['duration'] ?? 0) as int;
    }

    return {
      'workouts': workouts,
      'calories': calories,
      'duration': duration,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final rawName = (user?.email?.split('@').first ?? 'User')
    .replaceAll('.', ' ')
    .replaceAll('_', ' ');

final userName =
    rawName[0].toUpperCase() +
    rawName.substring(1);

    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: getUserStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      Colors.green.shade100,
                  child: Text(
                    userName.isNotEmpty
                        ? userName[0]
                            .toUpperCase()
                        : "U",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : const Color(
                            0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  user?.email ?? "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),
                const SizedBox(height: 6),

Text(
  "Fitness Enthusiast",
  style: TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.w600,
  ),
),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        stats['workouts']
                            .toString(),
                        "Workouts",
                        Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        stats['calories']
                            .toString(),
                        "Kcal Burned",
                        Icons
                            .local_fire_department,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
  width: double.infinity,
  child: _buildStatCard(
    context,
    "${stats['duration']} min",
    "Total Duration",
    Icons.timer,
  ),
),

                const SizedBox(height: 30),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dark_mode_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "Dark Mode",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: isDarkMode,
                        activeColor:
                            Colors.green,
                        onChanged: (value) {
                          themeProvider
                              .toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth
                        .instance
                        .signOut();
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(
                      color:
                          Colors.redAccent,
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(
                      double.infinity,
                      50,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Colors.redAccent,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.black.withAlpha(10),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}