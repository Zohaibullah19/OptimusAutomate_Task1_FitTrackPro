import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/dashboard_service.dart';
import 'edit_workout_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState
    extends State<WorkoutHistoryScreen> {
  final DashboardService _dashboardService =
      DashboardService();

  static const Color _brandColor =
      Color(0xFF10B981);

  static const Color _bgColor =
      Color(0xFFF8FAFC);

  static const Color _cardColor =
      Colors.white;

  static const Color _textPrimary =
      Color(0xFF0F172A);

  static const Color _textSecondary =
      Color(0xFF64748B);

  String formatDate(dynamic createdAt) {
    if (createdAt == null) {
      return "Today";
    }

    DateTime dateTime;

    if (createdAt is Timestamp) {
      dateTime = createdAt.toDate();
    } else if (createdAt is String) {
      dateTime =
          DateTime.tryParse(createdAt) ??
              DateTime.now();
    } else {
      return "Today";
    }

    return DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(dateTime);
  }

  IconData getWorkoutIcon(
    String exercise,
  ) {
    final name =
        exercise.toLowerCase();

    if (name.contains("run")) {
      return Icons.directions_run_rounded;
    }

    if (name.contains("walk")) {
      return Icons.directions_walk_rounded;
    }

    if (name.contains("cycle")) {
      return Icons.directions_bike_rounded;
    }

    if (name.contains("push")) {
      return Icons.fitness_center_rounded;
    }

    return Icons.fitness_center_rounded;
  }

  Color getWorkoutColor(
    String exercise,
  ) {
    final name =
        exercise.toLowerCase();

    if (name.contains("run")) {
      return Colors.green;
    }

    if (name.contains("walk")) {
      return Colors.blue;
    }

    if (name.contains("cycle")) {
      return Colors.orange;
    }

    return _brandColor;
  }

  void deleteWorkout(
    String docId,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          "Workout deleted",
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  void _editWorkout(
  String documentId,
  Map<String, dynamic> data,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditWorkoutScreen(
        documentId: documentId,
        exercise: data['exercise'] ?? '',
        duration: data['duration'] ?? 0,
        calories: data['calories'] ?? 0,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        surfaceTintColor:
    Colors.transparent,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Workout History",
          style: TextStyle(
            color: _textPrimary,
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot>(
        stream: _dashboardService
            .getUserWorkouts(),

        builder:
            (context, snapshot) {
          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: _brandColor,
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs
                  .isEmpty) {
            return _buildEmptyState();
          }

          final docs =
              snapshot.data!.docs;

          int totalCalories = 0;
          int totalDuration = 0;

          for (var doc in docs) {
            final data =
                doc.data()
                    as Map<String,
                        dynamic>;

            totalCalories +=
                (data['calories'] ??
                        0)
                    as int;

            totalDuration +=
                (data['duration'] ??
                        0)
                    as int;
          }

          return Center(
            child: Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 900,
              ),

              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                        20),

                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
                              20),

                      decoration:
                          BoxDecoration(
                        color:
                            _cardColor,

                        borderRadius:
                            BorderRadius.circular(
                                24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withAlpha(
                                    10),
                            blurRadius:
                                12,
                            offset:
                                const Offset(
                                    0,
                                    4),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                        children: [
                          _summaryItem(
                            Icons
                                .fitness_center_rounded,
                            docs.length
                                .toString(),
                            "Workouts",
                            Colors.orange,
                          ),

                          _summaryItem(
                            Icons
                                .local_fire_department_rounded,
                            "$totalCalories",
                            "Calories",
                            Colors.red,
                          ),

                          _summaryItem(
                            Icons
                                .timer_rounded,
                            "$totalDuration",
                            "Minutes",
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 24),

                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          docs.length,

                      itemBuilder:
                          (context,
                              index) {
                        final doc =
                            docs[index];

                        final data =
                            doc.data()
                                as Map<
                                    String,
                                    dynamic>;

                        final exercise =
                            data['exercise'] ??
                                "Workout";

                        final duration =
                            data['duration'] ??
                                0;

                        final calories =
                            data['calories'] ??
                                0;

                        final color =
                            getWorkoutColor(
                                exercise);

                        return Dismissible(
                          key: Key(
                              doc.id),

                          direction:
                              DismissDirection
                                  .endToStart,

                          background:
                              Container(
                            margin:
                                const EdgeInsets.only(
                                    bottom:
                                        16),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.red,
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),

                            alignment:
                                Alignment
                                    .centerRight,

                            padding:
                                const EdgeInsets.only(
                                    right:
                                        25),

                            child:
                                const Icon(
                              Icons.delete,
                              color: Colors
                                  .white,
                            ),
                          ),

                          child:
                              Container(
                            margin:
                                const EdgeInsets.only(
                                    bottom:
                                        16),

                            padding:
                                const EdgeInsets.all(
                                    18),

                            decoration:
                                BoxDecoration(
                              color:
                                  _cardColor,

                              borderRadius:
                                  BorderRadius.circular(
                                      22),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withAlpha(
                                          8),
                                  blurRadius:
                                      12,
                                  offset:
                                      const Offset(
                                          0,
                                          4),
                                ),
                              ],
                            ),

                            child:
                                Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(
                                          14),

                                  decoration:
                                      BoxDecoration(
                                    color: color
                                        .withAlpha(
                                            25),

                                    shape: BoxShape
                                        .circle,
                                  ),

                                  child:
                                      Icon(
                                    getWorkoutIcon(
                                        exercise),
                                    color:
                                        color,
                                    size:
                                        24,
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        16),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      Text(
                                        exercise,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight.bold,
                                          color:
                                              _textPrimary,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              6),

                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              10,
                                          vertical:
                                              4,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              color.withAlpha(
                                            25,
                                          ),

                                          borderRadius:
                                              BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child:
                                            Text(
                                          exercise,
                                          style:
                                              TextStyle(
                                            color:
                                                color,
                                            fontSize:
                                                11,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              8),

                                      Text(
                                        "$duration min • $calories kcal",
                                        style:
                                            const TextStyle(
                                          color:
                                              _textSecondary,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              4),

                                      Text(
                                        formatDate(
                                          data[
                                              'createdAt'],
                                        ),
                                        style:
                                            TextStyle(
                                          color: _textSecondary
                                              .withAlpha(
                                                  180),
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
  onPressed: () {
    _editWorkout(
      doc.id,
      data,
    );
  },
  icon: const Icon(
    Icons.edit_outlined,
    color: Colors.blue,
  ),
),

                                IconButton(
                                  onPressed:
                                      () {
                                    deleteWorkout(
                                        doc.id);
                                  },
                                  icon:
                                      const Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color: Colors
                                        .red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _summaryItem(
    IconData icon,
    String value,
    String title,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
            color: _textPrimary,
          ),
        ),

        Text(
          title,
          style: const TextStyle(
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.all(
                    20),

            decoration: BoxDecoration(
              color:
                  Colors.grey.shade100,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.history_rounded,
              size: 60,
              color:
                  Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "No Workouts Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Start your fitness journey by logging your first workout.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}