import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderOption('Male', 'M'),
            const SizedBox(width: 16),
            _buildGenderOption('Female', 'F'),
            const SizedBox(width: 16),
            _buildGenderOption('Other', 'O'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    return Expanded(
      child: InkWell(
        onTap: () => onGenderSelected(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedGender == value ? Colors.blue : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: selectedGender == value ? Colors.blue[50] : Colors.white,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selectedGender == value ? Colors.blue : Colors.black,
                fontWeight: selectedGender == value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}