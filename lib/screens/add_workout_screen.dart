import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() =>
      _AddWorkoutScreenState();
}

class _AddWorkoutScreenState
    extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController exerciseController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  final TextEditingController caloriesController =
      TextEditingController();

  bool isLoading = false;

  Future<void> saveWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? result =
          await WorkoutService().addWorkout(
        exercise:
            exerciseController.text.trim(),
        duration: int.parse(
          durationController.text.trim(),
        ),
        calories: int.parse(
          caloriesController.text.trim(),
        ),
      );

      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Workout Saved Successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    exerciseController.dispose();
    durationController.dispose();
    caloriesController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: exerciseController,
                decoration: fieldDecoration(
                  "Exercise Name",
                  Icons.fitness_center,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Enter exercise name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: durationController,
                keyboardType:
                    TextInputType.number,
                decoration: fieldDecoration(
                  "Duration (Minutes)",
                  Icons.timer,
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter duration";
                  }

                  if (int.tryParse(value) ==
                      null) {
                    return "Invalid number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: caloriesController,
                keyboardType:
                    TextInputType.number,
                decoration: fieldDecoration(
                  "Calories Burned",
                  Icons.local_fire_department,
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter calories";
                  }

                  if (int.tryParse(value) ==
                      null) {
                    return "Invalid number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : saveWorkout,
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),
                  label: Text(
                    isLoading
                        ? "Saving..."
                        : "Save Workout",
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green,
                    foregroundColor:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}