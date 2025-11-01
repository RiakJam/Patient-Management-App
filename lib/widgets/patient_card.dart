import 'package:flutter/material.dart';
import '../utils/calculations.dart';
import '../utils/helpers.dart';

class PatientCard extends StatelessWidget {
  final String patientName;
  final int age;
  final double bmi;
  final String bmiCategory;
  final VoidCallback? onTap;

  const PatientCard({
    super.key,
    required this.patientName,
    required this.age,
    required this.bmi,
    required this.bmiCategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getBMIColor(bmi);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age: $age years',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  bmiCategory,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
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