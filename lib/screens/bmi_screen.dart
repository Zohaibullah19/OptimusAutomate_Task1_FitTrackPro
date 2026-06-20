import 'package:flutter/material.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController heightController =
      TextEditingController();

  double bmi = 0;
  String result = '';

  void calculateBMI() {
    double weight =
        double.tryParse(weightController.text) ?? 0;

    double height =
        double.tryParse(heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      double heightInMeter = height / 100;

      double bmiValue =
          weight / (heightInMeter * heightInMeter);

      String category = '';

      if (bmiValue < 18.5) {
        category = 'Underweight';
      } else if (bmiValue < 25) {
        category = 'Normal Weight';
      } else if (bmiValue < 30) {
        category = 'Overweight';
      } else {
        category = 'Obese';
      }

      setState(() {
        bmi = bmiValue;
        result = category;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: calculateBMI,
              child: const Text('Calculate BMI'),
            ),

            const SizedBox(height: 30),

            Text(
              'BMI: ${bmi.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              result,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}