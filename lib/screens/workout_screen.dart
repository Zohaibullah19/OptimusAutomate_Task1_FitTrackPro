import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  Widget workoutCard(
    String title,
    String duration,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: 35,
        ),
        title: Text(title),
        subtitle: Text(duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Plans"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            workoutCard(
              "Push Ups",
              "3 Sets × 15 Reps",
              Icons.fitness_center,
              Colors.red,
            ),

            workoutCard(
              "Running",
              "20 Minutes",
              Icons.directions_run,
              Colors.blue,
            ),

            workoutCard(
              "Cycling",
              "30 Minutes",
              Icons.pedal_bike,
              Colors.green,
            ),

            workoutCard(
              "Plank",
              "3 Sets × 60 Seconds",
              Icons.accessibility_new,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}