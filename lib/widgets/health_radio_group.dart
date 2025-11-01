import 'package:flutter/material.dart';

class HealthRadioGroup extends StatelessWidget {
  final String question;
  final String? selectedValue;
  final List<String> options;
  final Function(String) onOptionSelected;

  const HealthRadioGroup({
    super.key,
    required this.question,
    required this.selectedValue,
    required this.options,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) => RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedValue,
          onChanged: (value) => onOptionSelected(value!),
        )).toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}