import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class EditWorkoutScreen extends StatefulWidget {
  final String documentId;
  final String exercise;
  final int duration;
  final int calories;

  const EditWorkoutScreen({
    super.key,
    required this.documentId,
    required this.exercise,
    required this.duration,
    required this.calories,
  });

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _exerciseController;
  late final TextEditingController _durationController;
  late final TextEditingController _caloriesController;

  bool _isLoading = false;

  // Premium Dashboard Typography & UI Match
  static const Color _brandColor = Color(0xFF10B981); // Emerald Green
  static const Color _brandGradientEnd = Color(0xFF059669); 
  static const Color _bgColor = Color(0xFFF8FAFC);    // Cool Light Gray
  static const Color _textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color _textSecondary = Color(0xFF64748B); // Slate 500

  @override
  void initState() {
    super.initState();
    _exerciseController = TextEditingController(text: widget.exercise);
    _durationController = TextEditingController(text: widget.duration.toString());
    _caloriesController = TextEditingController(text: widget.calories.toString());
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _updateWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // NOTE: If your WorkoutService's updateWorkout method takes 'exerciseName' instead of 'exercise',
      // swap the parameter label here to match your Firestore document schema mapping!
      await WorkoutService().updateWorkout(
        documentId: widget.documentId,
        exercise: _exerciseController.text.trim(), 
        duration: int.parse(_durationController.text.trim()),
        calories: int.parse(_caloriesController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Workout updated successfully", style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: _brandColor,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Workout Details",
          style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.4),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Modify Performance Data",
                      style: TextStyle(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 24),
                    
                    // Exercise Input Field
                    _buildInputField(
                      controller: _exerciseController,
                      labelText: "Exercise Name",
                      hintText: "e.g., Running, Push-ups",
                      icon: Icons.fitness_center_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter an exercise name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Duration Input Field
                    _buildInputField(
                      controller: _durationController,
                      labelText: "Duration (Minutes)",
                      hintText: "e.g., 30",
                      icon: Icons.timer_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a duration";
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return "Enter a valid number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Calories Input Field
                    _buildInputField(
                      controller: _caloriesController,
                      labelText: "Calories Burned",
                      hintText: "e.g., 250",
                      icon: Icons.local_fire_department_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter calories burned";
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return "Enter a valid number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Save Changes Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _isLoading 
                            ? null 
                            : const LinearGradient(
                                colors: [_brandColor, _brandGradientEnd],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _isLoading ? Colors.grey.shade300 : null,
                        boxShadow: _isLoading ? [] : [
                          BoxShadow(color: _brandColor.withAlpha(50), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading ? null : _updateWorkout,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text("Save Structural Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.2)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: _textSecondary.withAlpha(120), fontSize: 14),
        labelStyle: const TextStyle(color: _textSecondary, fontWeight: FontWeight.w500),
        floatingLabelStyle: const TextStyle(color: _brandColor, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: _textSecondary.withAlpha(200), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withAlpha(8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _brandColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}