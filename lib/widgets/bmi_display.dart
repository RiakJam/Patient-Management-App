import 'package:flutter/material.dart';
import '../utils/calculations.dart';
import '../utils/helpers.dart';

class BMIDisplay extends StatelessWidget {
  final double bmi;
  final String category;

  const BMIDisplay({
    super.key,
    required this.bmi,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final color = Helpers.getBMIColor(bmi);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'BMI: ${bmi.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: TextStyle(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}